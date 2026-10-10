import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/storage/message_records.dart';
import '../../../../core/validation/username_feedback.dart';

enum ProfileFieldType {
  displayName,
  username,
  phone,
  bio,
  birthday,
  country,
  avatarUrl,
}

class EditFieldScreen extends StatefulWidget {
  const EditFieldScreen({
    super.key,
    required this.fieldType,
    required this.currentUser,
    required this.onSave,
  });

  final ProfileFieldType fieldType;
  final UserProfile currentUser;
  final Future<UserProfile> Function(UserProfile profile) onSave;

  @override
  State<EditFieldScreen> createState() => _EditFieldScreenState();
}

class _EditFieldScreenState extends State<EditFieldScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _controller;
  bool _saving = false;
  String? _usernameServerError;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String get _initialValue => switch (widget.fieldType) {
    ProfileFieldType.displayName => widget.currentUser.displayName,
    ProfileFieldType.username => widget.currentUser.username,
    ProfileFieldType.phone => widget.currentUser.phoneE164,
    ProfileFieldType.bio => widget.currentUser.bio ?? '',
    ProfileFieldType.birthday => widget.currentUser.birthday,
    ProfileFieldType.country => widget.currentUser.countryCode,
    ProfileFieldType.avatarUrl => widget.currentUser.avatarUrl ?? '',
  };

  String get _title => switch (widget.fieldType) {
    ProfileFieldType.displayName => 'Nome',
    ProfileFieldType.username => 'Nome de usuário',
    ProfileFieldType.phone => 'Número de telefone',
    ProfileFieldType.bio => 'Bio',
    ProfileFieldType.birthday => 'Data de nascimento',
    ProfileFieldType.country => 'País (código ISO)',
    ProfileFieldType.avatarUrl => 'Foto de perfil',
  };

  String get _subtitle => switch (widget.fieldType) {
    ProfileFieldType.displayName => 'Seu nome de exibição',
    ProfileFieldType.username => 'Seu @username único no Tureon',
    ProfileFieldType.phone => 'Seu número de telefone cadastrado',
    ProfileFieldType.bio => 'Sua apresentação pessoal',
    ProfileFieldType.birthday => 'Sua data de nascimento',
    ProfileFieldType.country => 'Código de país com duas letras',
    ProfileFieldType.avatarUrl => 'URL da imagem do perfil',
  };

  String get _explanation => switch (widget.fieldType) {
    ProfileFieldType.displayName =>
      'Informe seu nome e sobrenome. Este nome será exibido nas suas conversas, '
          'grupos e para os seus contatos no Tureon.',
    ProfileFieldType.username =>
      'Você pode escolher um nome de usuário no Tureon. Se o fizer, as pessoas poderão '
          'encontrar você por este username e entrar em contato sem precisar do seu número de telefone.\n\n'
          'Você pode usar a–z, 0–9 e caracteres de sublinhado (_). O tamanho mínimo é de 5 caracteres.',
    ProfileFieldType.phone =>
      'Seu número de telefone é usado para autenticação e identificação da sua conta. '
          'Você pode controlar quem pode ver seu número nas configurações de Privacidade.',
    ProfileFieldType.bio =>
      'Você pode adicionar poucas linhas sobre você. Qualquer pessoa que visualizar seu perfil '
          'poderá ler esta bio. Links são permitidos.',
    ProfileFieldType.birthday =>
      'Sua data de nascimento é usada para confirmar sua idade e personalizar sua experiência no app. '
          'Selecione a data no calendário (datas futuras são desabilitadas).',
    ProfileFieldType.country =>
      'Informe o código ISO de duas letras do país, como BR ou US. Você controla a visibilidade nas configurações de Privacidade.',
    ProfileFieldType.avatarUrl =>
      'Insira a URL de uma imagem pública válida (ex: HTTPS) para exibir como sua foto de perfil no Tureon.',
  };

  int get _maxLines => switch (widget.fieldType) {
    ProfileFieldType.bio => 4,
    ProfileFieldType.avatarUrl => 2,
    _ => 1,
  };

  int? get _maxLength => switch (widget.fieldType) {
    ProfileFieldType.displayName => 150,
    ProfileFieldType.username => 32,
    ProfileFieldType.phone => 16,
    ProfileFieldType.bio => 150,
    ProfileFieldType.birthday => 10,
    ProfileFieldType.country => 2,
    ProfileFieldType.avatarUrl => 2048,
  };

  TextInputType get _keyboardType => switch (widget.fieldType) {
    ProfileFieldType.phone => TextInputType.phone,
    ProfileFieldType.birthday => TextInputType.datetime,
    ProfileFieldType.country => TextInputType.text,
    ProfileFieldType.avatarUrl => TextInputType.url,
    ProfileFieldType.bio => TextInputType.multiline,
    _ => TextInputType.text,
  };

  int? _calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age >= 0 ? age : null;
  }

  Future<void> _selectBirthdayDate() async {
    final now = DateTime.now();
    DateTime initial = DateTime(2000, 1, 1);
    if (_controller.text.isNotEmpty) {
      final parsed = DateTime.tryParse(_controller.text.trim());
      if (parsed != null && !parsed.isAfter(now)) {
        initial = parsed;
      }
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900, 1, 1),
      lastDate: now, // Prevents selecting future dates
      helpText: 'SELECIONE SUA DATA DE NASCIMENTO',
      cancelText: 'Cancelar',
      confirmText: 'Confirmar',
    );

    if (picked != null) {
      final formatted =
          '${picked.year.toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      setState(() {
        _controller.text = formatted;
      });
      _formKey.currentState?.validate();
    }
  }

  String? _validate(String? value) {
    final text = value?.trim() ?? '';
    switch (widget.fieldType) {
      case ProfileFieldType.displayName:
        if (text.isEmpty) return 'O nome é obrigatório.';
        return null;
      case ProfileFieldType.username:
        return _usernameServerError ??
            UsernameFeedback.validateUserUsername(text);
      case ProfileFieldType.birthday:
        if (text.isEmpty) return null;
        final parsed = DateTime.tryParse(text);
        if (parsed == null || parsed.isAfter(DateTime.now())) {
          return 'Informe uma data válida no formato AAAA-MM-DD.';
        }
        return null;
      case ProfileFieldType.country:
        if (text.isEmpty || RegExp(r'^[A-Za-z]{2}$').hasMatch(text)) {
          return null;
        }
        return 'Informe duas letras, como BR.';
      case ProfileFieldType.phone:
        if (text.isEmpty || RegExp(r'^\+[1-9][0-9]{1,14}$').hasMatch(text)) {
          return null;
        }
        return 'Informe o telefone no formato internacional E.164 (ex: +14155552671).';
      case ProfileFieldType.avatarUrl:
        if (text.isEmpty) return null;
        final uri = Uri.tryParse(text);
        final host = uri?.host.toLowerCase().replaceFirst(RegExp(r'\.$'), '');
        if (uri == null ||
            uri.scheme != 'https' ||
            host == null ||
            host.isEmpty ||
            uri.userInfo.isNotEmpty ||
            host == 'localhost' ||
            host.endsWith('.localhost') ||
            host.endsWith('.local') ||
            host.endsWith('.internal')) {
          return 'Use uma URL HTTPS pública válida.';
        }
        return null;
      default:
        return null;
    }
  }

  UserProfile _updatedProfile(String text) => switch (widget.fieldType) {
    ProfileFieldType.displayName => widget.currentUser.copyWith(
      displayName: text,
    ),
    ProfileFieldType.username => widget.currentUser.copyWith(username: text),
    ProfileFieldType.phone => widget.currentUser.copyWith(phoneE164: text),
    ProfileFieldType.bio => widget.currentUser.copyWith(bio: text),
    ProfileFieldType.birthday => widget.currentUser.copyWith(birthday: text),
    ProfileFieldType.country => widget.currentUser.copyWith(
      countryCode: text.toUpperCase(),
    ),
    ProfileFieldType.avatarUrl => widget.currentUser.copyWith(
      avatarUrl: text.isEmpty ? null : text,
      clearAvatarUrl: text.isEmpty,
    ),
  };

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final text = _controller.text.trim();
    try {
      final updated = await widget.onSave(_updatedProfile(text));
      if (mounted) Navigator.of(context).pop(updated);
    } on ProfileSyncPendingException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Perfil salvo neste dispositivo; sincronização pendente: ${error.cause}',
          ),
        ),
      );
      Navigator.of(context).pop(error.profile);
    } catch (error) {
      if (mounted) {
        final usernameMessage = widget.fieldType == ProfileFieldType.username
            ? UsernameFeedback.errorMessage(error)
            : null;
        if (usernameMessage != null) {
          setState(() => _usernameServerError = usernameMessage);
          _formKey.currentState?.validate();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Não foi possível salvar: $error')),
          );
        }
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final parsedBirthday =
        widget.fieldType == ProfileFieldType.birthday &&
            _controller.text.isNotEmpty
        ? DateTime.tryParse(_controller.text.trim())
        : null;
    final age =
        parsedBirthday != null && !parsedBirthday.isAfter(DateTime.now())
        ? _calculateAge(parsedBirthday)
        : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
        actions: [
          IconButton(
            tooltip: 'Salvar',
            onPressed: _saving ? null : _save,
            icon: _saving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _controller,
                  autofocus: true,
                  readOnly: widget.fieldType == ProfileFieldType.birthday,
                  onTap: widget.fieldType == ProfileFieldType.birthday
                      ? _selectBirthdayDate
                      : null,
                  autocorrect: widget.fieldType != ProfileFieldType.username,
                  maxLines: _maxLines,
                  maxLength: _maxLength,
                  maxLengthEnforcement: MaxLengthEnforcement.enforced,
                  keyboardType: _keyboardType,
                  textCapitalization:
                      widget.fieldType == ProfileFieldType.country
                      ? TextCapitalization.characters
                      : widget.fieldType == ProfileFieldType.username
                      ? TextCapitalization.none
                      : TextCapitalization.sentences,
                  inputFormatters: widget.fieldType == ProfileFieldType.country
                      ? [FilteringTextInputFormatter.allow(RegExp('[A-Za-z]'))]
                      : const [],
                  decoration: InputDecoration(
                    labelText: _subtitle,
                    prefixText: widget.fieldType == ProfileFieldType.username
                        ? '@ '
                        : null,
                    suffixIcon: widget.fieldType == ProfileFieldType.birthday
                        ? IconButton(
                            icon: const Icon(Icons.calendar_month_rounded),
                            tooltip: 'Selecionar data',
                            onPressed: _selectBirthdayDate,
                          )
                        : null,
                  ),
                  validator: _validate,
                  onChanged: widget.fieldType == ProfileFieldType.username
                      ? (_) {
                          if (_usernameServerError != null) {
                            setState(() => _usernameServerError = null);
                          }
                        }
                      : null,
                ),

                if (age != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Idade calculada: $age anos',
                      style: TextStyle(
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 16),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline_rounded, size: 20),
                    const SizedBox(width: 12),
                    Expanded(child: Text(_explanation)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
