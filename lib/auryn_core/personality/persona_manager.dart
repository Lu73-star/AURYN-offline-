/// lib/auryn_core/personality/persona_manager.dart
/// Load/switch profiles, adjust traits, Hive persistence (opt-in only).
/// 
/// PersonaManager is responsible for managing personality profiles,
/// switching between them, and optionally persisting them locally.

import 'package:auryn_offline/auryn_core/personality/personality_profile.dart';
import 'package:auryn_offline/auryn_core/personality/personality_traits.dart';
import 'package:auryn_offline/auryn_core/personality/personality_events.dart';
import 'package:auryn_offline/auryn_core/emotion/emotion_state.dart';
import 'package:auryn_offline/auryn_core/personality/behavior_shaping.dart';

/// Options for persistence
class PersistenceOptions {
  /// Enable automatic persistence
  final bool enabled;

  /// Storage key prefix
  final String storagePrefix;

  /// Auto-save on changes
  final bool autoSave;

  const PersistenceOptions({
    this.enabled = false,
    this.storagePrefix = 'auryn_personality',
    this.autoSave = true,
  });
}

/// Manager for personality profiles and switching
class PersonaManager {
  /// Singleton instance
  static final PersonaManager _instance = PersonaManager._internal();
  factory PersonaManager() => _instance;
  PersonaManager._internal();

  /// Current active profile
  PersonalityProfile? _currentProfile;

  /// Available profiles
  final Map<String, PersonalityProfile> _profiles = {};

  /// Event hooks
  final PersonalityHooks _hooks = PersonalityHooks();

  /// Persistence options
  PersistenceOptions _persistenceOptions = const PersistenceOptions();

  /// Indicates if the manager is initialized
  bool _isInitialized = false;

  /// Initialize the persona manager
  Future<void> initialize({
    PersonalityProfile? defaultProfile,
    PersistenceOptions? persistenceOptions,
    bool loadFromStorage = false,
  }) async {
    if (_isInitialized) {
      print('[PersonaManager] Already initialized');
      return;
    }

    _persistenceOptions = persistenceOptions ?? const PersistenceOptions();

    // Load from storage if enabled and requested
    if (loadFromStorage && _persistenceOptions.enabled) {
      await _loadFromStorage();
    }

    // Set default profile
    if (_profiles.isEmpty) {
      // Add default profiles
      addProfile(PersonalityProfile.aurynDefault());
      addProfile(PersonalityProfile.supportive());
      addProfile(PersonalityProfile.analytical());
    }

    // Activate default profile
    if (defaultProfile != null) {
      _currentProfile = defaultProfile;
      if (!_profiles.containsKey(defaultProfile.id)) {
        addProfile(defaultProfile);
      }
    } else {
      _currentProfile = _profiles['auryn_default'] ?? _profiles.values.first;
    }

    _isInitialized = true;
    print('[PersonaManager] Initialized with profile: ${_currentProfile?.name}');
  }

  /// Ensure manager is initialized
  void _ensureInitialized() {
    if (!_isInitialized) {
      throw StateError('PersonaManager not initialized. Call initialize() first.');
    }
  }

  /// Get current active profile
  PersonalityProfile get currentProfile {
    _ensureInitialized();
    return _currentProfile!;
  }

  /// Get all available profiles
  List<PersonalityProfile> get availableProfiles {
    _ensureInitialized();
    return _profiles.values.toList();
  }

  /// Get profile by ID
  PersonalityProfile? getProfile(String id) {
    _ensureInitialized();
    return _profiles[id];
  }

  /// Add a new profile
  void addProfile(PersonalityProfile profile) {
    _profiles[profile.id] = profile;
    
    if (_persistenceOptions.enabled && _persistenceOptions.autoSave) {
      _saveToStorage();
    }
  }

  /// Remove a profile
  bool removeProfile(String id) {
    _ensureInitialized();
    
    // Don't remove current profile
    if (_currentProfile?.id == id) {
      print('[PersonaManager] Cannot remove active profile');
      return false;
    }

    final removed = _profiles.remove(id) != null;
    
    if (removed && _persistenceOptions.enabled && _persistenceOptions.autoSave) {
      _saveToStorage();
    }
    
    return removed;
  }

  /// Switch to a different profile
  Future<void> switchProfile(String profileId, {String reason = 'manual'}) async {
    _ensureInitialized();

    final newProfile = _profiles[profileId];
    if (newProfile == null) {
      throw ArgumentError('Profile not found: $profileId');
    }

    if (_currentProfile?.id == profileId) {
      print('[PersonaManager] Already using profile: $profileId');
      return;
    }

    final previousProfile = _currentProfile;
    _currentProfile = newProfile;

    // Notify event
    final event = OnProfileShift(
      previousProfile: previousProfile,
      newProfile: newProfile,
      reason: reason,
    );
    _hooks.notifyProfileShift(event);

    if (_persistenceOptions.enabled && _persistenceOptions.autoSave) {
      await _saveToStorage();
    }

    print('[PersonaManager] Switched to profile: ${newProfile.name}');
  }

  /// Adjust a trait in the current profile
  void adjustTrait(String traitName, double delta) {
    _ensureInitialized();

    final oldProfile = _currentProfile!;
    final oldValue = oldProfile.traits.getTrait(traitName);
    final newProfile = oldProfile.adjustTrait(traitName, delta);
    final newValue = newProfile.traits.getTrait(traitName);

    _currentProfile = newProfile;
    _profiles[newProfile.id] = newProfile;

    // Notify event
    final event = OnTraitAdjustment(
      profileId: newProfile.id,
      traitName: traitName,
      oldValue: oldValue,
      newValue: newValue,
      delta: delta,
    );
    _hooks.notifyTraitAdjustment(event);

    if (_persistenceOptions.enabled && _persistenceOptions.autoSave) {
      _saveToStorage();
    }
  }

