import 'package:flutter_test/flutter_test.dart';
import 'package:auryn_offline/auryn_core/awareness/intent_filter.dart';

void main() {
  group('IntentFilter', () {
    late IntentFilter filter;

    setUp(() {
      filter = IntentFilterImpl();
    });

    test('classifica intent de voz', () {
      expect(filter.classifyIntent('speech'), equals('voice_input'));
      expect(filter.classifyIntent('fala'), equals('voice_input'));
      expect(filter.classifyIntent('voice'), equals('voice_input'));
    });

    test('classifica intent de texto', () {
      expect(filter.classifyIntent('text'), equals('text_input'));
      expect(filter.classifyIntent('texto'), equals('text_input'));
    });

    test('classifica intent de gesto', () {
      expect(filter.classifyIntent('gesture'), equals('gesture_input'));
      expect(filter.classifyIntent('gesto'), equals('gesture_input'));
    });

    test('classifica intent desconhecido', () {
      expect(filter.classifyIntent('random'), equals('unknown'));
      expect(filter.classifyIntent('xyz123'), equals('unknown'));
    });

    test('case insensitive classification', () {
      expect(filter.classifyIntent('SPEECH'), equals('voice_input'));
      expect(filter.classifyIntent('Speech'), equals('voice_input'));
      expect(filter.classifyIntent('FALA'), equals('voice_input'));
    });

    test('filtra intents suportados', () {
      final intents = [
        'voice_input',
        'text_input',
        'invalid_intent',
        'gesture_input',
      ];

      final filtered = filter.filterIntents(intents);
      expect(filtered.length, equals(3));
      expect(filtered.contains('invalid_intent'), isFalse);
    });

    test('remove duplicatas ao filtrar', () {
      final intents = [
        'voice_input',
        'voice_input',
        'text_input',
        'voice_input',
      ];

      final filtered = filter.filterIntents(intents);
      expect(filtered.length, equals(2));
    });

    test('adiciona pattern customizado', () {
      filter.addIntentPattern('custom_action', 'custom_input');
      expect(filter.classifyIntent('custom_action'), equals('custom_input'));
      expect(filter.isSupportedIntent('custom_input'), isTrue);
    });

    test('verifica suporte de intent', () {
      expect(filter.isSupportedIntent('voice_input'), isTrue);
      expect(filter.isSupportedIntent('text_input'), isTrue);
      expect(filter.isSupportedIntent('invalid'), isFalse);
    });

    test('patterns são case insensitive ao adicionar', () {
      filter.addIntentPattern('CUSTOM', 'custom_type');
      expect(filter.classifyIntent('custom'), equals('custom_type'));
      expect(filter.classifyIntent('CUSTOM'), equals('custom_type'));
    });
  });
}
