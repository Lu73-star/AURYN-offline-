/// test/memory/long_term_memory_test.dart
/// Testes unitários para LongTermMemory - armazenamento persistente.

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:auryn_offline/auryn_core/memory/long_term_memory.dart';
import 'package:auryn_offline/auryn_core/memory/memory_entry.dart';
import 'package:auryn_offline/auryn_core/memory/memory_scope.dart';
import 'package:auryn_offline/auryn_core/memory/memory_expiration.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LongTermMemory', () {
    late LongTermMemory longTerm;

    setUp(() async {
      // Inicializa Hive para testes
      Hive.init('/tmp/hive_test_ltm_${DateTime.now().millisecondsSinceEpoch}');

      longTerm = LongTermMemory(
        expiration: MemoryExpiration(configs: ExpirationPolicies.never()),
      );
      await longTerm.initialize();
    });

    tearDown(() async {
      await longTerm.close();
      await Hive.deleteFromDisk();
    });

    test('deve inicializar corretamente', () {
      expect(longTerm.isInitialized, isTrue);
    });

    test('deve salvar e recuperar memória', () async {
      final entry = MemoryEntry.interaction(
        userInput: 'Test',
        aurynResponse: 'Response',
      );

      await longTerm.save(entry);

      final found = await longTerm.find(entry.id);
      expect(found, isNotNull);
      expect(found!.id, equals(entry.id));
    });

    test('deve salvar múltiplas memórias', () async {
      final entries = [
        MemoryEntry.interaction(
          userInput: 'Test 1',
          aurynResponse: 'Response 1',
        ),
        MemoryEntry.interaction(
          userInput: 'Test 2',
          aurynResponse: 'Response 2',
        ),
        MemoryEntry.interaction(
          userInput: 'Test 3',
          aurynResponse: 'Response 3',
        ),
      ];

      await longTerm.saveMany(entries);

      final count = await longTerm.count();
      expect(count, equals(3));
    });

    test('deve deletar memória', () async {
      final entry = MemoryEntry.interaction(
        userInput: 'To Delete',
        aurynResponse: 'Response',
      );

      await longTerm.save(entry);

      final deleted = await longTerm.delete(entry.id);
      expect(deleted, isTrue);

      final found = await longTerm.find(entry.id);
      expect(found, isNull);
    });

    test('deve deletar múltiplas memórias', () async {
      final entries = [
        MemoryEntry.interaction(userInput: 'Test 1', aurynResponse: 'R1'),
        MemoryEntry.interaction(userInput: 'Test 2', aurynResponse: 'R2'),
      ];

      await longTerm.saveMany(entries);

      final ids = entries.map((e) => e.id).toList();
      final deleted = await longTerm.deleteMany(ids);

      expect(deleted, equals(2));

      final count = await longTerm.count();
      expect(count, equals(0));
    });

    test('deve buscar por tag', () async {
      await longTerm.save(MemoryEntry.interaction(
        userInput: 'Test',
        aurynResponse: 'Response',
        tags: ['important', 'test'],
      ));

      final results = await longTerm.queryByTag('important');
      expect(results.length, equals(1));
      expect(results[0].tags, contains('important'));
    });

    test('deve buscar por múltiplas tags (AND)', () async {
      await longTerm.save(MemoryEntry.interaction(
        userInput: 'Test 1',
        aurynResponse: 'Response',
        tags: ['tag1', 'tag2'],
      ));

      await longTerm.save(MemoryEntry.interaction(
        userInput: 'Test 2',
        aurynResponse: 'Response',
        tags: ['tag1'],
      ));

      final results = await longTerm.queryByAllTags(['tag1', 'tag2']);
      expect(results.length, equals(1));
      expect(results[0].content['user_input'], equals('Test 1'));
    });

    test('deve buscar por categoria', () async {
      await longTerm.save(MemoryEntry.learning(
        topic: 'Flutter',
        insight: 'Insight',
      ));

      await longTerm.save(MemoryEntry.interaction(
        userInput: 'Test',
        aurynResponse: 'Response',
      ));

      final learnings = await longTerm.queryByCategory('learning');
      expect(learnings.length, equals(1));
      expect(learnings[0].category, equals('learning'));
    });

    test('deve buscar por emoção positiva', () async {
      await longTerm.save(MemoryEntry.interaction(
        userInput: 'Happy',
        aurynResponse: 'Great',
        emotionalWeight: 0.8,
      ));

      await longTerm.save(MemoryEntry.interaction(
        userInput: 'Sad',
        aurynResponse: 'Sorry',
        emotionalWeight: -0.6,
      ));

      final positive = await longTerm.queryByEmotion(positive: true);
      expect(positive.length, equals(1));
      expect(positive[0].isPositive, isTrue);
    });

    test('deve buscar por emoção negativa', () async {
      await longTerm.save(MemoryEntry.interaction(
        userInput: 'Happy',
        aurynResponse: 'Great',
        emotionalWeight: 0.8,
      ));

      await longTerm.save(MemoryEntry.interaction(
        userInput: 'Sad',
        aurynResponse: 'Sorry',
        emotionalWeight: -0.6,
      ));

      final negative = await longTerm.queryByEmotion(positive: false);
      expect(negative.length, equals(1));
      expect(negative[0].isNegative, isTrue);
    });

    test('deve buscar por range de peso emocional', () async {
      await longTerm.save(MemoryEntry.interaction(
        userInput: 'Test 1',
        aurynResponse: 'R1',
        emotionalWeight: 0.2,
      ));

      await longTerm.save(MemoryEntry.interaction(
        userInput: 'Test 2',
        aurynResponse: 'R2',
        emotionalWeight: 0.7,
      ));

      final filtered = await longTerm.queryByEmotion(
        minWeight: 0.5,
        maxWeight: 1.0,
      );

      expect(filtered.length, equals(1));
      expect(filtered[0].emotionalWeight, greaterThanOrEqualTo(0.5));
    });

    test('deve buscar memórias recentes', () async {
      // Memória antiga
      final old = MemoryEntry.interaction(
        userInput: 'Old',
        aurynResponse: 'Response',
      );
      final oldWithDate = old.copyWith(
        timestamp: DateTime.now().subtract(Duration(days: 30)),
      );
      await longTerm.save(oldWithDate);

      // Memória recente
      await longTerm.save(MemoryEntry.interaction(
        userInput: 'Recent',
        aurynResponse: 'Response',
      ));

      final recent = await longTerm.queryRecent(days: 7);
      expect(recent.length, equals(1));
      expect(recent[0].content['user_input'], equals('Recent'));
    });

    test('deve buscar memórias mais acessadas', () async {
      final entry1 = MemoryEntry.interaction(
        userInput: 'Test 1',
        aurynResponse: 'R1',
      );

      final entry2 = MemoryEntry.interaction(
        userInput: 'Test 2',
        aurynResponse: 'R2',
      );

      await longTerm.save(entry1);
      await longTerm.save(entry2);

      // Acessa entry1 múltiplas vezes
      await longTerm.find(entry1.id);
      await longTerm.find(entry1.id);
      await longTerm.find(entry1.id);

      final mostAccessed = await longTerm.getMostAccessed(limit: 1);
      expect(mostAccessed.length, equals(1));
      expect(mostAccessed[0].id, equals(entry1.id));
      expect(mostAccessed[0].accessCount, greaterThan(2));
    });

    test('deve contar memórias', () async {
      expect(await longTerm.count(), equals(0));

      await longTerm.save(MemoryEntry.interaction(
        userInput: 'Test',
        aurynResponse: 'Response',
      ));

      expect(await longTerm.count(), equals(1));
    });

    test('deve obter todas as memórias', () async {
      final entries = [
        MemoryEntry.interaction(userInput: 'Test 1', aurynResponse: 'R1'),
        MemoryEntry.interaction(userInput: 'Test 2', aurynResponse: 'R2'),
        MemoryEntry.interaction(userInput: 'Test 3', aurynResponse: 'R3'),
      ];

      await longTerm.saveMany(entries);

      final all = await longTerm.getAll();
      expect(all.length, equals(3));
    });

    test('deve limpar todas as memórias', () async {
      await longTerm.save(MemoryEntry.interaction(
        userInput: 'Test',
        aurynResponse: 'Response',
      ));

      expect(await longTerm.count(), equals(1));

      await longTerm.clear();

      expect(await longTerm.count(), equals(0));
    });

    test('deve limpar memórias por categoria', () async {
      await longTerm.save(MemoryEntry.learning(
        topic: 'Topic',
        insight: 'Insight',
      ));

      await longTerm.save(MemoryEntry.interaction(
        userInput: 'Test',
        aurynResponse: 'Response',
      ));

      expect(await longTerm.count(), equals(2));

      final cleared = await longTerm.clearByCategory('learning');
      expect(cleared, equals(1));

      expect(await longTerm.count(), equals(1));
    });

    test('deve limpar memórias antigas', () async {
      // Memória antiga
      final old = MemoryEntry.interaction(
        userInput: 'Old',
        aurynResponse: 'Response',
      );
      final oldWithDate = old.copyWith(
        timestamp: DateTime.now().subtract(Duration(days: 100)),
      );
      await longTerm.save(oldWithDate);

      // Memória recente
      await longTerm.save(MemoryEntry.interaction(
        userInput: 'Recent',
        aurynResponse: 'Response',
      ));

      final cleared = await longTerm.clearOlderThan(90);
      expect(cleared, equals(1));

      final remaining = await longTerm.getAll();
      expect(remaining.length, equals(1));
      expect(remaining[0].content['user_input'], equals('Recent'));
    });

    test('deve exportar e importar memórias', () async {
      final entries = [
        MemoryEntry.interaction(
          userInput: 'Test 1',
          aurynResponse: 'Response 1',
          tags: ['export'],
        ),
        MemoryEntry.interaction(
          userInput: 'Test 2',
          aurynResponse: 'Response 2',
          tags: ['export'],
        ),
      ];

      await longTerm.saveMany(entries);

      // Exportar
      final json = await longTerm.export();
      expect(json, isNotEmpty);

      // Limpar
      await longTerm.clear();
      expect(await longTerm.count(), equals(0));

      // Importar
      final imported = await longTerm.import(json);
      expect(imported, equals(2));

      final all = await longTerm.getAll();
      expect(all.length, equals(2));
    });

    test('deve obter estatísticas', () async {
      await longTerm.save(MemoryEntry.interaction(
        userInput: 'Test',
        aurynResponse: 'Response',
        emotionalWeight: 0.5,
      ));

      final stats = await longTerm.getStatistics();

      expect(stats['total_entries'], greaterThan(0));
      expect(stats['by_category'], isNotNull);
      expect(stats['positive_count'], greaterThan(0));
    });

    test('deve validar integridade', () async {
      await longTerm.save(MemoryEntry.interaction(
        userInput: 'Test',
        aurynResponse: 'Response',
      ));

      final validation = await longTerm.validateIntegrity();

      expect(validation['valid_entries'], greaterThan(0));
      expect(validation['corrupted_entries'], equals(0));
      expect(validation['integrity_score'], equals(1.0));
    });

    test('deve usar filtro customizado', () async {
      await longTerm.save(MemoryEntry.interaction(
        userInput: 'Test',
        aurynResponse: 'Response',
        emotionalWeight: 0.5,
        tags: ['custom'],
      ));

      final filter = MemoryFilter(
        categories: ['interaction'],
        requiredTags: ['custom'],
        minEmotionalWeight: 0.3,
        limit: 10,
      );

      final results = await longTerm.query(filter);
      expect(results.length, equals(1));
    });

    test('deve incrementar accessCount ao buscar', () async {
      final entry = MemoryEntry.interaction(
        userInput: 'Test',
        aurynResponse: 'Response',
      );

      await longTerm.save(entry);

      // Acessa múltiplas vezes
      final found1 = await longTerm.find(entry.id);
      expect(found1!.accessCount, greaterThan(0));

      final found2 = await longTerm.find(entry.id);
      expect(found2!.accessCount, greaterThan(found1.accessCount));
    });

    test('deve aplicar data de expiração ao salvar', () async {
      // Cria LongTermMemory com política de expiração
      final ltmWithExpiration = LongTermMemory(
        expiration: MemoryExpiration(
          configs: [ExpirationConfig.afterDays(30)],
        ),
      );
      await ltmWithExpiration.initialize();

      final entry = MemoryEntry.interaction(
        userInput: 'Test',
        aurynResponse: 'Response',
      );

      await ltmWithExpiration.save(entry);

      final saved = await ltmWithExpiration.find(entry.id);
      expect(saved, isNotNull);
      expect(saved!.expiresAt, isNotNull);

      await ltmWithExpiration.close();
    });

    test('deve contar memórias ativas (sem expiradas)', () async {
      // Cria memória expirada
      final expired = MemoryEntry.interaction(
        userInput: 'Expired',
        aurynResponse: 'Response',
      );
      final expiredWithDate = expired.copyWith(
        expiresAt: DateTime.now().subtract(Duration(days: 1)),
      );

      // Cria memória ativa
      final active = MemoryEntry.interaction(
        userInput: 'Active',
        aurynResponse: 'Response',
      );

      await longTerm.save(expiredWithDate);
      await longTerm.save(active);

      final total = await longTerm.count();
      expect(total, equals(2));

      final activeCount = await longTerm.countActive();
      expect(activeCount, equals(1)); // Apenas a não expirada
    });
  });

  group('LongTermMemory Expiration', () {
    late LongTermMemory longTerm;

    setUp(() async {
      Hive.init('/tmp/hive_test_exp_${DateTime.now().millisecondsSinceEpoch}');

      longTerm = LongTermMemory(
        expiration: MemoryExpiration(
          configs: [ExpirationConfig.afterDays(7)],
        ),
      );
      await longTerm.initialize();
    });

    tearDown(() async {
      await longTerm.close();
      await Hive.deleteFromDisk();
    });

    test('deve limpar memórias expiradas', () async {
      // Cria memória expirada
      final expired = MemoryEntry.interaction(
        userInput: 'Expired',
        aurynResponse: 'Response',
      );
      final expiredWithDate = expired.copyWith(
        expiresAt: DateTime.now().subtract(Duration(days: 1)),
      );

      // Cria memória ativa
      final active = MemoryEntry.interaction(
        userInput: 'Active',
        aurynResponse: 'Response',
      );

      await longTerm.save(expiredWithDate);
      await longTerm.save(active);

      final cleaned = await longTerm.cleanExpired();
      expect(cleaned, equals(1));

      final remaining = await longTerm.getAll();
      expect(remaining.length, equals(1));
      expect(remaining[0].content['user_input'], equals('Active'));
    });
  });
}
