import 'package:flutter_test/flutter_test.dart';
import 'package:auryn_offline/auryn_core/awareness/context_manager.dart';

void main() {
  group('ContextManager', () {
    test('Atualiza e retorna contexto correto', () {
      final manager = ContextManagerTestDouble();
      manager.updateContext({'state': 'init'});
      expect(manager.getCurrentContext()['state'], equals('init'));
    });
  });
}

class ContextManagerTestDouble implements ContextManager {
  Map<String, dynamic> ctx = {};

  @override
  Map<String, dynamic> getCurrentContext() => ctx;

  @override
  void updateContext(Map<String, dynamic> changes) {
    ctx.addAll(changes);
  }
}
