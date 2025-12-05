/// test/emotion/emotion_core_test.dart
/// Testes unitários para EmotionCore - sistema completo de emoções.

import 'package:flutter_test/flutter_test.dart';
import 'package:auryn_offline/auryn_core/emotion/emotion_core.dart';
import 'package:auryn_offline/auryn_core/emotion/emotion_state.dart';
import 'package:auryn_offline/auryn_core/emotion/emotion_profile.dart';

void main() {
  group('EmotionCore', () {
    late EmotionCore emotionCore;

    setUp(() async {
      emotionCore = EmotionCore();
      await emotionCore.initialize();
    });

    tearDown(() {
      emotionCore.clearHistory();
    });

    test('deve inicializar corretamente', () async {
      expect(emotionCore.isInitialized, isTrue);
      expect(emotionCore.currentState, isNotNull);
      expect(emotionCore.currentState.mood, equals('neutral'));
    });

    test('deve lançar StateError quando não inicializado', () {
      final uninitializedCore = EmotionCore();
      expect(
        () => uninitializedCore.currentState,
        throwsStateError,
      );
    });

    test('deve processar input e atualizar estado', () {
      emotionCore.processInput('Estou muito feliz hoje!');

      final state = emotionCore.currentState;
      expect(state.mood, equals('happy'));
      expect(state.intensity, greaterThan(0));
      expect(state.valence, equals(1));
    });

    test('deve processar input triste', () {
      emotionCore.processInput('Estou muito triste e mal');

      final state = emotionCore.currentState;
      expect(state.mood, equals('sad'));
      expect(state.valence, equals(-1));
    });

    test('deve modular resposta baseada no estado emocional', () {
      emotionCore.processInput('Estou feliz!');

      final response = emotionCore.modulateResponse('Vamos conversar!');
      expect(response, contains('Vamos conversar!'));
      // Deve conter um prefixo emocional se intensidade > 0
    });

    test('deve aplicar decaimento emocional', () {
      // Define estado com intensidade alta
      emotionCore.setState(EmotionState(
        mood: 'happy',
        intensity: 3,
        valence: 1,
        arousal: 2,
      ));

      final initialIntensity = emotionCore.currentState.intensity;

      // Aplica decaimento
      emotionCore.applyDecay();

      final afterDecay = emotionCore.currentState.intensity;
      expect(afterDecay, lessThanOrEqualTo(initialIntensity));
    });

    test('deve resetar para baseline', () {
      emotionCore.processInput('Estou muito feliz!');
      expect(emotionCore.currentState.mood, isNot('neutral'));

      emotionCore.resetToBaseline();
      expect(emotionCore.currentState.mood, equals('neutral'));
    });

    test('deve atualizar baseline', () {
      final newBaseline = EmotionState(
        mood: 'warm',
        intensity: 1,
        valence: 1,
        arousal: 1,
      );

      emotionCore.updateBaseline(newBaseline);
      expect(emotionCore.profile.baseline.mood, equals('warm'));
    });

    test('deve obter estatísticas do perfil', () {
      emotionCore.processInput('Estou feliz!');
      emotionCore.processInput('Estou muito feliz!');

      final stats = emotionCore.getStatistics();
      expect(stats, isNotNull);
      expect(stats['totalStates'], greaterThan(0));
      expect(stats['currentMood'], isNotNull);
    });

    test('deve obter histórico recente', () {
      emotionCore.processInput('Estou feliz!');
      emotionCore.processInput('Estou calmo.');

      final history = emotionCore.getRecentHistory(count: 5);
      expect(history, isNotEmpty);
      expect(history.length, lessThanOrEqualTo(5));
    });

    test('deve analisar sentimento de texto', () {
      final sentiment = emotionCore.analyzeSentiment('Que dia ótimo e feliz!');

      expect(sentiment, isNotNull);
      expect(sentiment['sentiment'], isA<double>());
      expect(sentiment.containsKey('isPositive'), isTrue);
    });

    test('deve ajustar intensidade', () {
      emotionCore.setState(EmotionState(
        mood: 'happy',
        intensity: 1,
        valence: 1,
        arousal: 2,
      ));

      emotionCore.adjustIntensity(delta: 1);
      expect(emotionCore.currentState.intensity, equals(2));

      emotionCore.adjustIntensity(delta: -1);
      expect(emotionCore.currentState.intensity, equals(1));
    });

    test('deve criar emoção customizada', () {
      emotionCore.setCustomEmotion(
        mood: 'excited',
        intensity: 2,
        valence: 1,
        arousal: 3,
      );

      final state = emotionCore.currentState;
      expect(state.mood, equals('excited'));
      expect(state.intensity, equals(2));
      expect(state.valence, equals(1));
      expect(state.arousal, equals(3));
    });

    test('deve limpar histórico', () {
      emotionCore.processInput('Estou feliz!');
      emotionCore.processInput('Estou calmo.');

      expect(emotionCore.profile.history.length, greaterThan(0));

      emotionCore.clearHistory();
      expect(emotionCore.profile.history.length, equals(0));
    });

    test('deve exportar e importar perfil', () async {
      emotionCore.processInput('Estou muito feliz!');
      emotionCore.processInput('Estou calmo agora.');

      final exported = emotionCore.exportProfile();
      expect(exported, isNotNull);
      expect(exported['history'], isNotEmpty);

      // Cria nova instância e importa
      final newCore = EmotionCore();
      await newCore.importProfile(exported);

      expect(newCore.isInitialized, isTrue);
      expect(newCore.profile.history.length, equals(emotionCore.profile.history.length));
    });

    test('deve registrar e disparar hooks de mudança de estado', () {
      int callbackCount = 0;

      emotionCore.onStateChange((prev, curr) {
        callbackCount++;
        expect(prev, isNotNull);
        expect(curr, isNotNull);
      });

      emotionCore.processInput('Estou feliz!');
      expect(callbackCount, equals(1));

      emotionCore.processInput('Estou triste.');
      expect(callbackCount, equals(2));
    });

    test('deve registrar hook para alta intensidade', () {
      bool highIntensityDetected = false;

      emotionCore.onHighIntensity((state) {
        highIntensityDetected = true;
        expect(state.intensity, greaterThanOrEqualTo(2));
      });

      // Estado com baixa intensidade
      emotionCore.setState(EmotionState(
        mood: 'calm',
        intensity: 1,
        valence: 0,
        arousal: 1,
      ));
      expect(highIntensityDetected, isFalse);

      // Estado com alta intensidade
      emotionCore.setState(EmotionState(
        mood: 'happy',
        intensity: 3,
        valence: 1,
        arousal: 2,
      ));
      expect(highIntensityDetected, isTrue);
    });

    test('deve registrar hook para mudança de humor', () {
      String? previousMood;
      String? newMood;

      emotionCore.onMoodChange((prev, curr) {
        previousMood = prev;
        newMood = curr;
      });

      emotionCore.processInput('Estou feliz!');

      if (emotionCore.currentState.mood != 'neutral') {
        expect(previousMood, equals('neutral'));
        expect(newMood, equals('happy'));
      }
    });

    test('deve registrar hook para emoções positivas', () {
      bool positiveEmotionDetected = false;

      emotionCore.onPositiveEmotion((prev, curr) {
        positiveEmotionDetected = true;
        expect(curr.valence, greaterThan(0));
      });

      emotionCore.processInput('Estou muito feliz!');
      expect(positiveEmotionDetected, isTrue);
    });

    test('deve registrar hook para emoções negativas', () {
      bool negativeEmotionDetected = false;

      emotionCore.onNegativeEmotion((prev, curr) {
        negativeEmotionDetected = true;
        expect(curr.valence, lessThan(0));
      });

      emotionCore.processInput('Estou muito triste.');
      expect(negativeEmotionDetected, isTrue);
    });

    test('deve obter informações de debug', () {
      final debugInfo = emotionCore.getDebugInfo();

      expect(debugInfo, isNotNull);
      expect(debugInfo['initialized'], isTrue);
      expect(debugInfo['currentState'], isNotNull);
      expect(debugInfo['baseline'], isNotNull);
    });

    test('deve fazer reset completo', () async {
      emotionCore.processInput('Estou feliz!');
      emotionCore.onStateChange((prev, curr) {});

      await emotionCore.reset();

      expect(emotionCore.currentState.mood, equals('neutral'));
      expect(emotionCore.hooks.hasCallbacks, isFalse);
    });

    test('toString deve retornar informação útil', () {
      final str = emotionCore.toString();
      expect(str, contains('EmotionCore'));
      expect(str, contains('neutral'));
    });
  });
}
