// intent_filter.dart
// Intent detection/filtering for awareness flow
// Compatible with Dart/Flutter 3.x

/// {@template intent_filter}
/// Filters and classifies user intents within awareness modules.
///
/// Analyzes user input to determine intent type and
/// filters out irrelevant or low-confidence intents.
///
/// **Privacy Note**: All processing is done locally.
/// No data is sent to external services.
/// {@endtemplate}
abstract class IntentFilter {
  /// Classify raw input as intent
  /// [input] - The raw input text or identifier
  /// Returns classified intent type
  String classifyIntent(String input);

  /// Filter irrelevant intents
  /// [intents] - List of intent candidates
  /// Returns filtered list of relevant intents
  List<String> filterIntents(List<String> intents);

  /// Add a custom intent pattern
  /// [pattern] - Pattern to recognize
  /// [intentType] - Intent type to assign
  void addIntentPattern(String pattern, String intentType);

  /// Check if an intent type is supported
  bool isSupportedIntent(String intentType);
}

/// {@template intent_filter_impl}
/// Default implementation of [IntentFilter]
/// Uses simple keyword-based classification
/// {@endtemplate}
class IntentFilterImpl implements IntentFilter {
  final Map<String, String> _patterns = {
    'speech': 'voice_input',
    'fala': 'voice_input',
    'voice': 'voice_input',
    'text': 'text_input',
    'texto': 'text_input',
    'gesture': 'gesture_input',
    'gesto': 'gesture_input',
    'touch': 'touch_input',
    'toque': 'touch_input',
  };

  final Set<String> _supportedIntents = {
    'voice_input',
    'text_input',
    'gesture_input',
    'touch_input',
    'unknown',
  };

  @override
  String classifyIntent(String input) {
    final lowercaseInput = input.toLowerCase();

    // Check patterns
    for (final entry in _patterns.entries) {
      if (lowercaseInput.contains(entry.key)) {
        return entry.value;
      }
    }

    // Default to unknown
    return 'unknown';
  }

  @override
  List<String> filterIntents(List<String> intents) {
    // Filter out duplicates and unsupported intents
    return intents
        .where((intent) => _supportedIntents.contains(intent))
        .toSet()
        .toList();
  }

  @override
  void addIntentPattern(String pattern, String intentType) {
    _patterns[pattern.toLowerCase()] = intentType;
    _supportedIntents.add(intentType);
  }

  @override
  bool isSupportedIntent(String intentType) {
    return _supportedIntents.contains(intentType);
  }
}
