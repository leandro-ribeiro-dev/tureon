import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

class DeviceMetadata {
  const DeviceMetadata({required this.name, required this.platform});

  final String name;
  final String platform;

  static Future<DeviceMetadata> load() async {
    final plugin = DeviceInfoPlugin();
    if (kIsWeb) {
      final browser = await plugin.webBrowserInfo;
      final platform = _clean(browser.browserName.name);
      return DeviceMetadata(
        name: platform.isEmpty ? 'Web browser' : '$platform browser',
        platform: 'web',
      );
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        final info = await plugin.androidInfo;
        final manufacturer = _clean(info.manufacturer);
        final model = _clean(info.model);
        final version = _clean(info.version.release);
        final deviceName = [
          if (manufacturer.isNotEmpty) manufacturer,
          if (model.isNotEmpty &&
              model.toLowerCase() != manufacturer.toLowerCase())
            model,
        ].join(' ');
        return DeviceMetadata(
          name: formatName(deviceName, 'Android', version, 'Android device'),
          platform: 'android',
        );
      case TargetPlatform.iOS:
        final info = await plugin.iosInfo;
        return DeviceMetadata(
          name: formatName(
            info.modelName,
            'iOS',
            info.systemVersion,
            'iOS device',
          ),
          platform: 'ios',
        );
      case TargetPlatform.linux:
        final info = await plugin.linuxInfo;
        return DeviceMetadata(
          name: formatName(
            info.prettyName,
            'Linux',
            info.version,
            'Linux device',
          ),
          platform: 'linux',
        );
      case TargetPlatform.macOS:
        final info = await plugin.macOsInfo;
        return DeviceMetadata(
          name: formatName(
            info.modelName,
            'macOS',
            info.osRelease,
            'Mac device',
          ),
          platform: 'macos',
        );
      case TargetPlatform.windows:
        final info = await plugin.windowsInfo;
        return DeviceMetadata(
          name: formatName(
            info.computerName,
            'Windows',
            info.displayVersion,
            'Windows device',
          ),
          platform: 'windows',
        );
      case TargetPlatform.fuchsia:
        return const DeviceMetadata(
          name: 'Fuchsia device',
          platform: 'fuchsia',
        );
    }
  }

  static String formatName(
    String device,
    String os,
    String? version,
    String fallback,
  ) {
    final cleanDevice = _clean(device);
    final cleanVersion = _clean(version ?? '');
    final identity = cleanDevice.isEmpty ? fallback : cleanDevice;
    final versionLabel = cleanVersion.isEmpty ? os : '$os $cleanVersion';
    return '$identity · $versionLabel';
  }

  static String _clean(String value) =>
      value.replaceAll(RegExp(r'\s+'), ' ').trim();
}
