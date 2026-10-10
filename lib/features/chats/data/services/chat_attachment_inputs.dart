import 'dart:io';
import 'package:file_selector/file_selector.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import '../../domain/chat_attachment_action.dart';
import 'chat_media_transfer_service.dart';

/// Platform attachment acquisition and durable local staging, without UI.
class ChatAttachmentInputs {
  Future<XFile?> pickFile(ChatAttachmentAction action) async {
    XFile? picked;
    if (action == ChatAttachmentAction.camera) {
      if (!Platform.isAndroid && !Platform.isIOS) {
        throw StateError('A câmera não está disponível nesta plataforma.');
      }
      picked = await ImagePicker().pickImage(source: ImageSource.camera);
    } else if (action == ChatAttachmentAction.photo &&
        (Platform.isAndroid || Platform.isIOS)) {
      picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    } else if (action == ChatAttachmentAction.video &&
        (Platform.isAndroid || Platform.isIOS)) {
      picked = await ImagePicker().pickVideo(source: ImageSource.gallery);
    } else {
      final typeGroup = switch (action) {
        ChatAttachmentAction.photo => const XTypeGroup(
          label: 'Imagens',
          extensions: ['jpg', 'jpeg', 'png', 'webp', 'bmp'],
        ),
        ChatAttachmentAction.video => const XTypeGroup(
          label: 'Vídeos',
          extensions: ['mp4', 'mov', 'm4v', 'webm', 'mkv'],
        ),
        ChatAttachmentAction.gif => const XTypeGroup(
          label: 'GIF',
          extensions: ['gif'],
        ),
        _ => const XTypeGroup(label: 'Todos os arquivos'),
      };
      picked = await openFile(acceptedTypeGroups: [typeGroup]);
    }
    return picked;
  }

  Future<String> persistPickedFile(
    XFile picked, {
    required bool isSecret,
  }) async {
    final source = File(picked.path);
    if (!await source.exists()) {
      throw StateError('O arquivo selecionado não está mais disponível.');
    }
    final size = await source.length();
    final maxSize = isSecret
        ? ChatMediaTransferService.maxSecretUploadBytes
        : ChatMediaTransferService.maxUploadBytes;
    if (size <= 0 || size > maxSize) {
      final limit = isSecret ? '10 MB' : '50 MB';
      throw StateError('O arquivo deve ter tamanho entre 1 byte e $limit.');
    }
    final directory = await getApplicationSupportDirectory();
    final pending = Directory(path.join(directory.path, 'tureon_media_outbox'));
    await pending.create(recursive: true);
    final extension = path.extension(picked.name).toLowerCase();
    final safeExtension = RegExp(r'^\.[a-z0-9]{1,10}$').hasMatch(extension)
        ? extension
        : '';
    final destination = File(
      path.join(
        pending.path,
        '${DateTime.now().microsecondsSinceEpoch}$safeExtension',
      ),
    );
    await source.copy(destination.path);
    return destination.path;
  }

  Future<({double latitude, double longitude})> currentLocation() async {
    final location = Location();
    var enabled = await location.serviceEnabled();
    if (!enabled) enabled = await location.requestService();
    if (!enabled) {
      throw StateError('Ative a localização do dispositivo para continuar.');
    }
    var permission = await location.hasPermission();
    if (permission == PermissionStatus.denied) {
      permission = await location.requestPermission();
    }
    if (permission != PermissionStatus.granted) {
      throw StateError('A permissão de localização não foi concedida.');
    }
    final data = await location.getLocation();
    final latitude = data.latitude;
    final longitude = data.longitude;
    return (latitude: latitude, longitude: longitude);
  }

  Future<ChatVoiceRecording> startVoiceRecording() async {
    final recorder = AudioRecorder();
    try {
      if (!await recorder.hasPermission()) {
        throw StateError('A permissão para gravar áudio não foi concedida.');
      }
      final directory = await getApplicationSupportDirectory();
      final recordings = Directory(
        path.join(directory.path, 'tureon_recordings'),
      );
      await recordings.create(recursive: true);
      final outputPath = path.join(
        recordings.path,
        'voice-${DateTime.now().microsecondsSinceEpoch}.m4a',
      );
      await recorder.start(
        const RecordConfig(encoder: AudioEncoder.aacLc),
        path: outputPath,
      );
      return ChatVoiceRecording._(recorder, outputPath);
    } catch (_) {
      await recorder.dispose();
      rethrow;
    }
  }
}

/// A recording session has one owner and always releases its platform resource.
class ChatVoiceRecording {
  ChatVoiceRecording._(this._recorder, this.outputPath);
  final AudioRecorder _recorder;
  final String outputPath;
  Future<void> cancel() => _recorder.cancel();
  Future<String?> stop() => _recorder.stop();
  Future<void> dispose() async {
    try {
      if (await _recorder.isRecording()) await _recorder.cancel();
    } finally {
      await _recorder.dispose();
    }
  }
}
