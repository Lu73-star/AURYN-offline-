/// test/personality/personality_traits_test.dart
/// Tests for PersonalityTraits - normalization, adjustment, serialization.

import 'package:flutter_test/flutter_test.dart';
import 'package:auryn_offline/auryn_core/personality/personality_traits.dart';

void main() {
  group('PersonalityTraits', () {
    test('deve criar traits com valores válidos', () {
      final traits = PersonalityTraits(
        openness: 0.75,
        conscientiousness: 0.70,
        extraversion: 0.55,
        agreeableness: 0.85,
        neuroticism: 0.30,
        assertiveness: 0.60,
        playfulness: 0.45,
        intellectualism: 0.80,
      );

      expect(traits.openness, equals(0.75));
      expect(traits.conscientiousness, equals(0.70));
      expect(traits.extraversion, equals(0.55));
      expect(traits.agreeableness, equals(0.85));
      expect(traits.neuroticism, equals(0.30));
      expect(traits.assertiveness, equals(0.60));
      expect(traits.playfulness, equals(0.45));
      expect(traits.intellectualism, equals(0.80));
    });

    test('deve lançar assertion error para valores inválidos', () {
      expect(
        () => PersonalityTraits(
          openness: 1.5, // Invalid
          conscientiousness: 0.70,
          extraversion: 0.55,
          agreeableness: 0.85,
          neuroticism: 0.30,
          assertiveness: 0.60,
          playfulness: 0.45,
          intellectualism: 0.80,
        ),
        throwsAssertionError,
      );

      expect(
        () => PersonalityTraits(
          openness: 0.75,
          conscientiousness: -0.1, // Invalid
          extraversion: 0.55,
          agreeableness: 0.85,
          neuroticism: 0.30,
          assertiveness: 0.60,
          playfulness: 0.45,
          intellectualism: 0.80,
        ),
        throwsAssertionError,
      );
    });

    test('deve criar traits AURYN default corretamente', () {
      final traits = PersonalityTraits.aurynDefault();

      expect(traits.openness, equals(0.75));
      expect(traits.conscientiousness, equals(0.70));
      expect(traits.extraversion, equals(0.55));
      expect(traits.agreeableness, equals(0.85));
      expect(traits.neuroticism, equals(0.30));
      expect(traits.assertiveness, equals(0.60));
      expect(traits.playfulness, equals(0.45));
      expect(traits.intellectualism, equals(0.80));
    });

    test('deve serializar e deserializar corretamente', () {
      final traits = PersonalityTraits.aurynDefault();
      final map = traits.toMap();
      final restored = PersonalityTraits.fromMap(map);

      expect(restored.openness, equals(traits.openness));
      expect(restored.conscientiousness, equals(traits.conscientiousness));
      expect(restored.extraversion, equals(traits.extraversion));
      expect(restored.agreeableness, equals(traits.agreeableness));
      expect(restored.neuroticism, equals(traits.neuroticism));
      expect(restored.assertiveness, equals(traits.assertiveness));
      expect(restored.playfulness, equals(traits.playfulness));
      expect(restored.intellectualism, equals(traits.intellectualism));
    });

    test('deve normalizar valores corretamente no fromMap', () {
      final map = {
        'openness': '0.75', // String
        'conscientiousness': 1.5, // Out of range
        'extraversion': -0.5, // Out of range
        'agreeableness': 0.85,
        'neuroticism': null, // Null
        'assertiveness': 60, // Integer
        'playfulness': 0.45,
        'intellectualism': 'invalid', // Invalid string
      };

      final traits = PersonalityTraits.fromMap(map);

      expect(traits.openness, equals(0.75)); // Parsed string
      expect(traits.conscientiousness, equals(1.0)); // Clamped
      expect(traits.extraversion, equals(0.0)); // Clamped
      expect(traits.agreeableness, equals(0.85));
      expect(traits.neuroticism, equals(0.5)); // Default for null
      expect(traits.assertiveness, equals(1.0)); // Clamped int
      expect(traits.playfulness, equals(0.45));
      expect(traits.intellectualism, equals(0.5)); // Default for invalid
    });

    test('deve criar cópia com valores alterados', () {
      final traits = PersonalityTraits.aurynDefault();
      final modified = traits.copyWith(
        openness: 0.90,
        agreeableness: 0.95,
      );

      expect(modified.openness, equals(0.90));
      expect(modified.agreeableness, equals(0.95));
      // Outros valores devem permanecer iguais
      expect(modified.conscientiousness, equals(traits.conscientiousness));
      expect(modified.extraversion, equals(traits.extraversion));
    });

    test('deve ajustar trait individual corretamente', () {
      final traits = PersonalityTraits.aurynDefault();
      final adjusted = traits.adjustTrait('openness', 0.10);

      expect(adjusted.openness, equals(0.85));
      // Outros valores devem permanecer iguais
      expect(adjusted.conscientiousness, equals(traits.conscientiousness));
    });

    test('deve clampar ajuste de trait para range válido', () {
      final traits = PersonalityTraits.aurynDefault();
      
      // Ajuste que excede 1.0
      final adjusted1 = traits.adjustTrait('openness', 0.50);
      expect(adjusted1.openness, equals(1.0));

      // Ajuste que fica abaixo de 0.0
      final adjusted2 = traits.adjustTrait('neuroticism', -0.50);
      expect(adjusted2.neuroticism, equals(0.0));
    });

    test('deve lançar erro para trait desconhecido', () {
      final traits = PersonalityTraits.aurynDefault();
      
      expect(
        () => traits.adjustTrait('unknown_trait', 0.10),
        throwsArgumentError,
      );
    });

    test('deve obter valor de trait por nome', () {
      final traits = PersonalityTraits.aurynDefault();

      expect(traits.getTrait('openness'), equals(0.75));
      expect(traits.getTrait('agreeableness'), equals(0.85));
      expect(traits.getTrait('neuroticism'), equals(0.30));
    });

    test('deve obter todos os nomes de traits', () {
      final names = PersonalityTraits.traitNames;

      expect(names, contains('openness'));
      expect(names, contains('conscientiousness'));
      expect(names, contains('extraversion'));
      expect(names, contains('agreeableness'));
      expect(names, contains('neuroticism'));
      expect(names, contains('assertiveness'));
      expect(names, contains('playfulness'));
      expect(names, contains('intellectualism'));
      expect(names.length, equals(8));
    });

    test('deve calcular similaridade entre traits', () {
      final traits1 = PersonalityTraits.aurynDefault();
      final traits2 = PersonalityTraits.aurynDefault();

      // Traits idênticos devem ter similaridade 1.0
      expect(traits1.similarityTo(traits2), equals(1.0));

      // Traits completamente diferentes
      final traits3 = PersonalityTraits(
        openness: 0.25,
        conscientiousness: 0.30,
        extraversion: 0.45,
        agreeableness: 0.15,
        neuroticism: 0.70,
        assertiveness: 0.40,
        playfulness: 0.55,
        intellectualism: 0.20,
      );

      final similarity = traits1.similarityTo(traits3);
      expect(similarity, lessThan(0.5)); // Deve ser baixa
      expect(similarity, greaterThanOrEqualTo(0.0));
      expect(similarity, lessThanOrEqualTo(1.0));
    });

    test('deve implementar equals e hashCode corretamente', () {
      final traits1 = PersonalityTraits.aurynDefault();
      final traits2 = PersonalityTraits.aurynDefault();
      final traits3 = traits1.copyWith(openness: 0.90);

      expect(traits1, equals(traits2));
      expect(traits1.hashCode, equals(traits2.hashCode));
      expect(traits1, isNot(equals(traits3)));
    });

    test('deve ter toString informativo', () {
      final traits = PersonalityTraits.aurynDefault();
      final str = traits.toString();

      expect(str, contains('PersonalityTraits'));
      expect(str, contains('openness'));
      expect(str, contains('0.75'));
    });
  });
}
