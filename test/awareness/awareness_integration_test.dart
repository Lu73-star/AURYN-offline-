import 'package:flutter_test/flutter_test.dart';
import 'package:auryn_offline/auryn_core/awareness/awareness.dart';

void main() {
  group('Awareness Integration Tests', () {
    late AwarenessCore awareness;

    setUp(() {
      awareness = AwarenessCoreImpl();
    });

    test('inicialização completa do sistema', () {
      awareness.initialize();

      // Verificar que todos os componentes foram inicializados
      expect(awareness.contextManager, isNotNull);
      expect(awareness.shortTermMemory, isNotNull);
      expect(awareness.episodicMemory, isNotNull);
      expect(awareness.personalityController, isNotNull);
      expect(awareness.intentFilter, isNotNull);
      expect(awareness.voiceHooks, isNotNull);
    });

    test('fluxo completo de intent handling', () {
      awareness.initialize();

      // Handle um intent
      awareness.handleIntent('voice_input', {
        'text': 'Olá AURYN',
        'confidence': 0.95,
      });

      // Verificar que o contexto foi atualizado
      final context = awareness.contextManager.getCurrentContext();
      expect(context['lastIntent'], equals('voice_input'));
      expect(context.containsKey('timestamp'), isTrue);

      // Verificar que foi armazenado em STM
      final recentItems = awareness.shortTermMemory.getRecentItems(limit: 1);
      expect(recentItems.length, equals(1));
      expect(recentItems[0]['intent'], equals('voice_input'));
    });

    test('intent desconhecido é classificado corretamente', () {
      awareness.initialize();

      awareness.handleIntent('random_action', {'data': 'test'});

      final context = awareness.contextManager.getCurrentContext();
      expect(context['lastIntent'], equals('unknown'));
    });

    test('múltiplos intents atualizam contexto', () {
      awareness.initialize();

      awareness.handleIntent('voice', {});
      final context1 = awareness.contextManager.getCurrentContext();
      final timestamp1 = context1['timestamp'];

      // Pequeno delay para garantir timestamp diferente
      Future.delayed(Duration(milliseconds: 10));

      awareness.handleIntent('text', {});
      final context2 = awareness.contextManager.getCurrentContext();
      final timestamp2 = context2['timestamp'];

      expect(context2['lastIntent'], equals('text_input'));
      expect(timestamp2, isNot(equals(timestamp1)));
    });

    test('memoria episódica respeita opt-in', () {
      awareness.initialize();

      // Por padrão, episodic memory deve estar desabilitada
      expect(awareness.episodicMemory.isEnabled, isFalse);

      // Tentar adicionar episódio sem opt-in
      awareness.episodicMemory.addEpisode({'data': 'test'});
      expect(awareness.episodicMemory.episodeCount, equals(0));

      // Habilitar e tentar novamente
      awareness.episodicMemory.enable();
      awareness.episodicMemory.addEpisode({'data': 'test'});
      expect(awareness.episodicMemory.episodeCount, equals(1));
    });

    test('personalidade pode ser ajustada', () {
      awareness.initialize();

      final originalFriendliness = 
          awareness.personalityController.getTrait('friendliness');

      awareness.personalityController.updateTrait('friendliness', 0.95);

      final newFriendliness = 
          awareness.personalityController.getTrait('friendliness');

      expect(newFriendliness, equals(0.95));
      expect(newFriendliness, isNot(equals(originalFriendliness)));
    });

    test('voice hooks integram com sistema', () {
      awareness.initialize();

      String? receivedInput;
      awareness.voiceHooks.setVoiceInputCallback((transcript) {
        receivedInput = transcript;
      });

      awareness.voiceHooks.onVoiceInput('Test transcript');

      expect(receivedInput, equals('Test transcript'));
    });

    test('update sem inicialização lança erro', () {
      expect(() => awareness.update(), throwsStateError);
    });

    test('handleIntent sem inicialização lança erro', () {
      expect(
        () => awareness.handleIntent('test', {}),
        throwsStateError,
      );
    });

    test('dispose limpa recursos', () {
      awareness.initialize();
      awareness.dispose();

      // Após dispose, deve exigir re-inicialização
      expect(() => awareness.update(), throwsStateError);
    });

    test('workflow completo: input -> processamento -> memória', () {
      awareness.initialize();

      // 1. Configurar personalidade
      awareness.personalityController.updateTrait('empathy', 0.95);

      // 2. Processar intent de voz
      awareness.handleIntent('voice', {
        'transcript': 'Como você está?',
        'timestamp': DateTime.now().toIso8601String(),
      });

      // 3. Verificar contexto atualizado
      final context = awareness.contextManager.getCurrentContext();
      expect(context['lastIntent'], equals('voice_input'));

      // 4. Verificar STM
      final stm = awareness.shortTermMemory.getRecentItems(limit: 1);
      expect(stm.length, equals(1));
      expect(stm[0]['intent'], equals('voice_input'));

      // 5. Verificar personalidade mantida
      expect(
        awareness.personalityController.getTrait('empathy'),
        equals(0.95),
      );
    });
  });
}
