part of '../chat_screen.dart';

/// Presentation coordination for conversation attachments.
mixin _ConversationAttachments on _ChatConversationState {
  Future<void> _handleAttachmentPressed() async {
    final generation = _conversationGeneration;
    final currentRecipient = _liveRecipient ?? widget.recipient;
    if (_roomSlowModeRemainingSeconds(currentRecipient) > 0) return;
    final action = await showAttachmentMenu(context);
    if (!mounted || action == null || generation != _conversationGeneration) {
      return;
    }
    final permissionError = _attachmentPermissionError(action);
    if (permissionError != null) {
      _showAttachmentError(permissionError);
      return;
    }
    try {
      switch (action) {
        case ChatAttachmentAction.photo:
        case ChatAttachmentAction.camera:
        case ChatAttachmentAction.video:
        case ChatAttachmentAction.gif:
        case ChatAttachmentAction.file:
          await _chooseAndSendFile(action);
          break;
        case ChatAttachmentAction.location:
          await _sendCurrentLocation();
          break;
        case ChatAttachmentAction.voice:
          await _recordAndSendVoice();
          break;
      }
    } catch (error, stackTrace) {
      if (!mounted || generation != _conversationGeneration) return;
      if (error is RoomSlowModeFailure) {
        _startRoomSlowModeCooldown(
          _liveRecipient ?? widget.recipient,
          retryAfterSeconds: error.retryAfterSeconds,
        );
        return;
      }
      developer.log(
        'Could not prepare a chat attachment',
        name: 'tureon.messaging',
        error: error,
        stackTrace: stackTrace,
      );
      if (mounted && generation == _conversationGeneration) {
        _showAttachmentError(_failureMessage(error));
      }
    }
  }

  Future<void> _chooseAndSendFile(ChatAttachmentAction action) async {
    final generation = _conversationGeneration;
    final picked = await _attachmentInputs.pickFile(action);
    if (picked == null || !mounted || generation != _conversationGeneration) {
      return;
    }
    final caption = await _requestAttachmentCaption();
    if (caption == null || !mounted || generation != _conversationGeneration) {
      return;
    }
    final persistentPath = await _attachmentInputs.persistPickedFile(
      picked,
      isSecret: _secretMode,
    );
    if (!mounted || generation != _conversationGeneration) return;
    final messageType = switch (action) {
      ChatAttachmentAction.photo ||
      ChatAttachmentAction.camera => chat_domain.ChatMessageType.image,
      ChatAttachmentAction.video => chat_domain.ChatMessageType.video,
      ChatAttachmentAction.gif => chat_domain.ChatMessageType.gif,
      ChatAttachmentAction.file => chat_domain.ChatMessageType.file,
      _ => throw StateError('Tipo de anexo incompatível.'),
    };
    await _sendMediaFile(
      sourcePath: persistentPath,
      fileName: path.basename(picked.name),
      mimeType: lookupMimeType(picked.name) ?? 'application/octet-stream',
      type: messageType,
      caption: caption,
    );
  }

  Future<String?> _requestAttachmentCaption() async {
    final controller = TextEditingController();
    try {
      return await showDialog<String>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Adicionar descrição'),
          content: TextField(
            controller: controller,
            autofocus: true,
            minLines: 1,
            maxLines: 4,
            maxLength: ChatInputArea.maxMessageLength,
            decoration: const InputDecoration(
              hintText: 'Escreva uma legenda (opcional)',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.pop(dialogContext, controller.text.trim()),
              child: const Text('Enviar'),
            ),
          ],
        ),
      );
    } finally {
      controller.dispose();
    }
  }

  Future<void> _sendMediaFile({
    required String sourcePath,
    required String fileName,
    required String mimeType,
    required chat_domain.ChatMessageType type,
    required String caption,
    int? durationMillis,
  }) async {
    final generation = _conversationGeneration;
    final recipient = _liveRecipient ?? widget.recipient;
    if (_roomSlowModeRemainingSeconds(recipient) > 0) return;
    final repository = widget.services?.chatRepository;
    final senderId = _localUserId;
    if (repository == null || senderId == null) {
      throw StateError('Conecte-se e entre na conta para enviar anexos.');
    }
    final secretDevice = widget.secretChatDevice;
    if (_secretMode && secretDevice == null) {
      throw StateError('Selecione o dispositivo do chat secreto.');
    }
    await repository.sendAttachment(
      chatId: widget.recipient.id,
      senderRecipientId: senderId,
      type: type,
      sourcePath: sourcePath,
      fileName: fileName,
      mimeType: mimeType,
      caption: caption,
      replyToMessageId: _replyToMessage?.messageId,
      isSecret: _secretMode,
      recipientServerDeviceId: secretDevice?.deviceId,
      durationMillis: durationMillis,
    );
    if (mounted && generation == _conversationGeneration) {
      _startRoomSlowModeCooldown(recipient);
      setState(() {
        _chatLoadError = null;
        _replyToMessage = null;
      });
    }
  }

  Future<void> _sendCurrentLocation() async {
    final generation = _conversationGeneration;
    final recipient = _liveRecipient ?? widget.recipient;
    if (_roomSlowModeRemainingSeconds(recipient) > 0) return;
    final caption = await _requestAttachmentCaption();
    if (caption == null || !mounted || generation != _conversationGeneration) {
      return;
    }
    final coordinates = await _attachmentInputs.currentLocation();
    if (!mounted || generation != _conversationGeneration) return;
    final latitude = coordinates.latitude;
    final longitude = coordinates.longitude;
    final repository = widget.services?.chatRepository;
    final senderId = _localUserId;
    if (repository == null || senderId == null) {
      throw StateError('Conecte-se e entre na conta para enviar localização.');
    }
    final secretDevice = widget.secretChatDevice;
    if (_secretMode && secretDevice == null) {
      throw StateError('Selecione o dispositivo do chat secreto.');
    }
    await repository.sendLocation(
      chatId: widget.recipient.id,
      senderRecipientId: senderId,
      latitude: latitude,
      longitude: longitude,
      caption: caption,
      replyToMessageId: _replyToMessage?.messageId,
      isSecret: _secretMode,
      recipientServerDeviceId: secretDevice?.deviceId,
    );
    if (mounted && generation == _conversationGeneration) {
      _startRoomSlowModeCooldown(recipient);
      setState(() {
        _chatLoadError = null;
        _replyToMessage = null;
      });
    }
  }

  Future<void> _recordAndSendVoice() async {
    final generation = _conversationGeneration;
    final recording = await _attachmentInputs.startVoiceRecording();
    final outputPath = recording.outputPath;
    final stopwatch = Stopwatch()..start();
    try {
      if (!mounted || generation != _conversationGeneration) return;
      final shouldSend = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Gravando áudio'),
          content: const Row(
            children: [
              Icon(Icons.fiber_manual_record_rounded, color: Colors.red),
              SizedBox(width: 10),
              Expanded(
                child: Text('Sua gravação será enviada como nota de voz.'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await recording.cancel();
                if (dialogContext.mounted) Navigator.pop(dialogContext, false);
              },
              child: const Text('Descartar'),
            ),
            FilledButton.icon(
              onPressed: () async {
                await recording.stop();
                if (dialogContext.mounted) Navigator.pop(dialogContext, true);
              },
              icon: const Icon(Icons.send_rounded),
              label: const Text('Enviar'),
            ),
          ],
        ),
      );
      stopwatch.stop();
      if (shouldSend != true ||
          !mounted ||
          generation != _conversationGeneration) {
        return;
      }
      await _sendMediaFile(
        sourcePath: outputPath,
        fileName: 'Nota de voz.m4a',
        mimeType: 'audio/mp4',
        type: chat_domain.ChatMessageType.voiceNote,
        caption: '',
        durationMillis: stopwatch.elapsedMilliseconds,
      );
    } finally {
      await recording.dispose();
    }
  }

  void _showAttachmentError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
