/// lib/voice/tts_engine.dart
/// Text-To-Speech da AURYN Falante.
/// Voz feminina suave, em português, com modulação emocional futura.

import 'package:flutter_tts/flutter_tts.dart';

class TTSEngine {
  static final TTSEngine _instance = TTSEngine._internal();
  factory TTSEngine() => _instance;

  TTSEngine._internal();

  final FlutterTts _tts = FlutterTts();

  bool _initialized = false;

  /// Inicializa TTS com configurações da AURYN
  Future<void> init() async {
    if (_initialized) return;

    await _tts.setLanguage("pt-BR");  
    await _tts.setPitch(1.05);        // leve suavidade
    await _tts.setSpeechRate(0.87);   // ritmo mais calmo e presente
    await _tts.setVolume(1.0);

    // Para Web:
    await _tts.setVoice({
      "name": "pt-BR",
      "locale": "pt-BR",
    });

    _initialized = true;
  }

  /// Fala uma resposta
  Future<void> speak(String text) async {
    if (!_initialized) {
      await init();
    }

    await _tts.stop(); // evita sobreposição
    await _tts.speak(text);
  }

  /// Para a fala
  Future<void> stop() async {
    await _tts.stop();
  }
}
