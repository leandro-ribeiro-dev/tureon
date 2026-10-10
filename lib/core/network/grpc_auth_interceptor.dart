import 'dart:async';
import 'dart:developer' as developer;

import 'package:grpc/grpc.dart';

const _defaultUnaryRpcTimeout = Duration(seconds: 30);

class GrpcAuthInterceptor extends ClientInterceptor {
  GrpcAuthInterceptor({required this.accessToken});

  final String? Function() accessToken;
  Future<void>? _refreshInFlight;
  Future<void> Function(String? failedAccessToken)? onRefresh;
  Future<void> Function()? onRefreshFailure;

  @override
  ResponseFuture<R> interceptUnary<Q, R>(
    ClientMethod<Q, R> method,
    Q request,
    CallOptions options,
    ClientUnaryInvoker<Q, R> invoker,
  ) {
    final failedAccessToken = accessToken();
    final first = invoker(
      method,
      request,
      _withAccessToken(options, defaultTimeout: _defaultUnaryRpcTimeout),
    );
    final result = _retryUnary(
      method,
      request,
      options,
      invoker,
      first,
      failedAccessToken,
    );
    return _RetriableResponseFuture<Q, R>(result, first, method, options);
  }

  @override
  ResponseStream<R> interceptStreaming<Q, R>(
    ClientMethod<Q, R> method,
    Stream<Q> requests,
    CallOptions options,
    ClientStreamingInvoker<Q, R> invoker,
  ) {
    final failedAccessToken = accessToken();
    final replayableRequests = _ReplayableRequestStream<Q>(requests);
    final first = invoker(
      method,
      replayableRequests,
      _withAccessToken(options),
    );
    final result = _retryStream(
      method,
      replayableRequests,
      options,
      invoker,
      first,
      failedAccessToken,
    );
    return _RetriableResponseStream<Q, R>(result, first, method, options);
  }

  Future<void> refreshAfterUnauthenticated(String? failedAccessToken) {
    if (failedAccessToken == null || accessToken() != failedAccessToken) {
      return Future<void>.value();
    }
    final current = _refreshInFlight;
    if (current != null) return current;
    final refresh = onRefresh;
    if (refresh == null) {
      return Future<void>.error(
        StateError('No gRPC authentication refresh handler is configured.'),
      );
    }

    final pending = Future<void>(() async {
      try {
        await refresh(failedAccessToken);
      } catch (error) {
        if (_isTerminalRefreshFailure(error)) {
          await onRefreshFailure?.call();
        }
        rethrow;
      }
    });
    _refreshInFlight = pending;
    return pending.whenComplete(() {
      if (identical(_refreshInFlight, pending)) _refreshInFlight = null;
    });
  }

  Future<T> retryUnary<T>({
    required String? failedAccessToken,
    required Future<T> Function() firstAttempt,
    required Future<T> Function() retryAttempt,
  }) async {
    try {
      return await firstAttempt();
    } on GrpcError catch (error) {
      if (error.code != StatusCode.unauthenticated ||
          failedAccessToken == null) {
        rethrow;
      }
      await refreshAfterUnauthenticated(failedAccessToken);
      return retryAttempt();
    }
  }

  CallOptions _withAccessToken(
    CallOptions options, {
    Duration? defaultTimeout,
  }) => options.mergedWith(
    CallOptions(
      timeout: options.timeout ?? defaultTimeout,
      providers: [
        (metadata, _) {
          final token = accessToken();
          if (token == null || token.isEmpty) {
            metadata.remove('authorization');
          } else {
            metadata['authorization'] = 'Bearer $token';
          }
        },
      ],
    ),
  );

  Future<R> _retryUnary<Q, R>(
    ClientMethod<Q, R> method,
    Q request,
    CallOptions options,
    ClientUnaryInvoker<Q, R> invoker,
    ResponseFuture<R> first,
    String? failedAccessToken,
  ) async {
    try {
      if (_isAuthBootstrapMethod(method.path)) return await first;
      return await retryUnary(
        failedAccessToken: failedAccessToken,
        firstAttempt: () => first,
        retryAttempt: () => invoker(
          method,
          request,
          _withAccessToken(options, defaultTimeout: _defaultUnaryRpcTimeout),
        ),
      );
    } catch (error, stackTrace) {
      _logRpcFailure(method.path, error, stackTrace);
      Error.throwWithStackTrace(error, stackTrace);
    }
  }

  Stream<R> _retryStream<Q, R>(
    ClientMethod<Q, R> method,
    Stream<Q> requests,
    CallOptions options,
    ClientStreamingInvoker<Q, R> invoker,
    ResponseStream<R> first,
    String? failedAccessToken,
  ) async* {
    final replayableRequests = requests as _ReplayableRequestStream<Q>;
    var receivedResponse = false;
    try {
      await for (final response in first) {
        receivedResponse = true;
        // Once the server has answered, an authentication retry is no longer
        // eligible. Drop the replay history so a long-lived bidi stream does
        // not retain every request for its entire lifetime.
        replayableRequests.closeReplayWindow();
        yield response;
      }
    } on GrpcError catch (error, stackTrace) {
      if (error.code != StatusCode.unauthenticated ||
          failedAccessToken == null ||
          receivedResponse ||
          !replayableRequests.canReplay ||
          _isAuthBootstrapMethod(method.path)) {
        _logRpcFailure(method.path, error, stackTrace);
        rethrow;
      }
      try {
        await refreshAfterUnauthenticated(failedAccessToken);
        yield* invoker(method, requests, _withAccessToken(options));
      } catch (retryError, stackTrace) {
        _logRpcFailure(method.path, retryError, stackTrace);
        Error.throwWithStackTrace(retryError, stackTrace);
      }
    } catch (error, stackTrace) {
      _logRpcFailure(method.path, error, stackTrace);
      Error.throwWithStackTrace(error, stackTrace);
    }
  }

