/// test/emotion/emotion_regulator_test.dart
/// Testes unitários para EmotionRegulator.

import 'package:flutter_test/flutter_test.dart';
import 'package:auryn_offline/auryn_core/emotion/emotion_state.dart';
import 'package:auryn_offline/auryn_core/emotion/emotion_profile.dart';
import 'package:auryn_offline/auryn_core/emotion/emotion_regulator.dart';

void main() {
  group('EmotionRegulator', () {
    late EmotionProfile profile;
    late EmotionRegulator regulator;

    setUp(() {
      profile = EmotionProfile.defaultProfile();
      regulator = EmotionRegulator(profile: profile);
    });

    test('deve criar regulador com perfil', () {
      expect(regulator.profile, equals(profile));
      expect(regulator.decayRate, equals(0.3));
    });

    test('deve interpretar input feliz', () {
      final state = regulator.interpretInput('Estou muito feliz hoje!');

      expect(state.mood, equals('happy'));
      expect(state.intensity, greaterThan(0));
      expect(state.valence, equals(1));
    });

    test('deve interpretar input triste', () {
      final state = regulator.interpretInput('Estou triste e chateado');

      expect(state.mood, equals('sad'));
      expect(state.valence, equals(-1));
    });

    test('deve interpretar input calmo', () {
      final state = regulator.interpretInput('Estou muito calmo e tranquilo');

      expect(state.mood, equals('calm'));
      expect(state.valence, equals(1));
      expect(state.arousal, lessThanOrEqualTo(1));
    });

    test('deve interpretar input ansioso', () {
      final state = regulator.interpretInput('Estou muito nervoso e preocupado');

      expect(state.mood, equals('anxious'));
      expect(state.valence, equals(-1));
      expect(state.arousal, greaterThanOrEqualTo(2));
    });

    test('deve interpretar input com baixa energia', () {
      final state = regulator.interpretInput('Estou muito cansado e exausto');

      expect(state.mood, equals('low_energy'));
      expect(state.valence, equals(-1));
      expect(state.arousal, equals(0));
    });

    test('deve interpretar input irritado', () {
      final state = regulator.interpretInput('Estou com muita raiva');

      expect(state.mood, equals('irritated'));
      expect(state.valence, equals(-1));
      expect(state.arousal, equals(3));
    });

    test('deve interpretar input reflexivo', () {
      final state = regulator.interpretInput('Estou pensando sobre isso');

      expect(state.mood, equals('reflective'));
      expect(state.valence, equals(0));
    });

    test('deve retornar neutro para input sem emoção específica', () {
      final state = regulator.interpretInput('Olá, como vai?');

      expect(state.mood, equals('neutral'));
      expect(state.intensity, equals(0));
    });

    test('deve regular transição direta para pequena diferença', () {
      final current = EmotionState(
        mood: 'neutral',
        intensity: 1,
        valence: 0,
        arousal: 1,
      );

      final target = EmotionState(
        mood: 'happy',
        intensity: 2,
        valence: 1,
        arousal: 2,
      );

      final result = regulator.regulateTransition(current, target);

      // Diferença de 1 permite transição direta
      expect(result.mood, equals('happy'));
      expect(result.intensity, equals(2));
    });

    test('deve regular transição gradual para grande diferença', () {
      final current = EmotionState(
        mood: 'neutral',
        intensity: 0,
        valence: 0,
        arousal: 1,
      );

      final target = EmotionState(
        mood: 'happy',
        intensity: 3,
        valence: 1,
        arousal: 2,
      );

      final result = regulator.regulateTransition(current, target);

      // Deve aumentar apenas 1 ponto
      expect(result.mood, equals('happy'));
      expect(result.intensity, equals(1));
    });

    test('deve aplicar decaimento quando não está no baseline', () {
      final current = EmotionState(
        mood: 'happy',
        intensity: 2,
        valence: 1,
        arousal: 2,
      );

      final decayed = regulator.applyDecay(current);

      expect(decayed.intensity, lessThanOrEqualTo(current.intensity));
    });

    test('deve retornar ao baseline quando intensidade chega a 0', () {
      final current = EmotionState(
        mood: 'happy',
        intensity: 1,
        valence: 1,
        arousal: 2,
      );

      // Com decayRate de 0.3, deve reduzir a 0
      final decayed = regulator.applyDecay(current);

      // Pode levar múltiplas aplicações, vamos aplicar várias vezes
      var result = decayed;
      for (int i = 0; i < 5; i++) {
        result = regulator.applyDecay(result);
      }

      expect(result.mood, equals(profile.baseline.mood));
    });

    test('deve não aplicar decaimento se já está no baseline', () {
      final baseline = profile.baseline;
      final result = regulator.applyDecay(baseline);

      expect(result, equals(baseline));
    });

    test('deve modular resposta para estado feliz', () {
      final state = EmotionState(
        mood: 'happy',
        intensity: 2,
        valence: 1,
        arousal: 2,
      );

      final response = regulator.modulateResponse('Vamos conversar!', state);

      expect(response, contains('Vamos conversar!'));
      expect(response, isNot(equals('Vamos conversar!')));
      expect(response.length, greaterThan('Vamos conversar!'.length));
    });

    test('deve modular resposta para estado triste', () {
      final state = EmotionState(
        mood: 'sad',
        intensity: 2,
        valence: -1,
        arousal: 1,
      );

      final response = regulator.modulateResponse('Tudo bem.', state);

      expect(response, contains('Tudo bem.'));
      expect(response, contains('contigo'));
    });

    test('deve não modular resposta para estado neutro', () {
      final state = EmotionState.neutral();
      final text = 'Olá!';

      final response = regulator.modulateResponse(text, state);

      expect(response, equals(text));
    });

    test('deve não modular resposta para baixa intensidade', () {
      final state = EmotionState(
        mood: 'happy',
        intensity: 0,
        valence: 1,
        arousal: 2,
      );

      final text = 'Teste';
      final response = regulator.modulateResponse(text, state);

      expect(response, equals(text));
    });

    test('deve ajustar intensidade com delta positivo', () {
      final state = EmotionState(
        mood: 'happy',
        intensity: 1,
        valence: 1,
        arousal: 2,
      );

      final adjusted = regulator.adjustIntensity(state, delta: 1);

      expect(adjusted.intensity, equals(2));
      expect(adjusted.mood, equals(state.mood));
    });

    test('deve ajustar intensidade com delta negativo', () {
      final state = EmotionState(
        mood: 'happy',
        intensity: 2,
        valence: 1,
        arousal: 2,
      );

      final adjusted = regulator.adjustIntensity(state, delta: -1);

      expect(adjusted.intensity, equals(1));
    });

    test('deve limitar intensidade entre 0 e 3', () {
      final state = EmotionState(
        mood: 'happy',
        intensity: 3,
        valence: 1,
        arousal: 2,
      );

      final adjusted = regulator.adjustIntensity(state, delta: 5);

      expect(adjusted.intensity, equals(3));
    });

    test('deve criar estado customizado', () {
      final state = regulator.createCustomState(
        mood: 'excited',
        intensity: 2,
        valence: 1,
        arousal: 3,
      );

      expect(state.mood, equals('excited'));
      expect(state.intensity, equals(2));
      expect(state.valence, equals(1));
      expect(state.arousal, equals(3));
    });

    test('deve limitar valores ao criar estado customizado', () {
      final state = regulator.createCustomState(
        mood: 'test',
        intensity: 10,
        valence: 5,
        arousal: -1,
      );

      expect(state.intensity, equals(3)); // Max é 3
      expect(state.valence, equals(1)); // Max é 1
      expect(state.arousal, equals(0)); // Min é 0
    });

    test('deve analisar sentimento positivo', () {
      final sentiment = regulator.analyzeSentiment('Que dia ótimo e feliz!');

      expect(sentiment['sentiment'], greaterThan(0));
      expect(sentiment['positiveCount'], greaterThan(0));
      expect(sentiment['isPositive'], isTrue);
    });

    test('deve analisar sentimento negativo', () {
      final sentiment = regulator.analyzeSentiment('Que dia péssimo e triste.');

      expect(sentiment['sentiment'], lessThan(0));
      expect(sentiment['negativeCount'], greaterThan(0));
      expect(sentiment['isNegative'], isTrue);
    });

    test('deve analisar sentimento neutro', () {
      final sentiment = regulator.analyzeSentiment('A mesa é azul.');

      expect(sentiment['sentiment'], equals(0.0));
      expect(sentiment['isNeutral'], isTrue);
    });

    test('deve contar palavras positivas e negativas', () {
      final sentiment = regulator.analyzeSentiment('Bom dia, mas estou mal.');

      expect(sentiment['positiveCount'], equals(1)); // "bom"
      expect(sentiment['negativeCount'], equals(1)); // "mal"
    });
  });
}
