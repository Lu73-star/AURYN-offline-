/// lib/auryn_core/memory/memory_repository.dart
/// MemoryRepository - Camada de acesso a dados para memórias.
///
/// Responsável por todas as operações de CRUD e consulta
/// de memórias no armazenamento local usando Hive.

import 'package:hive/hive.dart';
import 'package:auryn_offline/auryn_core/memory/memory_entry.dart';
import 'package:auryn_offline/auryn_core/memory/memory_scope.dart';
import 'package:auryn_offline/auryn_core/memory/memory_serializer.dart';

/// {@template memory_repository}
/// Repositório de acesso a dados para memórias.
/// {@endtemplate}
class MemoryRepository {
  /// Box do Hive para armazenamento
  Box? _box;

  /// Box do Hive para índices
  Box? _indexBox;

  /// Índice de memórias
  final MemoryIndex _index = MemoryIndex();

  /// Indica se o repositório está inicializado
  bool _isInitialized = false;

  /// Verifica se está inicializado
  bool get isInitialized => _isInitialized;

  /// Inicializa o repositório
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _box = await Hive.openBox(MemorySerializer.boxName);
      _indexBox = await Hive.openBox(MemorySerializer.indexBoxName);

      // Reconstrói o índice
      await _rebuildIndex();

      _isInitialized = true;
      print('[MemoryRepository] Inicializado com ${_box!.length} memórias');
    } catch (e) {
      print('[MemoryRepository] Erro ao inicializar: $e');
      rethrow;
    }
  }

  /// Fecha o repositório
  Future<void> close() async {
    if (!_isInitialized) return;

    await _saveIndex();
    await _box?.close();
    await _indexBox?.close();

    _isInitialized = false;
  }

  /// Verifica se o repositório está inicializado, lançando erro se não
  void _ensureInitialized() {
    if (!_isInitialized) {
      throw StateError(
          'MemoryRepository não inicializado. Chame initialize() primeiro.');
    }
  }

  /// Salva uma memória
  Future<void> save(MemoryEntry entry) async {
    _ensureInitialized();

    await MemorySerializer.saveToBox(_box!, entry);
    _index.addEntry(entry);

    await _saveIndex();
  }

  /// Salva múltiplas memórias
  Future<void> saveMany(List<MemoryEntry> entries) async {
    _ensureInitialized();

    await MemorySerializer.saveManyToBox(_box!, entries);

    for (final entry in entries) {
      _index.addEntry(entry);
    }

    await _saveIndex();
  }

  /// Busca uma memória por ID
  Future<MemoryEntry?> findById(String id) async {
    _ensureInitialized();

    final entry = MemorySerializer.loadFromBox(_box!, id);

    // Incrementa contador de acesso se encontrado
    if (entry != null) {
      final updated = entry.incrementAccess();
      await save(updated);
      return updated;
    }

    return null;
  }

  /// Remove uma memória por ID
  Future<bool> delete(String id) async {
    _ensureInitialized();

    final entry = MemorySerializer.loadFromBox(_box!, id);
    if (entry == null) return false;

    await MemorySerializer.deleteFromBox(_box!, id);
    _index.removeEntry(entry);

    await _saveIndex();

    return true;
  }

  /// Remove múltiplas memórias por IDs
  Future<int> deleteMany(List<String> ids) async {
    _ensureInitialized();

    int deleted = 0;

    for (final id in ids) {
      final entry = MemorySerializer.loadFromBox(_box!, id);
      if (entry != null) {
        _index.removeEntry(entry);
        deleted++;
      }
    }

    await MemorySerializer.deleteManyFromBox(_box!, ids);
    await _saveIndex();

    return deleted;
  }

  /// Busca memórias por filtro
  Future<List<MemoryEntry>> find(MemoryFilter filter) async {
    _ensureInitialized();

    // Obtém candidatos usando índice
    Set<String>? candidateIds;

    // Filtra por categoria usando índice
    if (filter.categories != null && filter.categories!.isNotEmpty) {
      candidateIds = {};
      for (final category in filter.categories!) {
        candidateIds.addAll(_index.getByCategory(category));
      }
    }

    // Filtra por tags obrigatórias usando índice
    if (filter.requiredTags != null && filter.requiredTags!.isNotEmpty) {
      final tagIds = _index.getByAllTags(filter.requiredTags!);
      if (candidateIds == null) {
        candidateIds = tagIds;
      } else {
        candidateIds = candidateIds.intersection(tagIds);
      }
    }

    // Filtra por tags opcionais usando índice
    if (filter.optionalTags != null && filter.optionalTags!.isNotEmpty) {
      final tagIds = _index.getByAnyTag(filter.optionalTags!);
      if (candidateIds == null) {
        candidateIds = tagIds;
      } else {
        candidateIds = candidateIds.intersection(tagIds);
      }
    }

    // Se não há filtros de índice, carrega todas
    List<MemoryEntry> entries;
    if (candidateIds == null) {
      entries = MemorySerializer.loadAllFromBox(_box!);
    } else {
      entries = [];
      for (final id in candidateIds) {
        final entry = MemorySerializer.loadFromBox(_box!, id);
        if (entry != null) {
          entries.add(entry);
        }
      }
    }

    // Aplica filtros adicionais
    entries = _applyFilters(entries, filter);

    return entries;
  }

  /// Aplica filtros que não podem ser otimizados com índice
  List<MemoryEntry> _applyFilters(
      List<MemoryEntry> entries, MemoryFilter filter) {
    var filtered = entries;

    // Filtra expiradas
    if (!filter.includeExpired) {
      filtered = filtered.where((e) => !e.isExpired).toList();
    }

    // Filtra por peso emocional
    if (filter.minEmotionalWeight != null) {
      filtered = filtered
          .where((e) => e.emotionalWeight >= filter.minEmotionalWeight!)
          .toList();
    }

    if (filter.maxEmotionalWeight != null) {
      filtered = filtered
          .where((e) => e.emotionalWeight <= filter.maxEmotionalWeight!)
          .toList();
    }

    // Filtra por tipo emocional
    if (filter.onlyPositive == true) {
      filtered = filtered.where((e) => e.isPositive).toList();
    }

    if (filter.onlyNegative == true) {
      filtered = filtered.where((e) => e.isNegative).toList();
    }

    if (filter.onlyNeutral == true) {
      filtered = filtered.where((e) => e.isNeutral).toList();
    }

    // Filtra por data
    if (filter.fromDate != null) {
      filtered = filtered
          .where((e) => e.timestamp.isAfter(filter.fromDate!) ||
              e.timestamp.isAtSameMomentAs(filter.fromDate!))
          .toList();
    }

    if (filter.toDate != null) {
      filtered = filtered
          .where((e) => e.timestamp.isBefore(filter.toDate!) ||
              e.timestamp.isAtSameMomentAs(filter.toDate!))
          .toList();
    }

    // Ordena
    if (filter.orderBy != null) {
      filtered = _sortEntries(filtered, filter.orderBy!, filter.ascending);
    }

    // Limita resultados
    if (filter.limit != null && filter.limit! > 0) {
      filtered = filtered.take(filter.limit!).toList();
    }

    return filtered;
  }

  /// Ordena entradas
  List<MemoryEntry> _sortEntries(
      List<MemoryEntry> entries, String field, bool ascending) {
    final sorted = List<MemoryEntry>.from(entries);

    sorted.sort((a, b) {
      int comparison = 0;

      switch (field) {
        case 'timestamp':
          comparison = a.timestamp.compareTo(b.timestamp);
          break;
        case 'emotional_weight':
          comparison = a.emotionalWeight.compareTo(b.emotionalWeight);
          break;
        case 'access_count':
          comparison = a.accessCount.compareTo(b.accessCount);
          break;
        default:
          comparison = 0;
      }

      return ascending ? comparison : -comparison;
    });

    return sorted;
  }

  /// Obtém todas as memórias
  Future<List<MemoryEntry>> getAll() async {
    _ensureInitialized();
    return MemorySerializer.loadAllFromBox(_box!);
  }

  /// Obtém contagem total de memórias
  Future<int> count() async {
    _ensureInitialized();
    return _box!.length;
  }

  /// Limpa todas as memórias
  Future<void> clear() async {
    _ensureInitialized();

    await MemorySerializer.clearBox(_box!);
    _index.clear();
    await _saveIndex();
  }

  /// Reconstrói o índice a partir das memórias existentes
  Future<void> _rebuildIndex() async {
    _index.clear();

    // Tenta carregar índice salvo
    final savedIndex = _indexBox?.get('index');
    if (savedIndex != null) {
      try {
        final indexData = Map<String, dynamic>.from(savedIndex as Map);
        final loadedIndex = MemoryIndex.fromMap(indexData);

        // Verifica se o índice está consistente
        final indexStats = loadedIndex.getStatistics();
        final totalEntries = _box!.length;

        if (indexStats['total_indexed_entries'] == totalEntries) {
          // Índice está consistente, usa ele
          _index.buildFrom(MemorySerializer.loadAllFromBox(_box!));
          print('[MemoryRepository] Índice carregado do cache');
          return;
        }
      } catch (e) {
        print('[MemoryRepository] Erro ao carregar índice salvo: $e');
      }
    }

    // Reconstrói índice do zero
    final entries = MemorySerializer.loadAllFromBox(_box!);
    _index.buildFrom(entries);

    print('[MemoryRepository] Índice reconstruído (${entries.length} entradas)');
  }

  /// Salva o índice
  Future<void> _saveIndex() async {
    try {
      await _indexBox?.put('index', _index.toMap());
    } catch (e) {
      print('[MemoryRepository] Erro ao salvar índice: $e');
    }
  }

  /// Valida a integridade do armazenamento
  Future<Map<String, dynamic>> validateIntegrity() async {
    _ensureInitialized();

    final validation = await MemorySerializer.validateBox(_box!);
    final indexStats = _index.getStatistics();

    return {
      ...validation,
      'index_stats': indexStats,
    };
  }

  /// Repara o armazenamento removendo entradas corrompidas
  Future<int> repair() async {
    _ensureInitialized();

    final repaired = await MemorySerializer.repairBox(_box!);

    // Reconstrói índice após reparar
    await _rebuildIndex();

    return repaired;
  }

  /// Exporta todas as memórias para JSON
  Future<String> export() async {
    _ensureInitialized();

    final entries = await getAll();
    return MemorySerializer.exportToJson(entries);
  }

  /// Importa memórias de JSON
  Future<int> import(String jsonString) async {
    _ensureInitialized();

    final entries = MemorySerializer.importFromJson(jsonString);
    await saveMany(entries);

    return entries.length;
  }

  /// Estatísticas do repositório
  Future<Map<String, dynamic>> getStatistics() async {
    _ensureInitialized();

    final entries = await getAll();

    final byCategory = <String, int>{};
    int positiveCount = 0;
    int negativeCount = 0;
    int neutralCount = 0;
    double totalEmotionalWeight = 0.0;

    for (final entry in entries) {
      byCategory[entry.category] = (byCategory[entry.category] ?? 0) + 1;

      if (entry.isPositive) positiveCount++;
      if (entry.isNegative) negativeCount++;
      if (entry.isNeutral) neutralCount++;

      totalEmotionalWeight += entry.emotionalWeight;
    }

    return {
      'total_entries': entries.length,
      'by_category': byCategory,
      'positive_count': positiveCount,
      'negative_count': negativeCount,
      'neutral_count': neutralCount,
      'average_emotional_weight':
          entries.isEmpty ? 0.0 : totalEmotionalWeight / entries.length,
      'index_stats': _index.getStatistics(),
    };
  }
}
