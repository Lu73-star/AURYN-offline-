/// lib/auryn_core/memory/long_term_memory.dart
/// LongTermMemory - Armazenamento persistente de longo prazo.
///
/// Gerencia memórias persistentes usando MemoryRepository,
/// fornecendo métodos de alto nível para salvar, buscar e gerenciar
/// memórias de longo prazo.

import 'package:auryn_offline/auryn_core/memory/memory_entry.dart';
import 'package:auryn_offline/auryn_core/memory/memory_scope.dart';
import 'package:auryn_offline/auryn_core/memory/memory_repository.dart';
import 'package:auryn_offline/auryn_core/memory/memory_expiration.dart';

/// {@template long_term_memory}
/// Gerencia memória de longo prazo da AURYN.
///
/// Usa MemoryRepository para persistência e fornece
/// métodos de alto nível para operações de memória.
/// {@endtemplate}
class LongTermMemory {
  /// Repositório de memórias
  final MemoryRepository _repository;

  /// Gerenciador de expiração
  final MemoryExpiration _expiration;

  /// Indica se está inicializado
  bool _isInitialized = false;

  /// Construtor
  LongTermMemory({
    MemoryRepository? repository,
    MemoryExpiration? expiration,
  })  : _repository = repository ?? MemoryRepository(),
        _expiration = expiration ?? MemoryExpiration(
                configs: ExpirationPolicies.balanced());

  /// Verifica se está inicializado
  bool get isInitialized => _isInitialized;

  /// Inicializa a memória de longo prazo
  Future<void> initialize() async {
    if (_isInitialized) return;

    await _repository.initialize();
    _isInitialized = true;

    print('[LongTermMemory] Inicializado');

    // Aplica limpeza de memórias expiradas
    await cleanExpired();
  }

  /// Fecha a memória de longo prazo
  Future<void> close() async {
    if (!_isInitialized) return;

    await _repository.close();
    _isInitialized = false;
  }

  /// Verifica se está inicializado
  void _ensureInitialized() {
    if (!_isInitialized) {
      throw StateError(
          'LongTermMemory não inicializado. Chame initialize() primeiro.');
    }
  }

  /// Salva uma memória
  Future<void> save(MemoryEntry entry) async {
    _ensureInitialized();

    // Calcula data de expiração se não definida
    if (entry.expiresAt == null) {
      final expiresAt = _expiration.calculateExpirationDate(entry);
      if (expiresAt != null) {
        final updated = entry.copyWith(expiresAt: expiresAt);
        await _repository.save(updated);
        return;
      }
    }

    await _repository.save(entry);
  }

  /// Salva múltiplas memórias
  Future<void> saveMany(List<MemoryEntry> entries) async {
    _ensureInitialized();

    final toSave = <MemoryEntry>[];

    for (final entry in entries) {
      if (entry.expiresAt == null) {
        final expiresAt = _expiration.calculateExpirationDate(entry);
        if (expiresAt != null) {
          toSave.add(entry.copyWith(expiresAt: expiresAt));
          continue;
        }
      }
      toSave.add(entry);
    }

    await _repository.saveMany(toSave);
  }

  /// Busca uma memória por ID
  Future<MemoryEntry?> find(String id) async {
    _ensureInitialized();
    return await _repository.findById(id);
  }

  /// Remove uma memória
  Future<bool> delete(String id) async {
    _ensureInitialized();
    return await _repository.delete(id);
  }

  /// Remove múltiplas memórias
  Future<int> deleteMany(List<String> ids) async {
    _ensureInitialized();
    return await _repository.deleteMany(ids);
  }

  /// Busca memórias por tag
  Future<List<MemoryEntry>> queryByTag(String tag, {int? limit}) async {
    _ensureInitialized();

    final filter = MemoryFilter.byTags([tag], limit: limit);
    final results = await _repository.find(filter);

    // Filtra expiradas
    return _expiration.filterExpired(results);
  }

  /// Busca memórias por múltiplas tags (AND)
  Future<List<MemoryEntry>> queryByAllTags(List<String> tags,
      {int? limit}) async {
    _ensureInitialized();

    final filter = MemoryFilter(
      requiredTags: tags,
      orderBy: 'timestamp',
      ascending: false,
      limit: limit,
    );

    final results = await _repository.find(filter);
    return _expiration.filterExpired(results);
  }

  /// Busca memórias por categoria
  Future<List<MemoryEntry>> queryByCategory(String category,
      {int? limit}) async {
    _ensureInitialized();

    final filter = MemoryFilter.byCategory(category, limit: limit);
    final results = await _repository.find(filter);

    return _expiration.filterExpired(results);
  }

