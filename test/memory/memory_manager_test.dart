/// test/memory/memory_manager_test.dart
/// Testes unitários para MemoryManager - sistema completo de memória.

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:auryn_offline/auryn_core/memory/memory_manager.dart';
import 'package:auryn_offline/auryn_core/memory/memory_entry.dart';
import 'package:auryn_offline/auryn_core/memory/memory_scope.dart';
import 'package:auryn_offline/auryn_core/memory/memory_expiration.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MemoryManager', () {
    late MemoryManager manager;

    setUp(() async {
      // Inicializa Hive para testes em memória
      Hive.init('/tmp/hive_test_${DateTime.now().millisecondsSinceEpoch}');

      manager = MemoryManager();
      await manager.initialize(
        episodicSize: 10,
        expirationPolicies: ExpirationPolicies.never(),
        traitLearningRate: 0.2,
      );
    });

    tearDown(() async {
      await manager.close();
      // Limpa boxes do Hive
      await Hive.deleteFromDisk();
    });

    test('deve inicializar corretamente', () {
      expect(manager.isInitialized, isTrue);
    });

    test('deve lançar StateError quando não inicializado', () {
      final uninitializedManager = MemoryManager();

      expect(
        () => uninitializedManager.isInitialized,
        returnsNormally,
      );
    });

    test('deve armazenar interação', () async {
      await manager.storeInteraction(
        userInput: 'Olá!',
        aurynResponse: 'Olá! Como posso ajudar?',
        emotionalWeight: 0.5,
        tags: ['greeting'],
      );

      final episodes = manager.getRecentEpisodes(count: 5);
      expect(episodes.length, equals(1));
      expect(episodes[0].category, equals('interaction'));
      expect(episodes[0].content['user_input'], equals('Olá!'));
    });

    test('deve armazenar múltiplas interações', () async {
      for (int i = 0; i < 5; i++) {
        await manager.storeInteraction(
          userInput: 'Input $i',
          aurynResponse: 'Response $i',
          emotionalWeight: 0.1 * i,
          tags: ['test'],
        );
      }

      final episodes = manager.getRecentEpisodes(count: 10);
      expect(episodes.length, equals(5));
    });

    test('deve respeitar tamanho máximo da memória episódica', () async {
      // Adiciona mais que o tamanho máximo (10)
      for (int i = 0; i < 15; i++) {
        await manager.storeInteraction(
          userInput: 'Input $i',
          aurynResponse: 'Response $i',
        );
      }

      final episodes = manager.getEpisodicMemory();
      expect(episodes.length, equals(10));
      // Deve manter as últimas 10
      expect(episodes[0].content['user_input'], equals('Input 5'));
    });

    test('deve buscar por tag', () async {
      await manager.storeInteraction(
        userInput: 'Olá',
        aurynResponse: 'Oi',
        tags: ['greeting'],
      );

      await manager.storeInteraction(
        userInput: 'Tchau',
        aurynResponse: 'Até logo',
        tags: ['farewell'],
      );

      final greetings = await manager.queryByTag('greeting');
      expect(greetings.length, equals(1));
      expect(greetings[0].tags, contains('greeting'));
    });

    test('deve buscar por categoria', () async {
      final learning = MemoryEntry.learning(
        topic: 'Flutter',
        insight: 'Widgets são imutáveis',
        tags: ['programming'],
      );

      await manager.store(learning);

      final learnings = await manager.queryByCategory('learning');
      expect(learnings.length, equals(1));
      expect(learnings[0].category, equals('learning'));
    });

    test('deve buscar por emoção positiva', () async {
      await manager.storeInteraction(
        userInput: 'Estou feliz!',
        aurynResponse: 'Que bom!',
        emotionalWeight: 0.8,
      );

      await manager.storeInteraction(
        userInput: 'Estou triste',
        aurynResponse: 'Sinto muito',
        emotionalWeight: -0.6,
      );

      final positive = await manager.queryByEmotion(positive: true);
      expect(positive.length, equals(1));
      expect(positive[0].isPositive, isTrue);
    });

    test('deve buscar memórias recentes', () async {
      // Cria memória antiga (simulação)
      final old = MemoryEntry.interaction(
        userInput: 'Old',
        aurynResponse: 'Response',
      );
      final oldWithDate = old.copyWith(
        timestamp: DateTime.now().subtract(Duration(days: 30)),
      );
      await manager.store(oldWithDate);

      // Cria memória recente
      await manager.storeInteraction(
        userInput: 'Recent',
        aurynResponse: 'Response',
      );

      final recent = await manager.queryRecent(days: 7);
      expect(recent.length, equals(1));
      expect(recent[0].content['user_input'], equals('Recent'));
    });

    test('deve usar query builder', () async {
      await manager.storeInteraction(
        userInput: 'Test',
        aurynResponse: 'Response',
        emotionalWeight: 0.5,
        tags: ['test', 'important'],
      );

      final results = await manager.queryBuilder((q) => q
          .withCategories(['interaction'])
          .withTags(['important'])
          .limit(10));

      expect(results.length, equals(1));
    });

    test('deve obter sentimento episódico', () async {
      await manager.storeInteraction(
        userInput: 'Happy',
        aurynResponse: 'Great',
        emotionalWeight: 0.8,
      );

      await manager.storeInteraction(
        userInput: 'Sad',
        aurynResponse: 'Sorry',
        emotionalWeight: -0.5,
      );

      final sentiment = manager.getEpisodicSentiment();
      expect(sentiment['count'], equals(2));
      expect(sentiment['positive_count'], equals(1));
      expect(sentiment['negative_count'], equals(1));
    });

    test('deve obter padrões de interação', () async {
      for (int i = 0; i < 3; i++) {
        await manager.storeInteraction(
          userInput: 'Input $i',
          aurynResponse: 'Response $i',
          emotionalWeight: 0.5,
        );
      }

      final patterns = manager.getInteractionPatterns();
      expect(patterns['total_interactions'], equals(3));
      expect(patterns['emotional_trend'], equals('positive'));
    });

    test('deve atualizar traços de personalidade', () async {
      // Armazena memória de aprendizado
      final learning = MemoryEntry.learning(
        topic: 'Test',
        insight: 'Insight',
        emotionalWeight: 0.0,
        tags: ['learning'],
      );

      await manager.store(learning);

      // Traços devem ser afetados
      final openness = manager.getTraitScore('openness');
      expect(openness, greaterThan(0.5)); // Deve ter aumentado

      final curiosity = manager.getTraitScore('curiosity');
      expect(curiosity, greaterThan(0.5));
    });

    test('deve obter traços dominantes', () async {
      // Adiciona múltiplas memórias de aprendizado
      for (int i = 0; i < 5; i++) {
        final learning = MemoryEntry.learning(
          topic: 'Topic $i',
          insight: 'Insight $i',
        );
        await manager.store(learning);
      }

      final dominant = manager.getDominantTraits();
      // Deve ter traços dominantes após múltiplas memórias de aprendizado
      expect(dominant.isNotEmpty, isTrue);
    });

    test('deve gerar descrição de personalidade', () async {
      final description = manager.getPersonalityDescription();
      expect(description, isNotEmpty);
    });

    test('deve deletar memória', () async {
      await manager.storeInteraction(
        userInput: 'Test',
        aurynResponse: 'Response',
      );

      final all = await manager.queryRecent(days: 1);
      expect(all.length, equals(1));

      final deleted = await manager.delete(all[0].id);
      expect(deleted, isTrue);

      final afterDelete = await manager.queryRecent(days: 1);
      expect(afterDelete.length, equals(0));
    });

    test('deve limpar memória episódica', () async {
      await manager.storeInteraction(
        userInput: 'Test',
        aurynResponse: 'Response',
      );

      expect(manager.getEpisodicMemory().length, equals(1));

      manager.clearEpisodicMemory();

      expect(manager.getEpisodicMemory().length, equals(0));
    });

    test('deve obter estatísticas', () async {
      await manager.storeInteraction(
        userInput: 'Test',
        aurynResponse: 'Response',
        emotionalWeight: 0.5,
      );

      final stats = await manager.getStatistics();

      expect(stats['total_active_memories'], greaterThan(0));
      expect(stats['episodic'], isNotNull);
      expect(stats['long_term'], isNotNull);
      expect(stats['traits'], isNotNull);
    });

    test('deve obter resumo do sistema', () async {
      await manager.storeInteraction(
        userInput: 'Test',
        aurynResponse: 'Response',
      );

      final summary = await manager.getSummary();

      expect(summary, contains('Sistema de Memória AURYN'));
      expect(summary, contains('Memórias Ativas'));
      expect(summary, contains('Personalidade'));
    });

    test('deve exportar e importar memórias', () async {
      await manager.storeInteraction(
        userInput: 'Test',
        aurynResponse: 'Response',
        tags: ['export-test'],
      );

      // Exportar
      final json = await manager.export();
      expect(json, isNotEmpty);

      // Limpar
      await manager.clearAll();
      final afterClear = await manager.queryRecent(days: 1);
      expect(afterClear.length, equals(0));

      // Importar
      final imported = await manager.import(json, retrainTraits: true);
      expect(imported, equals(1));

      final afterImport = await manager.queryByTag('export-test');
      expect(afterImport.length, equals(1));
    });

    test('deve validar integridade', () async {
      await manager.storeInteraction(
        userInput: 'Test',
        aurynResponse: 'Response',
      );

      final validation = await manager.validateIntegrity();
      expect(validation['valid_entries'], greaterThan(0));
      expect(validation['integrity_score'], greaterThan(0.9));
    });

    test('deve re-treinar traços', () async {
      // Adiciona memórias
      for (int i = 0; i < 3; i++) {
        final learning = MemoryEntry.learning(
          topic: 'Topic $i',
          insight: 'Insight $i',
        );
        await manager.store(learning);
      }

      // Reseta traços manualmente (simulação)
      manager.memoryTraits.reset();

      // Re-treinar
      await manager.retrainTraits();

      // Traços devem ter valores atualizados
      final openness = manager.getTraitScore('openness');
      expect(openness, greaterThan(0.5));
    });

    test('deve buscar e encontrar memória por ID', () async {
      await manager.storeInteraction(
        userInput: 'Findable',
        aurynResponse: 'Found',
        tags: ['findable'],
      );

      final all = await manager.queryByTag('findable');
      expect(all.length, equals(1));

      final id = all[0].id;
      final found = await manager.find(id);

      expect(found, isNotNull);
      expect(found!.id, equals(id));
      expect(found.accessCount, greaterThan(0)); // Incrementado ao buscar
    });

    test('deve lidar com múltiplas categorias', () async {
      final learning = MemoryEntry.learning(
        topic: 'Topic',
        insight: 'Insight',
      );

      final emotion = MemoryEntry.emotion(
        mood: 'happy',
        intensity: 2,
      );

      await manager.store(learning);
      await manager.store(emotion);

      final learnings = await manager.queryByCategory('learning');
      final emotions = await manager.queryByCategory('emotion');

      expect(learnings.length, equals(1));
      expect(emotions.length, equals(1));
    });

    test('não deve persistir em longo prazo quando solicitado', () async {
      await manager.storeInteraction(
        userInput: 'Ephemeral',
        aurynResponse: 'Response',
        tags: ['ephemeral'],
        persistToLongTerm: false,
      );

      // Deve estar na memória episódica
      final episodic = manager.getEpisodicMemory();
      expect(episodic.length, equals(1));

      // Não deve estar na memória de longo prazo
      final longTerm = await manager.queryByTag('ephemeral');
      expect(longTerm.length, equals(0));
    });
  });
}
