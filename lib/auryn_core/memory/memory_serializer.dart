/// lib/auryn_core/memory/memory_serializer.dart
/// MemorySerializer - Serialização de memórias para Hive.
///
/// Responsável por serializar e deserializar entradas de memória
/// para armazenamento local usando Hive como backend.

import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:auryn_offline/auryn_core/memory/memory_entry.dart';

/// {@template memory_serializer}
/// Serializa e deserializa memórias para persistência com Hive.
/// {@endtemplate}
class MemorySerializer {
  /// Nome da box do Hive para memórias
  static const String boxName = 'auryn_memories';

  /// Nome da box do Hive para índices
  static const String indexBoxName = 'auryn_memory_indices';

  /// Serializa uma MemoryEntry para formato compatível com Hive
  static Map<String, dynamic> serialize(MemoryEntry entry) {
    final map = entry.toMap();

    // Garante que todos os valores são serializáveis pelo Hive
    return {
      'id': map['id'],
      'timestamp': map['timestamp'],
      'category': map['category'],
      'emotional_weight': map['emotional_weight'],
      'content': jsonEncode(map['content']), // Serializa content como JSON string
      'tags': map['tags'],
      'last_updated': map['last_updated'],
      'access_count': map['access_count'],
      'expires_at': map['expires_at'],
      'version': 1, // Versão do formato de serialização
    };
  }

  /// Deserializa do formato Hive para MemoryEntry
  static MemoryEntry deserialize(Map<String, dynamic> data) {
    // Converte content de volta de JSON string
    final contentJson = data['content'] as String;
    final content = jsonDecode(contentJson) as Map<String, dynamic>;

    return MemoryEntry.fromMap({
      'id': data['id'],
      'timestamp': data['timestamp'],
      'category': data['category'],
      'emotional_weight': data['emotional_weight'],
      'content': content,
      'tags': data['tags'],
      'last_updated': data['last_updated'],
      'access_count': data['access_count'] ?? 0,
      'expires_at': data['expires_at'],
    });
  }

  /// Serializa uma lista de entradas
  static List<Map<String, dynamic>> serializeList(List<MemoryEntry> entries) {
    return entries.map((entry) => serialize(entry)).toList();
  }

