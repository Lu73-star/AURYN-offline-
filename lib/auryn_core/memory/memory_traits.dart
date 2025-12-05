/// lib/auryn_core/memory/memory_traits.dart
/// MemoryTraits - Adaptação persistente de personalidade via memória.
///
/// Rastreia traços de personalidade que emergem das interações
/// armazenadas na memória, permitindo adaptação sutil ao longo do tempo.

import 'package:auryn_offline/auryn_core/memory/memory_entry.dart';
import 'package:auryn_offline/auryn_core/memory/memory_scope.dart';

/// {@template personality_trait}
/// Representa um traço de personalidade com score.
/// {@endtemplate}
class PersonalityTrait {
  /// Nome do traço
  final String name;

  /// Score do traço (0.0 a 1.0)
  final double score;

  /// Timestamp da última atualização
  final DateTime lastUpdated;

  /// Contador de amostras que influenciaram este traço
  final int sampleCount;

  const PersonalityTrait({
    required this.name,
    required this.score,
    DateTime? lastUpdated,
    this.sampleCount = 0,
  }) : lastUpdated = lastUpdated ?? const DateTime(0),
       assert(score >= 0.0 && score <= 1.0, 'score must be between 0.0 and 1.0');

  /// Cria um traço com score 0.5 (neutro)
  factory PersonalityTrait.neutral(String name) {
    return PersonalityTrait(name: name, score: 0.5);
  }

  /// Atualiza o score com uma nova amostra (média móvel ponderada)
  PersonalityTrait updateScore(double newSample, {double weight = 0.1}) {
    assert(newSample >= 0.0 && newSample <= 1.0);
    assert(weight > 0.0 && weight <= 1.0);

    // Média móvel: novo_score = (1-weight) * score_atual + weight * nova_amostra
    final updatedScore = (1.0 - weight) * score + weight * newSample;

    return PersonalityTrait(
      name: name,
      score: updatedScore.clamp(0.0, 1.0),
      lastUpdated: DateTime.now(),
      sampleCount: sampleCount + 1,
    );
  }

  /// Serializa para Map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'score': score,
      'last_updated': lastUpdated.toIso8601String(),
      'sample_count': sampleCount,
    };
  }

  /// Deserializa de Map
  factory PersonalityTrait.fromMap(Map<String, dynamic> map) {
    return PersonalityTrait(
      name: map['name'] as String,
      score: (map['score'] as num).toDouble(),
      lastUpdated: DateTime.parse(map['last_updated'] as String),
      sampleCount: map['sample_count'] as int? ?? 0,
    );
  }

  @override
  String toString() {
    return 'PersonalityTrait($name: ${score.toStringAsFixed(2)}, '
        'samples: $sampleCount)';
  }
}

/// {@template memory_traits}
/// Sistema de traços de personalidade baseado em memória.
/// {@endtemplate}
class MemoryTraits {
  /// Mapa de traços de personalidade
  final Map<String, PersonalityTrait> _traits = {};

  /// Taxa de aprendizado (quão rápido os traços se adaptam)
  final double learningRate;

  /// Construtor
  MemoryTraits({this.learningRate = 0.1})
      : assert(learningRate > 0.0 && learningRate <= 1.0);

  /// Inicializa com traços padrão
  factory MemoryTraits.withDefaults({double learningRate = 0.1}) {
    final traits = MemoryTraits(learningRate: learningRate);

    // Traços baseados no Big Five + extras
    traits._traits['openness'] = PersonalityTrait.neutral('openness');
    traits._traits['conscientiousness'] =
        PersonalityTrait.neutral('conscientiousness');
    traits._traits['extraversion'] = PersonalityTrait.neutral('extraversion');
    traits._traits['agreeableness'] = PersonalityTrait.neutral('agreeableness');
    traits._traits['emotional_stability'] =
        PersonalityTrait.neutral('emotional_stability');
    traits._traits['warmth'] = PersonalityTrait.neutral('warmth');
    traits._traits['curiosity'] = PersonalityTrait.neutral('curiosity');
    traits._traits['playfulness'] = PersonalityTrait.neutral('playfulness');

    return traits;
  }

  /// Obtém um traço
  PersonalityTrait? getTrait(String name) {
    return _traits[name];
  }

  /// Obtém score de um traço
  double getScore(String name) {
    return _traits[name]?.score ?? 0.5;
  }

  /// Define ou atualiza um traço
  void setTrait(PersonalityTrait trait) {
    _traits[trait.name] = trait;
  }

  /// Atualiza score de um traço
  void updateTrait(String name, double newSample) {
    final current = _traits[name] ?? PersonalityTrait.neutral(name);
    _traits[name] = current.updateScore(newSample, weight: learningRate);
  }

