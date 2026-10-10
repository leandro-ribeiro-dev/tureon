import 'package:flutter_test/flutter_test.dart';
import 'package:tureon/core/validation/username_feedback.dart';

void main() {
  group('UsernameFeedback.errorMessage', () {
    test('maps username errors from auth and profile RPCs', () {
      expect(
        UsernameFeedback.errorMessage('USERNAME_TAKEN'),
        'Esse nome de usuário já está em uso.',
      );
      expect(
        UsernameFeedback.errorMessage(
          'gRPC Error (codeName: ALREADY_EXISTS, message: username is already taken)',
        ),
        'Esse nome de usuário já está em uso.',
      );
      expect(
        UsernameFeedback.errorMessage('USERNAME_RESERVED'),
        'Esse nome de usuário é reservado.',
      );
      expect(
        UsernameFeedback.errorMessage('username is reserved'),
        'Esse nome de usuário é reservado.',
      );
      expect(
        UsernameFeedback.errorMessage('PREMIUM_USERNAME_UNAVAILABLE'),
        'Esse nome está disponível apenas para contas premium.',
      );
      expect(
        UsernameFeedback.errorMessage('username is not available'),
        'Esse nome está disponível apenas para contas premium.',
      );
      expect(
        UsernameFeedback.errorMessage(
          'gRPC Error (codeName: INVALID_ARGUMENT, message: username is invalid)',
        ),
        UsernameFeedback.invalidFormatMessage,
      );
      expect(
        UsernameFeedback.errorMessage(
          'gRPC Error (codeName: FAILED_PRECONDITION, message: username is not available)',
        ),
        'Esse nome está disponível apenas para contas premium.',
      );
    });

    test('returns null for unrelated failures', () {
      expect(UsernameFeedback.errorMessage('network unavailable'), isNull);
    });
  });

  group('UsernameFeedback.validateUserUsername', () {
    test('accepts valid user usernames', () {
      expect(UsernameFeedback.validateUserUsername('leandro_1'), isNull);
    });

    test('rejects invalid length, repeated separators and bot usernames', () {
      expect(UsernameFeedback.validateUserUsername('abcd'), isNotNull);
      expect(UsernameFeedback.validateUserUsername('leandro__1'), isNotNull);
      expect(UsernameFeedback.validateUserUsername('leandro_bot'), isNotNull);
    });
  });
}