  /// Deserializa uma lista de entradas
  static List<MemoryEntry> deserializeList(List<dynamic> data) {
    return data
        .map((item) => deserialize(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  /// Salva uma entrada em uma box do Hive
  static Future<void> saveToBox(Box box, MemoryEntry entry) async {
    final serialized = serialize(entry);
    await box.put(entry.id, serialized);
  }

  /// Salva múltiplas entradas em uma box do Hive
  static Future<void> saveManyToBox(Box box, List<MemoryEntry> entries) async {
    final map = <String, Map<String, dynamic>>{};
    for (final entry in entries) {
      map[entry.id] = serialize(entry);
    }
    await box.putAll(map);
  }

  /// Carrega uma entrada de uma box do Hive
  static MemoryEntry? loadFromBox(Box box, String id) {
    final data = box.get(id);
    if (data == null) return null;
    return deserialize(Map<String, dynamic>.from(data as Map));
  }

  /// Carrega todas as entradas de uma box do Hive
  static List<MemoryEntry> loadAllFromBox(Box box) {
    final entries = <MemoryEntry>[];

    for (final key in box.keys) {
      final data = box.get(key);
      if (data != null) {
        try {
          final entry = deserialize(Map<String, dynamic>.from(data as Map));
          entries.add(entry);
        } catch (e) {
          print('[MemorySerializer] Erro ao deserializar entrada $key: $e');
        }
      }
    }

    return entries;
  }

  /// Remove uma entrada de uma box do Hive
  static Future<void> deleteFromBox(Box box, String id) async {
    await box.delete(id);
  }

  /// Remove múltiplas entradas de uma box do Hive
  static Future<void> deleteManyFromBox(Box box, List<String> ids) async {
    await box.deleteAll(ids);
  }

  /// Limpa todas as entradas de uma box do Hive
  static Future<void> clearBox(Box box) async {
    await box.clear();
  }

  /// Exporta todas as memórias para um formato portável (JSON)
  static String exportToJson(List<MemoryEntry> entries) {
    final serialized = entries.map((e) => e.toMap()).toList();
    return jsonEncode({
      'version': 1,
      'exported_at': DateTime.now().toIso8601String(),
      'entries': serialized,
    });
  }

  /// Importa memórias de um formato portável (JSON)
  static List<MemoryEntry> importFromJson(String jsonString) {
    final data = jsonDecode(jsonString) as Map<String, dynamic>;
    final entries = data['entries'] as List;

    return entries
        .map((e) => MemoryEntry.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  /// Valida a integridade de uma box
  static Future<Map<String, dynamic>> validateBox(Box box) async {
    int totalEntries = 0;
    int validEntries = 0;
    int corruptedEntries = 0;
    final corruptedKeys = <String>[];

    for (final key in box.keys) {
      totalEntries++;
      final data = box.get(key);

      if (data == null) {
        corruptedEntries++;
        corruptedKeys.add(key.toString());
        continue;
      }

      try {
        deserialize(Map<String, dynamic>.from(data as Map));
        validEntries++;
      } catch (e) {
        corruptedEntries++;
        corruptedKeys.add(key.toString());
      }
    }

    return {
      'total_entries': totalEntries,
      'valid_entries': validEntries,
      'corrupted_entries': corruptedEntries,
      'corrupted_keys': corruptedKeys,
      'integrity_score':
          totalEntries > 0 ? validEntries / totalEntries : 1.0,
    };
  }

  /// Repara uma box removendo entradas corrompidas
  static Future<int> repairBox(Box box) async {
    final validation = await validateBox(box);
    final corruptedKeys = validation['corrupted_keys'] as List<String>;

    for (final key in corruptedKeys) {
      await box.delete(key);
    }

    return corruptedKeys.length;
  }
}

/// {@template memory_index}
/// Índice para busca rápida de memórias por categoria e tags.
/// {@endtemplate}
class MemoryIndex {
  /// Índice de IDs por categoria
  final Map<String, Set<String>> _categoryIndex = {};

  /// Índice de IDs por tag
  final Map<String, Set<String>> _tagIndex = {};

  /// Constrói o índice a partir de uma lista de memórias
  void buildFrom(List<MemoryEntry> entries) {
    clear();

    for (final entry in entries) {
      addEntry(entry);
    }
  }

  /// Adiciona uma entrada ao índice
  void addEntry(MemoryEntry entry) {
    // Índice por categoria
    _categoryIndex.putIfAbsent(entry.category, () => {}).add(entry.id);

    // Índice por tags
    for (final tag in entry.tags) {
      _tagIndex.putIfAbsent(tag, () => {}).add(entry.id);
    }
  }

  /// Remove uma entrada do índice
  void removeEntry(MemoryEntry entry) {
    // Remove do índice de categoria
    _categoryIndex[entry.category]?.remove(entry.id);

    // Remove do índice de tags
    for (final tag in entry.tags) {
      _tagIndex[tag]?.remove(entry.id);
    }
  }

  /// Obtém IDs por categoria
  Set<String> getByCategory(String category) {
    return _categoryIndex[category] ?? {};
  }

  /// Obtém IDs por tag
  Set<String> getByTag(String tag) {
    return _tagIndex[tag] ?? {};
  }

  /// Obtém IDs que têm todas as tags especificadas
  Set<String> getByAllTags(List<String> tags) {
    if (tags.isEmpty) return {};

    Set<String>? result;
    for (final tag in tags) {
      final ids = getByTag(tag);
      if (result == null) {
        result = Set.from(ids);
      } else {
        result = result.intersection(ids);
      }
    }

    return result ?? {};
  }

  /// Obtém IDs que têm pelo menos uma das tags especificadas
  Set<String> getByAnyTag(List<String> tags) {
    final result = <String>{};

    for (final tag in tags) {
      result.addAll(getByTag(tag));
    }

    return result;
  }

  /// Limpa o índice
  void clear() {
    _categoryIndex.clear();
    _tagIndex.clear();
  }

  /// Serializa o índice para persistência
  Map<String, dynamic> toMap() {
    return {
      'category_index': _categoryIndex
          .map((key, value) => MapEntry(key, value.toList())),
      'tag_index': _tagIndex.map((key, value) => MapEntry(key, value.toList())),
    };
  }

  /// Deserializa o índice
  factory MemoryIndex.fromMap(Map<String, dynamic> map) {
    final index = MemoryIndex();

    final categoryIndex =
        map['category_index'] as Map<String, dynamic>? ?? {};
    for (final entry in categoryIndex.entries) {
      index._categoryIndex[entry.key] =
          Set<String>.from(entry.value as List);
    }

    final tagIndex = map['tag_index'] as Map<String, dynamic>? ?? {};
    for (final entry in tagIndex.entries) {
      index._tagIndex[entry.key] = Set<String>.from(entry.value as List);
    }

    return index;
  }

  /// Estatísticas do índice
  Map<String, dynamic> getStatistics() {
    return {
      'categories_count': _categoryIndex.length,
      'tags_count': _tagIndex.length,
      'total_indexed_entries': _categoryIndex.values
          .fold<Set<String>>({}, (set, ids) => set..addAll(ids))
          .length,
    };
  }
}
