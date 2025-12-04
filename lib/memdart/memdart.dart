import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class MemDart {
  static final MemDart instance = MemDart._internal();
  factory MemDart() => instance;
  MemDart._internal();

  bool _initialized = false;
  late Box _box;

  static const String _boxName = 'auryn_memory_box';
  static const String _keyStorageId = 'auryn_secure_key';

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Future<void> init() async {
    if (_initialized) return;

    await Hive.initFlutter();

    final key = await _loadOrCreateEncryptionKey();

    _box = await Hive.openBox(
      _boxName,
      encryptionCipher: HiveAesCipher(key),
    );

    _initialized = true;
    debugPrint('[MemDart] initialized.');
  }

  Future<List<int>> _loadOrCreateEncryptionKey() async {
    final exists = await _secureStorage.read(key: _keyStorageId);

    if (exists != null) {
      return base64Decode(exists);
    }

    final newKey = Hive.generateSecureKey();
    await _secureStorage.write(
      key: _keyStorageId,
      value: base64Encode(newKey),
    );

    return newKey;
  }

  Future<void> save(String key, dynamic value) async {
    _ensureInit();
    await _box.put(key, value);
  }

  Future<dynamic> read(String key) async {
    _ensureInit();
    return _box.get(key);
  }

  Future<void> delete(String key) async {
    _ensureInit();
    await _box.delete(key);
  }

  Future<Map<String, dynamic>> query(String prefix) async {
    _ensureInit();
    final Map<String, dynamic> results = {};

    for (final key in _box.keys) {
      if (key.toString().startsWith(prefix)) {
        results[key.toString()] = _box.get(key);
      }
    }

    return results;
  }

  void _ensureInit() {
    if (!_initialized) {
      throw Exception('MemDart not initialized. Call MemDart().init() first.');
    }
  }
}
