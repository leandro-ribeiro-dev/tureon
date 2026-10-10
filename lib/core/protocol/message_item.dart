import 'delivery_status.dart';
import 'message_type.dart';
import 'system_message.dart';

class MessageItem {
  const MessageItem.text({
    required this.id,
    required this.senderName,
    required this.text,
    required this.timestamp,
    this.status = DeliveryStatus.read,
  }) : type = MessageType.text,
       system = null;

  const MessageItem.system({required this.id, required this.system})
    : type = MessageType.system,
      senderName = '',
      text = null,
      timestamp = null,
      status = DeliveryStatus.read;

  final String id;
  final MessageType type;
  final String senderName;
  final String? text;
  final DateTime? timestamp;
  final DeliveryStatus status;
  final SystemMessage? system;
}
