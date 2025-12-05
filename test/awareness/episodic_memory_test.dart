import 'package:flutter_test/flutter_test.dart';
import 'package:auryn_offline/auryn_core/awareness/episodic_memory.dart';

void main() {
  group('EpisodicMemory', () {
    late EpisodicMemory memory;

    setUp(() {
      memory = EpisodicMemoryImpl();
    });

    test('inicia desabilitado por padrão (opt-in)', () {
      expect(memory.isEnabled, isFalse);
    });

    test('não armazena episódios quando desabilitado', () {
      memory.addEpisode({'data': 'test'});
      expect(memory.episodeCount, equals(0));
    });

    test('armazena episódios quando habilitado', () {
      memory.enable();
      expect(memory.isEnabled, isTrue);

      memory.addEpisode({'type': 'conversation'});
      expect(memory.episodeCount, equals(1));
    });

    test('pode desabilitar gravação', () {
      memory.enable();
      memory.addEpisode({'data': 'test1'});

      memory.disable();
      expect(memory.isEnabled, isFalse);

      memory.addEpisode({'data': 'test2'});
      expect(memory.episodeCount, equals(1)); // Apenas o primeiro
    });

    test('recupera episódios sem critério', () {
      memory.enable();
      memory.addEpisode({'type': 'A'});
      memory.addEpisode({'type': 'B'});

      final episodes = memory.getEpisodes();
      expect(episodes.length, equals(2));
    });

    test('filtra episódios por critério', () {
      memory.enable();
      memory.addEpisode({'type': 'conversation', 'user': 'Alice'});
      memory.addEpisode({'type': 'gesture', 'user': 'Bob'});
      memory.addEpisode({'type': 'conversation', 'user': 'Charlie'});

      final conversations = memory.getEpisodes(
        criteria: {'type': 'conversation'}
      );
      expect(conversations.length, equals(2));
    });

    test('adiciona timestamp aos episódios', () {
      memory.enable();
      memory.addEpisode({'data': 'test'});

      final episodes = memory.getEpisodes();
      expect(episodes[0].containsKey('recordedAt'), isTrue);
      expect(episodes[0]['recordedAt'], isA<String>());
    });

    test('limpa todos os episódios', () {
      memory.enable();
      memory.addEpisode({'data': 'test1'});
      memory.addEpisode({'data': 'test2'});
      expect(memory.episodeCount, equals(2));

      memory.clearAllEpisodes();
      expect(memory.episodeCount, equals(0));
    });
  });
}
