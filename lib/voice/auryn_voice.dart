/// lib/voice/auryn_voice.dart
/// Ciclo completo usando:
/// VAD → STT → Processor → TTS
///
/// Agora a AURYN só transcreve quando o usuário PARA de falar.
/// Fluxo natural, econômico e humano.

import 'dart:async';
import 'dart:typed_data';

import 'package:auryn_offline/auryn_core/auryn_core.dart';
import 'package:auryn_offline/voice/voice_capture.dart';
import 'package:auryn_offline/voice/stt_bridge.dart';
import 'package:auryn_offline/voice/tts_engine.dart';
import 'package:auryn_offline/voice/vad_detector.dart';

class AurynVoice {
  static final AurynVoice _instance = AurynVoice._internal();
  factory AurynVoice() => _instance;

  AurynVoice._internal();

  final VoiceCapture _capture = VoiceCapture();
  final STTBridge _stt = STTBridge();
  final TTSEngine _tts = TTSEngine();
  final AURYNCore _core = AURYNCore();
  final VADDetector _vad = VADDetector();

  StreamSubscription? _sub;

  bool _isActive = false;
  bool get isActive => _isActive;

  /// Buffer para armazenar a fala inteira antes do STT
  List<Uint8List> _audioBuffer = [];

  Future<void> startListening() async {
    if (_isActive) return;

    _isActive = true;

    await _tts.init();
    await _capture.start();

    _sub = _capture.audioStream.stream.listen((chunk) async {
      // Se estiver falando, continuar juntando dados
      _audioBuffer.add(chunk);

      final endDetected = _vad.detectEndOfSpeech(chunk);

      if (!endDetected) return;

      // Usuário terminou a frase → juntar áudio
      final fullAudio = _mergeBuffer(_audioBuffer);
      _audioBuffer = [];

      // 1. Transcrever
      final text = await _stt.transcribe(fullAudio);

      if (text.trim().isEmpty || text == "Processando sua fala...") {
        return;
      }

      // 2. Processar a fala no núcleo
      final reply = _core.respond(text);

      // 3. Falar a resposta
      await _tts.speak(reply);
    });
  }

  Uint8List _mergeBuffer(List<Uint8List> pieces) {
    final totalLength =
        pieces.fold(0, (sum, chunk) => sum + chunk.length);

    final buffer = Uint8List(totalLength);
    int offset = 0;

    for (final chunk in pieces) {
      buffer.setRange(offset, offset + chunk.length, chunk);
      offset += chunk.length;
    }

    return buffer;
  }

  Future<void> stopListening() async {
    _isActive = false;

    await _capture.stop();
    await _tts.stop();
    await _sub?.cancel();
    _sub = null;

    _audioBuffer = [];
  }
}
