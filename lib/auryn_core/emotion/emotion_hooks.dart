/// lib/auryn_core/emotion/emotion_hooks.dart
/// Sistema de hooks para eventos emocionais.
/// 
/// EmotionHooks permite que outros módulos da AURYN sejam notificados
/// sobre mudanças emocionais e reajam apropriadamente.
/// 
/// Exemplos de uso:
/// - Sistema de voz pode ajustar tom baseado na emoção
/// - Sistema de personalidade pode adaptar respostas
/// - Sistema de memória pode marcar momentos emocionalmente significativos

import 'emotion_state.dart';

/// Tipo de callback para mudanças de estado emocional
typedef EmotionChangeCallback = void Function(
    EmotionState previous, EmotionState current);

/// Tipo de callback para eventos de intensidade alta
typedef HighIntensityCallback = void Function(EmotionState state);

/// Tipo de callback para mudanças de humor
typedef MoodChangeCallback = void Function(String previousMood, String newMood);

/// Gerenciador de hooks de eventos emocionais
class EmotionHooks {
  /// Lista de callbacks registrados para mudanças de estado
  final List<EmotionChangeCallback> _onStateChangeCallbacks = [];

  /// Lista de callbacks para eventos de alta intensidade
  final List<HighIntensityCallback> _onHighIntensityCallbacks = [];

  /// Lista de callbacks para mudanças de humor
  final List<MoodChangeCallback> _onMoodChangeCallbacks = [];

  /// Lista de callbacks para valência positiva
  final List<EmotionChangeCallback> _onPositiveCallbacks = [];

  /// Lista de callbacks para valência negativa
  final List<EmotionChangeCallback> _onNegativeCallbacks = [];

  /// Registra callback para qualquer mudança de estado
  void onStateChange(EmotionChangeCallback callback) {
    _onStateChangeCallbacks.add(callback);
  }

  /// Registra callback para eventos de alta intensidade (>= 2)
  void onHighIntensity(HighIntensityCallback callback) {
    _onHighIntensityCallbacks.add(callback);
  }

  /// Registra callback para mudanças de humor
  void onMoodChange(MoodChangeCallback callback) {
    _onMoodChangeCallbacks.add(callback);
  }

  /// Registra callback para estados positivos
  void onPositiveEmotion(EmotionChangeCallback callback) {
    _onPositiveCallbacks.add(callback);
  }

  /// Registra callback para estados negativos
  void onNegativeEmotion(EmotionChangeCallback callback) {
    _onNegativeCallbacks.add(callback);
  }

  /// Remove callback de mudança de estado
  void removeStateChangeCallback(EmotionChangeCallback callback) {
    _onStateChangeCallbacks.remove(callback);
  }

  /// Remove callback de alta intensidade
  void removeHighIntensityCallback(HighIntensityCallback callback) {
    _onHighIntensityCallbacks.remove(callback);
  }

  /// Remove callback de mudança de humor
  void removeMoodChangeCallback(MoodChangeCallback callback) {
    _onMoodChangeCallbacks.remove(callback);
  }

  /// Remove callback de emoção positiva
  void removePositiveCallback(EmotionChangeCallback callback) {
    _onPositiveCallbacks.remove(callback);
  }

  /// Remove callback de emoção negativa
  void removeNegativeCallback(EmotionChangeCallback callback) {
    _onNegativeCallbacks.remove(callback);
  }

  /// Limpa todos os callbacks registrados
  void clearAllCallbacks() {
    _onStateChangeCallbacks.clear();
    _onHighIntensityCallbacks.clear();
    _onMoodChangeCallbacks.clear();
    _onPositiveCallbacks.clear();
    _onNegativeCallbacks.clear();
  }

