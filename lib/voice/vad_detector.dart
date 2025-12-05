/// lib/voice/vad_detector.dart
/// Detector simples de atividade de voz.
/// Baseado em amplitude (energia) do sinal.
/// Ajuda a determinar quando o usuário está falando
/// e quando terminou de falar.

import 'dart:typed_data';
import 'dart:math';

class VADDetector {
  static final VADDetector _instance = VADDetector._internal();
  factory VADDetector() => _instance;
  VADDetector._internal();

  /// Threshold básico (ajustável)
  final double threshold = 0.015;

  /// Janela de silêncio para encerrar a fala
  final int silenceFramesToStop = 10;

  int _silenceCounter = 0;

  bool isUserSpeaking(Uint8List audioBytes) {
    // Converter para valores PCM aproximados
    double avg = 0;

    for (int i = 0; i < audioBytes.length; i++) {
      avg += audioBytes[i].abs();
    }

    avg /= max(1, audioBytes.length);

    // Normalizar (áudio WAV simples)
    double normalized = avg / 255.0;

    // Atividade detectada
    return normalized > threshold;
  }

  /// True quando a fala terminou
  bool detectEndOfSpeech(Uint8List audioBytes) {
    if (isUserSpeaking(audioBytes)) {
      _silenceCounter = 0;
      return false;
    }

    _silenceCounter++;

    if (_silenceCounter >= silenceFramesToStop) {
      _silenceCounter = 0;
      return true;
    }

    return false;
  }
}
