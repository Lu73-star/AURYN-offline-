/// lib/voice/speech_flow.dart
/// Coordena estados da fala:
/// idle → listening → processing → speaking → listening
/// Controla pausas naturais, interrupções e sincronização.
/// Integrado com sistema de eventos.

import 'package:auryn_offline/auryn_core/events/event_bus.dart';
import 'package:auryn_offline/auryn_core/events/auryn_event.dart';

/// Estados possíveis do fluxo de voz
enum VoiceFlowState {
  idle,
  listening,
  processing,
  speaking,
  interrupted,
  error,
}

class SpeechFlow {
  static final SpeechFlow _instance = SpeechFlow._internal();
  factory SpeechFlow() => _instance;
  SpeechFlow._internal();

  /// Event bus para comunicação
  final EventBus _eventBus = EventBus();

  /// Estado atual do fluxo de voz
  VoiceFlowState _state = VoiceFlowState.idle;
  VoiceFlowState get currentState => _state;
  
  /// Estado anterior (para transições)
  VoiceFlowState? _previousState;

  /// Timestamp da última mudança de estado
  DateTime _lastStateChange = DateTime.now();

  /// Histórico de transições
  final List<Map<String, dynamic>> _stateHistory = [];
  final int _maxHistorySize = 20;

  /// Getter para compatibilidade com código legado
  String get state => _stateToString(_state);

  /// Define o estado (compatibilidade com código legado)
  void setState(String s) {
    final newState = _stringToState(s);
    setFlowState(newState);
  }

  /// Define o estado do fluxo com evento
  void setFlowState(VoiceFlowState newState) {
    if (_state == newState) return;

    final oldState = _state;
    _previousState = _state;
    _state = newState;

    // Adicionar ao histórico
    _addToHistory(oldState, newState);

    // Publicar evento de mudança de estado
    _eventBus.publish(AurynEvent(
      type: AurynEventType.voiceStateChange,
      source: 'SpeechFlow',
      data: {
        'previous_state': _stateToString(oldState),
        'new_state': _stateToString(newState),
        'timestamp': DateTime.now().toIso8601String(),
      },
      priority: 7,
    ));

    _lastStateChange = DateTime.now();
  }

  /// Getters para estados específicos
  bool get isIdle => _state == VoiceFlowState.idle;
  bool get isListening => _state == VoiceFlowState.listening;
  bool get isProcessing => _state == VoiceFlowState.processing;
  bool get isSpeaking => _state == VoiceFlowState.speaking;
  bool get isInterrupted => _state == VoiceFlowState.interrupted;
  bool get isError => _state == VoiceFlowState.error;

  /// Aguarda uma pausa natural antes de falar
  Future<void> naturalPause() async {
    await Future.delayed(const Duration(milliseconds: 280));
  }

  /// Se o usuário começar a falar durante a resposta → interrompe a fala
  bool shouldInterrupt = false;

  /// Converte estado para string
  String _stateToString(VoiceFlowState state) {
    return state.toString().split('.').last;
  }

  /// Converte string para estado
  VoiceFlowState _stringToState(String s) {
    switch (s.toLowerCase()) {
      case 'idle':
        return VoiceFlowState.idle;
      case 'listening':
        return VoiceFlowState.listening;
      case 'processing':
        return VoiceFlowState.processing;
      case 'speaking':
        return VoiceFlowState.speaking;
      case 'interrupted':
        return VoiceFlowState.interrupted;
      case 'error':
        return VoiceFlowState.error;
      default:
        return VoiceFlowState.idle;
    }
  }

  /// Adiciona transição ao histórico
  void _addToHistory(VoiceFlowState from, VoiceFlowState to) {
    _stateHistory.add({
      'from': _stateToString(from),
      'to': _stateToString(to),
      'timestamp': DateTime.now().toIso8601String(),
      'duration_ms': DateTime.now().difference(_lastStateChange).inMilliseconds,
    });

    if (_stateHistory.length > _maxHistorySize) {
      _stateHistory.removeAt(0);
    }
  }

  /// Retorna histórico de transições
  List<Map<String, dynamic>> getStateHistory() {
    return List.unmodifiable(_stateHistory);
  }

  /// Retorna estatísticas do fluxo
  Map<String, dynamic> getStats() {
    final stateDistribution = <String, int>{};
    for (final transition in _stateHistory) {
      final state = transition['to'] as String;
      stateDistribution[state] = (stateDistribution[state] ?? 0) + 1;
    }

    return {
      'current_state': _stateToString(_state),
      'previous_state': _previousState != null ? _stateToString(_previousState!) : null,
      'last_state_change': _lastStateChange.toIso8601String(),
      'history_size': _stateHistory.length,
      'state_distribution': stateDistribution,
    };
  }

  /// Reset para estado inicial
  void reset() {
    setFlowState(VoiceFlowState.idle);
    shouldInterrupt = false;
  }
}
