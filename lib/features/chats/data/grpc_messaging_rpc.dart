import 'dart:async';
import 'dart:developer' as developer;

import 'package:grpc/grpc.dart';
import 'package:grpc/grpc.dart' as grpc;
import 'package:tureon/generated/proto/tureon.pb.dart' as pb;
import 'package:tureon/generated/proto/tureon.pbgrpc.dart';

import 'services/messaging_rpc.dart';

class GrpcMessagingRpc implements MessagingRpc {
  GrpcMessagingRpc({
    required this.client,
    required Stream<grpc.ConnectionState> connectionStateChanges,
  }) {
    _connectionSubscription = connectionStateChanges.listen(
      _handleConnectionState,
      onError: (Object error, StackTrace stackTrace) {
        developer.log(
          'gRPC connection state monitoring failed for chat stream',
          name: 'tureon.messaging',
          error: error,
          stackTrace: stackTrace,
        );
        _transportReady = false;
        _ready = false;
        _publishReadiness();
        _failPending(error, stackTrace);
      },
    );
  }

  final MessagingServiceClient client;
  late final StreamSubscription<grpc.ConnectionState> _connectionSubscription;
  final StreamController<bool> _readinessController =
      StreamController<bool>.broadcast(sync: true);
  final Map<String, Completer<pb.ChatStreamResponse>> _pendingRequests = {};
  StreamController<pb.ChatStreamRequest>? _requestController;
  StreamController<pb.MessageDelivery>? _deliveryController;
  StreamSubscription<pb.ChatStreamResponse>? _responseSubscription;
  Future<void>? _streamShutdownInFlight;
  bool _ready = false;
  bool _transportReady = false;
  bool _publishedReadiness = false;
  int _requestSequence = 0;

  @override
  bool get isReady => _ready && _transportReady;

  @override
  Stream<bool> get readinessChanges => _readinessController.stream;

  @override
  Future<void> close() async {
    await _stopStream();
    await _connectionSubscription.cancel();
    await _readinessController.close();
  }

  @override
  Future<void> resetStream() => _stopStream();

  @override
  Future<List<pb.ChatStreamBatchResult>> sendBatch(
    List<pb.ChatStreamBatchCommand> commands,
  ) async {
    if (commands.isEmpty) return const [];
    final response = await _sendCommand(
      (requestId) => pb.ChatStreamRequest(
        requestId: requestId,
        batch: pb.ChatStreamBatchRequest(commands: commands),
      ),
    );
    if (!response.hasBatch()) {
      throw StateError('Chat stream returned no batch result.');
    }
    return response.batch.results;
  }

  @override
  Stream<pb.MessageDelivery> streamMessages(pb.ChatStreamOpen request) {
    if (_requestController != null) {
      throw StateError('The chat stream is already running.');
    }
    final output = StreamController<pb.MessageDelivery>();
    _deliveryController = output;
    _requestController = StreamController<pb.ChatStreamRequest>();
    final requests = _requestController!;
    final deliveries = output;
    final responseSubscription = client
        .chatStream(requests.stream)
        .listen(
          _handleResponse,
          onError: (Object error, StackTrace stackTrace) {
            _failPending(error, stackTrace);
            if (!deliveries.isClosed) deliveries.addError(error, stackTrace);
            unawaited(_finishStream(requests, deliveries));
          },
          onDone: () {
            _failPending(
              StateError('The chat stream closed.'),
              StackTrace.current,
            );
            unawaited(_finishStream(requests, deliveries));
          },
          cancelOnError: true,
        );
    _responseSubscription = responseSubscription;
    // The repository pauses delivery handling when its bounded worker pool is
    // saturated. Carry that pause through the adapter to gRPC so deliveries do
    // not accumulate in this intermediate controller without bound.
    output.onPause = responseSubscription.pause;
    output.onResume = responseSubscription.resume;
    requests.add(
      pb.ChatStreamRequest(
        open: pb.ChatStreamOpen(
          recipientId: request.recipientId,
          deviceId: request.deviceId,
        ),
      ),
    );
    output.onCancel = () => _stopStream(requests);
    return output.stream;
  }

