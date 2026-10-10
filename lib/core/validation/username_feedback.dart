class UsernameFeedback {
  const UsernameFeedback._();

  static String? errorMessage(Object? error) {
    if (error == null) return null;
    final normalized = error.toString().toLowerCase();
    if (normalized.contains('username_taken') ||
        normalized.contains('username is already taken') ||
        normalized.contains('already_exists')) {
      return 'Esse nome de usuário já está em uso.';
    }
    if (normalized.contains('username_reserved') ||
        normalized.contains('username is reserved')) {
      return 'Esse nome de usuário é reservado.';
    }
    if (normalized.contains('premium_username') ||
        normalized.contains('username is not available')) {
      return 'Esse nome está disponível apenas para contas premium.';
    }
    if (normalized.contains('username_invalid') ||
        normalized.contains('username is invalid')) {
      return invalidFormatMessage;
    }
    return null;
  }

  static String? validateUserUsername(String value) {
    final username = value.trim();
    if (!RegExp(r'^[a-zA-Z0-9_]{5,32}$').hasMatch(username) ||
        username.contains('__') ||
        username.toLowerCase().endsWith('_bot')) {
      return invalidFormatMessage;
    }
    return null;
  }

  static const invalidFormatMessage =
      'Formato inválido. Use de 5 a 32 letras, números ou _; usernames de usuário não podem terminar em _bot.';
}
