/// lib/data/model_loader.dart
/// 
/// Model Loader Utility
/// 
/// This module provides utilities for loading, caching, and managing AI model
/// files within AURYN. It handles model discovery, validation, caching, and
/// efficient loading for the LWM runtime.
/// 
/// **Responsibilities:**
/// - Load model files from assets or filesystem
/// - Validate model integrity (checksums, format)
/// - Cache frequently used models in memory
/// - Manage model lifecycle (load, unload, reload)
/// - Handle model versioning and compatibility
/// - Support multiple model formats (TFLite, ONNX, custom)
/// - Provide efficient streaming for large models
/// 
/// **Architecture Position:**
/// ModelLoader is a utility layer used by various components:
/// - `RuntimeInitializer`: Validates model availability at startup
/// - `LWMCore`: Loads models for adapters
/// - `STTOfflineAdapter`: Loads speech recognition models
/// - `TTSOfflineAdapter`: Loads voice synthesis models
/// - `NativeBinding`: May use loader for native model formats
/// 
/// **Model Types:**
/// AURYN supports various model types:
/// - TensorFlow Lite (.tflite): Lightweight ML models
/// - ONNX (.onnx): Cross-platform ML models
/// - Vosk (.zip): Speech recognition models
/// - Piper (.onnx + .json): TTS voice models
/// - Custom formats: AURYN-specific model formats
/// 
/// **Model Storage:**
/// Models can be stored in multiple locations:
/// - `assets/models/`: Bundled with app (immutable)
/// - App documents: Downloaded or user-provided models
/// - Cache directory: Temporary model cache
/// - External storage: Optional for large models
/// 
/// **Design Philosophy:**
/// - Lazy loading: Load models only when needed
/// - Memory efficient: Stream large files, cache strategically
/// - Validation: Always verify model integrity
/// - Offline-first: No network dependencies
/// - Graceful degradation: Handle missing/corrupted models
/// 
/// **Caching Strategy:**
/// - LRU (Least Recently Used) cache for model data
/// - Configurable cache size limits
/// - Automatic eviction of old models
/// - Memory pressure handling
/// 
/// **Model Metadata:**
/// Each model should have accompanying metadata:
/// ```json
/// {
///   "name": "whisper-tiny-pt",
///   "version": "1.0.0",
///   "type": "stt",
///   "format": "tflite",
///   "language": "pt-BR",
///   "size_bytes": 39401900,
///   "checksum_sha256": "abc123...",
///   "compatibility": "0.1.0+",
///   "description": "Tiny Whisper model for Portuguese"
/// }
/// ```
/// 
/// **Future Extensions:**
/// - Delta updates for model versions
/// - Model compression/decompression
/// - Encrypted model support
/// - Remote model download with verification
/// - Model quantization on-the-fly
/// - Multi-part model loading

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:crypto/crypto.dart';
import 'dart:convert';

/// Utility class for loading and managing AI model files.
/// 
/// Provides methods for discovering, loading, validating, and caching model
/// files for AURYN's LWM runtime.
/// 
/// Example usage:
/// ```dart
/// final loader = ModelLoader();
/// 
/// // Initialize with configuration
/// await loader.initialize({
///   'cache_size_mb': 100,
///   'model_dirs': ['assets/models', '/data/models'],
/// });
/// 
/// // Load a model
/// final modelData = await loader.loadModel('whisper-tiny-pt', {
///   'validate_checksum': true,
///   'cache': true,
/// });
/// 
/// // Check model availability
/// if (await loader.isModelAvailable('tts-voice-female')) {
///   print('Model is available');
/// }
/// 
/// // Get model metadata
/// final metadata = await loader.getModelMetadata('whisper-tiny-pt');
/// print('Model version: ${metadata['version']}');
/// 
/// // Clear cache when done
/// await loader.clearCache();
/// ```
class ModelLoader {
  /// Singleton instance
  static final ModelLoader _instance = ModelLoader._internal();
  
  /// Factory constructor
  factory ModelLoader() => _instance;
  
  /// Private constructor
  ModelLoader._internal();

  /// Model cache: modelId -> model data
  final Map<String, Uint8List> _modelCache = {};

  /// Model metadata cache: modelId -> metadata
  final Map<String, Map<String, dynamic>> _metadataCache = {};

  /// Maximum cache size in bytes
  int _maxCacheSize = 100 * 1024 * 1024; // 100MB default

  /// Current cache size in bytes
  int _currentCacheSize = 0;

  /// Model search directories
  final List<String> _modelDirectories = ['assets/models'];

  /// Whether loader is initialized
  bool _initialized = false;

