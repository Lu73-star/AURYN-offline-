/// lib/voice/stt_bridge.dart
/// Speech-to-Text unificado para AURYN Falante.
/// Suporta:
/// - Modo offline (fallback)
/// - Modo online usando Whisper (OpenAI API)

import 'dart:typed_data';
import 'dart:convert';
import 'package:http/http.dart' as http;

class STTBridge {
  static final STTBridge _instance = STTBridge._internal();
  factory STTBridge() => _instance;
  STTBridge._internal();

  /// SE VOCÊ QUISER USAR WHISPER:
  /// Coloque sua API Key abaixo depois.
  String? openAIKey;

  /// Alterna entre os modos
  bool get onlineMode => openAIKey != null && openAIKey!.isNotEmpty;

  /// Processa áudio e retorna texto
  Future<String> transcribe(Uint8List audioBytes) async {
    if (!onlineMode) {
      return _offlineFallback(audioBytes);
    }

    try {
      return await _transcribeWithWhisper(audioBytes);
    } catch (_) {
      return _offlineFallback(audioBytes);
    }
  }

  // ---------------------------
  // OFFLINE MODE
  // ---------------------------

  String _offlineFallback(Uint8List audioBytes) {
    // Aqui, como estamos no Módulo 2,
    // apenas retornamos um placeholder.
    //
    // Quando chegarmos ao Módulo 3,
    // podemos implementar modelos STT locais.
    return "Processando sua fala...";
  }

  // ---------------------------
  // OPENAI WHISPER MODE
  // ---------------------------

  Future<String> _transcribeWithWhisper(Uint8List audioBytes) async {
    if (openAIKey == null || openAIKey!.isEmpty) {
      return "Chave da API não configurada.";
    }

    final uri = Uri.parse("https://api.openai.com/v1/audio/transcriptions");

    final request = http.MultipartRequest("POST", uri)
      ..headers["Authorization"] = "Bearer $openAIKey"
      ..fields["model"] = "whisper-1"
      ..files.add(
        http.MultipartFile.fromBytes(
          "file",
          audioBytes,
          filename: "audio.wav",
          contentType: http.MediaType("audio", "wav"),
        ),
      );

    final response = await request.send();
    final body = await response.stream.bytesToString();

    final data = jsonDecode(body);

    if (data["text"] != null) {
      return data["text"];
    }

    return "Erro ao transcrever áudio.";
  }
}
