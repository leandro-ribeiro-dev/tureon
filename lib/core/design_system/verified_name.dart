import 'package:flutter/material.dart';

import '../protocol/recipient_type.dart';
import '../protocol/verification_badge.dart';
import 'verification_badge_indicator.dart';

/// VerifiedName component that displays recipient name with optional type icon
/// (groups, channels, bots) and verification badge indicator according to AGENTS.md.
class VerifiedName extends StatelessWidget {
  const VerifiedName({
    super.key,
    required this.name,
    required this.badge,
    this.type,
    this.style,
    this.maxLines = 1,
    this.overflow = TextOverflow.ellipsis,
    this.textAlign,
    this.badgeSize = 16,
  });

  final String name;
  final VerificationBadge badge;
  final RecipientType? type;
  final TextStyle? style;
  final int maxLines;
  final TextOverflow overflow;
  final TextAlign? textAlign;
  final double badgeSize;

  Widget? _getLeadingTypeIcon(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final iconColor = style?.color ?? colorScheme.primary;
    final iconSize = (style?.fontSize ?? 16) * 1.15;

    return switch (type) {
      RecipientType.group => Icon(
          Icons.groups_rounded,
          size: iconSize,
          color: iconColor,
        ),
      RecipientType.channel => Icon(
          Icons.campaign_rounded,
          size: iconSize,
          color: iconColor,
        ),
      RecipientType.bot => Icon(
          Icons.smart_toy_rounded,
          size: iconSize,
          color: iconColor,
        ),
      _ => null,
    };
  }

  @override
  Widget build(BuildContext context) {
    final leadingIcon = _getLeadingTypeIcon(context);

    Widget nameWidget;
    if (badge == VerificationBadge.none) {
      nameWidget = Text(
        name,
        style: style,
        maxLines: maxLines,
        overflow: overflow,
        textAlign: textAlign,
      );
    } else {
      nameWidget = Text.rich(
        TextSpan(
          style: style,
          children: [
            TextSpan(text: name),
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Padding(
                padding: const EdgeInsetsDirectional.only(start: 4),
                child: VerificationBadgeIndicator(badge: badge, size: badgeSize),
              ),
            ),
          ],
        ),
        maxLines: maxLines,
        overflow: overflow,
        textAlign: textAlign,
      );
    }

    if (leadingIcon == null) return nameWidget;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        leadingIcon,
        const SizedBox(width: 4),
        Flexible(child: nameWidget),
      ],
    );
  }
}
