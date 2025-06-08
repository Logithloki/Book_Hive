import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:permission_handler/permission_handler.dart';

class MicrophoneService {
  final SpeechToText _speechToText = SpeechToText();
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (!_isInitialized) {
      _isInitialized = await _speechToText.initialize();
    }
  }

  Future<bool> _requestMicrophonePermission() async {
    final status = await Permission.microphone.request();
    return status == PermissionStatus.granted;
  }

  Future<void> startListening({
    required Function(String) onResult,
    required Function(String) onError,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (!_isInitialized) {
      onError('Speech recognition not available');
      return;
    }

    final hasPermission = await _requestMicrophonePermission();
    if (!hasPermission) {
      onError('Microphone permission denied');
      return;
    }
    try {
      await _speechToText.listen(
        onResult: (result) {
          if (result.finalResult) {
            onResult(result.recognizedWords);
          }
        },
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        listenOptions: SpeechListenOptions(partialResults: false),
      );
    } catch (e) {
      onError('Failed to start listening: $e');
    }
  }

  Future<void> stopListening() async {
    if (_speechToText.isListening) {
      await _speechToText.stop();
    }
  }

  bool get isListening => _speechToText.isListening;

  void dispose() {
    _speechToText.cancel();
  }
}
