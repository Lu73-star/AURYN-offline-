/// Scheduler determinístico da AURYN
/// Não depende de DateTime.now()
/// Todo avanço ocorre via tick explícito

class AurynScheduler {
  int _currentTick = 0;
  final Map<int, List<void Function()>> _tasks = {};

  int get currentTick => _currentTick;

  /// Agenda uma tarefa para um tick futuro
  void schedule({
    required int atTick,
    required void Function() task,
  }) {
    if (atTick < _currentTick) {
      throw StateError(
        'Cannot schedule task in the past (currentTick=$_currentTick, atTick=$atTick)',
      );
    }

    _tasks.putIfAbsent(atTick, () => []);
    _tasks[atTick]!.add(task);
  }

  /// Avança o scheduler em 1 tick
  void tick() {
    _currentTick++;

    final tasks = _tasks.remove(_currentTick);
    if (tasks != null) {
      for (final task in tasks) {
        task();
      }
    }
  }

  /// Avança múltiplos ticks de forma controlada
  void advance(int ticks) {
    if (ticks < 0) {
      throw ArgumentError('Cannot advance negative ticks');
    }

    for (int i = 0; i < ticks; i++) {
      tick();
    }
  }

  /// Reseta o scheduler (uso em testes)
  void reset() {
    _currentTick = 0;
    _tasks.clear();
  }
}
