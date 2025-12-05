/// lib/memdart/adapters/hive_adapter.dart
/// Adaptador de memória usando Hive para persistência local.

import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:auryn_offline/memdart/adapters/memory_adapter.dart';

class HiveAdapter implements MemoryAdapter {
  @override
  String get adapterName => 'HiveAdapter';

  late Box _box;
  bool _initialized = false;
  final String boxName;
  final List<int>? encryptionKey;

  HiveAdapter({
    this.boxName = 'auryn_memory',
    this.encryptionKey,
  });

  @override
  Future<void> init() async {
    if (_initialized) return;

    await Hive.initFlutter();

    if (encryptionKey != null) {
      _box = await Hive.openBox(
        boxName,
        encryptionCipher: HiveAesCipher(encryptionKey!),
      );
    } else {
      _box = await Hive.openBox(boxName);
    }

    _initialized = true;
  }

  @override
  Future<void> save(String key, dynamic value) async {
    _ensureInit();
    await _box.put(key, value);
  }

  @override
  Future<dynamic> read(String key) async {
    _ensureInit();
    return _box.get(key);
  }

  @override
  Future<void> delete(String key) async {
    _ensureInit();
    await _box.delete(key);
  }

  @override
  Future<bool> exists(String key) async {
    _ensureInit();
    return _box.containsKey(key);
  }

  @override
  Future<List<String>> listKeys() async {
    _ensureInit();
    return _box.keys.map((k) => k.toString()).toList();
  }

  @override
  Future<void> clear() async {
    _ensureInit();
    await _box.clear();
  }

  @override
  Future<void> close() async {
    if (!_initialized) return;
    await _box.close();
    _initialized = false;
  }

  void _ensureInit() {
    if (!_initialized) {
      throw Exception('HiveAdapter not initialized. Call init() first.');
    }
  }
}
