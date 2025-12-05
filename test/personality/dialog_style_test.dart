/// test/personality/dialog_style_test.dart
/// Tests for DialogStyle - style mapping, mood adjustments.

import 'package:flutter_test/flutter_test.dart';
import 'package:auryn_offline/auryn_core/personality/dialog_style.dart';

void main() {
  group('DialogStyle', () {
    test('deve criar dialog style neutro', () {
      final style = DialogStyle.neutral();

      expect(style.warmth, equals(0.5));
      expect(style.precision, equals(0.5));
      expect(style.cadence, equals(0.5));
      expect(style.expressiveness, equals(0.5));
      expect(style.formality, equals(0.5));
      expect(style.verbosity, equals(0.5));
    });

    test('deve criar dialog style AURYN default', () {
      final style = DialogStyle.aurynDefault();

      expect(style.warmth, equals(0.75));
      expect(style.precision, equals(0.65));
      expect(style.cadence, equals(0.50));
      expect(style.expressiveness, equals(0.60));
      expect(style.formality, equals(0.40));
      expect(style.verbosity, equals(0.60));
    });

    test('deve lançar assertion error para valores inválidos', () {
      expect(
        () => DialogStyle(
          warmth: 1.5, // Invalid
          precision: 0.5,
          cadence: 0.5,
          expressiveness: 0.5,
          formality: 0.5,
          verbosity: 0.5,
        ),
        throwsAssertionError,
      );
    });

    test('deve serializar e deserializar corretamente', () {
      final style = DialogStyle.aurynDefault();
      final map = style.toMap();
      final restored = DialogStyle.fromMap(map);

      expect(restored.warmth, equals(style.warmth));
      expect(restored.precision, equals(style.precision));
      expect(restored.cadence, equals(style.cadence));
      expect(restored.expressiveness, equals(style.expressiveness));
      expect(restored.formality, equals(style.formality));
      expect(restored.verbosity, equals(style.verbosity));
    });

    test('deve normalizar valores no fromMap', () {
      final map = {
        'warmth': 1.5, // Out of range
        'precision': -0.5, // Out of range
        'cadence': null, // Null
        'expressiveness': '0.75', // String
        'formality': 60, // Integer
        'verbosity': 'invalid', // Invalid string
      };

      final style = DialogStyle.fromMap(map);

      expect(style.warmth, equals(1.0)); // Clamped
      expect(style.precision, equals(0.0)); // Clamped
      expect(style.cadence, equals(0.5)); // Default for null
      expect(style.expressiveness, equals(0.75)); // Parsed string
      expect(style.formality, equals(1.0)); // Clamped int
      expect(style.verbosity, equals(0.5)); // Default for invalid
    });

    test('deve criar cópia com valores alterados', () {
      final style = DialogStyle.aurynDefault();
      final modified = style.copyWith(
        warmth: 0.90,
        cadence: 0.70,
      );

      expect(modified.warmth, equals(0.90));
      expect(modified.cadence, equals(0.70));
      expect(modified.precision, equals(style.precision));
    });

    test('deve ajustar para mood happy', () {
      final style = DialogStyle.aurynDefault();
      final adjusted = style.adjustForMood('happy');

      expect(adjusted.warmth, greaterThan(style.warmth));
      expect(adjusted.cadence, greaterThan(style.cadence));
      expect(adjusted.expressiveness, greaterThan(style.expressiveness));
    });

    test('deve ajustar para mood sad', () {
      final style = DialogStyle.aurynDefault();
      final adjusted = style.adjustForMood('sad');

      expect(adjusted.warmth, greaterThan(style.warmth));
      expect(adjusted.cadence, lessThan(style.cadence));
      expect(adjusted.expressiveness, lessThan(style.expressiveness));
      expect(adjusted.verbosity, lessThan(style.verbosity));
    });

    test('deve ajustar para mood calm', () {
      final style = DialogStyle.aurynDefault();
      final adjusted = style.adjustForMood('calm');

      expect(adjusted.warmth, greaterThan(style.warmth));
      expect(adjusted.cadence, lessThan(style.cadence));
      expect(adjusted.precision, greaterThan(style.precision));
    });

    test('deve ajustar para mood anxious', () {
      final style = DialogStyle.aurynDefault();
      final adjusted = style.adjustForMood('anxious');

      expect(adjusted.warmth, greaterThan(style.warmth));
      expect(adjusted.cadence, lessThan(style.cadence));
      expect(adjusted.precision, greaterThan(style.precision));
      expect(adjusted.verbosity, lessThan(style.verbosity));
    });

    test('deve ajustar para mood excited', () {
      final style = DialogStyle.aurynDefault();
      final adjusted = style.adjustForMood('excited');

      expect(adjusted.cadence, greaterThan(style.cadence));
      expect(adjusted.expressiveness, greaterThan(style.expressiveness));
      expect(adjusted.formality, lessThan(style.formality));
    });

    test('deve ajustar para mood reflective', () {
      final style = DialogStyle.aurynDefault();
      final adjusted = style.adjustForMood('reflective');

      expect(adjusted.cadence, lessThan(style.cadence));
      expect(adjusted.precision, greaterThan(style.precision));
      expect(adjusted.verbosity, greaterThan(style.verbosity));
    });

    test('deve retornar inalterado para mood desconhecido', () {
      final style = DialogStyle.aurynDefault();
      final adjusted = style.adjustForMood('unknown_mood');

      expect(adjusted.warmth, equals(style.warmth));
      expect(adjusted.cadence, equals(style.cadence));
      expect(adjusted.precision, equals(style.precision));
    });

    test('deve ajustar para intensidade emocional', () {
      final style = DialogStyle.aurynDefault();

      final adjusted0 = style.adjustForIntensity(0);
      expect(adjusted0.expressiveness, equals(style.expressiveness));

      final adjusted1 = style.adjustForIntensity(1);
      expect(adjusted1.expressiveness, greaterThan(style.expressiveness));

      final adjusted3 = style.adjustForIntensity(3);
      expect(adjusted3.expressiveness, greaterThan(adjusted1.expressiveness));
      expect(adjusted3.warmth, greaterThan(style.warmth));
    });

    test('deve ter labels descritivos corretos', () {
      final style = DialogStyle(
        warmth: 0.2,
        precision: 0.4,
        cadence: 0.65,
        expressiveness: 0.85,
        formality: 0.5,
        verbosity: 0.5,
      );

      expect(style.warmthLabel, equals('cool'));
      expect(style.precisionLabel, equals('moderate'));
      expect(style.cadenceLabel, equals('brisk'));
      expect(style.expressivenessLabel, equals('highly expressive'));
    });

    test('deve ter toString informativo', () {
      final style = DialogStyle.aurynDefault();
      final str = style.toString();

      expect(str, contains('DialogStyle'));
      expect(str, contains('warmth'));
      expect(str, contains('warm'));
      expect(str, contains('cadence'));
    });

    test('deve implementar equals e hashCode corretamente', () {
      final style1 = DialogStyle.aurynDefault();
      final style2 = DialogStyle.aurynDefault();
      final style3 = style1.copyWith(warmth: 0.90);

      expect(style1, equals(style2));
      expect(style1.hashCode, equals(style2.hashCode));
      expect(style1, isNot(equals(style3)));
    });

    test('deve clampar valores ajustados para range válido', () {
      final style = DialogStyle(
        warmth: 0.95,
        precision: 0.05,
        cadence: 0.5,
        expressiveness: 0.5,
        formality: 0.5,
        verbosity: 0.5,
      );

      // Test clamping at upper bound
      final adjusted1 = style.adjustForMood('happy');
      expect(adjusted1.warmth, lessThanOrEqualTo(1.0));

      // Test clamping at lower bound
      final adjusted2 = style.copyWith(precision: 0.05).adjustForMood('anxious');
      expect(adjusted2.cadence, greaterThanOrEqualTo(0.0));
    });
  });
}
