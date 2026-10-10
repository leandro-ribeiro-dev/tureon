/// Domain-specific failures for Channel operations adhering to Section 6.1 of AGENTS.md.
sealed class ChannelFailure implements Exception {
  const ChannelFailure(this.message);

  final String message;

  @override
  String toString() => 'ChannelFailure: $message';
}

class ChannelCreateFailure extends ChannelFailure {
  const ChannelCreateFailure(super.message);
}

class ChannelSubscribeFailure extends ChannelFailure {
  const ChannelSubscribeFailure(super.message);
}

class ChannelPermissionFailure extends ChannelFailure {
  const ChannelPermissionFailure(super.message);
}
