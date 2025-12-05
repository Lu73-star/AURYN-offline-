// voice_hooks.dart
// Voice interaction hooks for awareness system
// Compatible with Dart/Flutter 3.x

/// {@template voice_hooks}
/// Defines events and triggers for voice interactions
/// {@endtemplate}
abstract class VoiceHooks {
  /// Trigger on voice input received
  void onVoiceInput(String transcript); // TODO: Implement voice input hook

  /// Trigger on voice feedback
  void onVoiceFeedback(String feedback); // TODO: Implement feedback handling
}