  /// Dispara eventos quando há mudança de estado emocional
  void notifyStateChange(EmotionState previous, EmotionState current) {
    // Notifica todos os callbacks de mudança de estado
    for (final callback in _onStateChangeCallbacks) {
      try {
        callback(previous, current);
      } catch (e) {
        // Log do erro mas continua notificando outros callbacks
        print('Error in emotion state change callback: $e');
      }
    }

    // Verifica se houve mudança de humor
    if (previous.mood != current.mood) {
      _notifyMoodChange(previous.mood, current.mood);
    }

    // Verifica se intensidade é alta
    if (current.intensity >= 2) {
      _notifyHighIntensity(current);
    }

    // Verifica valência
    if (current.valence > 0) {
      _notifyPositiveEmotion(previous, current);
    } else if (current.valence < 0) {
      _notifyNegativeEmotion(previous, current);
    }
  }

  /// Notifica callbacks de mudança de humor
  void _notifyMoodChange(String previousMood, String newMood) {
    for (final callback in _onMoodChangeCallbacks) {
      try {
        callback(previousMood, newMood);
      } catch (e) {
        print('Error in mood change callback: $e');
      }
    }
  }

  /// Notifica callbacks de alta intensidade
  void _notifyHighIntensity(EmotionState state) {
    for (final callback in _onHighIntensityCallbacks) {
      try {
        callback(state);
      } catch (e) {
        print('Error in high intensity callback: $e');
      }
    }
  }

  /// Notifica callbacks de emoção positiva
  void _notifyPositiveEmotion(EmotionState previous, EmotionState current) {
    for (final callback in _onPositiveCallbacks) {
      try {
        callback(previous, current);
      } catch (e) {
        print('Error in positive emotion callback: $e');
      }
    }
  }

  /// Notifica callbacks de emoção negativa
  void _notifyNegativeEmotion(EmotionState previous, EmotionState current) {
    for (final callback in _onNegativeCallbacks) {
      try {
        callback(previous, current);
      } catch (e) {
        print('Error in negative emotion callback: $e');
      }
    }
  }

  /// Retorna o número de callbacks registrados
  Map<String, int> get callbackCounts {
    return {
      'stateChange': _onStateChangeCallbacks.length,
      'highIntensity': _onHighIntensityCallbacks.length,
      'moodChange': _onMoodChangeCallbacks.length,
      'positive': _onPositiveCallbacks.length,
      'negative': _onNegativeCallbacks.length,
    };
  }

  /// Verifica se há algum callback registrado
  bool get hasCallbacks {
    return _onStateChangeCallbacks.isNotEmpty ||
        _onHighIntensityCallbacks.isNotEmpty ||
        _onMoodChangeCallbacks.isNotEmpty ||
        _onPositiveCallbacks.isNotEmpty ||
        _onNegativeCallbacks.isNotEmpty;
  }

  @override
  String toString() {
    return 'EmotionHooks(callbacks: $callbackCounts)';
  }
}

/// Classe auxiliar para criar hooks pré-configurados
class EmotionHookPresets {
  /// Hook que loga todas as mudanças emocionais
  static EmotionChangeCallback get loggingHook {
    return (previous, current) {
      print('[EmotionLog] Mudança: ${previous.mood} -> ${current.mood} '
          '(intensity: ${current.intensity}, valence: ${current.valence})');
    };
  }

  /// Hook que detecta mudanças dramáticas (intensidade >= 2)
  static HighIntensityCallback get dramaticChangeHook {
    return (state) {
      print('[EmotionAlert] Estado emocional intenso detectado: '
          '${state.mood} (intensity: ${state.intensity})');
    };
  }

  /// Hook que rastreia mudanças de humor
  static MoodChangeCallback get moodTrackingHook {
    return (previousMood, newMood) {
      print('[MoodTracker] Humor mudou: $previousMood -> $newMood');
    };
  }

  /// Hook que celebra emoções positivas
  static EmotionChangeCallback get positiveEmotionHook {
    return (previous, current) {
      print('[PositiveVibes] Emoção positiva detectada: ${current.mood}');
    };
  }

  /// Hook que oferece suporte em emoções negativas
  static EmotionChangeCallback get supportiveHook {
    return (previous, current) {
      print('[Support] Emoção negativa detectada: ${current.mood}. '
          'Sistema de suporte ativado.');
    };
  }
}