  /// Initializes the model loader.
  /// 
  /// Parameters:
  /// - `config`: Configuration map
  /// 
  /// Common config keys:
  /// - `cache_size_mb`: Maximum cache size in megabytes
  /// - `model_dirs`: List of directories to search for models
  /// - `preload_models`: List of model IDs to preload
  /// 
  /// Returns: Future that completes when initialization is done
  Future<void> initialize(Map<String, dynamic>? config) async {
    if (_initialized) return;

    try {
      // Configure cache size
      if (config?['cache_size_mb'] != null) {
        _maxCacheSize = (config!['cache_size_mb'] as int) * 1024 * 1024;
      }

      // Add additional model directories
      if (config?['model_dirs'] != null) {
        final dirs = config!['model_dirs'] as List;
        _modelDirectories.addAll(dirs.cast<String>());
      }

      // TODO: Phase 3 - Implement initialization
      // - Scan model directories
      // - Build model registry
      // - Preload specified models
      // - Validate model directory permissions

      _initialized = true;
    } catch (e) {
      throw ModelLoaderException('Initialization failed: $e');
    }
  }

  /// Loads a model by ID.
  /// 
  /// Parameters:
  /// - `modelId`: Unique identifier for the model
  /// - `options`: Optional loading options
  /// 
  /// Common options:
  /// - `validate_checksum`: Whether to validate checksum (default: true)
  /// - `cache`: Whether to cache loaded model (default: true)
  /// - `force_reload`: Force reload even if cached (default: false)
  /// 
  /// Returns: Future containing model data as Uint8List
  /// 
  /// Throws:
  /// - `ModelLoaderException` if model not found or loading fails
  Future<Uint8List> loadModel(
    String modelId, {
    Map<String, dynamic>? options,
  }) async {
    _ensureInitialized();

    final validateChecksum = options?['validate_checksum'] as bool? ?? true;
    final cache = options?['cache'] as bool? ?? true;
    final forceReload = options?['force_reload'] as bool? ?? false;

    // Check cache first
    if (!forceReload && _modelCache.containsKey(modelId)) {
      return _modelCache[modelId]!;
    }

    try {
      // TODO: Phase 3 - Implement model loading
      // 1. Find model file path
      final modelPath = await _findModelPath(modelId);
      if (modelPath == null) {
        throw ModelLoaderException('Model "$modelId" not found');
      }

      // 2. Load model data
      final modelData = await _loadModelData(modelPath);

      // 3. Validate checksum if requested
      if (validateChecksum) {
        await _validateChecksum(modelId, modelData);
      }

      // 4. Cache if requested and space available
      if (cache) {
        await _cacheModel(modelId, modelData);
      }

      return modelData;
    } catch (e) {
      throw ModelLoaderException('Failed to load model "$modelId": $e');
    }
  }

  /// Finds the file path for a model.
  /// 
  /// Searches in configured model directories.
  /// 
  /// Parameters:
  /// - `modelId`: Model identifier
  /// 
  /// Returns: Future with file path, or null if not found
  Future<String?> _findModelPath(String modelId) async {
    // TODO: Phase 3 - Implement model path resolution
    // - Check each model directory
    // - Look for model file with various extensions
    // - Check asset bundle
    // - Return first found path

    // Check asset bundle first
    try {
      final assetPath = 'assets/models/$modelId';
      // Try common extensions
      for (final ext in ['.tflite', '.onnx', '.bin', '']) {
        final fullPath = '$assetPath$ext';
        try {
          await rootBundle.load(fullPath);
          return fullPath;
        } catch (_) {
          continue;
        }
      }
    } catch (_) {}

    // Check filesystem directories
    for (final dir in _modelDirectories) {
      if (dir.startsWith('assets/')) continue; // Already checked
      
      for (final ext in ['.tflite', '.onnx', '.bin', '']) {
        final fullPath = '$dir/$modelId$ext';
        if (await File(fullPath).exists()) {
          return fullPath;
        }
      }
    }

    return null;
  }

  /// Loads model data from file or assets.
  /// 
  /// Parameters:
  /// - `path`: Path to model file
  /// 
  /// Returns: Future with model data
  Future<Uint8List> _loadModelData(String path) async {
    // TODO: Phase 3 - Implement model data loading
    if (path.startsWith('assets/')) {
      // Load from asset bundle
      final byteData = await rootBundle.load(path);
      return byteData.buffer.asUint8List();
    } else {
      // Load from filesystem
      final file = File(path);
      return await file.readAsBytes();
    }
  }

  /// Validates model checksum.
  /// 
  /// Parameters:
  /// - `modelId`: Model identifier
  /// - `modelData`: Model data to validate
  /// 
  /// Throws: ModelLoaderException if checksum doesn't match
  Future<void> _validateChecksum(
    String modelId,
    Uint8List modelData,
  ) async {
    // TODO: Phase 3 - Implement checksum validation
    // - Load expected checksum from metadata
    // - Calculate actual checksum
    // - Compare and throw if mismatch

    final metadata = await getModelMetadata(modelId);
    if (metadata == null || metadata['checksum_sha256'] == null) {
      return; // No checksum to validate
    }

    final expectedChecksum = metadata['checksum_sha256'] as String;
    final actualChecksum = sha256.convert(modelData).toString();

    if (actualChecksum != expectedChecksum) {
      throw ModelLoaderException(
        'Checksum mismatch for model "$modelId"',
      );
    }
  }

