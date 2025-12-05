import 'package:flutter_test/flutter_test.dart';
import 'package:auryn_offline/auryn_core/awareness/short_term_memory.dart';

void main() {
  group('ShortTermMemory', () {
    late ShortTermMemory memory;

    setUp(() {
      memory = ShortTermMemoryImpl();
    });

    test('inicializa vazio', () {
      expect(memory.itemCount, equals(0));
      expect(memory.getRecentItems(), isEmpty);
    });

    test('armazena e recupera items', () {
      memory.storeItem({'data': 'test1'});
      memory.storeItem({'data': 'test2'});

      expect(memory.itemCount, equals(2));
      final items = memory.getRecentItems();
      expect(items.length, equals(2));
      expect(items[0]['data'], equals('test2')); // Mais recente primeiro
      expect(items[1]['data'], equals('test1'));
    });

    test('respeita limite de items recentes', () {
      for (int i = 0; i < 20; i++) {
        memory.storeItem({'index': i});
      }

      final items = memory.getRecentItems(limit: 5);
      expect(items.length, equals(5));
      expect(items[0]['index'], equals(19)); // Mais recente
    });

    test('limpa memoria', () {
      memory.storeItem({'data': 'test'});
      expect(memory.itemCount, equals(1));

      memory.clear();
      expect(memory.itemCount, equals(0));
      expect(memory.getRecentItems(), isEmpty);
    });

    test('evict items antigos quando excede capacidade', () {
      // A implementação tem capacidade de 100 items
      for (int i = 0; i < 105; i++) {
        memory.storeItem({'index': i});
      }

      expect(memory.itemCount, equals(100));
      final items = memory.getRecentItems(limit: 100);
      // Os primeiros 5 devem ter sido removidos
      expect(items.last['index'], equals(5));
    });
  });
}
