import 'package:flutter/material.dart';
import 'dart:developer' as developer;

import '../protocol/recipient.dart';
import '../protocol/recipient_type.dart';
import '../protocol/verification_badge.dart';
import 'verification_badge_indicator.dart';

/// AppAvatar with deterministic avatar colors, online indicator,
/// and interactive full-screen image expansion viewer.
class AppAvatar extends StatelessWidget {
  const AppAvatar({
    super.key,
    required this.name,
    this.id,
    this.imageUrl,
    this.radius = 24.0,
    this.isOnline = false,
    this.type = RecipientType.user,
    this.verificationBadge = VerificationBadge.none,
    this.onTap,
    this.isExpandable = true,
  });

  factory AppAvatar.fromRecipient(
    Recipient recipient, {
    double radius = 24.0,
    VoidCallback? onTap,
    bool isExpandable = true,
  }) {
    return AppAvatar(
      name: recipient.name,
      id: recipient.id,
      imageUrl: recipient.avatarUrl,
      radius: radius,
      isOnline: recipient.isOnline && recipient.isPresenceVisible,
      type: recipient.type,
      verificationBadge: recipient.verificationBadge,
      onTap: onTap,
      isExpandable: isExpandable,
    );
  }

  final String name;
  final String? id;
  final String? imageUrl;
  final double radius;
  final bool isOnline;
  final RecipientType type;
  final VerificationBadge verificationBadge;
  final VoidCallback? onTap;
  final bool isExpandable;

  /// Deterministic color palette for avatars.
  static const List<Color> _avatarColors = [
    Color(0xFFE57373), // Red
    Color(0xFFF06292), // Pink
    Color(0xFFBA68C8), // Purple
    Color(0xFF9575CD), // Deep Purple
    Color(0xFF7986CB), // Indigo
    Color(0xFF64B5F6), // Blue
    Color(0xFF4FC3F7), // Light Blue
    Color(0xFF4DD0E1), // Cyan
    Color(0xFF4DB6AC), // Teal
    Color(0xFF81C784), // Green
    Color(0xFFAED581), // Light Green
    Color(0xFFFFB74D), // Orange
    Color(0xFFFF8A65), // Deep Orange
  ];

  Color _getDeterministicColor() {
    final key = id ?? name;
    if (key.isEmpty) return _avatarColors[0];
    int hash = 0;
    for (int i = 0; i < key.length; i++) {
      hash = key.codeUnitAt(i) + ((hash << 5) - hash);
    }
    final index = hash.abs() % _avatarColors.length;
    return _avatarColors[index];
  }

  String _getInitials() {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '?';
    final parts = trimmed.split(RegExp(r'\s+'));
    if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return trimmed.substring(0, trimmed.length >= 2 ? 2 : 1).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final glassToken = Theme.of(context).colorScheme;
    final backgroundColor = _getDeterministicColor();
    final initials = _getInitials();

    Widget content;
    final normalizedImageUrl = imageUrl?.trim();
    if (normalizedImageUrl?.isNotEmpty == true) {
      content = CircleAvatar(
        radius: radius,
        backgroundColor: backgroundColor,
        child: ClipOval(
          child: SizedBox.square(
            dimension: radius * 2,
            child: Image.network(
              normalizedImageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                developer.log(
                  'Avatar image could not be loaded',
                  name: 'tureon.avatar',
                  error: error,
                  stackTrace: stackTrace,
                );
                return _initialsFallback(
                  initials: initials,
                  color: backgroundColor,
                  radius: radius,
                );
              },
            ),
          ),
        ),
      );
    } else {
      content = _initialsFallback(
        initials: initials,
        color: backgroundColor,
        radius: radius,
      );
    }

    final VoidCallback? effectiveOnTap = onTap ??
        (isExpandable
            ? () => AvatarExpandedDialog.show(
                  context,
                  name: name,
                  imageUrl: imageUrl,
                  id: id,
                )
            : null);

    if (effectiveOnTap != null) {
      content = GestureDetector(onTap: effectiveOnTap, child: content);
    }

    // Stack online indicator dot or bot/group badge if applicable
    return Stack(
      clipBehavior: Clip.none,
      children: [
        content,
        if (isOnline && type == RecipientType.user)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: radius * 0.5,
              height: radius * 0.5,
              decoration: BoxDecoration(
                color: const Color(0xFF22C55E), // Green online status
                shape: BoxShape.circle,
                border: Border.all(color: glassToken.surface, width: 2.0),
              ),
            ),
          ),
        if (type == RecipientType.bot)
          Positioned(
            right: -2,
            bottom: -2,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: glassToken.primary,
                shape: BoxShape.circle,
                border: Border.all(color: glassToken.surface, width: 1.5),
              ),
              child: Icon(
                Icons.smart_toy_rounded,
                size: radius * 0.45,
                color: Colors.white,
              ),
            ),
          ),
        if (verificationBadge != VerificationBadge.none)
          Positioned(
            top: -2,
            right: -2,
            child: Container(
              width: radius * 0.75,
              height: radius * 0.75,
              decoration: BoxDecoration(
                color: glassToken.surface,
                shape: BoxShape.circle,
              ),
              child: VerificationBadgeIndicator(
                badge: verificationBadge,
                size: radius * 0.5,
              ),
            ),
          ),
      ],
    );
  }

  Widget _initialsFallback({
    required String initials,
    required Color color,
    required double radius,
  }) => CircleAvatar(
    radius: radius,
    backgroundColor: color,
    child: Text(
      initials,
      style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w700,
        fontSize: radius * 0.75,
      ),
    ),
  );
}

/// Interactive full-screen dialog for viewing enlarged profile avatar images with pinch-to-zoom.
class AvatarExpandedDialog extends StatelessWidget {
  const AvatarExpandedDialog({
    super.key,
    required this.name,
    this.imageUrl,
    this.id,
  });

  final String name;
  final String? imageUrl;
  final String? id;

  static void show(
    BuildContext context, {
    required String name,
    String? imageUrl,
    String? id,
  }) {
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        opaque: false,
        barrierDismissible: true,
        barrierColor: Colors.black.withValues(alpha: 0.9),
        pageBuilder: (ctx, animation, secondaryAnimation) {
          return FadeTransition(
            opacity: animation,
            child: AvatarExpandedDialog(
              name: name,
              imageUrl: imageUrl,
              id: id,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final normalizedUrl = imageUrl?.trim();

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.black.withValues(alpha: 0.6),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.8,
          maxScale: 4.0,
          child: normalizedUrl?.isNotEmpty == true
              ? Image.network(
                  normalizedUrl!,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) =>
                      _fallbackBigAvatar(theme),
                )
              : _fallbackBigAvatar(theme),
        ),
      ),
    );
  }

  Widget _fallbackBigAvatar(ThemeData theme) {
    return Container(
      width: 280,
      height: 280,
      decoration: const BoxDecoration(
        color: Color(0xFF232D36),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: AppAvatar(
          name: name,
          id: id,
          imageUrl: null,
          radius: 130,
          isExpandable: false,
        ),
      ),
    );
  }
}