  /// Caches a model in memory.
  /// 
  /// Parameters:
  /// - `modelId`: Model identifier
  /// - `modelData`: Model data to cache
  Future<void> _cacheModel(String modelId, Uint8List modelData) async {
    // Check if adding this model exceeds cache limit
    final modelSize = modelData.length;
    
    if (modelSize > _maxCacheSize) {
      // Model too large to cache
      return;
    }

    // Evict old models if necessary
    while (_currentCacheSize + modelSize > _maxCacheSize) {
      _evictOldestModel();
    }

    // Cache the model
    _modelCache[modelId] = modelData;
    _currentCacheSize += modelSize;
  }

  /// Evicts the oldest model from cache (LRU).
  void _evictOldestModel() {
    if (_modelCache.isEmpty) return;

    // Simple implementation: remove first entry
    // TODO: Phase 3 - Implement proper LRU tracking
    final firstKey = _modelCache.keys.first;
    final modelData = _modelCache.remove(firstKey);
    if (modelData != null) {
      _currentCacheSize -= modelData.length;
    }
  }

  /// Checks if a model is available.
  /// 
  /// Parameters:
  /// - `modelId`: Model identifier
  /// 
  /// Returns: Future<bool> indicating availability
  Future<bool> isModelAvailable(String modelId) async {
    _ensureInitialized();
    
    // Check cache
    if (_modelCache.containsKey(modelId)) return true;
    
    // Check if file exists
    final path = await _findModelPath(modelId);
    return path != null;
  }

  /// Gets metadata for a model.
  /// 
  /// Parameters:
  /// - `modelId`: Model identifier
  /// 
  /// Returns: Future with metadata map, or null if not found
  Future<Map<String, dynamic>?> getModelMetadata(String modelId) async {
    _ensureInitialized();

    // Check metadata cache
    if (_metadataCache.containsKey(modelId)) {
      return _metadataCache[modelId];
    }

    // TODO: Phase 3 - Load metadata from file
    // Look for {modelId}.json or {modelId}.meta
    final metadataPath = await _findModelPath('$modelId.meta');
    if (metadataPath == null) {
      return null;
    }

    try {
      final metadataJson = await _loadModelData(metadataPath);
      final metadata = json.decode(utf8.decode(metadataJson)) as Map<String, dynamic>;
      _metadataCache[modelId] = metadata;
      return metadata;
    } catch (_) {
      return null;
    }
  }

  /// Lists all available models.
  /// 
  /// Returns: Future with list of model IDs
  Future<List<String>> listAvailableModels() async {
    _ensureInitialized();

    // TODO: Phase 3 - Scan directories and list models
    final models = <String>[];
    
    // Add cached models
    models.addAll(_modelCache.keys);
    
    // Scan directories for additional models
    // ...

    return models;
  }

  /// Unloads a model from cache.
  /// 
  /// Parameters:
  /// - `modelId`: Model identifier
  Future<void> unloadModel(String modelId) async {
    final modelData = _modelCache.remove(modelId);
    if (modelData != null) {
      _currentCacheSize -= modelData.length;
    }
  }

  /// Clears all cached models.
  /// 
  /// Returns: Future that completes when cache is cleared
  Future<void> clearCache() async {
    _modelCache.clear();
    _currentCacheSize = 0;
  }

  /// Gets cache statistics.
  /// 
  /// Returns: Map with cache information
  Map<String, dynamic> getCacheStats() {
    return {
      'cached_models': _modelCache.length,
      'cache_size_bytes': _currentCacheSize,
      'max_cache_size_bytes': _maxCacheSize,
      'cache_utilization': _currentCacheSize / _maxCacheSize,
    };
  }

  /// Ensures loader is initialized.
  void _ensureInitialized() {
    if (!_initialized) {
      throw ModelLoaderException(
        'ModelLoader not initialized. Call initialize() first.',
      );
    }
  }

  /// Cleanup resources.
  Future<void> cleanup() async {
    await clearCache();
    _metadataCache.clear();
    _initialized = false;
  }
}

/// Exception thrown by model loader operations.
class ModelLoaderException implements Exception {
  /// Error message
  final String message;

  /// Optional error code
  final String? errorCode;

  /// Creates a model loader exception
  ModelLoaderException(this.message, {this.errorCode});

  @override
  String toString() {
    if (errorCode != null) {
      return 'ModelLoaderException[$errorCode]: $message';
    }
    return 'ModelLoaderException: $message';
  }
}
