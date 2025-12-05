/// lib/auryn_core/memory/memory_entry.dart
/// MemoryEntry - Estrutura fundamental de entrada de memória da AURYN.
///
/// MemoryEntry representa uma unidade individual de memória, incluindo:
/// - Identificador único
/// - Timestamp de criação
/// - Categoria da memória
/// - Peso emocional associado
/// - Conteúdo da memória
/// - Tags para busca e organização

import 'package:uuid/uuid.dart';

/// {@template memory_entry}
/// Representa uma entrada individual na memória da AURYN.
///
/// Cada entrada contém metadados e conteúdo que podem ser
/// persistidos, buscados e filtrados.
/// {@endtemplate}
class MemoryEntry {
  /// Identificador único da entrada
  final String id;

  /// Timestamp de quando a memória foi criada
  final DateTime timestamp;

  /// Categoria da memória (ex: 'interaction', 'emotion', 'learning')
  final String category;

  /// Peso emocional associado (-1.0 a 1.0)
  /// -1.0 = muito negativo, 0.0 = neutro, 1.0 = muito positivo
  final double emotionalWeight;

  /// Conteúdo da memória
  final Map<String, dynamic> content;

  /// Tags para busca e organização
  final List<String> tags;

  /// Timestamp de última atualização (opcional)
  final DateTime? lastUpdated;

  /// Contador de acesso (quantas vezes foi recuperada)
  final int accessCount;

  /// Data de expiração (opcional)
  final DateTime? expiresAt;

  /// Construtor principal
  MemoryEntry({
    String? id,
    DateTime? timestamp,
    required this.category,
    this.emotionalWeight = 0.0,
    required this.content,
    List<String>? tags,
    this.lastUpdated,
    this.accessCount = 0,
    this.expiresAt,
  })  : id = id ?? const Uuid().v4(),
        timestamp = timestamp ?? DateTime.now(),
        tags = tags ?? [],
        assert(emotionalWeight >= -1.0 && emotionalWeight <= 1.0,
            'emotionalWeight must be between -1.0 and 1.0');

  /// Cria uma entrada de memória de interação com o usuário
  factory MemoryEntry.interaction({
    required String userInput,
    required String aurynResponse,
    double emotionalWeight = 0.0,
    List<String>? tags,
  }) {
    return MemoryEntry(
      category: 'interaction',
      emotionalWeight: emotionalWeight,
      content: {
        'user_input': userInput,
        'auryn_response': aurynResponse,
      },
      tags: tags,
    );
  }

  /// Cria uma entrada de memória emocional
  factory MemoryEntry.emotion({
    required String mood,
    required int intensity,
    Map<String, dynamic>? additionalData,
    List<String>? tags,
  }) {
    return MemoryEntry(
      category: 'emotion',
      emotionalWeight: intensity / 3.0, // Normaliza intensidade para peso
      content: {
        'mood': mood,
        'intensity': intensity,
        ...?additionalData,
      },
      tags: tags,
    );
  }

  /// Cria uma entrada de memória de aprendizado
  factory MemoryEntry.learning({
    required String topic,
    required String insight,
    double emotionalWeight = 0.0,
    List<String>? tags,
  }) {
    return MemoryEntry(
      category: 'learning',
      emotionalWeight: emotionalWeight,
      content: {
        'topic': topic,
        'insight': insight,
      },
      tags: tags,
    );
  }

  /// Verifica se a memória está expirada
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  /// Verifica se a memória tem peso emocional positivo
  bool get isPositive => emotionalWeight > 0.0;

  /// Verifica se a memória tem peso emocional negativo
  bool get isNegative => emotionalWeight < 0.0;

  /// Verifica se a memória é neutra
  bool get isNeutral => emotionalWeight == 0.0;

  /// Retorna a idade da memória em dias
  int get ageInDays {
    return DateTime.now().difference(timestamp).inDays;
  }

  /// Cria uma cópia da entrada com incremento de accessCount
  MemoryEntry incrementAccess() {
    return copyWith(
      accessCount: accessCount + 1,
      lastUpdated: DateTime.now(),
    );
  }

  /// Adiciona tags à entrada
  MemoryEntry addTags(List<String> newTags) {
    final updatedTags = [...tags, ...newTags];
    return copyWith(tags: updatedTags);
  }

  /// Remove tags da entrada
  MemoryEntry removeTags(List<String> tagsToRemove) {
    final updatedTags = tags.where((tag) => !tagsToRemove.contains(tag)).toList();
    return copyWith(tags: updatedTags);
  }

  /// Cria uma cópia da entrada com campos opcionalmente modificados
  MemoryEntry copyWith({
    String? id,
    DateTime? timestamp,
    String? category,
    double? emotionalWeight,
    Map<String, dynamic>? content,
    List<String>? tags,
    DateTime? lastUpdated,
    int? accessCount,
    DateTime? expiresAt,
  }) {
    return MemoryEntry(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      category: category ?? this.category,
      emotionalWeight: emotionalWeight ?? this.emotionalWeight,
      content: content ?? Map.from(this.content),
      tags: tags ?? List.from(this.tags),
      lastUpdated: lastUpdated ?? this.lastUpdated,
      accessCount: accessCount ?? this.accessCount,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }

  /// Serializa para Map (para persistência)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'category': category,
      'emotional_weight': emotionalWeight,
      'content': content,
      'tags': tags,
      'last_updated': lastUpdated?.toIso8601String(),
      'access_count': accessCount,
      'expires_at': expiresAt?.toIso8601String(),
    };
  }

  /// Deserializa de Map
  factory MemoryEntry.fromMap(Map<String, dynamic> map) {
    return MemoryEntry(
      id: map['id'] as String,
      timestamp: DateTime.parse(map['timestamp'] as String),
      category: map['category'] as String,
      emotionalWeight: (map['emotional_weight'] as num).toDouble(),
      content: Map<String, dynamic>.from(map['content'] as Map),
      tags: List<String>.from(map['tags'] as List),
      lastUpdated: map['last_updated'] != null
          ? DateTime.parse(map['last_updated'] as String)
          : null,
      accessCount: map['access_count'] as int? ?? 0,
      expiresAt: map['expires_at'] != null
          ? DateTime.parse(map['expires_at'] as String)
          : null,
    );
  }

  @override
  String toString() {
    return 'MemoryEntry(id: $id, category: $category, '
        'emotionalWeight: $emotionalWeight, tags: $tags, '
        'ageInDays: $ageInDays)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MemoryEntry &&
        other.id == id &&
        other.timestamp == timestamp &&
        other.category == category;
  }

  @override
  int get hashCode {
    return id.hashCode ^ timestamp.hashCode ^ category.hashCode;
  }
}
