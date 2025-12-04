import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Serviço de Memória Persistente da AURYN (MemDart)
/// Responsável por:
/// - Carregar e inicializar a memória criptografada
/// - Armazenar interações e dados internos
/// - Prover consultas rápidas
/// - Manter chave segura
class MemDart {
  static final MemDart _instancia = MemDart._internal();
  factory MemDart() => _instancia;
  MemDart._internal();

  static const String _boxName = 'auryn_memory';
  static const String _secureKeyId = 'auryn_secure_key_v1';

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  bool _inicializado = false;
  Box? _box;

  /// Inicialização completa da memória
  Future<void> inicializar() async {
    if (_inicializado) return;

    await Hive.initFlutter();

    // Recupera ou cria chave criptografada
    final chave = await _obterOuCriarChave();

    // Abre a Hive Box criptografada
    _box = await Hive.openBox(
      _boxName,
      encryptionCipher: HiveAesCipher(chave),
    );

    _inicializado = true;
    debugPrint("[MemDart] Memória inicializada.");
  }

  /// Obter chave criptografada ou criar uma nova
  Future<List<int>> _obterOuCriarChave() async {
    final armazenada = await _secureStorage.read(key: _secureKeyId);

    if (armazenada != null) {
      return base64Decode(armazenada);
    }

    final chaveNova = Hive.generateSecureKey();
    await _secureStorage.write(
      key: _secureKeyId,
      value: base64Encode(chaveNova),
    );

    return chaveNova;
  }

  /// Salvar chave-valor simples
  Future<void> salvar(String chave, dynamic valor) async {
    _garantirInicializacao();
    await _box!.put(chave, valor);
  }

  /// Ler chave-valor simples
  Future<dynamic> ler(String chave) async {
    _garantirInicializacao();
    return _box!.get(chave);
  }

  /// Remover item
  Future<void> remover(String chave) async {
    _garantirInicializacao();
    await _box!.delete(chave);
  }

  /// Salvar interações (memória narrativa)
  Future<void> salvarInteracao(String texto) async {
    _garantirInicializacao();
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    await _box!.put("interacao_$timestamp", texto);
  }

  /// Buscar por prefixo (ex.: “interacao_”)
  Future<Map<String, dynamic>> buscarPrefixo(String prefixo) async {
    _garantirInicializacao();

    final resultados = <String, dynamic>{};

    for (final chave in _box!.keys) {
      final ks = chave.toString();
      if (ks.startsWith(prefixo)) {
        resultados[ks] = _box!.get(chave);
      }
    }

    return resultados;
  }

  /// Exportar toda a memória para JSON (para backup futuro)
  Future<String> exportarComoJson() async {
    _garantirInicializacao();

    final data = <String, dynamic>{};

    for (final chave in _box!.keys) {
      data[chave.toString()] = _box!.get(chave);
    }

    return jsonEncode(data);
  }

  void _garantirInicializacao() {
    if (!_inicializado) {
      throw Exception("MemDart não inicializado. Execute inicializar() primeiro.");
    }
  }
}
