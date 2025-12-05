/// lib/memdart/memory_adapter.dart
/// 
/// Memory System Adapter
/// 
/// This adapter integrates AURYN's MemDart memory system with the LWM
/// architecture, providing unified access to memory operations through
/// the adapter interface.
/// 
/// **Responsibilities:**
/// - Provide LWM adapter interface for memory operations
/// - Bridge between LWMCore and MemDart memory system
/// - Handle memory queries, storage, and retrieval
/// - Support different memory types (short-term, long-term, working)
/// - Manage memory lifecycle and cleanup
/// - Provide context-aware memory operations
/// 
/// **Architecture Position:**
/// MemoryAdapter connects the LWM runtime with AURYN's memory subsystem:
/// - `LWMCore`: Uses memory adapter for context and history
/// - `MemDart`: Underlying memory storage system
/// - `AurynProcessor`: Stores and retrieves conversation context
/// - Other adapters: May query memory for context
/// 
/// **Memory Types:**
/// AURYN uses multiple memory layers:
/// - **Episodic Memory**: Specific events and interactions
/// - **Semantic Memory**: Facts and knowledge
/// - **Working Memory**: Current context and active information
/// - **Procedural Memory**: Learned behaviors and patterns
/// 
/// **Design Philosophy:**
/// - Privacy-first: All memory stays on-device
/// - Efficient: Fast queries with minimal overhead
/// - Context-aware: Provide relevant information based on current state
/// - Organized: Structured storage with metadata
/// - Secure: Encrypted storage via MemDart
/// 
/// **Memory Operations:**
/// - Store: Save new information with metadata
/// - Query: Search memory with filters and ranking
/// - Retrieve: Get specific memory entries
/// - Update: Modify existing memories
/// - Delete: Remove memories (with user consent)
/// - Consolidate: Merge similar memories, forget irrelevant ones
/// 
/// **Context Management:**
/// Memory adapter helps maintain conversation context:
/// - Recent interactions for continuity
/// - User preferences and patterns
/// - Emotional state history
/// - Important facts about the user
/// 
/// **Future Extensions:**
/// - Vector embeddings for semantic search
/// - Memory importance scoring
/// - Automatic memory consolidation
/// - Memory visualization for users
/// - Export/import memory data
/// - Memory sharing between AURYN instances (with consent)

import 'dart:async';
import 'package:auryn_offline/auryn_core/lwm_adapter.dart';
import 'package:auryn_offline/memdart/memdart.dart';

/// Memory system adapter for AURYN's LWM architecture.
/// 
/// Provides unified memory operations through the LWM adapter interface,
/// integrating MemDart's encrypted storage with the runtime system.
/// 
/// Example usage:
/// ```dart
/// final memoryAdapter = MemoryAdapter();
/// 
/// // Initialize adapter
/// await memoryAdapter.initialize({
///   'cache_size': 100,
///   'auto_cleanup': true,
/// });
/// 
/// // Store a memory
/// await memoryAdapter.process({
///   'operation': 'store',
///   'type': 'episodic',
///   'key': 'conversation_2024_12_05',
///   'content': 'User asked about weather',
///   'metadata': {'timestamp': DateTime.now().toIso8601String()},
/// });
/// 
/// // Query memories
/// final results = await memoryAdapter.process({
///   'operation': 'query',
///   'type': 'episodic',
///   'filter': {'contains': 'weather'},
///   'limit': 5,
/// });
/// 
/// // Retrieve specific memory
/// final memory = await memoryAdapter.process({
///   'operation': 'retrieve',
///   'key': 'user_preferences',
/// });
/// 
/// await memoryAdapter.cleanup();
/// ```
class MemoryAdapter extends LWMAdapter {
  @override
  String get adapterId => 'memory';

  @override
  String get adapterVersion => '0.1.0';

  @override
  String get adapterType => 'memory';

  @override
  String get description =>
      'Memory system adapter providing unified access to AURYN\'s encrypted memory storage';

  /// Reference to MemDart instance
  final MemDart _memDart = MemDart();

  /// Whether adapter is ready
  bool _ready = false;

  /// Memory type prefixes for organization
  static const Map<String, String> _memoryPrefixes = {
    'episodic': 'mem_episodic_',
    'semantic': 'mem_semantic_',
    'working': 'mem_working_',
    'procedural': 'mem_procedural_',
    'user_prefs': 'mem_prefs_',
  };

  /// In-memory cache for frequently accessed data
  final Map<String, dynamic> _cache = {};

  /// Maximum cache entries
  int _maxCacheSize = 100;

