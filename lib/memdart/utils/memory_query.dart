/// lib/memdart/utils/memory_query.dart
/// Utilidades para consultas e filtragem de memória.

class MemoryQuery {
  /// Filtra chaves por prefixo
  static List<String> filterByPrefix(List<String> keys, String prefix) {
    return keys.where((key) => key.startsWith(prefix)).toList();
  }

  /// Filtra chaves por sufixo
  static List<String> filterBySuffix(List<String> keys, String suffix) {
    return keys.where((key) => key.endsWith(suffix)).toList();
  }

  /// Filtra chaves que contêm um padrão
  static List<String> filterByPattern(List<String> keys, String pattern) {
    return keys.where((key) => key.contains(pattern)).toList();
  }

  /// Filtra chaves usando RegExp
  static List<String> filterByRegex(List<String> keys, String regexPattern) {
    final regex = RegExp(regexPattern);
    return keys.where((key) => regex.hasMatch(key)).toList();
  }

  /// Ordena chaves alfabeticamente
  static List<String> sortAlphabetically(List<String> keys, {bool descending = false}) {
    final sorted = List<String>.from(keys);
    sorted.sort();
    return descending ? sorted.reversed.toList() : sorted;
  }

  /// Limita o número de resultados
  static List<String> limit(List<String> keys, int maxResults) {
    return keys.take(maxResults).toList();
  }

  /// Paginação de resultados
  static List<String> paginate(List<String> keys, int page, int pageSize) {
    final start = page * pageSize;
    final end = start + pageSize;
    
    if (start >= keys.length) return [];
    if (end > keys.length) return keys.sublist(start);
    
    return keys.sublist(start, end);
  }
}
