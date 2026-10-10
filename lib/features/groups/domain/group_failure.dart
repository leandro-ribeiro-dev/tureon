/// Domain-specific failures for Group operations adhering to Section 6.1 of AGENTS.md.
sealed class GroupFailure implements Exception {
  const GroupFailure(this.message);

  final String message;

  @override
  String toString() => 'GroupFailure: $message';
}

class GroupCreateFailure extends GroupFailure {
  const GroupCreateFailure(super.message);
}

class GroupMemberFailure extends GroupFailure {
  const GroupMemberFailure(super.message);
}

class GroupPermissionFailure extends GroupFailure {
  const GroupPermissionFailure(super.message);
}
