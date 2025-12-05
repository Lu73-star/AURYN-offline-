/// AURYN States — módulo responsável por gerenciar os estados internos da IA.
/// Estados mantêm o 'continuum interno' da AURYN entre interações.
///
/// Exemplos de estados:
/// - humor emocional
/// - foco atual
/// - contexto ativo
/// - energia cognitiva
/// - último comando processado

class AurynStates {
  static final AurynStates _instance = AurynStates._internal();
  factory AurynStates() => _instance;

  /// Armazena todos os estados internos
  final Map<String, dynamic> _states = {};

  AurynStates._internal();

  /// Define um estado
  void set(String key, dynamic value) {
    _states[key] = value;
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
    _states["energy"] = (_states["energy"] ?? 100) + delta;

    if (_states["energy"] > 100) _states["energy"] = 100;
    if (_states["energy"] < 0) _states["energy"] = 0;
  }
}
