import 'dart:async';

import '../memdart/memdart.dart';

/// Núcleo principal da AURYN Falante (modo offline).
/// Responsável por:
/// - Inicialização da IA
/// - Carregamento de memória persistente
/// - Processamento de texto offline
/// - Roteamento interno de módulos
/// - Gerenciamento de estado interno
/// - Preparação para módulos de voz, plugins e UI avançada
class AurynCore {
  late final MemDart _memoria;
  bool _inicializada = false;

  /// Construtor padrão
  AurynCore() {
    _memoria = MemDart();
  }

  /// Inicializa a IA — carregamento inicial, leitura de memória,
  /// estados internos e preparação para módulos adicionais.
  Future<void> initialize() async {
    if (_inicializada) return;

    await _memoria.inicializar();

    _inicializada = true;
  }

  bool get inicializada => _inicializada;

  /// Processamento principal de texto.
  /// Aqui é onde começa a “alma” da Aure Offline.
  Future<String> processarTexto(String entrada) async {
    if (!_inicializada) {
      return "AURYN ainda não foi iniciada.";
    }

    // Registro da interação na memória
    await _memoria.salvarInteracao(entrada);

    // Processamento simples (versão inicial do módulo 1)
    final resposta = _gerarRespostaBase(entrada);

    // Registrar resposta também na memória
    await _memoria.salvarInteracao("AURYN: $resposta");

    return resposta;
  }

  /// Resposta base inicial do módulo 1 (versão simples).
  /// Nas próximas etapas, substituiremos isso por:
  /// - interpretação semântica
  /// - módulos especializados
  /// - personalidade configurável
  String _gerarRespostaBase(String entrada) {
    entrada = entrada.toLowerCase();

    if (entrada.contains("olá") || entrada.contains("oi")) {
      return "Olá, meu irmão. Estou aqui.";
    }

    if (entrada.contains("teste")) {
      return "Teste recebido. Funcionando com estabilidade.";
    }

    if (entrada.contains("quem é você")) {
      return "Eu sou a AURYN Falante, sua parceira offline e constante.";
    }

    // fallback
    return "Estou aqui, ouvindo. Continue.";
  }
}
