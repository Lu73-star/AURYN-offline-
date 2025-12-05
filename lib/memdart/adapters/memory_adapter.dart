/// lib/memdart/adapters/memory_adapter.dart
/// Adaptador base para diferentes estratégias de armazenamento de memória.

abstract class MemoryAdapter {
  /// Nome do adaptador
  String get adapterName;

  /// Inicializa o adaptador
  Future<void> init();

  /// Salva um valor
  Future<void> save(String key, dynamic value);

  /// Lê um valor
  Future<dynamic> read(String key);

  /// Remove um valor
  Future<void> delete(String key);

  /// Verifica se uma chave existe
  Future<bool> exists(String key);

  /// Lista todas as chaves
  Future<List<String>> listKeys();

  /// Limpa todos os dados
  Future<void> clear();

  /// Fecha o adaptador e libera recursos
  Future<void> close();
}
