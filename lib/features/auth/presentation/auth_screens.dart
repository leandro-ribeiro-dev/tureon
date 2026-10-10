import 'package:flutter/material.dart';

import '../../../core/validation/username_feedback.dart';
import '../data/onboarding_slides.dart';
import '../domain/auth_gateway.dart';
import 'auth_controller.dart';
import 'onboarding_carousel.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({required this.controller, super.key});

  final AuthController controller;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late AuthState _state;
  late final VoidCallback _removeListener;

  @override
  void initState() {
    super.initState();
    _state = widget.controller.currentState;
    _removeListener = widget.controller.listen((value) {
      if (mounted) setState(() => _state = value);
    });
  }

  @override
  void dispose() {
    _removeListener();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAuthenticating = _state.status == AuthStatus.authenticating;
    final displayError = _state.error != null
        ? _displayableAuthError(_state.error!)
        : null;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: OnboardingCarousel(
            slides: onboardingSlides,
            isAuthenticating: isAuthenticating,
            authError: displayError,
            onSignInWithGoogle: widget.controller.signInWithGoogle,
            onSkip: () {},
          ),
        ),
      ),
    );
  }

  String _displayableAuthError(String error) {
    final normalized = error.toLowerCase();
    if (normalized.contains('unavailable') ||
        normalized.contains('deadline_exceeded') ||
        normalized.contains('socketexception') ||
        normalized.contains('timeoutexception')) {
      return 'Não foi possível conectar ao servidor. Verifique sua conexão e '
          'tente novamente.';
    }
    if (normalized.contains('internal') ||
        normalized.contains('unknown') ||
        normalized.contains('resource_exhausted')) {
      return 'O servidor não conseguiu concluir a autenticação. Tente '
          'novamente em alguns instantes.';
    }
    if (normalized.contains('redirect_uri_mismatch')) {
      return 'O Google recusou o endereço de retorno do aplicativo. Confirme '
          'se o Client ID configurado no Linux é do tipo app para computador.';
    }
    if (normalized.contains('invalid_client') ||
        normalized.contains('unauthorized_client')) {
      return 'O Google recusou o Client ID do computador. Confira se o Client '
          'ID desktop está correto e habilitado no projeto OAuth.';
    }
    if (normalized.contains('invalid_grant')) {
      return 'O código de autorização expirou ou já foi usado. Feche a aba do '
          'Google e tente entrar novamente.';
    }
    if (normalized.contains('google authorization failed') ||
        normalized.contains('token exchange failed') ||
        normalized.contains('google did not return') ||
        normalized.contains('google returned')) {
      final detail = _safeGoogleOAuthDetail(error);
      return detail.isEmpty
          ? 'Não foi possível concluir o login com Google. Tente novamente.'
          : 'O Google não concluiu o login: $detail';
    }
    if (normalized.contains('google authentication failed') ||
        normalized.contains('unauthenticated')) {
      return 'O servidor recusou o login Google. Verifique se o Client ID '
          'desta plataforma está autorizado no servidor.';
    }
    return error;
  }

  String _safeGoogleOAuthDetail(String error) {
    var detail = error.trim().replaceFirst(
      RegExp(r'^Bad state:\s*', caseSensitive: false),
      '',
    );
    for (final prefix in [
      'Google authorization failed:',
      'Google token exchange failed:',
      'Google did not return',
      'Google returned',
    ]) {
      if (detail.toLowerCase().startsWith(prefix.toLowerCase())) {
        detail = detail.substring(prefix.length).trim();
        break;
      }
    }
    detail = detail.replaceAll(RegExp(r'[\r\n\t]+'), ' ');
    detail = detail.replaceAll(RegExp(r'\s{2,}'), ' ').trim();
    if (detail.length > 180) {
      detail = '${detail.substring(0, 177)}...';
    }
    return detail;
  }
}

class RestrictedAccountScreen extends StatelessWidget {
  const RestrictedAccountScreen({required this.onLogout, super.key});

  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Sua conta está temporariamente restrita.'),
          const SizedBox(height: 16),
          OutlinedButton(onPressed: onLogout, child: const Text('Sair')),
        ],
      ),
    ),
  );
}

class UsernameSetupScreen extends StatefulWidget {
  const UsernameSetupScreen({required this.controller, super.key});

  final AuthController controller;

  @override
  State<UsernameSetupScreen> createState() => _UsernameSetupScreenState();
}

class _UsernameSetupScreenState extends State<UsernameSetupScreen> {
  final _usernameController = TextEditingController();
  late AuthState _state;
  late final VoidCallback _removeListener;
  bool _submitting = false;
  bool _usernameTouched = false;

  @override
  void initState() {
    super.initState();
    _state = widget.controller.currentState;
    _removeListener = widget.controller.listen((state) {
      if (mounted) setState(() => _state = state);
    });
  }

  @override
  void dispose() {
    _removeListener();
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final error =
        _usernameErrorText(_state.usernameError) ??
        (_usernameTouched
            ? UsernameFeedback.validateUserUsername(_usernameController.text)
            : null);
    return Scaffold(
      appBar: AppBar(title: const Text('Escolha seu nome de usuário')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Seu nome de usuário será usado para encontrar você no Tureon.',
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _usernameController,
                autocorrect: false,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: 'Nome de usuário',
                  prefixText: '@',
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) {
                  setState(() => _usernameTouched = true);
                  if (_state.usernameError != null) {
                    widget.controller.state = AuthState(
                      status: AuthStatus.needsUsername,
                      session: _state.session,
                    );
                  }
                },
                onSubmitted: (_) => _submit(),
              ),
              if (error != null) ...[
                const SizedBox(height: 12),
                Text(
                  error,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
              const SizedBox(height: 20),
              FilledButton(
                onPressed: _submitting ? null : _submit,
                child: _submitting
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Continuar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final username = _usernameController.text.trim();
    if (_submitting) return;
    if (UsernameFeedback.validateUserUsername(username) != null) {
      setState(() => _usernameTouched = true);
      return;
    }
    setState(() => _submitting = true);
    try {
      await widget.controller.chooseUsername(username);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  String? _usernameErrorText(String? error) {
    if (error == null) return null;
    if (error.toLowerCase().contains('premium_username_unavailable')) {
      return 'Esse nome premium não está disponível para sua conta.';
    }
    final feedback = UsernameFeedback.errorMessage(error);
    if (feedback != null) return feedback;
    if (error.toLowerCase().contains('username_rate_limited') ||
        error.toLowerCase().contains('resource_exhausted')) {
      return 'Muitas tentativas. Aguarde um pouco e tente novamente.';
    }
    return 'Não foi possível salvar o nome de usuário. Tente novamente.';
  }
}
