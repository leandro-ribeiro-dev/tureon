import '../../../core/protocol/recipient.dart';
import '../../../core/protocol/recipient_type.dart';

String? presenceStatusLabel(Recipient recipient, {DateTime? now}) {
  if (recipient.type != RecipientType.user) return null;
  if (recipient.isOnline) return 'online';
  if (!recipient.isPresenceVisible) return null;

  final lastSeenAt = recipient.lastSeenAt?.toLocal();
  if (lastSeenAt == null) return 'visto por último recentemente';

  final current = (now ?? DateTime.now()).toLocal();
  final elapsed = current.difference(lastSeenAt);
  if (elapsed.isNegative || elapsed < const Duration(minutes: 1)) {
    return 'visto por último agora';
  }

  final time =
      '${lastSeenAt.hour.toString().padLeft(2, '0')}:${lastSeenAt.minute.toString().padLeft(2, '0')}';
  if (current.year == lastSeenAt.year &&
      current.month == lastSeenAt.month &&
      current.day == lastSeenAt.day) {
    return 'visto por último hoje às $time';
  }

  final yesterday = current.subtract(const Duration(days: 1));
  if (yesterday.year == lastSeenAt.year &&
      yesterday.month == lastSeenAt.month &&
      yesterday.day == lastSeenAt.day) {
    return 'visto por último ontem às $time';
  }

  final date =
      '${lastSeenAt.day.toString().padLeft(2, '0')}/${lastSeenAt.month.toString().padLeft(2, '0')}';
  final year = lastSeenAt.year == current.year ? '' : '/${lastSeenAt.year}';
  return 'visto por último em $date$year às $time';
}
