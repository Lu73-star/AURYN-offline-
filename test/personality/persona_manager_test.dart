/// test/personality/persona_manager_test.dart
/// Tests for PersonaManager - profile switching, trait adjustment, events.

import 'package:flutter_test/flutter_test.dart';
import 'package:auryn_offline/auryn_core/personality/persona_manager.dart';
import 'package:auryn_offline/auryn_core/personality/personality_profile.dart';
import 'package:auryn_offline/auryn_core/personality/personality_traits.dart';
import 'package:auryn_offline/auryn_core/personality/personality_events.dart';
import 'package:auryn_offline/auryn_core/personality/dialog_style.dart';
import 'package:auryn_offline/auryn_core/emotion/emotion_state.dart';
import 'package:auryn_offline/auryn_core/personality/behavior_shaping.dart';

void main() {
  group('PersonaManager', () {
    late PersonaManager manager;

    setUp(() async {
      manager = PersonaManager();
      await manager.reset(); // Reset to clean state
      await manager.initialize();
    });

    test('deve inicializar corretamente', () {
      expect(manager.isInitialized, isTrue);
      expect(manager.currentProfile, isNotNull);
      expect(manager.currentProfile.id, equals('auryn_default'));
    });

    test('deve lançar StateError quando não inicializado', () async {
      final uninitializedManager = PersonaManager();
      await uninitializedManager.reset();

      expect(
        () => uninitializedManager.currentProfile,
        throwsStateError,
      );
    });

    test('deve ter profiles default após inicialização', () {
      final profiles = manager.availableProfiles;

      expect(profiles.length, greaterThanOrEqualTo(3));
      expect(profiles.any((p) => p.id == 'auryn_default'), isTrue);
      expect(profiles.any((p) => p.id == 'supportive'), isTrue);
      expect(profiles.any((p) => p.id == 'analytical'), isTrue);
    });

    test('deve obter profile por ID', () {
      final profile = manager.getProfile('supportive');

      expect(profile, isNotNull);
      expect(profile!.name, equals('Supportive Mode'));
    });

    test('deve retornar null para profile inexistente', () {
      final profile = manager.getProfile('non_existent');

      expect(profile, isNull);
    });

    test('deve adicionar novo profile', () {
      final customProfile = PersonalityProfile(
        id: 'custom',
        name: 'Custom Profile',
        description: 'A custom test profile',
        traits: PersonalityTraits.aurynDefault(),
        emotionalBaseline: EmotionState.neutral(),
        dialogStyle: DialogStyle.aurynDefault(),
      );

      manager.addProfile(customProfile);

      final retrieved = manager.getProfile('custom');
      expect(retrieved, isNotNull);
      expect(retrieved!.name, equals('Custom Profile'));
    });

    test('deve remover profile', () {
      final customProfile = PersonalityProfile(
        id: 'custom',
        name: 'Custom Profile',
        description: 'Test',
        traits: PersonalityTraits.aurynDefault(),
        emotionalBaseline: EmotionState.neutral(),
        dialogStyle: DialogStyle.aurynDefault(),
      );

      manager.addProfile(customProfile);
      expect(manager.getProfile('custom'), isNotNull);

      final removed = manager.removeProfile('custom');
      expect(removed, isTrue);
      expect(manager.getProfile('custom'), isNull);
    });

    test('não deve remover profile atual', () {
      final removed = manager.removeProfile('auryn_default');

      expect(removed, isFalse);
      expect(manager.currentProfile.id, equals('auryn_default'));
    });

    test('deve trocar profile', () async {
      await manager.switchProfile('supportive');

      expect(manager.currentProfile.id, equals('supportive'));
      expect(manager.currentProfile.name, equals('Supportive Mode'));
    });

    test('deve lançar erro ao trocar para profile inexistente', () {
      expect(
        () => manager.switchProfile('non_existent'),
        throwsArgumentError,
      );
    });

    test('deve disparar evento OnProfileShift ao trocar profile', () async {
      OnProfileShift? capturedEvent;

      manager.onProfileShift((event) {
        capturedEvent = event;
      });

      await manager.switchProfile('supportive');

      expect(capturedEvent, isNotNull);
      expect(capturedEvent!.previousProfile?.id, equals('auryn_default'));
      expect(capturedEvent!.newProfile.id, equals('supportive'));
      expect(capturedEvent!.reason, equals('manual'));
    });

    test('deve ajustar trait', () {
      final oldOpenness = manager.currentProfile.traits.openness;

      manager.adjustTrait('openness', 0.10);

      final newOpenness = manager.currentProfile.traits.openness;
      expect(newOpenness, equals(oldOpenness + 0.10));
    });

    test('deve disparar evento OnTraitAdjustment ao ajustar trait', () {
      OnTraitAdjustment? capturedEvent;

      manager.onTraitAdjustment((event) {
        capturedEvent = event;
      });

      final oldValue = manager.currentProfile.traits.agreeableness;
      manager.adjustTrait('agreeableness', -0.05);

      expect(capturedEvent, isNotNull);
      expect(capturedEvent!.traitName, equals('agreeableness'));
      expect(capturedEvent!.oldValue, equals(oldValue));
      expect(capturedEvent!.delta, equals(-0.05));
    });

    test('deve atualizar current profile', () {
      final updatedProfile = manager.currentProfile.copyWith(
        name: 'Modified AURYN',
      );

      manager.updateCurrentProfile(updatedProfile);

      expect(manager.currentProfile.name, equals('Modified AURYN'));
    });

    test('deve lançar erro ao atualizar profile com ID diferente', () {
      final differentProfile = PersonalityProfile(
        id: 'different',
        name: 'Different',
        description: 'Test',
        traits: PersonalityTraits.aurynDefault(),
        emotionalBaseline: EmotionState.neutral(),
        dialogStyle: DialogStyle.aurynDefault(),
      );

      expect(
        () => manager.updateCurrentProfile(differentProfile),
        throwsArgumentError,
      );
    });

    test('deve modular emoção baseado em personality atual', () {
      final emotion = EmotionState(
        mood: 'sad',
        intensity: 1,
        valence: -1,
        arousal: 1,
      );

      final modulated = manager.modulateEmotion(emotion);

      expect(modulated, isNotNull);
      expect(modulated.mood, equals(emotion.mood));
      // Modulation may change intensity based on traits
    });

    test('deve computar behavioral directive', () {
      final emotion = EmotionState.neutral();
      final context = BehaviorContext.casual();

      OnBehaviorComputed? capturedEvent;
      manager.onBehaviorComputed((event) {
        capturedEvent = event;
      });

      final directive = manager.computeBehavior(
        emotionState: emotion,
        context: context,
      );

      expect(directive, isNotNull);
      expect(directive.dialogStyle, isNotNull);
      expect(directive.pacing, isNotNull);

      // Event should be fired
      expect(capturedEvent, isNotNull);
      expect(capturedEvent!.emotionMood, equals('neutral'));
      expect(capturedEvent!.contextType, equals('casual'));
    });

    test('deve exportar current profile', () {
      final exported = manager.exportCurrentProfile();

      expect(exported, isMap);
      expect(exported['id'], equals('auryn_default'));
      expect(exported['name'], isNotNull);
    });

    test('deve exportar todos os profiles', () {
      final exported = manager.exportAllProfiles();

      expect(exported, isMap);
      expect(exported.containsKey('auryn_default'), isTrue);
      expect(exported.containsKey('supportive'), isTrue);
    });

    test('deve importar profile', () async {
      final profileData = {
        'id': 'imported',
        'name': 'Imported Profile',
        'description': 'Test import',
        'traits': PersonalityTraits.aurynDefault().toMap(),
        'emotionalBaseline': EmotionState.neutral().toMap(),
        'dialogStyle': DialogStyle.aurynDefault().toMap(),
        'contextPreferences': {},
        'createdAt': DateTime.now().toIso8601String(),
        'lastModified': DateTime.now().toIso8601String(),
      };

      await manager.importProfile(profileData);

      final imported = manager.getProfile('imported');
      expect(imported, isNotNull);
      expect(imported!.name, equals('Imported Profile'));
    });

    test('deve importar e definir como current', () async {
      final profileData = {
        'id': 'imported_current',
        'name': 'Imported Current',
        'description': 'Test',
        'traits': PersonalityTraits.aurynDefault().toMap(),
        'emotionalBaseline': EmotionState.neutral().toMap(),
        'dialogStyle': DialogStyle.aurynDefault().toMap(),
        'contextPreferences': {},
        'createdAt': DateTime.now().toIso8601String(),
        'lastModified': DateTime.now().toIso8601String(),
      };

      await manager.importProfile(profileData, setAsCurrent: true);

      expect(manager.currentProfile.id, equals('imported_current'));
    });

    test('deve lançar erro para dados de import inválidos', () async {
      // Missing id
      final invalidData1 = {
        'name': 'Test',
        'traits': PersonalityTraits.aurynDefault().toMap(),
      };
      
      expect(
        () => manager.importProfile(invalidData1),
        throwsArgumentError,
      );

      // Missing name
      final invalidData2 = {
        'id': 'test',
        'traits': PersonalityTraits.aurynDefault().toMap(),
      };
      
      expect(
        () => manager.importProfile(invalidData2),
        throwsArgumentError,
      );

      // Missing traits
      final invalidData3 = {
        'id': 'test',
        'name': 'Test',
      };
      
      expect(
        () => manager.importProfile(invalidData3),
        throwsArgumentError,
      );
    });

    test('deve obter debug info', () {
      final debugInfo = manager.getDebugInfo();

      expect(debugInfo['initialized'], isTrue);
      expect(debugInfo['currentProfile'], equals('AURYN Default'));
      expect(debugInfo['profileCount'], greaterThanOrEqualTo(3));
      expect(debugInfo['profiles'], isList);
    });

    test('deve ter toString informativo', () {
      final str = manager.toString();

      expect(str, contains('PersonaManager'));
      expect(str, contains('AURYN Default'));
    });

    test('deve permitir múltiplos callbacks', () {
      var callbackCount = 0;

      manager.onProfileShift((_) => callbackCount++);
      manager.onProfileShift((_) => callbackCount++);

      manager.switchProfile('supportive');

      expect(callbackCount, equals(2));
    });

    test('deve fornecer acesso aos hooks', () {
      final hooks = manager.hooks;

      expect(hooks, isNotNull);
      expect(hooks, isA<PersonalityHooks>());
    });
  });

  group('PersistenceOptions', () {
    test('deve criar com valores default', () {
      const options = PersistenceOptions();

      expect(options.enabled, isFalse);
      expect(options.storagePrefix, equals('auryn_personality'));
      expect(options.autoSave, isTrue);
    });

    test('deve criar com valores customizados', () {
      const options = PersistenceOptions(
        enabled: true,
        storagePrefix: 'custom_prefix',
        autoSave: false,
      );

      expect(options.enabled, isTrue);
      expect(options.storagePrefix, equals('custom_prefix'));
      expect(options.autoSave, isFalse);
    });
  });
}
