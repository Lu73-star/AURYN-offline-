/// test/personality/personality_profile_test.dart
/// Tests for PersonalityProfile - modulation, compatibility, serialization.

import 'package:flutter_test/flutter_test.dart';
import 'package:auryn_offline/auryn_core/personality/personality_profile.dart';
import 'package:auryn_offline/auryn_core/personality/personality_traits.dart';
import 'package:auryn_offline/auryn_core/emotion/emotion_state.dart';

void main() {
  group('PersonalityProfile', () {
    test('deve criar profile AURYN default', () {
      final profile = PersonalityProfile.aurynDefault();

      expect(profile.id, equals('auryn_default'));
      expect(profile.name, equals('AURYN Default'));
      expect(profile.traits, isNotNull);
      expect(profile.emotionalBaseline, isNotNull);
      expect(profile.dialogStyle, isNotNull);
    });

    test('deve criar profile supportive', () {
      final profile = PersonalityProfile.supportive();

      expect(profile.id, equals('supportive'));
      expect(profile.name, equals('Supportive Mode'));
      expect(profile.traits.agreeableness, equals(0.95));
      expect(profile.emotionalBaseline.mood, equals('warm'));
    });

    test('deve criar profile analytical', () {
      final profile = PersonalityProfile.analytical();

      expect(profile.id, equals('analytical'));
      expect(profile.name, equals('Analytical Mode'));
      expect(profile.traits.intellectualism, equals(0.90));
      expect(profile.traits.conscientiousness, equals(0.85));
      expect(profile.emotionalBaseline.mood, equals('focused'));
    });

    test('deve serializar e deserializar corretamente', () {
      final profile = PersonalityProfile.aurynDefault();
      final map = profile.toMap();
      final restored = PersonalityProfile.fromMap(map);

      expect(restored.id, equals(profile.id));
      expect(restored.name, equals(profile.name));
      expect(restored.description, equals(profile.description));
      expect(restored.traits.openness, equals(profile.traits.openness));
      expect(restored.emotionalBaseline.mood, equals(profile.emotionalBaseline.mood));
    });

    test('deve criar cópia com valores alterados', () {
      final profile = PersonalityProfile.aurynDefault();
      final modified = profile.copyWith(
        name: 'Modified Profile',
        description: 'A modified version',
      );

      expect(modified.name, equals('Modified Profile'));
      expect(modified.description, equals('A modified version'));
      expect(modified.id, equals(profile.id)); // Should remain same
      expect(modified.traits, equals(profile.traits));
    });

    test('deve modular emoção baseada em neuroticism alto', () {
      final highNeuroticismTraits = PersonalityTraits.aurynDefault()
          .copyWith(neuroticism: 0.8);
      
      final profile = PersonalityProfile.aurynDefault().copyWith(
        traits: highNeuroticismTraits,
      );

      final negativeEmotion = EmotionState(
        mood: 'sad',
        intensity: 1,
        valence: -1,
        arousal: 1,
      );

      final modulated = profile.modulateEmotion(negativeEmotion);

      // High neuroticism should amplify negative emotions
      expect(modulated.intensity, greaterThan(negativeEmotion.intensity));
    });

    test('deve modular emoção baseada em neuroticism baixo', () {
      final lowNeuroticismTraits = PersonalityTraits.aurynDefault()
          .copyWith(neuroticism: 0.2);
      
      final profile = PersonalityProfile.aurynDefault().copyWith(
        traits: lowNeuroticismTraits,
      );

      final intenseEmotion = EmotionState(
        mood: 'anxious',
        intensity: 3,
        valence: -1,
        arousal: 3,
      );

      final modulated = profile.modulateEmotion(intenseEmotion);

      // Low neuroticism should dampen extreme emotions
      expect(modulated.intensity, lessThan(intenseEmotion.intensity));
    });

    test('deve modular emoção baseada em agreeableness alto', () {
      final highAgreeablenessTraits = PersonalityTraits.aurynDefault()
          .copyWith(agreeableness: 0.9);
      
      final profile = PersonalityProfile.aurynDefault().copyWith(
        traits: highAgreeablenessTraits,
      );

      final neutralEmotion = EmotionState(
        mood: 'neutral',
        intensity: 1,
        valence: 0,
        arousal: 1,
      );

      final modulated = profile.modulateEmotion(neutralEmotion);

      // High agreeableness biases toward positive
      expect(modulated.valence, equals(1));
    });

    test('deve modular emoção baseada em extraversion alto', () {
      final highExtraversionTraits = PersonalityTraits.aurynDefault()
          .copyWith(extraversion: 0.85);
      
      final profile = PersonalityProfile.aurynDefault().copyWith(
        traits: highExtraversionTraits,
      );

      final lowArousalEmotion = EmotionState(
        mood: 'calm',
        intensity: 1,
        valence: 1,
        arousal: 1,
      );

      final modulated = profile.modulateEmotion(lowArousalEmotion);

      // High extraversion increases arousal
      expect(modulated.arousal, greaterThan(lowArousalEmotion.arousal));
    });

    test('deve modular emoção baseada em extraversion baixo', () {
      final lowExtraversionTraits = PersonalityTraits.aurynDefault()
          .copyWith(extraversion: 0.3);
      
      final profile = PersonalityProfile.aurynDefault().copyWith(
        traits: lowExtraversionTraits,
      );

      final highArousalEmotion = EmotionState(
        mood: 'excited',
        intensity: 2,
        valence: 1,
        arousal: 3,
      );

      final modulated = profile.modulateEmotion(highArousalEmotion);

      // Low extraversion decreases arousal
      expect(modulated.arousal, lessThan(highArousalEmotion.arousal));
    });

    test('deve ajustar trait e atualizar lastModified', () async {
      final profile = PersonalityProfile.aurynDefault();
      final oldModified = profile.lastModified;

      // Wait a bit to ensure timestamp difference
      await Future.delayed(const Duration(milliseconds: 10));

      final adjusted = profile.adjustTrait('openness', 0.10);

      expect(adjusted.traits.openness, equals(0.85));
      expect(adjusted.lastModified.isAfter(oldModified), isTrue);
    });

    test('deve atualizar emotional baseline', () {
      final profile = PersonalityProfile.aurynDefault();
      final newBaseline = EmotionState(
        mood: 'warm',
        intensity: 2,
        valence: 1,
        arousal: 2,
      );

      final updated = profile.updateEmotionalBaseline(newBaseline);

      expect(updated.emotionalBaseline.mood, equals('warm'));
      expect(updated.emotionalBaseline.intensity, equals(2));
    });

    test('deve atualizar dialog style', () {
      final profile = PersonalityProfile.aurynDefault();
      final newDialogStyle = profile.dialogStyle.copyWith(
        warmth: 0.95,
        precision: 0.80,
      );

      final updated = profile.updateDialogStyle(newDialogStyle);

      expect(updated.dialogStyle.warmth, equals(0.95));
      expect(updated.dialogStyle.precision, equals(0.80));
    });

    test('deve obter e definir preferências contextuais', () {
      final profile = PersonalityProfile.aurynDefault();

      final prefValue = profile.getPreference<bool>('prefer_depth');
      expect(prefValue, equals(true));

      final updated = profile.setPreference('new_preference', 'test_value');
      final newValue = updated.getPreference<String>('new_preference');
      expect(newValue, equals('test_value'));
    });

    test('deve retornar valor padrão para preferência não existente', () {
      final profile = PersonalityProfile.aurynDefault();

      final value = profile.getPreference<String>('non_existent', 
          defaultValue: 'default');
      expect(value, equals('default'));
    });

    test('deve calcular compatibilidade entre profiles', () {
      final profile1 = PersonalityProfile.aurynDefault();
      final profile2 = PersonalityProfile.aurynDefault();

      // Profiles idênticos devem ter alta compatibilidade
      final compatibility = profile1.compatibilityWith(profile2);
      expect(compatibility, greaterThan(0.9));

      // Profiles diferentes devem ter menor compatibilidade
      final profile3 = PersonalityProfile.analytical();
      final compatibility2 = profile1.compatibilityWith(profile3);
      expect(compatibility2, lessThan(compatibility));
    });

    test('deve implementar equals e hashCode baseado em id', () {
      final profile1 = PersonalityProfile.aurynDefault();
      final profile2 = PersonalityProfile.aurynDefault();
      final profile3 = PersonalityProfile.supportive();

      expect(profile1, equals(profile2)); // Same ID
      expect(profile1.hashCode, equals(profile2.hashCode));
      expect(profile1, isNot(equals(profile3))); // Different ID
    });

    test('deve ter toString informativo', () {
      final profile = PersonalityProfile.aurynDefault();
      final str = profile.toString();

      expect(str, contains('PersonalityProfile'));
      expect(str, contains('auryn_default'));
      expect(str, contains('AURYN Default'));
    });
  });
}
