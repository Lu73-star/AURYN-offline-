/// lib/voice/auryn_voice.dart
/// Ciclo completo de voz da AURYN Falante
/// Agora com:
/// VAD → SpeechFlow → STT → Processor → TTS
///
/// AURYN fala, escuta, espera, entende e reage como um ser vivo.

import 'dart:async';
import 'dart:typed_data';

import 'package:auryn_offline/auryn_core/auryn_core.dart';
import 'package:auryn_offline/voice/voice_capture.dart';
import 'package:auryn_offline/voice/stt_bridge.dart';
import 'package:auryn_offline/voice/tts_engine.dart';
import 'package:auryn_offline/voice/vad_detector.dart';
import 'package:auryn_offline/voice/speech_flow.dart';

class AurynVoice {
  static final AurynVoice _instance = AurynVoice._internal();
  factory AurynVoice() => _instance;

  AurynVoice._internal();

  final VoiceCapture _capture = VoiceCapture();
  final STTBridge _stt = STTBridge();
  final TTSEngine _tts = TTSEngine();
  final AURYNCore _core = AURYNCore();
  final VADDetector _vad = VADDetector();
  final SpeechFlow _flow = SpeechFlow();

  StreamSubscription? _sub;

  bool _isActive = false;
  bool get isActive => _isActive;

  /// Buffer para guardar os pedaços de áudio até a frase inteira estar completa
  List<Uint8List> _audioBuffer = [];

  /// Inicia o ciclo de escuta da AURYN
  Future<void> startListening() async {
    if (_isActive) return;

    _isActive = true;
    _flow.setState("listening");

    await _tts.init();
    await _capture.start();

    // Monitorar áudio em tempo real
    _sub = _capture.audioStream.stream.listen((chunk) async {
      // Enquanto o usuário está falando, guardar o áudio
      _audioBuffer.add(chunk);

      // Se ainda está falando → não faz nada
      final endDetected = _vad.detectEndOfSpeech(chunk);
      if (!endDetected) return;

      // Se chegou aqui → o usuário PAROU de falar
      _flow.setState("processing");

      // Unir a fala completa
      final fullAudio = _mergeBuffer(_audioBuffer);
      _audioBuffer = [];

      // 1. Transcrever
      final text = await _stt.transcribe(fullAudio);

      if (text.trim().isEmpty || text == "Processando sua fala...") {
        _flow.setState("listening");
        return;
      }

      // 2. Processar a fala
      final reply = _core.respond(text);

      // 3. Pausa natural (dá sensação de “pensando…”)
      await _flow.naturalPause();

      // 4. Verificar se usuário falou durante a pausa
      if (_flow.shouldInterrupt == true) {
        _flow.shouldInterrupt = false;
        _flow.setState("listening");
        return;
      }

      // 5. Falar resposta
      _flow.setState("speaking");
      await _tts.speak(reply);

      // 6. Voltar a escutar
      _flow.setState("listening");
    });
  }

  /// Une todos os bytes capturados em um único WAV
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

  /// Para completamente o módulo de voz
  Future<void> stopListening() async {
    _isActive = false;

    await _capture.stop();
    await _tts.stop();

    await _sub?.cancel();
    _sub = null;

    _audioBuffer = [];

    _flow.setState("idle");
  }
}
