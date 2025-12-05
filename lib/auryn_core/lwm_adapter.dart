/// lib/auryn_core/lwm_adapter.dart
/// 
/// Abstract LWM Adapter Interface
/// 
/// This file defines the contract that all LWM adapters must implement.
/// Adapters are specialized modules that provide specific functionality
/// (STT, TTS, memory, etc.) within the AURYN LWM architecture.
/// 
/// **Purpose:**
/// LWMAdapter establishes a uniform interface for all adapter implementations,
/// enabling the LWMCore to interact with different subsystems in a consistent
/// manner. This abstraction allows for:
/// - Easy addition of new adapters
/// - Swapping implementations without changing core code
/// - Testing with mock adapters
/// - Plugin architecture for community extensions
/// 
/// **Architecture Position:**
/// LWMAdapter is the base contract in AURYN's adapter ecosystem:
/// - LWMCore uses LWMAdapter interface to communicate with adapters
/// - All concrete adapters (STTOfflineAdapter, TTSOfflineAdapter, etc.) implement this interface
/// - Adapters may interact with NativeBinding, ModelLoader, and other subsystems
/// 
/// **Adapter Lifecycle:**
/// 1. Creation: Adapter instance is created
/// 2. Registration: Adapter registered with LWMCore via registerAdapter()
/// 3. Initialization: initialize() called to setup adapter resources
/// 4. Ready: Adapter ready to process requests via process()
/// 5. Shutdown: cleanup() called to release resources
/// 
/// **Design Philosophy:**
/// - Simple interface: Easy to implement and understand
/// - Async by default: All operations are async for flexibility
/// - Type safety: Strong typing with generic return types
/// - Error handling: Clear error reporting via exceptions or error states
/// - Offline-first: No network dependencies in core interface
/// 
/// **Implementing an Adapter:**
/// To create a custom adapter:
/// 1. Extend LWMAdapter abstract class
/// 2. Implement all required methods
/// 3. Register with LWMCore during application setup
/// 4. Use getCapabilities() to declare adapter features
/// 
/// Example:
/// ```dart
/// class CustomAdapter extends LWMAdapter {
///   @override
///   String get adapterId => 'custom';
///   
///   @override
///   String get adapterVersion => '1.0.0';
///   
///   @override
///   Future<void> initialize(Map<String, dynamic>? config) async {
///     // Setup code
///   }
///   
///   @override
///   Future<dynamic> process(dynamic input, Map<String, dynamic>? options) async {
///     // Processing logic
///     return result;
///   }
///   
///   @override
///   Future<void> cleanup() async {
///     // Cleanup code
///   }
///   
///   @override
///   Map<String, dynamic> getCapabilities() {
///     return {'feature1': true, 'feature2': false};
///   }
/// }
/// ```

import 'dart:async';

/// Abstract base class for all LWM adapters.
/// 
/// Defines the contract that all adapters must implement to integrate with
/// AURYN's LWM system. Adapters provide specialized functionality like
/// speech-to-text, text-to-speech, memory management, etc.
/// 
/// All methods are designed to be async to support long-running operations
/// without blocking the main thread.
abstract class LWMAdapter {
  /// Unique identifier for this adapter.
  /// 
  /// Must be unique across all registered adapters. Common IDs include:
  /// - 'stt': Speech-to-text
  /// - 'tts': Text-to-speech
  /// - 'memory': Memory management
  /// - 'nlp': Natural language processing
  /// 
  /// Returns: String identifier (e.g., 'stt_offline', 'tts_google')
  String get adapterId;

  /// Version string for this adapter implementation.
  /// 
  /// Used for compatibility checking and debugging. Should follow
  /// semantic versioning (e.g., '1.0.0', '2.1.3-beta').
  /// 
  /// Returns: Version string
  String get adapterVersion;

  /// Adapter type/category for grouping related adapters.
  /// 
  /// Common types:
  /// - 'voice': Voice-related adapters (STT, TTS)
  /// - 'memory': Memory and storage adapters
  /// - 'nlp': Natural language processing
  /// - 'vision': Image/video processing
  /// - 'custom': User-defined adapters
  /// 
  /// Returns: Type string (default: 'custom')
  String get adapterType => 'custom';

  /// Human-readable description of this adapter.
  /// 
  /// Returns: Description string explaining adapter's purpose
  String get description => 'No description provided';

  /// Initializes the adapter with optional configuration.
  /// 
  /// Called by LWMCore after adapter registration. This is where the adapter
  /// should:
  /// - Load required models
  /// - Initialize native bindings
  /// - Setup internal state
  /// - Validate configuration
  /// 
  /// Parameters:
  /// - `config`: Optional configuration map with adapter-specific settings
  /// 
  /// Common config keys:
  /// - 'model_path': Path to model files
  /// - 'cache_enabled': Whether to enable caching
  /// - 'num_threads': Number of threads for processing
  /// 
  /// Returns: Future that completes when initialization is done
  /// 
  /// Throws:
  /// - `AdapterException` if initialization fails
  /// - `ArgumentError` if configuration is invalid
  Future<void> initialize(Map<String, dynamic>? config);

