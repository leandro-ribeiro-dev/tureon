import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/storage/message_records.dart';
import '../../../../l10n/app_localizations_extensions.dart';

class DevicesScreen extends StatefulWidget {
  const DevicesScreen({
    super.key,
    required this.loadDevices,
    required this.revokeDevice,
  });

  final Future<List<DeviceSession>> Function() loadDevices;
  final Future<void> Function(String deviceId) revokeDevice;

  @override
  State<DevicesScreen> createState() => _DevicesScreenState();
}

class _DevicesScreenState extends State<DevicesScreen>
    with WidgetsBindingObserver {
  late Future<List<DeviceSession>> _devices;
  final Set<String> _revokingDeviceIds = {};
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _devices = Future<List<DeviceSession>>.sync(widget.loadDevices);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) unawaited(_reload());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _reload() async {
    if (_revokingDeviceIds.isNotEmpty || !mounted) return;
    final next = Future<List<DeviceSession>>.sync(widget.loadDevices);
    setState(() {
      _devices = next;
      _isRefreshing = true;
    });
    try {
      await next;
    } catch (_) {
      // FutureBuilder displays the load error; consume this future for app-bar
      // and lifecycle-triggered refreshes, which have no awaiting caller.
    } finally {
      if (mounted) setState(() => _isRefreshing = false);
    }
  }

  Future<void> _revoke(DeviceSession device) async {
    final l10n = context.safeLocalizations;
    final shouldRevoke = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.devicesRevokeConfirmTitle),
        content: Text(
          l10n.devicesRevokeConfirmBody(
            device.name.isEmpty ? device.platform : device.name,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.devicesRevoke),
          ),
        ],
      ),
    );
    if (shouldRevoke != true || !mounted) return;

    setState(() => _revokingDeviceIds.add(device.deviceId));
    Object? revokeError;
    try {
      await widget.revokeDevice(device.deviceId);
    } catch (error) {
      // A server may commit revocation and then fail to notify an already-open
      // stream. Always reload before deciding what to show to the user.
      revokeError = error;
    }
    if (!mounted) return;

    final refreshedDevices = Future<List<DeviceSession>>.sync(
      widget.loadDevices,
    );
    setState(() {
      _devices = refreshedDevices;
      _isRefreshing = true;
    });

    try {
      final latest = await refreshedDevices;
      if (!mounted) return;
      final stillActive = latest.any(
        (entry) => entry.deviceId == device.deviceId,
      );
      if (revokeError == null || !stillActive) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.devicesRevokeSuccess)));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.devicesRevokeFailed(revokeError.toString())),
          ),
        );
      }
    } catch (_) {
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            revokeError == null
                ? l10n.devicesRevokeSuccess
                : l10n.devicesRevokeFailed(revokeError.toString()),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _revokingDeviceIds.remove(device.deviceId);
          _isRefreshing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.safeLocalizations;
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.devicesScreenTitle),
        actions: [
          IconButton(
            tooltip: l10n.devicesRefresh,
            onPressed: _isRefreshing || _revokingDeviceIds.isNotEmpty
                ? null
                : _reload,
            icon: _isRefreshing
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: FutureBuilder<List<DeviceSession>>(
        future: _devices,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return _refreshableStatus(child: const CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _refreshableStatus(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.cloud_off_rounded,
                    size: 38,
                    color: colors.onSurfaceVariant,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.devicesLoadFailed(snapshot.error.toString()),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: colors.onSurface),
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: _reload,
                    icon: const Icon(Icons.refresh_rounded),
                    label: Text(l10n.devicesRefresh),
                  ),
                ],
              ),
            );
          }

          final devices = snapshot.data ?? const <DeviceSession>[];
          if (devices.isEmpty) {
            return _refreshableStatus(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.devices_rounded,
                    size: 42,
                    color: colors.onSurfaceVariant,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.devicesEmpty,
                    style: TextStyle(color: colors.onSurfaceVariant),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _reload,
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              itemCount: devices.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final device = devices[index];
                final localized = MaterialLocalizations.of(context);
                final activeAt = device.lastActiveAt.toLocal();
                final lastActive =
                    '${localized.formatMediumDate(activeAt)} · '
                    '${localized.formatTimeOfDay(TimeOfDay.fromDateTime(activeAt))}';
                final title = device.name.isEmpty
                    ? device.platform
                    : device.name;
                final revoking = _revokingDeviceIds.contains(device.deviceId);

                return Card(
                  margin: EdgeInsets.zero,
                  color: colors.surfaceContainerLow,
                  child: ListTile(
                    minVerticalPadding: 12,
                    leading: CircleAvatar(
                      backgroundColor: colors.secondaryContainer,
                      foregroundColor: colors.onSecondaryContainer,
                      child: Icon(_deviceIcon(device.platform)),
                    ),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                        if (device.isCurrent) ...[
                          const SizedBox(width: 8),
                          Chip(
                            visualDensity: VisualDensity.compact,
                            label: Text(l10n.devicesCurrent),
                            padding: EdgeInsets.zero,
                          ),
                        ],
                      ],
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '${device.platform} · '
                        '${device.isCurrent ? lastActive : l10n.devicesLastActive(lastActive)}',
                      ),
                    ),
                    trailing: device.isCurrent
                        ? null
                        : IconButton(
                            tooltip: l10n.devicesRevoke,
                            onPressed: _revokingDeviceIds.isNotEmpty
                                ? null
                                : () => _revoke(device),
                            icon: revoking
                                ? const SizedBox.square(
                                    dimension: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.logout_rounded),
                          ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _refreshableStatus({required Widget child}) => RefreshIndicator(
    onRefresh: _reload,
    child: LayoutBuilder(
      builder: (context, constraints) => ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: constraints.maxHeight,
            child: Center(
              child: Padding(padding: const EdgeInsets.all(24), child: child),
            ),
          ),
        ],
      ),
    ),
  );

  IconData _deviceIcon(String platform) {
    final value = platform.toLowerCase();
    if (value.contains('web')) return Icons.language_rounded;
    if (value.contains('desktop') || value.contains('linux')) {
      return Icons.computer_rounded;
    }
    if (value.contains('ios') || value.contains('iphone')) {
      return Icons.phone_iphone_rounded;
    }
    return Icons.phone_android_rounded;
  }
}