  @override
  Future<void> ackDelivery(pb.AckDeliveryRequest request) => ackDeliveries([
    pb.DeliveryAcknowledgement(
      deliveryId: request.deliveryId,
      targetDeviceId: request.targetDeviceId,
    ),
  ]);

  @override
  Future<void> ackDeliveries(
    List<pb.DeliveryAcknowledgement> deliveries,
  ) async {
    if (deliveries.isEmpty) return;
    await _sendCommand(
      (requestId) => pb.ChatStreamRequest(
        requestId: requestId,
        acknowledge: pb.AckDeliveryRequest(deliveries: deliveries),
      ),
    );
  }

  @override
  Future<void> sendReadReceipt(pb.SendReadReceiptRequest request) async {
    await _sendCommand(
      (requestId) =>
          pb.ChatStreamRequest(requestId: requestId, readReceipt: request),
    );
  }

  @override
  Future<void> sendMessageMutation(
    pb.SendMessageMutationRequest request,
  ) async {
    await _sendCommand(
      (requestId) =>
          pb.ChatStreamRequest(requestId: requestId, mutateMessage: request),
    );
  }

  @override
  Future<pb.InteractBotResponse> interactBot(
    pb.InteractBotRequest request,
  ) async {
    final response = await _sendCommand(
      (requestId) =>
          pb.ChatStreamRequest(requestId: requestId, interactBot: request),
    );
    if (!response.hasBotInteraction()) {
      throw StateError('Chat stream returned no bot interaction result.');
    }
    return response.botInteraction;
  }

  Future<pb.ChatStreamResponse> _sendCommand(
    pb.ChatStreamRequest Function(String requestId) createRequest,
  ) async {
    if (!isReady || _requestController == null) {
      throw StateError('The real-time chat stream is not connected.');
    }
    if (_pendingRequests.length >= 128) {
      throw StateError('Too many chat commands are awaiting a response.');
    }
    final requestId =
        '${DateTime.now().microsecondsSinceEpoch}-${++_requestSequence}';
    final completer = Completer<pb.ChatStreamResponse>();
    _pendingRequests[requestId] = completer;
    try {
      _requestController!.add(createRequest(requestId));
    } catch (error, stackTrace) {
      _pendingRequests.remove(requestId);
      Error.throwWithStackTrace(error, stackTrace);
    }
    try {
      final response = await completer.future.timeout(
        const Duration(seconds: 30),
      );
      if (response.hasCommandResult() && !response.commandResult.accepted) {
        throw GrpcError.custom(
          response.commandResult.statusCode,
          response.commandResult.message,
        );
      }
      return response;
    } on TimeoutException catch (error, stackTrace) {
      developer.log(
        'Chat stream command timed out; resetting the command channel',
        name: 'tureon.messaging',
        error: error,
        stackTrace: stackTrace,
      );
      _signalStreamFailure(error, stackTrace);
      rethrow;
    } finally {
      _pendingRequests.remove(requestId);
    }
  }

  void _handleResponse(pb.ChatStreamResponse response) {
    if (response.hasReady()) {
      _setReady(true);
      return;
    }
    if (response.hasDelivery()) {
      _deliveryController?.add(response.delivery);
      return;
    }
    final completer = _pendingRequests[response.requestId];
    if (completer == null || completer.isCompleted) return;
    if (response.hasSendMessage() ||
        response.hasCommandResult() ||
        response.hasBotInteraction() ||
        response.hasBatch()) {
      completer.complete(response);
      return;
    }
    completer.completeError(
      StateError('Chat stream returned an unsupported response.'),
    );
  }

  void _signalStreamFailure(Object error, StackTrace stackTrace) {
    _setReady(false);
    _failPending(
      StateError('The chat stream is being reset after a command timeout.'),
      stackTrace,
    );
    final deliveries = _deliveryController;
    if (deliveries != null && !deliveries.isClosed) {
      deliveries.addError(error, stackTrace);
    }
  }

  void _setReady(bool value) {
    if (_ready == value) return;
    _ready = value;
    _publishReadiness();
  }

