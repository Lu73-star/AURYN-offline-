// voice_hooks.dart
// Voice interaction hooks for awareness system
// Compatible with Dart/Flutter 3.x

/// {@template voice_hooks}
/// Defines events and triggers for voice interactions.
///
/// Provides callback hooks for voice-related events
/// to integrate with the awareness system.
///
/// **Privacy Note**: Voice transcripts are processed locally only.
/// Recording voice data requires explicit opt-in consent.
/// {@endtemplate}
abstract class VoiceHooks {
  /// Trigger on voice input received
  /// [transcript] - The transcribed text from voice input
  void onVoiceInput(String transcript);

  /// Trigger on voice feedback
  /// [feedback] - The feedback text to be spoken
  void onVoiceFeedback(String feedback);

  /// Trigger on voice recording start
  void onRecordingStart();

  /// Trigger on voice recording stop
  void onRecordingStop();

  /// Set a callback for voice input events
  /// [callback] - Function to call when voice input is received
  void setVoiceInputCallback(void Function(String) callback);

  /// Set a callback for voice feedback events
  /// [callback] - Function to call when voice feedback is given
  void setVoiceFeedbackCallback(void Function(String) callback);
}

/// {@template voice_hooks_impl}
/// Default implementation of [VoiceHooks]
/// Provides basic event handling for voice interactions
/// {@endtemplate}
class VoiceHooksImpl implements VoiceHooks {
  void Function(String)? _voiceInputCallback;
  void Function(String)? _voiceFeedbackCallback;
  final List<String> _inputHistory = [];
  final List<String> _feedbackHistory = [];

  @override
  void onVoiceInput(String transcript) {
    _inputHistory.add(transcript);
    _voiceInputCallback?.call(transcript);
  }

  @override
  void onVoiceFeedback(String feedback) {
    _feedbackHistory.add(feedback);
    _voiceFeedbackCallback?.call(feedback);
  }

  @override
  void onRecordingStart() {
    // TODO: Implement recording start logic
    // Could be used to adjust system state during recording
  }

  @override
  void onRecordingStop() {
    // TODO: Implement recording stop logic
    // Could be used to finalize recording state
  }

  @override
  void setVoiceInputCallback(void Function(String) callback) {
    _voiceInputCallback = callback;
  }

  @override
  void setVoiceFeedbackCallback(void Function(String) callback) {
    _voiceFeedbackCallback = callback;
  }

  /// Get voice input history (for debugging/testing)
  List<String> getInputHistory() => List.from(_inputHistory);

  /// Get voice feedback history (for debugging/testing)
  List<String> getFeedbackHistory() => List.from(_feedbackHistory);
}
