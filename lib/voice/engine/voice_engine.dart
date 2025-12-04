import 'package:flutter_tts/flutter_tts.dart';
import '../auryn_voice.dart';

/// VoiceEngine — Módulo base de voz da AURYN Falante.
/// Módulo 1: apenas TTS funcional.
/// Módulo 2: adicionaremos STT + hotword offline.
class VoiceEngine {
  final AurynVoice _voice = AurynVoice();
  final FlutterTts _tts = FlutterTts();

  VoiceEngine() {
    _configureTTS();
  }

  /// Configurações iniciais de fala
  void _configureTTS() async {
    await _tts.setLanguage("pt-BR");
    await _tts.setPitch(1.0);
    await _tts.setSpeechRate(0.9);
  }

  /// Entrada por texto → núcleo → fala
  Future<void> speak(String text) async {
    final response = _voice.processText(text);
    await _tts.speak(response);
  }

  /// Entrada de fala transcrita (placeholder do STT)
  Future<void> processSpeech(String transcript) async {
    final response = await _voice.processSpeech(transcript);
    await _tts.speak(response);
  }
}
