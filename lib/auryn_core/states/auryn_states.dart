/// AURYN States — módulo responsável por gerenciar os estados internos da IA.
/// Estados mantêm o 'continuum interno' da AURYN entre interações.
///
/// Exemplos de estados:
/// - humor emocional
/// - foco atual
/// - contexto ativo
/// - energia cognitiva
/// - último comando processado

import 'package:auryn_offline/auryn_core/interfaces/i_auryn_module.dart';
import 'package:auryn_offline/auryn_core/events/event_bus.dart';
import 'package:auryn_offline/auryn_core/events/auryn_event.dart';

class AurynStates implements IAurynModule {
  static final AurynStates _instance = AurynStates._internal();
  factory AurynStates() => _instance;

  /// Armazena todos os estados internos
  final Map<String, dynamic> _states = {};

  /// Event bus para publicar mudanças
  final EventBus _eventBus = EventBus();

  /// Estado do módulo
  String _moduleState = 'stopped';

  AurynStates._internal();

  @override
  String get moduleName => 'AurynStates';

  @override
  String get version => '1.0.0';

  @override
  String get state => _moduleState;

  @override
  bool get isReady => _moduleState == 'running' || _moduleState == 'initialized';

  @override
  Future<void> init({Map<String, dynamic>? config}) async {
    if (_moduleState == 'running' || _moduleState == 'initialized') return;
    _moduleState = 'initialized';
    initializeDefaults();
  }

  @override
  Future<void> shutdown() async {
    _moduleState = 'shutdown';
    _states.clear();
  }

  /// Define um estado
  void set(String key, dynamic value) {
    final oldValue = _states[key];
    _states[key] = value;

    // Publicar evento de mudança de estado se o valor mudou
    if (oldValue != value) {
      _eventBus.publish(AurynEvent(
        type: AurynEventType.stateChange,
        source: moduleName,
        data: {
          'key': key,
          'old_value': oldValue,
          'new_value': value,
        },
        priority: 6,
      ));
    }
  }

  /// Recupera um estado
  dynamic get(String key) {
    return _states[key];
  }

  /// Retorna todos os estados
  Map<String, dynamic> get all => Map.unmodifiable(_states);

  /// Limpa todos os estados (reset)
  void reset() {
    _states.clear();
  }

  /// Estados padrão ao iniciar
  void initializeDefaults() {
    _states["mood"] = "neutral";
    _states["focus"] = "listening";
    _states["context_mode"] = "general";
    _states["energy"] = 100;
    _states["last_input"] = "";
  }

  /// Atualiza energia cognitiva (simula cansaço/intensidade de processamento)
  void updateEnergy(int delta) {
    final oldEnergy = _states["energy"] ?? 100;
    final newEnergy = (oldEnergy + delta).clamp(0, 100);
    
    if (oldEnergy != newEnergy) {
      _states["energy"] = newEnergy;
      
      // Publicar evento de mudança de energia
      _eventBus.publish(AurynEvent(
        type: AurynEventType.energyChange,
        source: moduleName,
        data: {
          'old_energy': oldEnergy,
          'new_energy': newEnergy,
          'delta': delta,
        },
        priority: 5,
      ));
    }
  }

  @override
  Map<String, dynamic> getStatus() {
    return {
      'state': _moduleState,
      'is_ready': isReady,
      'total_states': _states.length,
      'current_states': Map.unmodifiable(_states),
    };
  }
}
