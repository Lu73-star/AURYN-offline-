/// lib/auryn_core/memory/episodic_memory.dart
/// EpisodicMemory - Armazenamento de últimas N interações.
///
/// Gerencia memória episódica (recente) da AURYN, armazenando
/// as últimas interações em uma fila de tamanho limitado.

import 'package:auryn_offline/auryn_core/memory/memory_entry.dart';
import 'package:auryn_offline/auryn_core/memory/memory_scope.dart';

/// {@template episodic_memory}
/// Gerencia memória episódica (recente) da AURYN.
///
/// Mantém as últimas N interações em memória, permitindo acesso
/// rápido ao contexto recente da conversa.
/// {@endtemplate}
class EpisodicMemory {
  /// Tamanho máximo da memória episódica
  final int maxSize;

  /// Lista de entradas episódicas (FIFO)
  final List<MemoryEntry> _episodes = [];

  /// Construtor
  EpisodicMemory({this.maxSize = 50});

  /// Adiciona uma nova entrada episódica
  void add(MemoryEntry entry) {
    _episodes.add(entry);

    // Remove as mais antigas se exceder o tamanho máximo
    while (_episodes.length > maxSize) {
      _episodes.removeAt(0);
    }
  }

  /// Adiciona uma interação
  void addInteraction({
    required String userInput,
    required String aurynResponse,
    double emotionalWeight = 0.0,
    List<String>? tags,
  }) {
    final entry = MemoryEntry.interaction(
      userInput: userInput,
      aurynResponse: aurynResponse,
      emotionalWeight: emotionalWeight,
      tags: tags ?? ['episodic'],
    );

    add(entry);
  }

  /// Obtém todas as entradas episódicas
  List<MemoryEntry> getAll() {
    return List.from(_episodes);
  }

  /// Obtém as últimas N entradas
  List<MemoryEntry> getRecent({int count = 10}) {
    if (_episodes.length <= count) {
      return List.from(_episodes);
    }

    return _episodes.sublist(_episodes.length - count);
  }

  /// Obtém as primeiras N entradas
  List<MemoryEntry> getOldest({int count = 10}) {
    if (_episodes.length <= count) {
      return List.from(_episodes);
    }

    return _episodes.sublist(0, count);
  }

  /// Obtém entradas por categoria
  List<MemoryEntry> getByCategory(String category) {
    return _episodes.where((e) => e.category == category).toList();
  }

  /// Obtém entradas por tag
  List<MemoryEntry> getByTag(String tag) {
    return _episodes.where((e) => e.tags.contains(tag)).toList();
  }

  /// Obtém entradas emocionais (positivas ou negativas)
  List<MemoryEntry> getEmotional({bool? positive}) {
    if (positive == null) {
      return _episodes.where((e) => !e.isNeutral).toList();
    }

    return _episodes
        .where((e) => positive ? e.isPositive : e.isNegative)
        .toList();
  }

  /// Obtém entradas em um período
  List<MemoryEntry> getInPeriod(DateTime start, DateTime end) {
    return _episodes
        .where((e) =>
            (e.timestamp.isAfter(start) || e.timestamp.isAtSameMomentAs(start)) &&
            (e.timestamp.isBefore(end) || e.timestamp.isAtSameMomentAs(end)))
        .toList();
  }

  /// Obtém entradas desde um timestamp
  List<MemoryEntry> getSince(DateTime since) {
    return _episodes
        .where((e) =>
            e.timestamp.isAfter(since) || e.timestamp.isAtSameMomentAs(since))
        .toList();
  }

  /// Busca por conteúdo (simples busca de texto)
  List<MemoryEntry> search(String query) {
    final queryLower = query.toLowerCase();

    return _episodes.where((entry) {
      final contentStr = entry.content.toString().toLowerCase();
      return contentStr.contains(queryLower);
    }).toList();
  }