  /// Update current profile
  void updateCurrentProfile(PersonalityProfile updatedProfile) {
    _ensureInitialized();

    if (updatedProfile.id != _currentProfile!.id) {
      throw ArgumentError('Profile ID mismatch');
    }

    _currentProfile = updatedProfile;
    _profiles[updatedProfile.id] = updatedProfile;

    if (_persistenceOptions.enabled && _persistenceOptions.autoSave) {
      _saveToStorage();
    }
  }

  /// Modulate an emotion based on current personality
  EmotionState modulateEmotion(EmotionState state) {
    _ensureInitialized();
    return _currentProfile!.modulateEmotion(state);
  }

  /// Compute behavioral directive
  BehavioralDirective computeBehavior({
    required EmotionState emotionState,
    required BehaviorContext context,
  }) {
    _ensureInitialized();

    final directive = BehaviorShaping.computeDirective(
      emotionState: emotionState,
      traits: _currentProfile!.traits,
      context: context,
    );

    // Notify event
    final event = OnBehaviorComputed(
      directive: directive,
      emotionMood: emotionState.mood,
      profileName: _currentProfile!.name,
      contextType: context.interactionType,
    );
    _hooks.notifyBehaviorComputed(event);

    return directive;
  }

  /// Get event hooks
  PersonalityHooks get hooks => _hooks;

  /// Register trait adjustment callback
  void onTraitAdjustment(TraitAdjustmentCallback callback) {
    _hooks.onTraitAdjustment(callback);
  }

  /// Register profile shift callback
  void onProfileShift(ProfileShiftCallback callback) {
    _hooks.onProfileShift(callback);
  }

  /// Register behavior computed callback
  void onBehaviorComputed(BehaviorComputedCallback callback) {
    _hooks.onBehaviorComputed(callback);
  }

  /// Save profiles to storage (opt-in only)
  Future<void> _saveToStorage() async {
    if (!_persistenceOptions.enabled) return;

    try {
      // Note: Actual Hive implementation would go here
      // For now, this is a placeholder that respects opt-in privacy
      print('[PersonaManager] Persistence enabled but Hive storage not yet implemented');
      
      // TODO: Implement Hive storage when user explicitly opts in
      // final box = await Hive.openBox(_persistenceOptions.storagePrefix);
      // await box.put('current_profile_id', _currentProfile?.id);
      // await box.put('profiles', _profiles.map((k, v) => MapEntry(k, v.toMap())));
    } catch (e) {
      print('[PersonaManager] Error saving to storage: $e');
    }
  }

  /// Load profiles from storage (opt-in only)
  Future<void> _loadFromStorage() async {
    if (!_persistenceOptions.enabled) return;

    try {
      // Note: Actual Hive implementation would go here
      print('[PersonaManager] Persistence enabled but Hive storage not yet implemented');
      
      // TODO: Implement Hive storage when user explicitly opts in
      // final box = await Hive.openBox(_persistenceOptions.storagePrefix);
      // final profilesData = box.get('profiles') as Map<String, dynamic>?;
      // if (profilesData != null) {
      //   profilesData.forEach((id, data) {
      //     _profiles[id] = PersonalityProfile.fromMap(data);
      //   });
      // }
      // final currentId = box.get('current_profile_id') as String?;
      // if (currentId != null) {
      //   _currentProfile = _profiles[currentId];
      // }
    } catch (e) {
      print('[PersonaManager] Error loading from storage: $e');
    }
  }

  /// Export current profile
  Map<String, dynamic> exportCurrentProfile() {
    _ensureInitialized();
    return _currentProfile!.toMap();
  }

  /// Export all profiles
  Map<String, Map<String, dynamic>> exportAllProfiles() {
    _ensureInitialized();
    return _profiles.map((id, profile) => MapEntry(id, profile.toMap()));
  }

  /// Import a profile
  Future<void> importProfile(Map<String, dynamic> data, {bool setAsCurrent = false}) async {
    final profile = PersonalityProfile.fromMap(data);
    addProfile(profile);
    
    if (setAsCurrent) {
      await switchProfile(profile.id, reason: 'imported');
    }
  }

  /// Reset to default state
  Future<void> reset() async {
    _profiles.clear();
    _currentProfile = null;
    _hooks.clearAllCallbacks();
    _isInitialized = false;
    
    await initialize();
  }

  /// Get debug information
  Map<String, dynamic> getDebugInfo() {
    if (!_isInitialized) {
      return {'initialized': false};
    }

    return {
      'initialized': true,
      'currentProfile': _currentProfile?.name,
      'profileCount': _profiles.length,
      'profiles': _profiles.keys.toList(),
      'persistenceEnabled': _persistenceOptions.enabled,
      'callbackCounts': _hooks.callbackCounts,
    };
  }

  /// Check if manager is initialized
  bool get isInitialized => _isInitialized;

  @override
  String toString() {
    if (!_isInitialized) {
      return 'PersonaManager(not initialized)';
    }
    return 'PersonaManager(current: ${_currentProfile?.name}, '
        'profiles: ${_profiles.length})';
  }
}