  /// Processes input data and returns result.
  /// 
  /// This is the main entry point for adapter operations. The exact type
  /// of input and output depends on the adapter:
  /// 
  /// STT Adapter:
  /// - Input: Audio data (Uint8List, File path, or Stream)
  /// - Output: Transcribed text (String)
  /// 
  /// TTS Adapter:
  /// - Input: Text to speak (String)
  /// - Output: Audio data or playback confirmation
  /// 
  /// Memory Adapter:
  /// - Input: Query parameters (Map)
  /// - Output: Retrieved data
  /// 
  /// Parameters:
  /// - `input`: Input data (type depends on adapter)
  /// - `options`: Optional processing options
  /// 
  /// Common options:
  /// - 'timeout': Maximum processing time in milliseconds
  /// - 'quality': Quality/accuracy trade-off setting
  /// - 'callback': Progress callback function
  /// 
  /// Returns: Future containing processing result (type depends on adapter)
  /// 
  /// Throws:
  /// - `AdapterException` if processing fails
  /// - `TimeoutException` if operation exceeds timeout
  Future<dynamic> process(dynamic input, Map<String, dynamic>? options);

  /// Returns adapter capabilities and features.
  /// 
  /// Used by LWMCore and applications to discover what features an adapter
  /// supports. This enables dynamic feature detection and graceful degradation.
  /// 
  /// Returns: Map describing supported features
  /// 
  /// Example return value:
  /// ```dart
  /// {
  ///   'streaming': true,           // Supports streaming input
  ///   'offline': true,              // Works offline
  ///   'languages': ['en', 'pt'],    // Supported languages
  ///   'formats': ['wav', 'mp3'],    // Supported input formats
  ///   'max_duration': 300,          // Max processing duration in seconds
  /// }
  /// ```
  Map<String, dynamic> getCapabilities();

  /// Validates whether this adapter can process given input.
  /// 
  /// Optional method for pre-validation before calling process().
  /// Allows adapters to quickly reject invalid input without expensive
  /// processing attempts.
  /// 
  /// Parameters:
  /// - `input`: Input data to validate
  /// 
  /// Returns: Future<bool> indicating if input is valid
  Future<bool> canProcess(dynamic input) async {
    // Default implementation: assume valid
    return true;
  }

  /// Returns current adapter status.
  /// 
  /// Provides runtime information about adapter state for monitoring
  /// and debugging.
  /// 
  /// Returns: Map containing status information
  /// 
  /// Common status keys:
  /// - 'ready': bool indicating if adapter is ready
  /// - 'busy': bool indicating if currently processing
  /// - 'error': String describing any error state
  /// - 'metrics': Map of performance metrics
  Map<String, dynamic> getStatus() {
    return {
      'adapter_id': adapterId,
      'version': adapterVersion,
      'type': adapterType,
      'ready': true,
    };
  }

  /// Cleans up adapter resources.
  /// 
  /// Called by LWMCore during shutdown or when adapter is unregistered.
  /// The adapter should:
  /// - Release memory
  /// - Close file handles
  /// - Stop background threads
  /// - Unload models
  /// - Clean up native resources
  /// 
  /// After cleanup(), the adapter should not be used until initialize()
  /// is called again.
  /// 
  /// Returns: Future that completes when cleanup is done
  Future<void> cleanup();

  /// Resets adapter to initial state.
  /// 
  /// Optional method to reset adapter without full cleanup/reinitialize.
  /// Useful for clearing caches or resetting state while keeping
  /// models loaded.
  /// 
  /// Returns: Future that completes when reset is done
  Future<void> reset() async {
    // Default implementation: no-op
  }
}

/// Exception thrown by adapter operations.
/// 
/// Used to report adapter-specific errors with context about what went wrong.
class AdapterException implements Exception {
  /// The adapter ID that threw this exception
  final String adapterId;

  /// Error message describing what went wrong
  final String message;

  /// Optional error code for categorizing errors
  final String? errorCode;

  /// Optional original exception that caused this error
  final dynamic originalError;

  /// Creates an adapter exception.
  /// 
  /// Parameters:
  /// - `adapterId`: ID of the adapter that threw the error
  /// - `message`: Human-readable error message
  /// - `errorCode`: Optional error code (e.g., 'MODEL_NOT_FOUND')
  /// - `originalError`: Optional underlying exception
  AdapterException(
    this.adapterId,
    this.message, {
    this.errorCode,
    this.originalError,
  });

  @override
  String toString() {
    final buffer = StringBuffer('AdapterException[$adapterId]: $message');
    if (errorCode != null) {
      buffer.write(' (code: $errorCode)');
    }
    if (originalError != null) {
      buffer.write('\nCaused by: $originalError');
    }
    return buffer.toString();
  }
}

/// Configuration builder for adapters.
/// 
/// Utility class to help construct adapter configuration maps with
/// validation and defaults.
class AdapterConfig {
  final Map<String, dynamic> _config = {};

  /// Sets a configuration value.
  /// 
  /// Parameters:
  /// - `key`: Configuration key
  /// - `value`: Configuration value
  /// 
  /// Returns: this for method chaining
  AdapterConfig set(String key, dynamic value) {
    _config[key] = value;
    return this;
  }

  /// Gets a configuration value.
  /// 
  /// Parameters:
  /// - `key`: Configuration key
  /// - `defaultValue`: Value to return if key not found
  /// 
  /// Returns: Configuration value or default
  dynamic get(String key, [dynamic defaultValue]) {
    return _config[key] ?? defaultValue;
  }

  /// Builds the final configuration map.
  /// 
  /// Returns: Immutable copy of configuration
  Map<String, dynamic> build() {
    return Map<String, dynamic>.unmodifiable(_config);
  }

  /// Creates config from existing map.
  /// 
  /// Parameters:
  /// - `map`: Initial configuration values
  static AdapterConfig fromMap(Map<String, dynamic> map) {
    final config = AdapterConfig();
    config._config.addAll(map);
    return config;
  }
}
