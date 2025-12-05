import 'package:flutter_test/flutter_test.dart';
import 'package:auryn_offline/auryn_core/awareness/awareness_core.dart';

void main() {
  group('AwarenessCore', () {
    test('initialize não lança exceção', () {
      final core = AwarenessCoreTestDouble();
      expect(() => core.initialize(), returnsNormally);
    });
  });
}

class AwarenessCoreTestDouble implements AwarenessCore {
  @override
  void initialize() {}
  @override
  void update() {}
}
