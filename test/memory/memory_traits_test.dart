/// test/memory/memory_traits_test.dart
/// Testes unitários para MemoryTraits - adaptação de personalidade.

import 'package:flutter_test/flutter_test.dart';
import 'package:auryn_offline/auryn_core/memory/memory_traits.dart';
import 'package:auryn_offline/auryn_core/memory/memory_entry.dart';

void main() {
  group('PersonalityTrait', () {
    test('deve criar traço neutro', () {
      final trait = PersonalityTrait.neutral('openness');

      expect(trait.name, equals('openness'));
      expect(trait.score, equals(0.5));
      expect(trait.sampleCount, equals(0));
    });

    test('deve criar traço com score customizado', () {
      final trait = PersonalityTrait(
        name: 'curiosity',
        score: 0.7,
      );

      expect(trait.name, equals('curiosity'));
      expect(trait.score, equals(0.7));
    });

    test('deve lançar assertion para score fora do range', () {
      expect(
        () => PersonalityTrait(name: 'test', score: 1.5),
        throwsA(isA<AssertionError>()),
      );

      expect(
        () => PersonalityTrait(name: 'test', score: -0.5),
        throwsA(isA<AssertionError>()),
      );
    });

    test('deve atualizar score com média móvel', () {
      final trait = PersonalityTrait.neutral('openness');
      expect(trait.score, equals(0.5));

      final updated = trait.updateScore(0.8, weight: 0.2);

      // novo_score = (1-0.2) * 0.5 + 0.2 * 0.8 = 0.56
      expect(updated.score, closeTo(0.56, 0.01));
      expect(updated.sampleCount, equals(1));
    });

    test('deve clampar score entre 0.0 e 1.0', () {
      final trait = PersonalityTrait(name: 'test', score: 0.9);

      // Atualiza com valor alto múltiplas vezes
      var updated = trait;
      for (int i = 0; i < 10; i++) {
        updated = updated.updateScore(1.0, weight: 0.5);
      }

      expect(updated.score, lessThanOrEqualTo(1.0));
      expect(updated.score, greaterThan(0.9));
    });

    test('deve serializar e deserializar', () {
      final trait = PersonalityTrait(
        name: 'openness',
        score: 0.7,
        lastUpdated: DateTime.now(),
        sampleCount: 5,
      );

      final map = trait.toMap();
      final restored = PersonalityTrait.fromMap(map);

      expect(restored.name, equals(trait.name));
      expect(restored.score, equals(trait.score));
      expect(restored.sampleCount, equals(trait.sampleCount));
    });

    test('deve ter toString informativo', () {
      final trait = PersonalityTrait(
        name: 'openness',
        score: 0.75,
        sampleCount: 10,
      );

      final str = trait.toString();
      expect(str, contains('openness'));
      expect(str, contains('0.75'));
      expect(str, contains('10'));
    });
  });

  group('MemoryTraits', () {
    late MemoryTraits traits;

    setUp(() {
      traits = MemoryTraits.withDefaults(learningRate: 0.2);
    });

    test('deve criar com traços padrão', () {
      final allTraits = traits.getAllTraits();

      expect(allTraits['openness'], isNotNull);
      expect(allTraits['conscientiousness'], isNotNull);
      expect(allTraits['extraversion'], isNotNull);
      expect(allTraits['agreeableness'], isNotNull);
      expect(allTraits['emotional_stability'], isNotNull);
      expect(allTraits['warmth'], isNotNull);
      expect(allTraits['curiosity'], isNotNull);
      expect(allTraits['playfulness'], isNotNull);
    });

    test('deve obter traço', () {
      final openness = traits.getTrait('openness');

      expect(openness, isNotNull);
      expect(openness!.name, equals('openness'));
    });

    test('deve obter score de traço', () {
      final score = traits.getScore('openness');
      expect(score, equals(0.5)); // Neutro inicialmente
    });

    test('deve retornar 0.5 para traço inexistente', () {
      final score = traits.getScore('non_existent');
      expect(score, equals(0.5));
    });

    test('deve atualizar traço', () {
      traits.updateTrait('openness', 0.8);

      final score = traits.getScore('openness');
      expect(score, greaterThan(0.5));
    });

    test('deve aprender de memória de interação positiva', () {
      final memory = MemoryEntry.interaction(
        userInput: 'Olá!',
        aurynResponse: 'Olá! Como vai?',
        emotionalWeight: 0.6,
        tags: ['greeting'],
      );

      traits.learnFromMemory(memory);

      // Interações aumentam extroversão
      final extraversion = traits.getScore('extraversion');
      expect(extraversion, greaterThan(0.5));

      // Positivas aumentam agreeableness e warmth
      final agreeableness = traits.getScore('agreeableness');
      final warmth = traits.getScore('warmth');
      expect(agreeableness, greaterThan(0.5));
      expect(warmth, greaterThan(0.5));
    });

    test('deve aprender de memória de aprendizado', () {
      final memory = MemoryEntry.learning(
        topic: 'Flutter',
        insight: 'Widgets são imutáveis',
        emotionalWeight: 0.0,
        tags: ['programming'],
      );

      traits.learnFromMemory(memory);

      // Aprendizado aumenta openness e curiosity
      final openness = traits.getScore('openness');
      final curiosity = traits.getScore('curiosity');

      expect(openness, greaterThan(0.5));
      expect(curiosity, greaterThan(0.5));
    });

    test('deve aprender de memória emocional', () {
      final memory = MemoryEntry.emotion(
        mood: 'happy',
        intensity: 2,
        tags: ['positive'],
      );

      traits.learnFromMemory(memory);

      // Emoções felizes aumentam playfulness
      final playfulness = traits.getScore('playfulness');
      expect(playfulness, greaterThan(0.5));
    });

    test('deve aprender de memória com tag curious', () {
      final memory = MemoryEntry.interaction(
        userInput: 'Como funciona?',
        aurynResponse: 'Deixe-me explicar...',
        tags: ['curious', 'question'],
      );

      traits.learnFromMemory(memory);

      final curiosity = traits.getScore('curiosity');
      final openness = traits.getScore('openness');

      expect(curiosity, greaterThan(0.5));
      expect(openness, greaterThan(0.5));
    });

    test('deve aprender de memória com tag supportive', () {
      final memory = MemoryEntry.interaction(
        userInput: 'Preciso de ajuda',
        aurynResponse: 'Estou aqui para ajudar',
        tags: ['supportive', 'empathy'],
      );

      traits.learnFromMemory(memory);

      final agreeableness = traits.getScore('agreeableness');
      final warmth = traits.getScore('warmth');

      expect(agreeableness, greaterThan(0.5));
      expect(warmth, greaterThan(0.5));
    });

    test('deve aprender de memória com tag playful', () {
      final memory = MemoryEntry.interaction(
        userInput: 'Vamos brincar?',
        aurynResponse: 'Sim, vamos!',
        tags: ['playful', 'humor'],
      );

      traits.learnFromMemory(memory);

      final playfulness = traits.getScore('playfulness');
      expect(playfulness, greaterThan(0.5));
    });

    test('deve aprender de múltiplas memórias', () {
      final memories = [
        MemoryEntry.learning(topic: 'Topic 1', insight: 'Insight 1'),
        MemoryEntry.learning(topic: 'Topic 2', insight: 'Insight 2'),
        MemoryEntry.learning(topic: 'Topic 3', insight: 'Insight 3'),
      ];

      traits.learnFromMemories(memories);

      final openness = traits.getScore('openness');
      final curiosity = traits.getScore('curiosity');

      expect(openness, greaterThan(0.5));
      expect(curiosity, greaterThan(0.5));
    });

    test('deve obter traços dominantes', () {
      // Adiciona múltiplas memórias de aprendizado
      for (int i = 0; i < 5; i++) {
        traits.learnFromMemory(MemoryEntry.learning(
          topic: 'Topic $i',
          insight: 'Insight $i',
        ));
      }

      final dominant = traits.getDominantTraits();

      // Deve ter traços dominantes (score > 0.6)
      expect(dominant.isNotEmpty, isTrue);
      for (final trait in dominant.values) {
        expect(trait.score, greaterThan(0.6));
      }
    });

    test('deve obter traços fracos', () {
      // Atualiza um traço para fraco
      for (int i = 0; i < 5; i++) {
        traits.updateTrait('emotional_stability', 0.1);
      }

      final weak = traits.getWeakTraits();

      expect(weak.isNotEmpty, isTrue);
      for (final trait in weak.values) {
        expect(trait.score, lessThan(0.4));
      }
    });

    test('deve obter traços ordenados por score', () {
      // Atualiza alguns traços
      traits.updateTrait('openness', 0.9);
      traits.updateTrait('curiosity', 0.7);
      traits.updateTrait('playfulness', 0.3);

      final sorted = traits.getTraitsSortedByScore(descending: true);

      expect(sorted.isNotEmpty, isTrue);
      // Deve estar em ordem decrescente
      for (int i = 0; i < sorted.length - 1; i++) {
        expect(sorted[i].score, greaterThanOrEqualTo(sorted[i + 1].score));
      }
    });

    test('deve obter traços ordenados ascendente', () {
      traits.updateTrait('openness', 0.9);
      traits.updateTrait('playfulness', 0.3);

      final sorted = traits.getTraitsSortedByScore(descending: false);

      // Deve estar em ordem crescente
      for (int i = 0; i < sorted.length - 1; i++) {
        expect(sorted[i].score, lessThanOrEqualTo(sorted[i + 1].score));
      }
    });

    test('deve resetar todos os traços', () {
      // Atualiza alguns traços
      traits.updateTrait('openness', 0.9);
      traits.updateTrait('curiosity', 0.7);

      expect(traits.getScore('openness'), greaterThan(0.5));

      traits.reset();

      expect(traits.getScore('openness'), equals(0.5));
      expect(traits.getScore('curiosity'), equals(0.5));
    });

    test('deve resetar traço específico', () {
      traits.updateTrait('openness', 0.9);
      expect(traits.getScore('openness'), greaterThan(0.5));

      traits.resetTrait('openness');
      expect(traits.getScore('openness'), equals(0.5));
    });

    test('deve serializar e deserializar', () {
      traits.updateTrait('openness', 0.7);
      traits.updateTrait('curiosity', 0.8);

      final map = traits.toMap();
      final restored = MemoryTraits.fromMap(map);

      expect(restored.getScore('openness'), closeTo(0.7, 0.1));
      expect(restored.getScore('curiosity'), closeTo(0.8, 0.1));
      expect(restored.learningRate, equals(traits.learningRate));
    });

    test('deve obter estatísticas', () {
      traits.updateTrait('openness', 0.9);
      traits.updateTrait('curiosity', 0.7);
      traits.updateTrait('playfulness', 0.3);

      final stats = traits.getStatistics();

      expect(stats['total_traits'], greaterThan(0));
      expect(stats['average_score'], isNotNull);
      expect(stats['dominant_count'], greaterThan(0));
      expect(stats['learning_rate'], equals(0.2));
    });

    test('deve gerar descrição de personalidade', () {
      // Aumenta alguns traços
      for (int i = 0; i < 5; i++) {
        traits.updateTrait('openness', 0.8);
        traits.updateTrait('curiosity', 0.8);
      }

      final description = traits.getPersonalityDescription();

      expect(description, isNotEmpty);
      expect(description, isNot(equals('Personalidade equilibrada e neutra.')));
    });

    test('deve gerar descrição neutra quando sem traços dominantes', () {
      final description = traits.getPersonalityDescription();
      expect(description, equals('Personalidade equilibrada e neutra.'));
    });

    test('deve gerar descrição com intensidades', () {
      // Cria traços com diferentes intensidades
      for (int i = 0; i < 3; i++) {
        traits.updateTrait('openness', 0.95); // Muito alto (>0.75)
      }

      for (int i = 0; i < 3; i++) {
        traits.updateTrait('curiosity', 0.7); // Alto (0.65-0.75)
      }

      final description = traits.getPersonalityDescription();

      expect(description, contains('aberta'));
      expect(description, contains('curiosa'));
    });

    test('deve ter toString informativo', () {
      final str = traits.toString();

      expect(str, contains('MemoryTraits'));
      expect(str, contains('learningRate'));
    });

    test('deve lidar com learning rate customizado', () {
      final customTraits = MemoryTraits.withDefaults(learningRate: 0.5);

      customTraits.updateTrait('openness', 0.8);

      // Com learning rate maior, deve mudar mais rapidamente
      final score = customTraits.getScore('openness');
      expect(score, greaterThan(0.6)); // Mudança mais significativa
    });

    test('deve adaptar estabilidade emocional baseado em peso', () {
      // Memória com alto peso emocional negativo
      final negative = MemoryEntry.interaction(
        userInput: 'Test',
        aurynResponse: 'Response',
        emotionalWeight: -0.8,
      );

      traits.learnFromMemory(negative);

      // Deve diminuir estabilidade emocional
      final stability = traits.getScore('emotional_stability');
      expect(stability, lessThan(0.5));
    });

    test('deve adaptar múltiplos traços de uma vez', () {
      final supportive = MemoryEntry.interaction(
        userInput: 'Preciso de apoio',
        aurynResponse: 'Estou aqui',
        emotionalWeight: 0.6,
        tags: ['supportive', 'empathy'],
      );

      final initialAgreeableness = traits.getScore('agreeableness');
      final initialWarmth = traits.getScore('warmth');
      final initialExtraversion = traits.getScore('extraversion');

      traits.learnFromMemory(supportive);

      // Múltiplos traços devem ter mudado
      expect(traits.getScore('agreeableness'), greaterThan(initialAgreeableness));
      expect(traits.getScore('warmth'), greaterThan(initialWarmth));
      expect(traits.getScore('extraversion'), greaterThan(initialExtraversion));
    });

    test('deve manter traços dentro do range 0.0-1.0', () {
      // Força atualizações extremas
      for (int i = 0; i < 20; i++) {
        traits.updateTrait('openness', 1.0);
        traits.updateTrait('playfulness', 0.0);
      }

      final allTraits = traits.getAllTraits();

      for (final trait in allTraits.values) {
        expect(trait.score, greaterThanOrEqualTo(0.0));
        expect(trait.score, lessThanOrEqualTo(1.0));
      }
    });
  });
}
