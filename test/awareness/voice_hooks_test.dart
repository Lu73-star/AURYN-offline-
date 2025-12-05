import 'package:flutter_test/flutter_test.dart';
import 'package:auryn_offline/auryn_core/awareness/voice_hooks.dart';

void main() {
  group('VoiceHooks', () {
    late VoiceHooksImpl hooks;

    setUp(() {
      hooks = VoiceHooksImpl();
    });

    test('registra voice input', () {
      hooks.onVoiceInput('Hello AURYN');

      final history = hooks.getInputHistory();
      expect(history.length, equals(1));
      expect(history[0], equals('Hello AURYN'));
    });

    test('registra voice feedback', () {
      hooks.onVoiceFeedback('Olá! Como posso ajudar?');

      final history = hooks.getFeedbackHistory();
      expect(history.length, equals(1));
      expect(history[0], equals('Olá! Como posso ajudar?'));
    });

    test('callback de input é chamado', () {
      String? received;
      hooks.setVoiceInputCallback((transcript) {
        received = transcript;
      });

      hooks.onVoiceInput('Test message');
      expect(received, equals('Test message'));
    });

    test('callback de feedback é chamado', () {
      String? received;
      hooks.setVoiceFeedbackCallback((feedback) {
        received = feedback;
      });

      hooks.onVoiceFeedback('Response message');
      expect(received, equals('Response message'));
    });

    test('múltiplos inputs são armazenados', () {
      hooks.onVoiceInput('First');
      hooks.onVoiceInput('Second');
      hooks.onVoiceInput('Third');

      final history = hooks.getInputHistory();
      expect(history.length, equals(3));
      expect(history[0], equals('First'));
      expect(history[2], equals('Third'));
    });

    test('onRecordingStart não lança exceção', () {
      expect(() => hooks.onRecordingStart(), returnsNormally);
    });

    test('onRecordingStop não lança exceção', () {
      expect(() => hooks.onRecordingStop(), returnsNormally);
    });

    test('callback pode ser mudado', () {
      String? first;
      String? second;

      hooks.setVoiceInputCallback((t) => first = t);
      hooks.onVoiceInput('Message 1');

      hooks.setVoiceInputCallback((t) => second = t);
      hooks.onVoiceInput('Message 2');

      expect(first, equals('Message 1'));
      expect(second, equals('Message 2'));
    });

    test('funciona sem callbacks configurados', () {
      // Não deve lançar exceção mesmo sem callbacks
      expect(() => hooks.onVoiceInput('Test'), returnsNormally);
      expect(() => hooks.onVoiceFeedback('Test'), returnsNormally);
    });
  });
}