  @override
  Future<void> initialize(Map<String, dynamic>? config) async {
    if (_ready) {
      throw AdapterException(
        adapterId,
        'Adapter already initialized',
        errorCode: 'ALREADY_INITIALIZED',
      );
    }

    try {
      // Configure cache size
      _maxCacheSize = config?['cache_size'] as int? ?? 100;

      // Initialize MemDart if not already initialized
      await _memDart.init();

      // TODO: Phase 3 - Additional initialization
      // - Setup memory schemas
      // - Load frequently accessed memories to cache
      // - Initialize memory consolidation scheduler
      // - Setup memory metrics tracking

      _ready = true;
    } catch (e) {
      throw AdapterException(
        adapterId,
        'Initialization failed: $e',
        errorCode: 'INIT_FAILED',
        originalError: e,
      );
    }
  }

  @override
  Future<dynamic> process(dynamic input, Map<String, dynamic>? options) async {
    if (!_ready) {
      throw AdapterException(
        adapterId,
        'Adapter not initialized',
        errorCode: 'NOT_INITIALIZED',
      );
    }

    if (input is! Map<String, dynamic>) {
      throw AdapterException(
        adapterId,
        'Input must be a Map<String, dynamic>',
        errorCode: 'INVALID_INPUT',
      );
    }

    final operation = input['operation'] as String?;
    if (operation == null) {
      throw AdapterException(
        adapterId,
        'Operation not specified',
        errorCode: 'MISSING_OPERATION',
      );
    }

    try {
      switch (operation) {
        case 'store':
          return await _handleStore(input);
        case 'retrieve':
          return await _handleRetrieve(input);
        case 'query':
          return await _handleQuery(input);
        case 'update':
          return await _handleUpdate(input);
        case 'delete':
          return await _handleDelete(input);
        case 'clear':
          return await _handleClear(input);
        default:
          throw AdapterException(
            adapterId,
            'Unknown operation: $operation',
            errorCode: 'UNKNOWN_OPERATION',
          );
      }
    } catch (e) {
      throw AdapterException(
        adapterId,
        'Operation "$operation" failed: $e',
        errorCode: 'OPERATION_FAILED',
        originalError: e,
      );
    }
  }

  /// Handles store operation.
  /// 
  /// Stores data in memory with optional metadata.
  /// 
  /// Input format:
  /// ```dart
  /// {
  ///   'operation': 'store',
  ///   'key': 'unique_key',
  ///   'content': data,
  ///   'type': 'episodic|semantic|working|procedural',
  ///   'metadata': {'timestamp': ..., 'importance': ...},
  /// }
  /// ```
  Future<Map<String, dynamic>> _handleStore(Map<String, dynamic> input) async {
    final key = input['key'] as String?;
    final content = input['content'];
    final type = input['type'] as String? ?? 'episodic';
    final metadata = input['metadata'] as Map<String, dynamic>? ?? {};

    if (key == null) {
      throw AdapterException(adapterId, 'Key is required for store operation');
    }

    // Add timestamp if not present
    if (!metadata.containsKey('timestamp')) {
      metadata['timestamp'] = DateTime.now().toIso8601String();
    }

    // Build storage key with prefix
    final prefix = _memoryPrefixes[type] ?? 'mem_other_';
    final storageKey = '$prefix$key';

    // Create memory entry
    final memoryEntry = {
      'content': content,
      'metadata': metadata,
      'type': type,
    };

    // TODO: Phase 3 - Implement full storage logic
    // - Validate content
    // - Apply memory consolidation if needed
    // - Update importance scores
    // - Trigger cleanup if memory full

    await _memDart.save(storageKey, memoryEntry);

    // Update cache
    _updateCache(storageKey, memoryEntry);

    return {
      'success': true,
      'key': key,
      'storage_key': storageKey,
    };
  }

  /// Handles retrieve operation.
  /// 
  /// Retrieves a specific memory by key.
  /// 
  /// Input format:
  /// ```dart
  /// {
  ///   'operation': 'retrieve',
  ///   'key': 'unique_key',
  ///   'type': 'episodic|semantic|...',
  /// }
  /// ```
  Future<dynamic> _handleRetrieve(Map<String, dynamic> input) async {
    final key = input['key'] as String?;
    final type = input['type'] as String? ?? 'episodic';

    if (key == null) {
      throw AdapterException(adapterId, 'Key is required for retrieve operation');
    }

    // Build storage key
    final prefix = _memoryPrefixes[type] ?? 'mem_other_';
    final storageKey = '$prefix$key';

    // Check cache first
    if (_cache.containsKey(storageKey)) {
      return _cache[storageKey];
    }

    // TODO: Phase 3 - Implement retrieval with error handling
    final memoryEntry = await _memDart.read(storageKey);

    if (memoryEntry != null) {
      _updateCache(storageKey, memoryEntry);
    }

    return memoryEntry;
  }

