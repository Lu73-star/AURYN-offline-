/// test/personality/behavior_shaping_test.dart
/// Tests for BehaviorShaping - directive computation, context handling.

import 'package:flutter_test/flutter_test.dart';
import 'package:auryn_offline/auryn_core/personality/behavior_shaping.dart';
import 'package:auryn_offline/auryn_core/personality/personality_traits.dart';
import 'package:auryn_offline/auryn_core/emotion/emotion_state.dart';

void main() {
  group('BehaviorContext', () {
    test('deve criar context casual', () {
      final context = BehaviorContext.casual();

      expect(context.interactionType, equals('casual'));
      expect(context.userEnergy, equals(0.6));
      expect(context.urgency, equals(0.3));
      expect(context.topicComplexity, equals(0.4));
    });

    test('deve criar context support', () {
      final context = BehaviorContext.support();

      expect(context.interactionType, equals('support'));
      expect(context.userEnergy, equals(0.4));
      expect(context.urgency, equals(0.6));
    });

    test('deve criar context learning', () {
      final context = BehaviorContext.learning();

      expect(context.interactionType, equals('learning'));
      expect(context.topicComplexity, equals(0.7));
    });

    test('deve serializar context corretamente', () {
      final context = BehaviorContext.casual();
      final map = context.toMap();

      expect(map['interactionType'], equals('casual'));
      expect(map['userEnergy'], equals(0.6));
    });
  });

  group('BehaviorShaping', () {
    late PersonalityTraits traits;
    late EmotionState emotionState;
    late BehaviorContext context;

    setUp(() {
      traits = PersonalityTraits.aurynDefault();
      emotionState = EmotionState.neutral();
      context = BehaviorContext.casual();
    });

    test('deve computar behavioral directive básico', () {
      final directive = BehaviorShaping.computeDirective(
        emotionState: emotionState,
        traits: traits,
        context: context,
      );

      expect(directive, isNotNull);
      expect(directive.dialogStyle, isNotNull);
      expect(directive.toneIndicators, isNotEmpty);
      expect(directive.pacing, isNotNull);
      expect(directive.responseStrategy, isNotNull);
    });

    test('deve ajustar dialog style baseado em emoção', () {
      final happyEmotion = EmotionState(
        mood: 'happy',
        intensity: 2,
        valence: 1,
        arousal: 2,
      );

      final directive = BehaviorShaping.computeDirective(
        emotionState: happyEmotion,
        traits: traits,
        context: context,
      );

      // Dialog style should reflect happiness
      expect(directive.dialogStyle.warmth, greaterThan(0.5));
      expect(directive.dialogStyle.expressiveness, greaterThan(0.5));
    });

    test('deve gerar tone indicators apropriados para emoção positiva', () {
      final happyEmotion = EmotionState(
        mood: 'happy',
        intensity: 2,
        valence: 1,
        arousal: 2,
      );

      final playfulTraits = traits.copyWith(
        playfulness: 0.8,
        agreeableness: 0.85,
      );

      final directive = BehaviorShaping.computeDirective(
        emotionState: happyEmotion,
        traits: playfulTraits,
        context: context,
      );

      // Should have positive tone indicators
      expect(directive.toneIndicators, isNotEmpty);
      expect(
        directive.toneIndicators.any((t) => 
          t == 'playful' || t == 'warm' || t == 'balanced'),
        isTrue,
      );
    });

    test('deve gerar tone indicators apropriados para emoção negativa', () {
      final sadEmotion = EmotionState(
        mood: 'sad',
        intensity: 2,
        valence: -1,
        arousal: 1,
      );

      final emphaticTraits = traits.copyWith(
        agreeableness: 0.9,
        intellectualism: 0.75,
      );

      final directive = BehaviorShaping.computeDirective(
        emotionState: sadEmotion,
        traits: emphaticTraits,
        context: context,
      );

      // Should have supportive tone indicators
      expect(
        directive.toneIndicators.any((t) => 
          t == 'supportive' || t == 'understanding'),
        isTrue,
      );
    });

    test('deve ajustar tone indicators para context support', () {
      final supportContext = BehaviorContext.support();
      final sadEmotion = EmotionState(
        mood: 'sad',
        intensity: 2,
        valence: -1,
        arousal: 1,
      );

      final directive = BehaviorShaping.computeDirective(
        emotionState: sadEmotion,
        traits: traits,
        context: supportContext,
      );

      expect(directive.toneIndicators, contains('compassionate'));
    });

    test('deve ajustar tone indicators para context learning', () {
      final learningContext = BehaviorContext.learning();

      final directive = BehaviorShaping.computeDirective(
        emotionState: emotionState,
        traits: traits,
        context: learningContext,
      );

      expect(directive.toneIndicators, contains('instructive'));
    });

    test('deve determinar pacing baseado em traits e context', () {
      final slowContext = BehaviorContext(
        interactionType: 'casual',
        urgency: 0.1,
      );

      final introvertedTraits = traits.copyWith(extraversion: 0.3);

      final directive = BehaviorShaping.computeDirective(
        emotionState: emotionState,
        traits: introvertedTraits,
        context: slowContext,
      );

      expect(directive.pacing, equals('slow'));
    });

    test('deve determinar pacing rápido para alta urgência', () {
      final urgentContext = BehaviorContext(
        interactionType: 'casual',
        urgency: 0.9,
      );

      final energeticTraits = traits.copyWith(extraversion: 0.8);

      final directive = BehaviorShaping.computeDirective(
        emotionState: emotionState,
        traits: energeticTraits,
        context: urgentContext,
      );

      expect(directive.pacing, equals('fast'));
    });

    test('deve escolher estratégia empathetic para support negativo', () {
      final supportContext = BehaviorContext.support();
      final sadEmotion = EmotionState(
        mood: 'sad',
        intensity: 2,
        valence: -1,
        arousal: 1,
      );

      final emphaticTraits = traits.copyWith(agreeableness: 0.9);

      final directive = BehaviorShaping.computeDirective(
        emotionState: sadEmotion,
        traits: emphaticTraits,
        context: supportContext,
      );

      expect(directive.responseStrategy, equals('empathetic'));
    });

    test('deve escolher estratégia elaborate para learning complexo', () {
      final learningContext = BehaviorContext.learning();
      final intellectualTraits = traits.copyWith(intellectualism: 0.85);

      final directive = BehaviorShaping.computeDirective(
        emotionState: emotionState,
        traits: intellectualTraits,
        context: learningContext,
      );

      expect(
        directive.responseStrategy,
        anyOf(equals('elaborate'), equals('structured')),
      );
    });

    test('deve calcular emotional engagement apropriadamente', () {
      final intenseSadEmotion = EmotionState(
        mood: 'sad',
        intensity: 3,
        valence: -1,
        arousal: 2,
      );

      final supportContext = BehaviorContext.support();
      final emphaticTraits = traits.copyWith(agreeableness: 0.95);

      final directive = BehaviorShaping.computeDirective(
        emotionState: intenseSadEmotion,
        traits: emphaticTraits,
        context: supportContext,
      );

      expect(directive.emotionalEngagement, greaterThan(0.5));
    });

    test('deve marcar acknowledgeEmotion para alta intensidade', () {
      final intenseEmotion = EmotionState(
        mood: 'happy',
        intensity: 3,
        valence: 1,
        arousal: 3,
      );

      final directive = BehaviorShaping.computeDirective(
        emotionState: intenseEmotion,
        traits: traits,
        context: context,
      );

      expect(directive.acknowledgeEmotion, isTrue);
    });

    test('deve marcar acknowledgeEmotion para negativo com support', () {
      final sadEmotion = EmotionState(
        mood: 'sad',
        intensity: 1,
        valence: -1,
        arousal: 1,
      );

      final supportContext = BehaviorContext.support();

      final directive = BehaviorShaping.computeDirective(
        emotionState: sadEmotion,
        traits: traits,
        context: supportContext,
      );

      expect(directive.acknowledgeEmotion, isTrue);
    });

    test('deve calcular length factor baseado em traits', () {
      final verboseTraits = traits.copyWith(
        intellectualism: 0.9,
        conscientiousness: 0.9,
      );

      final complexContext = BehaviorContext(
        interactionType: 'learning',
        topicComplexity: 0.8,
      );

      final directive = BehaviorShaping.computeDirective(
        emotionState: emotionState,
        traits: verboseTraits,
        context: complexContext,
      );

      expect(directive.lengthFactor, greaterThan(1.0));
    });

    test('deve reduzir length factor para alta urgência', () {
      final urgentContext = BehaviorContext(
        interactionType: 'casual',
        urgency: 0.9,
      );

      final directive = BehaviorShaping.computeDirective(
        emotionState: emotionState,
        traits: traits,
        context: urgentContext,
      );

      expect(directive.lengthFactor, lessThan(1.0));
    });

    test('deve incluir priority aspects apropriados', () {
      final intenseNegativeEmotion = EmotionState(
        mood: 'anxious',
        intensity: 3,
        valence: -1,
        arousal: 3,
      );

      final directive = BehaviorShaping.computeDirective(
        emotionState: intenseNegativeEmotion,
        traits: traits,
        context: context,
      );

      expect(directive.priorityAspects, contains('emotional_support'));
    });

    test('deve incluir direct_answer para alta urgência', () {
      final urgentContext = BehaviorContext(
        interactionType: 'casual',
        urgency: 0.9,
      );

      final directive = BehaviorShaping.computeDirective(
        emotionState: emotionState,
        traits: traits,
        context: urgentContext,
      );

      expect(directive.priorityAspects, contains('direct_answer'));
    });

    test('deve serializar behavioral directive corretamente', () {
      final directive = BehaviorShaping.computeDirective(
        emotionState: emotionState,
        traits: traits,
        context: context,
      );

      final map = directive.toMap();

      expect(map['pacing'], isNotNull);
      expect(map['responseStrategy'], isNotNull);
      expect(map['toneIndicators'], isList);
      expect(map['dialogStyle'], isMap);
    });

    test('deve ter toString informativo', () {
      final directive = BehaviorShaping.computeDirective(
        emotionState: emotionState,
        traits: traits,
        context: context,
      );

      final str = directive.toString();

      expect(str, contains('BehavioralDirective'));
      expect(str, contains('pacing'));
      expect(str, contains('strategy'));
    });
  });
}
