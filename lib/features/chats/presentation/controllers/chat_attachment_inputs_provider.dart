import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/chat_attachment_inputs.dart';

final chatAttachmentInputsProvider = Provider<ChatAttachmentInputs>(
  (ref) => ChatAttachmentInputs(),
);
