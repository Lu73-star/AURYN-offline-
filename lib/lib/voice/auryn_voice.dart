/// lib/voice/auryn_voice.dart
/// Módulo que unifica o ciclo completo de voz:
/// Microfone → STT → Processor → TTS → loop opcional.

import 'dart:async';
import 'package:auryn_offline/auryn_core/auryn_core.dart';
import 'package:auryn_offline/voice/voice_capture.dart';
import 'package:auryn_offline/voice/stt_bridge.dart';
import 'package:auryn_offline/voice/tts_engine.dart';

class AurynVoice {
  static final AurynVoice _instance = AurynVoice._internal();
  factory AurynVoice() => _instance;

  AurynVoice._internal();

  final VoiceCapture _capture = VoiceCapture();
  final STTBridge _stt = STTBridge();
  final TTSEngine _tts = TTSEngine();
  final AURYNCore _core = AURYNCore();

  StreamSubscription? _sub;

  bool _isActive = false;
  bool get isActive => _isActive;

  /// Inicia a AURYN Falante escutando
  Future<void> startListening() async {
    if (_isActive) return;

    _isActive = true;

    // Inicializar TTS
    await _tts.init();

    // Iniciar captura de áudio
    await _capture.start();

    // Conectar stream de áudio → STT → Processor → TTS
    _sub = _capture.audioStream.stream.listen((audioBytes) async {
      // 1. Transcrever
      final text = await _stt.transcribe(audioBytes);

      // Caso seja só o placeholder do offline, ignoramos
      if (text.trim().isEmpty || text == "Processando sua fala...") {
        return;
      }

      // 2. Interpretar no núcleo
      final response = _core.respond(text);

      // 3. Falar a resposta
      await _tts.speak(response);
    });
  }

  /// Para completamente a escuta
  Future<void> stopListening() async {
    _isActive = false;

    await _capture.stop();
    await _tts.stop();

    await _sub?.cancel();
    _sub = null;
  }
}
