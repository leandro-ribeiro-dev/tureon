import 'package:tureon/generated/proto/tureon.pb.dart' as pb;

abstract interface class MessagingRpc {
  Future<void> close();

  Future<void> resetStream();

  bool get isReady;

  Stream<bool> get readinessChanges;

  Future<List<pb.ChatStreamBatchResult>> sendBatch(
    List<pb.ChatStreamBatchCommand> commands,
  );

  Stream<pb.MessageDelivery> streamMessages(pb.ChatStreamOpen request);

  Future<void> ackDelivery(pb.AckDeliveryRequest request);

  Future<void> ackDeliveries(List<pb.DeliveryAcknowledgement> deliveries);

  Future<void> sendReadReceipt(pb.SendReadReceiptRequest request);

  Future<void> sendMessageMutation(pb.SendMessageMutationRequest request);

  Future<pb.InteractBotResponse> interactBot(pb.InteractBotRequest request);
}
