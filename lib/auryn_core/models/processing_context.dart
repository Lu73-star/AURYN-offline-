/// lib/auryn_core/models/processing_context.dart
/// Modelo que representa o contexto de processamento de uma entrada.

class ProcessingContext {
  /// Input original do usuário
  final String rawInput;

  /// Input sanitizado
  final String sanitizedInput;

  /// Timestamp de recebimento
  final DateTime timestamp;

  /// Intenção detectada
  String? intent;

  /// Entidades extraídas
  Map<String, dynamic> entities;

  /// Estado emocional no momento do processamento
  String? mood;

  /// Energia no momento do processamento
  int? energy;

  /// Resposta gerada
  String? response;

  /// Metadados adicionais
  Map<String, dynamic> metadata;

  /// Indicador de processamento completo
  bool isComplete;

  /// Erros durante o processamento
  List<String> errors;

  ProcessingContext({
    required this.rawInput,
    required this.sanitizedInput,
    DateTime? timestamp,
    this.intent,
    this.entities = const {},
    this.mood,
    this.energy,
    this.response,
    this.metadata = const {},
    this.isComplete = false,
    this.errors = const [],
  }) : timestamp = timestamp ?? DateTime.now();

  /// Marca o contexto como completo
  void markComplete() {
    isComplete = true;
  }

  /// Adiciona um erro
  void addError(String error) {
    errors = [...errors, error];
  }

  /// Converte para Map
  Map<String, dynamic> toMap() {
    return {
      'rawInput': rawInput,
      'sanitizedInput': sanitizedInput,
      'timestamp': timestamp.toIso8601String(),
      'intent': intent,
      'entities': entities,
      'mood': mood,
      'energy': energy,
      'response': response,
      'metadata': metadata,
      'isComplete': isComplete,
      'errors': errors,
    };
  }

  @override
  String toString() {
    return 'ProcessingContext(intent: $intent, mood: $mood, energy: $energy, complete: $isComplete)';
  }
}