  /// Obtém resumo de sentimento das últimas N entradas
  Map<String, dynamic> getSentimentSummary({int lastN = 10}) {
    final recent = getRecent(count: lastN);

    if (recent.isEmpty) {
      return {
        'count': 0,
        'average_weight': 0.0,
        'positive_ratio': 0.0,
        'negative_ratio': 0.0,
        'neutral_ratio': 0.0,
      };
    }

    int positiveCount = 0;
    int negativeCount = 0;
    int neutralCount = 0;
    double totalWeight = 0.0;

    for (final entry in recent) {
      totalWeight += entry.emotionalWeight;

      if (entry.isPositive) {
        positiveCount++;
      } else if (entry.isNegative) {
        negativeCount++;
      } else {
        neutralCount++;
      }
    }

    return {
      'count': recent.length,
      'average_weight': totalWeight / recent.length,
      'positive_ratio': positiveCount / recent.length,
      'negative_ratio': negativeCount / recent.length,
      'neutral_ratio': neutralCount / recent.length,
      'positive_count': positiveCount,
      'negative_count': negativeCount,
      'neutral_count': neutralCount,
    };
  }

  /// Obtém padrões de interação recente
  Map<String, dynamic> getInteractionPatterns() {
    final interactions = getByCategory(MemoryCategory.interaction);

    if (interactions.isEmpty) {
      return {
        'total_interactions': 0,
        'average_length': 0.0,
        'emotional_trend': 'neutral',
      };
    }

    // Calcula comprimento médio das interações
    int totalLength = 0;
    for (final interaction in interactions) {
      final userInput = interaction.content['user_input']?.toString() ?? '';
      totalLength += userInput.length;
    }

    final avgLength = totalLength / interactions.length;

    // Analisa tendência emocional
    final recentEmotions = interactions.map((e) => e.emotionalWeight).toList();
    final avgEmotion = recentEmotions.reduce((a, b) => a + b) / recentEmotions.length;

    String trend;
    if (avgEmotion > 0.2) {
      trend = 'positive';
    } else if (avgEmotion < -0.2) {
      trend = 'negative';
    } else {
      trend = 'neutral';
    }

    return {
      'total_interactions': interactions.length,
      'average_length': avgLength,
      'emotional_trend': trend,
      'average_emotion': avgEmotion,
    };
  }

  /// Limpa todas as entradas episódicas
  void clear() {
    _episodes.clear();
  }

  /// Remove entradas antigas (mais antigas que N dias)
  int removeOlderThan(int days) {
    final threshold = DateTime.now().subtract(Duration(days: days));
    final initialSize = _episodes.length;

    _episodes.removeWhere((entry) => entry.timestamp.isBefore(threshold));

    return initialSize - _episodes.length;
  }

  /// Tamanho atual da memória episódica
  int get size => _episodes.length;

  /// Verifica se está vazia
  bool get isEmpty => _episodes.isEmpty;

  /// Verifica se está cheia
  bool get isFull => _episodes.length >= maxSize;

  /// Porcentagem de ocupação
  double get fillPercentage => _episodes.length / maxSize;

  /// Serializa para Map
  Map<String, dynamic> toMap() {
    return {
      'max_size': maxSize,
      'episodes': _episodes.map((e) => e.toMap()).toList(),
    };
  }

  /// Deserializa de Map
  factory EpisodicMemory.fromMap(Map<String, dynamic> map) {
    final memory = EpisodicMemory(maxSize: map['max_size'] as int? ?? 50);

    final episodes = map['episodes'] as List? ?? [];
    for (final episodeData in episodes) {
      final entry = MemoryEntry.fromMap(Map<String, dynamic>.from(episodeData as Map));
      memory._episodes.add(entry);
    }

    return memory;
  }

  /// Estatísticas da memória episódica
  Map<String, dynamic> getStatistics() {
    final byCategory = <String, int>{};
    int positiveCount = 0;
    int negativeCount = 0;
    int neutralCount = 0;
    double totalWeight = 0.0;

    for (final entry in _episodes) {
      byCategory[entry.category] = (byCategory[entry.category] ?? 0) + 1;

      if (entry.isPositive) positiveCount++;
      if (entry.isNegative) negativeCount++;
      if (entry.isNeutral) neutralCount++;

      totalWeight += entry.emotionalWeight;
    }

    return {
      'total_episodes': _episodes.length,
      'max_size': maxSize,
      'fill_percentage': fillPercentage,
      'is_full': isFull,
      'by_category': byCategory,
      'positive_count': positiveCount,
      'negative_count': negativeCount,
      'neutral_count': neutralCount,
      'average_weight': _episodes.isEmpty ? 0.0 : totalWeight / _episodes.length,
    };
  }

  @override
  String toString() {
    return 'EpisodicMemory(size: $_episodes.length/$maxSize, '
        'fillPercentage: ${(fillPercentage * 100).toStringAsFixed(1)}%)';
  }
}
