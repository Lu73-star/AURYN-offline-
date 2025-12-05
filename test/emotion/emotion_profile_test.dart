/// test/emotion/emotion_profile_test.dart
/// Testes unitários para EmotionProfile.

import 'package:flutter_test/flutter_test.dart';
import 'package:auryn_offline/auryn_core/emotion/emotion_state.dart';
import 'package:auryn_offline/auryn_core/emotion/emotion_profile.dart';

void main() {
  group('EmotionProfile', () {
    late EmotionProfile profile;

    setUp(() {
      profile = EmotionProfile.defaultProfile();
    });

    test('deve criar perfil padrão', () {
      expect(profile.baseline.mood, equals('neutral'));
      expect(profile.history, isEmpty);
      expect(profile.maxHistorySize, equals(50));
    });

    test('deve criar perfil com parâmetros customizados', () {
      final customProfile = EmotionProfile(
        baseline: EmotionState(
          mood: 'warm',
          intensity: 1,
          valence: 1,
          arousal: 1,
        ),
        maxHistorySize: 100,
      );

      expect(customProfile.baseline.mood, equals('warm'));
      expect(customProfile.maxHistorySize, equals(100));
    });

    test('deve adicionar estado ao histórico', () {
      final state = EmotionState(
        mood: 'happy',
        intensity: 2,
        valence: 1,
        arousal: 2,
      );

      profile.addState(state);

      expect(profile.history.length, equals(1));
      expect(profile.history.first, equals(state));
    });

    test('deve atualizar frequência ao adicionar estados', () {
      final happy1 = EmotionState(
        mood: 'happy',
        intensity: 2,
        valence: 1,
        arousal: 2,
      );

      final happy2 = EmotionState(
        mood: 'happy',
        intensity: 1,
        valence: 1,
        arousal: 2,
      );

      profile.addState(happy1);
      profile.addState(happy2);

      expect(profile.moodFrequency['happy'], equals(2));
    });

    test('deve limitar tamanho do histórico', () {
      // Adiciona mais estados que o máximo
      for (int i = 0; i < 60; i++) {
        profile.addState(EmotionState(
          mood: 'happy',
          intensity: 1,
          valence: 1,
          arousal: 2,
        ));
      }

      expect(profile.history.length, equals(profile.maxHistorySize));
    });

    test('deve retornar estado atual', () {
      expect(profile.currentState, isNull);

      final state = EmotionState(
        mood: 'happy',
        intensity: 2,
        valence: 1,
        arousal: 2,
      );

      profile.addState(state);

      expect(profile.currentState, equals(state));
    });

    test('deve retornar humor dominante', () {
      // Adiciona mais estados "happy"
      for (int i = 0; i < 3; i++) {
        profile.addState(EmotionState(
          mood: 'happy',
          intensity: 1,
          valence: 1,
          arousal: 2,
        ));
      }

      // Adiciona um estado "sad"
      profile.addState(EmotionState(
        mood: 'sad',
        intensity: 1,
        valence: -1,
        arousal: 1,
      ));

      expect(profile.dominantMood, equals('happy'));
    });

    test('deve retornar baseline como dominante quando histórico vazio', () {
      expect(profile.dominantMood, equals(profile.baseline.mood));
    });

    test('deve calcular valência geral', () {
      // Adiciona estados positivos
      profile.addState(EmotionState(
        mood: 'happy',
        intensity: 2,
        valence: 1,
        arousal: 2,
      ));

      profile.addState(EmotionState(
        mood: 'happy',
        intensity: 2,
        valence: 1,
        arousal: 2,
      ));

      expect(profile.overallValence, greaterThan(0));
    });

    test('deve identificar tendência positiva', () {
      // Adiciona vários estados positivos
      for (int i = 0; i < 5; i++) {
        profile.addState(EmotionState(
          mood: 'happy',
          intensity: 2,
          valence: 1,
          arousal: 2,
        ));
      }

      expect(profile.isTrendingPositive, isTrue);
      expect(profile.isTrendingNegative, isFalse);
    });

    test('deve identificar tendência negativa', () {
      // Adiciona vários estados negativos
      for (int i = 0; i < 5; i++) {
        profile.addState(EmotionState(
          mood: 'sad',
          intensity: 2,
          valence: -1,
          arousal: 1,
        ));
      }

      expect(profile.isTrendingNegative, isTrue);
      expect(profile.isTrendingPositive, isFalse);
    });

    test('deve identificar tendência neutra', () {
      // Adiciona estados mistos
      profile.addState(EmotionState(
        mood: 'happy',
        intensity: 1,
        valence: 1,
        arousal: 2,
      ));

      profile.addState(EmotionState(
        mood: 'sad',
        intensity: 1,
        valence: -1,
        arousal: 1,
      ));

      expect(profile.isTrendingNeutral, isTrue);
    });

    test('deve retornar histórico recente', () {
      // Adiciona 15 estados
      for (int i = 0; i < 15; i++) {
        profile.addState(EmotionState(
          mood: 'happy',
          intensity: 1,
          valence: 1,
          arousal: 2,
        ));
      }

      final recent = profile.getRecentHistory(count: 10);

      expect(recent.length, equals(10));
    });

    test('deve retornar todo histórico se menor que count', () {
      profile.addState(EmotionState(
        mood: 'happy',
        intensity: 1,
        valence: 1,
        arousal: 2,
      ));

      final recent = profile.getRecentHistory(count: 10);

      expect(recent.length, equals(1));
    });

    test('deve limpar histórico', () {
      profile.addState(EmotionState(
        mood: 'happy',
        intensity: 1,
        valence: 1,
        arousal: 2,
      ));

      expect(profile.history.length, equals(1));

      profile.clearHistory();

      expect(profile.history.length, equals(0));
      expect(profile.moodFrequency.length, equals(0));
      expect(profile.overallValence, equals(0.0));
    });

    test('deve atualizar baseline', () {
      final newBaseline = EmotionState(
        mood: 'warm',
        intensity: 1,
        valence: 1,
        arousal: 1,
      );

      profile.updateBaseline(newBaseline);

      expect(profile.baseline, equals(newBaseline));
    });

    test('deve obter estatísticas', () {
      profile.addState(EmotionState(
        mood: 'happy',
        intensity: 2,
        valence: 1,
        arousal: 2,
      ));

      final stats = profile.getStatistics();

      expect(stats, isNotNull);
      expect(stats['totalStates'], equals(1));
      expect(stats['dominantMood'], equals('happy'));
      expect(stats['currentMood'], equals('happy'));
      expect(stats.containsKey('overallValence'), isTrue);
      expect(stats.containsKey('moodFrequency'), isTrue);
    });

    test('deve serializar para mapa', () {
      profile.addState(EmotionState(
        mood: 'happy',
        intensity: 2,
        valence: 1,
        arousal: 2,
      ));

      final map = profile.toMap();

      expect(map, isNotNull);
      expect(map['baseline'], isNotNull);
      expect(map['history'], isA<List>());
      expect(map['maxHistorySize'], equals(50));
      expect(map['moodFrequency'], isNotNull);
    });

    test('deve deserializar de mapa', () {
      profile.addState(EmotionState(
        mood: 'happy',
        intensity: 2,
        valence: 1,
        arousal: 2,
      ));

      final map = profile.toMap();
      final restored = EmotionProfile.fromMap(map);

      expect(restored.baseline.mood, equals(profile.baseline.mood));
      expect(restored.history.length, equals(profile.history.length));
      expect(restored.maxHistorySize, equals(profile.maxHistorySize));
    });

    test('deve preservar dados na serialização/deserialização', () {
      // Adiciona vários estados
      for (int i = 0; i < 5; i++) {
        profile.addState(EmotionState(
          mood: 'happy',
          intensity: 2,
          valence: 1,
          arousal: 2,
        ));
      }

      profile.addState(EmotionState(
        mood: 'sad',
        intensity: 1,
        valence: -1,
        arousal: 1,
      ));

      final map = profile.toMap();
      final restored = EmotionProfile.fromMap(map);

      expect(restored.dominantMood, equals(profile.dominantMood));
      expect(restored.moodFrequency, equals(profile.moodFrequency));
    });

    test('toString deve retornar informação útil', () {
      profile.addState(EmotionState(
        mood: 'happy',
        intensity: 2,
        valence: 1,
        arousal: 2,
      ));

      final str = profile.toString();

      expect(str, contains('EmotionProfile'));
      expect(str, contains('baseline'));
      expect(str, contains('happy'));
    });

    test('deve calcular duração média dos humores', () {
      // Adiciona estados com timestamps diferentes
      final state1 = EmotionState(
        mood: 'happy',
        intensity: 1,
        valence: 1,
        arousal: 2,
        timestamp: DateTime.now().subtract(Duration(seconds: 10)),
      );

      final state2 = EmotionState(
        mood: 'calm',
        intensity: 1,
        valence: 1,
        arousal: 1,
        timestamp: DateTime.now(),
      );

      profile.addState(state1);
      profile.addState(state2);

      // Deve ter calculado duração para 'happy'
      expect(profile.moodDuration.containsKey('happy'), isTrue);
    });
  });
}
