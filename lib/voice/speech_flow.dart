/// lib/voice/speech_flow.dart
/// Coordena estados da fala:
/// listening → processing → speaking
/// Controla pausas naturais, interrupções e sincronização.

class SpeechFlow {
  static final SpeechFlow _instance = SpeechFlow._internal();
  factory SpeechFlow() => _instance;
  SpeechFlow._internal();

  String _state = "idle";  
  String get state => _state;

  void setState(String s) {
    _state = s;
  }

  bool get isListening => _state == "listening";
  bool get isProcessing => _state == "processing";
  bool get isSpeaking => _state == "speaking";

  /// Aguarda uma pausa natural antes de falar
  Future<void> naturalPause() async {
    await Future.delayed(const Duration(milliseconds: 280));
  }

  /// Se o usuário começar a falar durante a resposta → interrompe a fala
  bool shouldInterrupt = false;
}