  /// Analisa uma memória e atualiza traços relevantes
  void learnFromMemory(MemoryEntry memory) {
    // Análise baseada em peso emocional
    if (memory.emotionalWeight != 0.0) {
      // Memórias emocionais indicam estabilidade emocional
      final stability = 0.5 - (memory.emotionalWeight.abs() * 0.5);
      updateTrait('emotional_stability', stability);
    }

    // Análise baseada em categoria
    switch (memory.category) {
      case 'learning':
        // Memórias de aprendizado aumentam abertura e curiosidade
        updateTrait('openness', 0.6 + (memory.emotionalWeight * 0.2));
        updateTrait('curiosity', 0.6 + (memory.emotionalWeight * 0.2));
        break;

      case 'interaction':
        // Interações indicam extroversão
        updateTrait('extraversion', 0.55);
        // Interações positivas aumentam agreeableness e warmth
        if (memory.isPositive) {
          updateTrait('agreeableness', 0.6 + (memory.emotionalWeight * 0.2));
          updateTrait('warmth', 0.6 + (memory.emotionalWeight * 0.2));
        }
        break;

      case 'emotion':
        // Memórias emocionais afetam vários traços
        final content = memory.content;
        final mood = content['mood'] as String?;

        if (mood == 'happy' || mood == 'playful') {
          updateTrait('playfulness', 0.6);
          updateTrait('emotional_stability', 0.55);
        } else if (mood == 'calm' || mood == 'focused') {
          updateTrait('conscientiousness', 0.6);
          updateTrait('emotional_stability', 0.65);
        }
        break;
    }

    // Análise baseada em tags
    if (memory.tags.contains('curious') || memory.tags.contains('question')) {
      updateTrait('curiosity', 0.6);
      updateTrait('openness', 0.6);
    }

    if (memory.tags.contains('supportive') || memory.tags.contains('empathy')) {
      updateTrait('agreeableness', 0.65);
      updateTrait('warmth', 0.65);
    }

    if (memory.tags.contains('playful') || memory.tags.contains('humor')) {
      updateTrait('playfulness', 0.65);
    }
  }

  /// Analisa múltiplas memórias
  void learnFromMemories(List<MemoryEntry> memories) {
    for (final memory in memories) {
      learnFromMemory(memory);
    }
  }

  /// Obtém todos os traços
  Map<String, PersonalityTrait> getAllTraits() {
    return Map.from(_traits);
  }

  /// Obtém traços dominantes (score > 0.6)
  Map<String, PersonalityTrait> getDominantTraits() {
    return Map.fromEntries(
      _traits.entries.where((entry) => entry.value.score > 0.6),
    );
  }

  /// Obtém traços fracos (score < 0.4)
  Map<String, PersonalityTrait> getWeakTraits() {
    return Map.fromEntries(
      _traits.entries.where((entry) => entry.value.score < 0.4),
    );
  }

  /// Obtém traços ordenados por score
  List<PersonalityTrait> getTraitsSortedByScore({bool descending = true}) {
    final traits = _traits.values.toList();
    traits.sort((a, b) {
      final comparison = a.score.compareTo(b.score);
      return descending ? -comparison : comparison;
    });
    return traits;
  }

  /// Reseta todos os traços para neutro
  void reset() {
    for (final name in _traits.keys) {
      _traits[name] = PersonalityTrait.neutral(name);
    }
  }

  /// Reseta um traço específico
  void resetTrait(String name) {
    if (_traits.containsKey(name)) {
      _traits[name] = PersonalityTrait.neutral(name);
    }
  }

  /// Serializa para Map
  Map<String, dynamic> toMap() {
    return {
      'learning_rate': learningRate,
      'traits': _traits.map((key, value) => MapEntry(key, value.toMap())),
    };
  }

  /// Deserializa de Map
  factory MemoryTraits.fromMap(Map<String, dynamic> map) {
    final traits = MemoryTraits(
      learningRate: (map['learning_rate'] as num?)?.toDouble() ?? 0.1,
    );

    final traitsMap = map['traits'] as Map<String, dynamic>? ?? {};
    for (final entry in traitsMap.entries) {
      final trait = PersonalityTrait.fromMap(
          Map<String, dynamic>.from(entry.value as Map));
      traits._traits[entry.key] = trait;
    }

    return traits;
  }

  /// Estatísticas dos traços
  Map<String, dynamic> getStatistics() {
    if (_traits.isEmpty) {
      return {
        'total_traits': 0,
        'average_score': 0.5,
        'dominant_count': 0,
        'weak_count': 0,
      };
    }

    final scores = _traits.values.map((t) => t.score).toList();
    final avgScore = scores.reduce((a, b) => a + b) / scores.length;

    final dominant = getDominantTraits().length;
    final weak = getWeakTraits().length;

    return {
      'total_traits': _traits.length,
      'average_score': avgScore,
      'dominant_count': dominant,
      'weak_count': weak,
      'learning_rate': learningRate,
    };
  }

  /// Gera descrição textual da personalidade
  String getPersonalityDescription() {
    final dominant = getDominantTraits();

    if (dominant.isEmpty) {
      return 'Personalidade equilibrada e neutra.';
    }

    final traitNames = dominant.keys.toList()..sort();
    final descriptions = <String>[];

    for (final name in traitNames) {
      final score = dominant[name]!.score;
      final intensity = score > 0.75
          ? 'muito'
          : score > 0.65
              ? 'bastante'
              : '';

      final traitDesc = _getTraitDescription(name, intensity);
      if (traitDesc != null) {
        descriptions.add(traitDesc);
      }
    }

    if (descriptions.isEmpty) {
      return 'Personalidade em desenvolvimento.';
    }

    return descriptions.join(', ') + '.';
  }

  String? _getTraitDescription(String trait, String intensity) {
    final prefix = intensity.isEmpty ? '' : '$intensity ';

    switch (trait) {
      case 'openness':
        return '${prefix}aberta a novas ideias';
      case 'conscientiousness':
        return '${prefix}conscienciosa e organizada';
      case 'extraversion':
        return '${prefix}extrovertida';
      case 'agreeableness':
        return '${prefix}amigável e cooperativa';
      case 'emotional_stability':
        return '${prefix}emocionalmente estável';
      case 'warmth':
        return '${prefix}calorosa e acolhedora';
      case 'curiosity':
        return '${prefix}curiosa';
      case 'playfulness':
        return '${prefix}brincalhona';
      default:
        return null;
    }
  }

  @override
  String toString() {
    return 'MemoryTraits(traits: ${_traits.length}, '
        'learningRate: $learningRate)';
  }
}
