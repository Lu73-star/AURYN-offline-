/// lib/auryn_core/events/auryn_event.dart
/// Classe base para todos os eventos do sistema AURYN.

import 'package:uuid/uuid.dart';

/// Tipo de evento
enum AurynEventType {
  stateChange,
  emotionalPulse,
  runtimePulse,
  inputReceived,
  outputGenerated,
  moodChange,
  energyChange,
  processingStart,
  processingEnd,
  voiceStateChange,
  memoryUpdate,
  error,
  custom,
}

/// Evento base do sistema AURYN
class AurynEvent {
  /// ID único do evento
  final String id;

  /// Tipo do evento
  final AurynEventType type;

  /// Timestamp de criação
  final DateTime timestamp;

  /// Dados associados ao evento
  final Map<String, dynamic> data;

  /// Origem do evento (nome do módulo)
  final String source;

  /// Prioridade do evento (0-10, 10 = máxima)
  final int priority;

  AurynEvent({
    String? id,
    required this.type,
    DateTime? timestamp,
    this.data = const {},
    this.source = 'unknown',
    this.priority = 5,
  })  : id = id ?? const Uuid().v4(),
        timestamp = timestamp ?? DateTime.now();

  /// Cria uma cópia do evento com dados modificados
  AurynEvent copyWith({
    String? id,
    AurynEventType? type,
    DateTime? timestamp,
    Map<String, dynamic>? data,
    String? source,
    int? priority,
  }) {
    return AurynEvent(
      id: id ?? this.id,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      data: data ?? this.data,
      source: source ?? this.source,
      priority: priority ?? this.priority,
    );
  }

  @override
  String toString() {
    return 'AurynEvent(id: $id, type: $type, source: $source, timestamp: $timestamp, priority: $priority)';
  }

  /// Converte para Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.toString(),
      'timestamp': timestamp.toIso8601String(),
      'data': data,
      'source': source,
      'priority': priority,
    };
  }
}
