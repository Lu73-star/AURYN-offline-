import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:auryn_offline/memdart/adapters/memory_adapter.dart';
import 'package:auryn_offline/memdart/adapters/hive_adapter.dart';
import 'package:auryn_offline/memdart/utils/memory_query.dart';
import 'package:auryn_offline/memdart/utils/memory_index.dart';

/// MemDart - Sistema de memória persistente local da AURYN
/// Micro-storage otimizado para armazenamento offline
class MemDart {
  static final MemDart instance = MemDart._internal();
  factory MemDart() => instance;
  MemDart._internal();

  bool _initialized = false;
  late Box _box;
  late MemoryAdapter _adapter;
  final MemoryIndex _index = MemoryIndex();

  static const String _boxName = 'auryn_memory_box';
  static const String _keyStorageId = 'auryn_secure_key';

  Future<void> init({MemoryAdapter? adapter}) async {
    if (_initialized) return;

    await Hive.initFlutter();

    // Usar adaptador fornecido ou criar um HiveAdapter padrão
    if (adapter != null) {
      _adapter = adapter;
    } else {
      final key = Hive.generateSecureKey();
      _adapter = HiveAdapter(
        boxName: _boxName,
        encryptionKey: key,
      );
    }

    await _adapter.init();

    // Abrir box para compatibilidade com código legado
    _box = await Hive.openBox(_boxName);

    _initialized = true;
    debugPrint('[MemDart] initialized with ${_adapter.adapterName}');
  }

  Future<void> save(String key, dynamic value, {String? tag}) async {
    _ensureInit();
    
    // Salvar via adapter (principal)
    await _adapter.save(key, value);
    
    // Salvar em box legado para compatibilidade (pode ser removido no futuro)
    // TODO: Remover dual-write após migração completa
    await _box.put(key, value);

    // Indexar por prefixo (primeiros 3 caracteres)
    if (key.length >= 3) {
      _index.indexByPrefix(key, key.substring(0, 3));
    }

    // Indexar por tag se fornecida
    if (tag != null) {
      _index.indexByTag(key, tag);
    }

    // Indexar por tempo
    _index.indexByTime(key, DateTime.now());
  }

  /// Alias para save() para compatibilidade com código antigo
  Future<void> set(String key, dynamic value) async {
    await save(key, value);
  }

  Future<dynamic> read(String key) async {
    _ensureInit();
    return await _adapter.read(key);
  }

  /// Alias para read() para compatibilidade
  Future<dynamic> get(String key) async {
    return await read(key);
  }

  Future<void> delete(String key) async {
    _ensureInit();
    await _adapter.delete(key);
    _index.removeKey(key);
  }

  /// Consulta por prefixo
  Future<Map<String, dynamic>> query(String prefix) async {
    _ensureInit();
    final Map<String, dynamic> results = {};

    final keys = await _adapter.listKeys();
    final filteredKeys = MemoryQuery.filterByPrefix(keys, prefix);

    for (final key in filteredKeys) {
      results[key] = await _adapter.read(key);
    }

    return results;
  }

  /// Consulta por tag
  Future<Map<String, dynamic>> queryByTag(String tag) async {
    _ensureInit();
    final Map<String, dynamic> results = {};

    final keys = _index.searchByTag(tag);
    for (final key in keys) {
      results[key] = await _adapter.read(key);
    }

    return results;
  }

  /// Consulta por intervalo de tempo
  Future<Map<String, dynamic>> queryByTimeRange(
    DateTime start,
    DateTime end,
  ) async {
    _ensureInit();
    final Map<String, dynamic> results = {};

    final keys = _index.searchByTimeRange(start, end);
    for (final key in keys) {
      results[key] = await _adapter.read(key);
    }

    return results;
  }

  /// Lista todas as chaves
  Future<List<String>> listKeys() async {
    _ensureInit();
    return await _adapter.listKeys();
  }

  /// Verifica se uma chave existe
  Future<bool> exists(String key) async {
    _ensureInit();
    return await _adapter.exists(key);
  }

  /// Limpa todos os dados
  Future<void> clear() async {
    _ensureInit();
    await _adapter.clear();
    _index.clear();
  }

  void _ensureInit() {
    if (!_initialized) {
      throw Exception('MemDart not initialized. Call MemDart().init() first.');
    }
  }

  /// Retorna estatísticas da memória
  Future<Map<String, dynamic>> getStats() async {
    _ensureInit();
    final keys = await _adapter.listKeys();

    return {
      'total_keys': keys.length,
      'adapter': _adapter.adapterName,
      'index_stats': _index.getStats(),
    };
  }

  /// Fecha o sistema de memória
  Future<void> close() async {
    if (!_initialized) return;
    await _adapter.close();
    await _box.close();
    _index.clear();
    _initialized = false;
  }
}
