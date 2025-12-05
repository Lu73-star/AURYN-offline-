// personality_controller.dart
// Personality configuration for AURYN awareness
// Compatible with Dart/Flutter 3.x

/// {@template personality_controller}
/// Manages adaptable personality traits and behaviors.
///
/// Controls the personality characteristics of AURYN,
/// allowing for customization and dynamic adjustment
/// based on interactions.
///
/// **Privacy Note**: Personality traits are stored locally only.
/// {@endtemplate}
abstract class PersonalityController {
  /// Get all personality traits
  /// Returns a copy of current personality configuration
  Map<String, dynamic> getTraits();

  /// Update a personality trait
  /// [trait] - The trait name to update
  /// [value] - The new value for the trait
  void updateTrait(String trait, dynamic value);

  /// Get a specific trait value
  /// Returns null if trait doesn't exist
  dynamic getTrait(String trait);

  /// Reset traits to default values
  void resetToDefaults();

  /// Get available trait names
  List<String> getTraitNames();
}

/// {@template personality_controller_impl}
/// Default implementation of [PersonalityController]
/// Maintains personality traits in memory
/// {@endtemplate}
class PersonalityControllerImpl implements PersonalityController {
  final Map<String, dynamic> _traits = {
    'friendliness': 0.8,
    'formality': 0.5,
    'verbosity': 0.6,
    'empathy': 0.9,
    'humor': 0.5,
  };

  static const Map<String, dynamic> _defaultTraits = {
    'friendliness': 0.8,
    'formality': 0.5,
    'verbosity': 0.6,
    'empathy': 0.9,
    'humor': 0.5,
  };

  @override
  Map<String, dynamic> getTraits() {
    return Map<String, dynamic>.from(_traits);
  }

  @override
  void updateTrait(String trait, dynamic value) {
    _traits[trait] = value;
  }

  @override
  dynamic getTrait(String trait) {
    return _traits[trait];
  }

  @override
  void resetToDefaults() {
    _traits.clear();
    _traits.addAll(_defaultTraits);
  }

  @override
  List<String> getTraitNames() {
    return _traits.keys.toList();
  }
}