  /// Busca memórias por emoção
  Future<List<MemoryEntry>> queryByEmotion({
    bool? positive,
    double? minWeight,
    double? maxWeight,
    int? limit,
  }) async {
    _ensureInitialized();

    final filter = MemoryFilter.byEmotion(
      onlyPositive: positive == true ? true : null,
      onlyNegative: positive == false ? true : null,
      minWeight: minWeight,
      maxWeight: maxWeight,
      limit: limit,
    );

    final results = await _repository.find(filter);
    return _expiration.filterExpired(results);
  }

  /// Busca memórias recentes
  Future<List<MemoryEntry>> queryRecent({int days = 7, int? limit}) async {
    _ensureInitialized();

    final filter = MemoryFilter.recent(days: days, limit: limit);
    final results = await _repository.find(filter);

    return _expiration.filterExpired(results);
  }

  /// Busca memórias usando filtro customizado
  Future<List<MemoryEntry>> query(MemoryFilter filter) async {
    _ensureInitialized();

    final results = await _repository.find(filter);
    return _expiration.filterExpired(results);
  }

  /// Busca memórias usando query builder
  Future<List<MemoryEntry>> queryBuilder(
      MemoryQuery Function(MemoryQuery) builder) async {
    final query = builder(MemoryQuery());
    return await this.query(query.build());
  }

  /// Obtém memórias mais acessadas
  Future<List<MemoryEntry>> getMostAccessed({int limit = 10}) async {
    _ensureInitialized();

    final filter = MemoryFilter.mostAccessed(limit: limit);
    final results = await _repository.find(filter);

    return _expiration.filterExpired(results);
  }

  /// Obtém todas as memórias
  Future<List<MemoryEntry>> getAll() async {
    _ensureInitialized();

    final results = await _repository.getAll();
    return _expiration.filterExpired(results);
  }

  /// Contagem de memórias (incluindo expiradas)
  Future<int> count() async {
    _ensureInitialized();
    return await _repository.count();
  }

  /// Contagem de memórias ativas (sem expiradas)
  Future<int> countActive() async {
    _ensureInitialized();

    final all = await _repository.getAll();
    final active = _expiration.filterExpired(all);
    return active.length;
  }

  /// Limpa todas as memórias
  Future<void> clear() async {
    _ensureInitialized();
    await _repository.clear();
  }

  /// Limpa memórias expiradas
  Future<int> cleanExpired() async {
    _ensureInitialized();

    final all = await _repository.getAll();
    final expired = _expiration.getExpired(all);

    if (expired.isEmpty) return 0;

    final ids = expired.map((e) => e.id).toList();
    final deleted = await _repository.deleteMany(ids);

    print('[LongTermMemory] Limpou $deleted memórias expiradas');

    return deleted;
  }

  /// Limpa memórias por categoria
  Future<int> clearByCategory(String category) async {
    _ensureInitialized();

    final entries = await queryByCategory(category);
    final ids = entries.map((e) => e.id).toList();

    return await _repository.deleteMany(ids);
  }

  /// Limpa memórias antigas (mais antigas que N dias)
  Future<int> clearOlderThan(int days) async {
    _ensureInitialized();

    final threshold = DateTime.now().subtract(Duration(days: days));
    final filter = MemoryFilter(toDate: threshold);

    final entries = await _repository.find(filter);
    final ids = entries.map((e) => e.id).toList();

    return await _repository.deleteMany(ids);
  }

  /// Exporta memórias para JSON
  Future<String> export() async {
    _ensureInitialized();
    return await _repository.export();
  }

  /// Importa memórias de JSON
  Future<int> import(String jsonString) async {
    _ensureInitialized();
    return await _repository.import(jsonString);
  }

  /// Valida integridade do armazenamento
  Future<Map<String, dynamic>> validateIntegrity() async {
    _ensureInitialized();
    return await _repository.validateIntegrity();
  }

  /// Repara o armazenamento
  Future<int> repair() async {
    _ensureInitialized();
    return await _repository.repair();
  }

  /// Estatísticas da memória de longo prazo
  Future<Map<String, dynamic>> getStatistics() async {
    _ensureInitialized();

    final repoStats = await _repository.getStatistics();
    final all = await _repository.getAll();
    final expirationStats = _expiration.getStatistics(all);

    return {
      ...repoStats,
      'expiration_stats': expirationStats,
    };
  }

  /// Obtém configuração de expiração
  MemoryExpiration get expirationManager => _expiration;

  /// Acesso direto ao repositório (para casos avançados)
  MemoryRepository get repository => _repository;

  @override
  String toString() {
    return 'LongTermMemory(initialized: $_isInitialized)';
  }
}
