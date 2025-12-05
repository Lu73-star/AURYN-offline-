/// lib/auryn_core/events/event_bus.dart
/// Sistema de eventos para comunicação entre módulos do AURYN Core.
/// Implementa um padrão pub-sub simples e eficiente.

import 'dart:async';
import 'package:auryn_offline/auryn_core/events/auryn_event.dart';

/// Tipo de callback para handlers de eventos
typedef EventHandler = void Function(AurynEvent event);

/// Event Bus do AURYN Core
/// Facilita comunicação desacoplada entre módulos
class EventBus {
  static final EventBus _instance = EventBus._internal();
  factory EventBus() => _instance;
  EventBus._internal();

  /// Stream controller para broadcasting de eventos
  final StreamController<AurynEvent> _controller =
      StreamController<AurynEvent>.broadcast();

  /// Mapa de subscriptions por tipo de evento
  final Map<AurynEventType, List<StreamSubscription>> _subscriptions = {};

  /// Lista de todos os eventos recentes (buffer limitado)
  final List<AurynEvent> _eventHistory = [];

  /// Tamanho máximo do histórico de eventos
  final int maxHistorySize = 100;

  /// Publica um evento no bus
  void publish(AurynEvent event) {
    _controller.add(event);
    _addToHistory(event);
  }

  /// Subscreve a um tipo específico de evento
  StreamSubscription<AurynEvent> subscribe(
    AurynEventType type,
    EventHandler handler,
  ) {
    final subscription = _controller.stream
        .where((event) => event.type == type)
        .listen(handler);

    _subscriptions.putIfAbsent(type, () => []);
    _subscriptions[type]!.add(subscription);

    return subscription;
  }

  /// Subscreve a todos os eventos
  StreamSubscription<AurynEvent> subscribeAll(EventHandler handler) {
    return _controller.stream.listen(handler);
  }

  /// Subscreve a múltiplos tipos de eventos
  StreamSubscription<AurynEvent> subscribeMultiple(
    List<AurynEventType> types,
    EventHandler handler,
  ) {
    return _controller.stream
        .where((event) => types.contains(event.type))
        .listen(handler);
  }

  /// Remove uma subscription
  Future<void> unsubscribe(StreamSubscription subscription) async {
    await subscription.cancel();

    // Remove da lista de subscriptions
    _subscriptions.forEach((type, subs) {
      subs.remove(subscription);
    });
  }

  /// Remove todas as subscriptions de um tipo específico
  Future<void> unsubscribeType(AurynEventType type) async {
    final subs = _subscriptions[type];
    if (subs != null) {
      for (final sub in subs) {
        await sub.cancel();
      }
      _subscriptions.remove(type);
    }
  }

  /// Limpa todas as subscriptions
  Future<void> clear() async {
    for (final subs in _subscriptions.values) {
      for (final sub in subs) {
        await sub.cancel();
      }
    }
    _subscriptions.clear();
  }

  /// Adiciona evento ao histórico
  void _addToHistory(AurynEvent event) {
    _eventHistory.add(event);
    if (_eventHistory.length > maxHistorySize) {
      _eventHistory.removeAt(0);
    }
  }

  /// Retorna histórico de eventos
  List<AurynEvent> get eventHistory => List.unmodifiable(_eventHistory);

  /// Retorna eventos de um tipo específico do histórico
  List<AurynEvent> getEventsByType(AurynEventType type) {
    return _eventHistory.where((e) => e.type == type).toList();
  }

  /// Limpa o histórico de eventos
  void clearHistory() {
    _eventHistory.clear();
  }

  /// Fecha o event bus (deve ser chamado no shutdown)
  Future<void> close() async {
    await clear();
    await _controller.close();
  }

  /// Retorna estatísticas do event bus
  Map<String, dynamic> getStats() {
    final eventsByType = <String, int>{};
    for (final event in _eventHistory) {
      final typeName = event.type.toString();
      eventsByType[typeName] = (eventsByType[typeName] ?? 0) + 1;
    }

    return {
      'total_events': _eventHistory.length,
      'events_by_type': eventsByType,
      'active_subscriptions': _subscriptions.length,
    };
  }
}