  void _logRpcFailure(String methodPath, Object error, StackTrace stackTrace) {
    developer.log(
      'gRPC call failed: $methodPath',
      name: 'tureon.grpc',
      error: error,
      stackTrace: stackTrace,
    );
  }

  bool _isAuthBootstrapMethod(String path) =>
      path.endsWith('/LoginWithGoogle') || path.endsWith('/RefreshToken');

  bool _isTerminalRefreshFailure(Object error) =>
      error is GrpcError &&
      {
        StatusCode.unauthenticated,
        StatusCode.permissionDenied,
        StatusCode.notFound,
      }.contains(error.code);
}

class _RetriableResponseFuture<Q, R> extends ResponseFuture<R> {
  _RetriableResponseFuture(
    this._result,
    this._response,
    ClientMethod<Q, R> method,
    CallOptions options,
  ) : super(ClientCall<Q, R>(method, Stream<Q>.empty(), options));

  final Future<R> _result;
  final ResponseFuture<R> _response;

  @override
  Future<Map<String, String>> get headers => _response.headers;

  @override
  Future<Map<String, String>> get trailers => _response.trailers;

  @override
  Future<void> cancel() => _response.cancel();

  @override
  Future<S> then<S>(
    FutureOr<S> Function(R value) onValue, {
    Function? onError,
  }) => _result.then(onValue, onError: onError);

  @override
  Future<R> catchError(Function onError, {bool Function(Object error)? test}) =>
      _result.catchError(onError, test: test);

  @override
  Future<R> whenComplete(FutureOr<void> Function() action) =>
      _result.whenComplete(action);

  @override
  Future<R> timeout(Duration timeLimit, {FutureOr<R> Function()? onTimeout}) =>
      _result.timeout(timeLimit, onTimeout: onTimeout);

  @override
  Stream<R> asStream() => _result.asStream();
}

class _RetriableResponseStream<Q, R> extends ResponseStream<R> {
  _RetriableResponseStream(
    this._stream,
    this._response,
    ClientMethod<Q, R> method,
    CallOptions options,
  ) : super(ClientCall<Q, R>(method, Stream<Q>.empty(), options));

  final Stream<R> _stream;
  final ResponseStream<R> _response;

  @override
  Future<Map<String, String>> get headers => _response.headers;

  @override
  Future<Map<String, String>> get trailers => _response.trailers;

  @override
  Future<void> cancel() async {
    try {
      await _response.cancel();
    } catch (error, stackTrace) {
      developer.log(
        'gRPC stream cancellation ended with a transport error',
        name: 'tureon.grpc',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  StreamSubscription<R> listen(
    void Function(R event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) => _stream.listen(
    onData,
    onError: onError,
    onDone: onDone,
    cancelOnError: cancelOnError,
  );
}

class _ReplayableRequestStream<T> extends Stream<T> {
  static const _maxReplayRequests = 256;

  _ReplayableRequestStream(Stream<T> source) : _source = source;

  final Stream<T> _source;
  final List<T> _values = [];
  final StreamController<T> _events = StreamController<T>.broadcast();
  Object? _error;
  StackTrace? _stackTrace;
  bool _started = false;
  bool _done = false;
  bool _replayWindowOpen = true;
  bool _replayOverflowed = false;

  bool get canReplay => !_replayOverflowed;

  void closeReplayWindow() {
    _replayWindowOpen = false;
    _values.clear();
  }

  void _start() {
    if (_started) return;
    _started = true;
    _source.listen(
      (value) {
        if (_replayWindowOpen) {
          if (_values.length < _maxReplayRequests) {
            _values.add(value);
          } else {
            // Never replay a truncated request stream: doing so could silently
            // omit commands. Fail the auth retry instead of growing memory
            // without bound or replaying an incomplete sequence.
            _replayOverflowed = true;
            _values.clear();
          }
        }
        _events.add(value);
      },
      onError: (Object error, StackTrace stackTrace) {
        _error = error;
        _stackTrace = stackTrace;
        _done = true;
        _events.addError(error, stackTrace);
        _events.close();
      },
      onDone: () {
        _done = true;
        _events.close();
      },
    );
  }

  @override
  StreamSubscription<T> listen(
    void Function(T event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    late final Stream<T> replay;
    replay = Stream<T>.multi((controller) {
      final snapshot = List<T>.of(_values);
      final isDone = _done;
      final error = _error;
      final stackTrace = _stackTrace;
      StreamSubscription<T>? eventsSubscription;
      if (!isDone) {
        eventsSubscription = _events.stream.listen(
          controller.add,
          onError: controller.addError,
          onDone: controller.close,
        );
        controller.onCancel = eventsSubscription.cancel;
      }
      for (final value in snapshot) {
        controller.add(value);
      }
      if (isDone) {
        if (error != null) controller.addError(error, stackTrace);
        controller.close();
      } else {
        _start();
      }
    });
    return replay.listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }
}
