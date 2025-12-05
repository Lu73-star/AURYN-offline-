/// lib/memdart/utils/memory_index.dart
/// Sistema de indexação para buscas rápidas em memória.

class MemoryIndex {
  /// Índice por prefixo
  final Map<String, List<String>> _prefixIndex = {};

  /// Índice por tags/categorias
  final Map<String, List<String>> _tagIndex = {};

  /// Índice temporal
  final Map<DateTime, List<String>> _timeIndex = {};

  /// Adiciona uma chave ao índice de prefixo
  void indexByPrefix(String key, String prefix) {
    _prefixIndex.putIfAbsent(prefix, () => []);
    if (!_prefixIndex[prefix]!.contains(key)) {
      _prefixIndex[prefix]!.add(key);
    }
  }

  /// Adiciona uma chave ao índice de tags
  void indexByTag(String key, String tag) {
    _tagIndex.putIfAbsent(tag, () => []);
    if (!_tagIndex[tag]!.contains(key)) {
      _tagIndex[tag]!.add(key);
    }
  }

  /// Adiciona uma chave ao índice temporal
  void indexByTime(String key, DateTime timestamp) {
    _timeIndex.putIfAbsent(timestamp, () => []);
    if (!_timeIndex[timestamp]!.contains(key)) {
      _timeIndex[timestamp]!.add(key);
    }
  }

  /// Busca por prefixo
  List<String> searchByPrefix(String prefix) {
    return _prefixIndex[prefix] ?? [];
  }

  /// Busca por tag
  List<String> searchByTag(String tag) {
    return _tagIndex[tag] ?? [];
  }

  /// Busca por intervalo de tempo
  List<String> searchByTimeRange(DateTime start, DateTime end) {
    final results = <String>[];
    for (final entry in _timeIndex.entries) {
      if (entry.key.isAfter(start) && entry.key.isBefore(end)) {
        results.addAll(entry.value);
      }
    }
    return results;
  }

  /// Remove uma chave de todos os índices
  void removeKey(String key) {
    _prefixIndex.forEach((prefix, keys) => keys.remove(key));
    _tagIndex.forEach((tag, keys) => keys.remove(key));
    _timeIndex.forEach((time, keys) => keys.remove(key));
  }

  /// Limpa todos os índices
  void clear() {
    _prefixIndex.clear();
    _tagIndex.clear();
    _timeIndex.clear();
  }

  /// Retorna estatísticas dos índices
  Map<String, dynamic> getStats() {
    return {
      'prefix_index_size': _prefixIndex.length,
      'tag_index_size': _tagIndex.length,
      'time_index_size': _timeIndex.length,
      'total_prefixes': _prefixIndex.keys.length,
      'total_tags': _tagIndex.keys.length,
      'total_timestamps': _timeIndex.keys.length,
    };
  }
}
