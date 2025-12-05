import 'package:flutter_test/flutter_test.dart';
import 'package:auryn_offline/auryn_core/awareness/personality_controller.dart';

void main() {
  group('PersonalityController', () {
    late PersonalityController controller;

    setUp(() {
      controller = PersonalityControllerImpl();
    });

    test('tem traits padrão inicializados', () {
      final traits = controller.getTraits();
      expect(traits.isNotEmpty, isTrue);
      expect(traits.containsKey('friendliness'), isTrue);
      expect(traits.containsKey('empathy'), isTrue);
    });

    test('retorna lista de nomes de traits', () {
      final names = controller.getTraitNames();
      expect(names.contains('friendliness'), isTrue);
      expect(names.contains('formality'), isTrue);
      expect(names.contains('verbosity'), isTrue);
    });

    test('obtém trait específico', () {
      final empathy = controller.getTrait('empathy');
      expect(empathy, isNotNull);
      expect(empathy, isA<num>());
    });

    test('atualiza trait individual', () {
      controller.updateTrait('friendliness', 0.95);
      expect(controller.getTrait('friendliness'), equals(0.95));
    });

    test('permite adicionar traits customizados', () {
      controller.updateTrait('custom_trait', 0.7);
      expect(controller.getTrait('custom_trait'), equals(0.7));
      expect(controller.getTraitNames().contains('custom_trait'), isTrue);
    });

    test('reset para valores padrão', () {
      controller.updateTrait('friendliness', 0.1);
      controller.updateTrait('custom_trait', 0.5);

      controller.resetToDefaults();

      // Trait padrão deve ser restaurado
      expect(controller.getTrait('friendliness'), equals(0.8));
      // Trait customizado deve ser removido
      expect(controller.getTrait('custom_trait'), isNull);
    });

    test('retorna cópia dos traits', () {
      final traits1 = controller.getTraits();
      traits1['friendliness'] = 0.1;

      final traits2 = controller.getTraits();
      expect(traits2['friendliness'], isNot(equals(0.1)));
    });
  });
}