  void _handleConnectionState(grpc.ConnectionState state) {
    final transportReady = state == grpc.ConnectionState.ready;
    if (_transportReady == transportReady) return;
    _transportReady = transportReady;
    if (!transportReady) {
      _ready = false;
      _failPending(
        StateError('The gRPC transport disconnected from the chat stream.'),
        StackTrace.current,
      );
    }
    _publishReadiness();
  }

  void _publishReadiness() {
    final ready = isReady;
    if (_publishedReadiness == ready) return;
    _publishedReadiness = ready;
    if (!_readinessController.isClosed) _readinessController.add(ready);
  }

  void _failPending(Object error, StackTrace stackTrace) {
    for (final completer in _pendingRequests.values) {
      if (!completer.isCompleted) completer.completeError(error, stackTrace);
    }
    _pendingRequests.clear();
  }

  Future<void> _stopStream([
    StreamController<pb.ChatStreamRequest>? expectedRequests,
  ]) {
    if (expectedRequests != null &&
        !identical(_requestController, expectedRequests)) {
      return Future<void>.value();
    }
    final pending = _streamShutdownInFlight;
    if (pending != null) return pending;
    _setReady(false);
    final subscription = _responseSubscription;
    _responseSubscription = null;
    final requests = _requestController;
    _requestController = null;
    final deliveries = _deliveryController;
    _deliveryController = null;
    // Complete commands before awaiting transport cancellation. grpc's cancel
    // can wait on the in-flight response; leaving these completers pending
    // turns a normal reconnect into a 30-second command deadline.
    _failPending(
      StateError('The real-time chat stream was stopped.'),
      StackTrace.current,
    );
    final shutdown = () async {
      await _cancelResponseSubscription(subscription);
      await _closeRequestController(requests);
      if (deliveries != null && !deliveries.isClosed) {
        await deliveries.close();
      }
    }();
    late final Future<void> trackedShutdown;
    trackedShutdown = shutdown.whenComplete(() {
      if (identical(_streamShutdownInFlight, trackedShutdown)) {
        _streamShutdownInFlight = null;
      }
    });
    _streamShutdownInFlight = trackedShutdown;
    return trackedShutdown;
  }

  Future<void> _finishStream(
    StreamController<pb.ChatStreamRequest> requests,
    StreamController<pb.MessageDelivery> deliveries,
  ) {
    // A response callback from an old stream must not tear down a newer one.
    if (!identical(_requestController, requests)) {
      return Future<void>.value();
    }
    final pending = _streamShutdownInFlight;
    if (pending != null) return pending;
    _setReady(false);
    final subscription = _responseSubscription;
    _requestController = null;
    _responseSubscription = null;
    _deliveryController = null;
    final shutdown = () async {
      await _cancelResponseSubscription(subscription);
      await _closeRequestController(requests);
      try {
        if (!deliveries.isClosed) await deliveries.close();
      } catch (error, stackTrace) {
        developer.log(
          'Could not close the chat delivery stream cleanly',
          name: 'tureon.messaging',
          error: error,
          stackTrace: stackTrace,
        );
      }
    }();
    late final Future<void> trackedShutdown;
    trackedShutdown = shutdown.whenComplete(() {
      if (identical(_streamShutdownInFlight, trackedShutdown)) {
        _streamShutdownInFlight = null;
      }
    });
    _streamShutdownInFlight = trackedShutdown;
    return trackedShutdown;
  }

  Future<void> _cancelResponseSubscription(
    StreamSubscription<pb.ChatStreamResponse>? subscription,
  ) async {
    try {
      await subscription?.cancel();
    } catch (error, stackTrace) {
      developer.log(
        'Chat stream cancellation ended with a transport error',
        name: 'tureon.messaging',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _closeRequestController(
    StreamController<pb.ChatStreamRequest>? requests,
  ) async {
    if (requests == null || requests.isClosed) return;
    try {
      await requests.close();
    } catch (error, stackTrace) {
      developer.log(
        'Could not close the chat request stream cleanly',
        name: 'tureon.messaging',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }
}