  /// Handles query operation.
  /// 
  /// Searches memories based on filters.
  /// 
  /// Input format:
  /// ```dart
  /// {
  ///   'operation': 'query',
  ///   'type': 'episodic|semantic|...',
  ///   'filter': {'contains': 'search_term'},
  ///   'limit': 10,
  ///   'sort': 'timestamp|importance',
  /// }
  /// ```
  Future<List<dynamic>> _handleQuery(Map<String, dynamic> input) async {
    final type = input['type'] as String?;
    final filter = input['filter'] as Map<String, dynamic>?;
    final limit = input['limit'] as int? ?? 10;

    // Build prefix for query
    final prefix = type != null ? (_memoryPrefixes[type] ?? 'mem_other_') : 'mem_';

    // TODO: Phase 3 - Implement advanced query logic
    // - Apply filters
    // - Rank results by relevance/importance
    // - Apply limit
    // - Return sorted results

    final results = await _memDart.query(prefix);
    final entries = <dynamic>[];

    for (final entry in results.entries) {
      // Simple filter implementation
      if (filter != null && filter['contains'] != null) {
        final searchTerm = filter['contains'] as String;
        final content = entry.value.toString();
        if (!content.toLowerCase().contains(searchTerm.toLowerCase())) {
          continue;
        }
      }

      entries.add({
        'key': entry.key,
        'data': entry.value,
      });

      if (entries.length >= limit) break;
    }

    return entries;
  }

  /// Handles update operation.
  Future<Map<String, dynamic>> _handleUpdate(Map<String, dynamic> input) async {
    // Similar to store but checks if key exists
    final existing = await _handleRetrieve(input);
    if (existing == null) {
      throw AdapterException(adapterId, 'Key not found for update');
    }

    return await _handleStore(input);
  }

  /// Handles delete operation.
  Future<Map<String, dynamic>> _handleDelete(Map<String, dynamic> input) async {
    final key = input['key'] as String?;
    final type = input['type'] as String? ?? 'episodic';

    if (key == null) {
      throw AdapterException(adapterId, 'Key is required for delete operation');
    }

    final prefix = _memoryPrefixes[type] ?? 'mem_other_';
    final storageKey = '$prefix$key';

    // TODO: Phase 3 - Implement delete with confirmation
    await _memDart.delete(storageKey);
    _cache.remove(storageKey);

    return {
      'success': true,
      'key': key,
    };
  }

  /// Handles clear operation.
  Future<Map<String, dynamic>> _handleClear(Map<String, dynamic> input) async {
    final type = input['type'] as String?;

    // TODO: Phase 3 - Implement clear with confirmation
    // Clear specific type or all memories
    _cache.clear();

    return {
      'success': true,
      'cleared_type': type ?? 'all',
    };
  }

  /// Updates in-memory cache.
  void _updateCache(String key, dynamic value) {
    // Simple LRU: remove oldest if full
    if (_cache.length >= _maxCacheSize) {
      _cache.remove(_cache.keys.first);
    }
    _cache[key] = value;
  }

  @override
  Future<bool> canProcess(dynamic input) async {
    return input is Map<String, dynamic> && input['operation'] != null;
  }

  @override
  Map<String, dynamic> getCapabilities() {
    return {
      'offline': true,
      'encrypted': true,
      'memory_types': _memoryPrefixes.keys.toList(),
      'operations': ['store', 'retrieve', 'query', 'update', 'delete', 'clear'],
      'features': {
        'metadata': true,
        'query_filters': true,
        'importance_scoring': false, // TODO: Phase 4
        'semantic_search': false, // TODO: Phase 4
        'auto_consolidation': false, // TODO: Phase 4
      },
    };
  }

  @override
  Map<String, dynamic> getStatus() {
    return {
      ...super.getStatus(),
      'ready': _ready,
      'cache_entries': _cache.length,
      'max_cache_size': _maxCacheSize,
    };
  }

  @override
  Future<void> cleanup() async {
    // TODO: Phase 3 - Implement cleanup
    // - Flush cache
    // - Consolidate memories if needed
    // - Save important metrics

    _cache.clear();
    _ready = false;
  }

  @override
  Future<void> reset() async {
    _cache.clear();
  }
}
