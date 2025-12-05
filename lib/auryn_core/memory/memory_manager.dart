/// lib/auryn_core/memory/memory_manager.dart
/// MemoryManager - Facade principal do sistema de memória da AURYN.
///
/// Integra todos os componentes do sistema de memória:
/// - LongTermMemory: Armazenamento persistente
/// - EpisodicMemory: Memória de curto prazo (últimas N interações)
/// - MemoryTraits: Adaptação de personalidade baseada em memória
/// - MemoryExpiration: Gerenciamento de expiração
///
/// Esta é a interface principal que outros módulos devem usar.

import 'package:hive_flutter/hive_flutter.dart';
import 'package:auryn_offline/auryn_core/memory/memory_entry.dart';
import 'package:auryn_offline/auryn_core/memory/memory_scope.dart';
import 'package:auryn_offline/auryn_core/memory/long_term_memory.dart';
import 'package:auryn_offline/auryn_core/memory/episodic_memory.dart';
import 'package:auryn_offline/auryn_core/memory/memory_traits.dart';
import 'package:auryn_offline/auryn_core/memory/memory_expiration.dart';

/// {@template memory_manager}
/// Gerenciador principal do sistema de memória da AURYN.
///
/// Fornece interface unificada para:
/// - Armazenar e recuperar memórias
/// - Gerenciar memória episódica e de longo prazo
/// - Adaptar traços de personalidade
/// - Limpar memórias expiradas
/// {@endtemplate}
class MemoryManager {
  /// Singleton instance
  static final MemoryManager _instance = MemoryManager._internal();
  factory MemoryManager() => _instance;
  MemoryManager._internal();

  /// Memória de longo prazo
  late LongTermMemory _longTerm;

  /// Memória episódica
  late EpisodicMemory _episodic;

  /// Traços de personalidade
  late MemoryTraits _traits;

  /// Indica se está inicializado
  bool _isInitialized = false;

  /// Verifica se está inicializado
  bool get isInitialized => _isInitialized;

  /// Inicializa o sistema de memória
  ///
  /// [episodicSize] - Tamanho da memória episódica (padrão: 50)
  /// [expirationPolicies] - Políticas de expiração (padrão: balanced)
  /// [traitLearningRate] - Taxa de aprendizado de traços (padrão: 0.1)
  /// [hivePath] - Caminho customizado para Hive (opcional)
  Future<void> initialize({
    int episodicSize = 50,
    List<ExpirationConfig>? expirationPolicies,
    double traitLearningRate = 0.1,
    String? hivePath,
  }) async {
    if (_isInitialized) {
      print('[MemoryManager] Já inicializado');
      return;
    }

    try {
      // Inicializa Hive
      if (hivePath != null) {
        await Hive.initFlutter(hivePath);
      } else {
        await Hive.initFlutter();
      }

      // Inicializa componentes
      final expiration = MemoryExpiration(
        configs: expirationPolicies ?? ExpirationPolicies.balanced(),
      );

      _longTerm = LongTermMemory(expiration: expiration);
      await _longTerm.initialize();

      _episodic = EpisodicMemory(maxSize: episodicSize);

      _traits = MemoryTraits.withDefaults(learningRate: traitLearningRate);

      _isInitialized = true;

      print('[MemoryManager] Sistema de memória inicializado');
      print('  - Memória episódica: $episodicSize entradas');
      print('  - Memória longo prazo: ${await _longTerm.countActive()} entradas ativas');
      print('  - Traços: ${_traits.getAllTraits().length} traços');
    } catch (e) {
      print('[MemoryManager] Erro ao inicializar: $e');
      rethrow;
    }
  }

  /// Fecha o sistema de memória
  Future<void> close() async {
    if (!_isInitialized) return;

    await _longTerm.close();
    _isInitialized = false;

    print('[MemoryManager] Sistema de memória fechado');
  }

  /// Verifica se está inicializado
  void _ensureInitialized() {
    if (!_isInitialized) {
      throw StateError(
          'MemoryManager não inicializado. Chame initialize() primeiro.');
    }
  }

  // ========== Operações de Memória ==========

  /// Armazena uma interação (salva em ambas memória episódica e longo prazo)
  Future<void> storeInteraction({
    required String userInput,
    required String aurynResponse,
    double emotionalWeight = 0.0,
    List<String>? tags,
    bool persistToLongTerm = true,
  }) async {
    _ensureInitialized();

    final entry = MemoryEntry.interaction(
      userInput: userInput,
      aurynResponse: aurynResponse,
      emotionalWeight: emotionalWeight,
      tags: tags ?? ['interaction'],
    );

    // Adiciona à memória episódica
    _episodic.add(entry);

    // Persiste em longo prazo se solicitado
    if (persistToLongTerm) {
      await _longTerm.save(entry);
    }

    // Aprende com a memória
    _traits.learnFromMemory(entry);

    print('[MemoryManager] Interação armazenada: $userInput');
  }

  /// Armazena uma memória genérica
  Future<void> store(MemoryEntry entry, {bool addToEpisodic = false}) async {
    _ensureInitialized();

    await _longTerm.save(entry);

    if (addToEpisodic) {
      _episodic.add(entry);
    }

    _traits.learnFromMemory(entry);
  }

  /// Armazena múltiplas memórias
  Future<void> storeMany(List<MemoryEntry> entries) async {
    _ensureInitialized();

    await _longTerm.saveMany(entries);
    _traits.learnFromMemories(entries);
  }

  /// Busca uma memória por ID
  Future<MemoryEntry?> find(String id) async {
    _ensureInitialized();
    return await _longTerm.find(id);
  }

  /// Remove uma memória
  Future<bool> delete(String id) async {
    _ensureInitialized();
    return await _longTerm.delete(id);
  }

  // ========== Consultas ==========

  /// Busca memórias por tag
  Future<List<MemoryEntry>> queryByTag(String tag, {int? limit}) async {
    _ensureInitialized();
    return await _longTerm.queryByTag(tag, limit: limit);
  }

  /// Busca memórias por categoria
  Future<List<MemoryEntry>> queryByCategory(String category,
      {int? limit}) async {
    _ensureInitialized();
    return await _longTerm.queryByCategory(category, limit: limit);
  }

  /// Busca memórias por emoção
  Future<List<MemoryEntry>> queryByEmotion({
    bool? positive,
    double? minWeight,
    double? maxWeight,
    int? limit,
  }) async {
    _ensureInitialized();

    return await _longTerm.queryByEmotion(
      positive: positive,
      minWeight: minWeight,
      maxWeight: maxWeight,
      limit: limit,
    );
  }

  /// Busca memórias recentes
  Future<List<MemoryEntry>> queryRecent({int days = 7, int? limit}) async {
    _ensureInitialized();
    return await _longTerm.queryRecent(days: days, limit: limit);
  }

  /// Busca usando filtro customizado
  Future<List<MemoryEntry>> query(MemoryFilter filter) async {
    _ensureInitialized();
    return await _longTerm.query(filter);
  }

  /// Busca usando query builder
  Future<List<MemoryEntry>> queryBuilder(
      MemoryQuery Function(MemoryQuery) builder) async {
    _ensureInitialized();
    return await _longTerm.queryBuilder(builder);
  }

  // ========== Memória Episódica ==========

  /// Obtém memória episódica completa
  List<MemoryEntry> getEpisodicMemory() {
    _ensureInitialized();
    return _episodic.getAll();
  }

  /// Obtém últimas N entradas episódicas
  List<MemoryEntry> getRecentEpisodes({int count = 10}) {
    _ensureInitialized();
    return _episodic.getRecent(count: count);
  }

  /// Obtém resumo de sentimento das memórias episódicas
  Map<String, dynamic> getEpisodicSentiment({int lastN = 10}) {
    _ensureInitialized();
    return _episodic.getSentimentSummary(lastN: lastN);
  }

  /// Obtém padrões de interação da memória episódica
  Map<String, dynamic> getInteractionPatterns() {
    _ensureInitialized();
    return _episodic.getInteractionPatterns();
  }

  /// Limpa memória episódica
  void clearEpisodicMemory() {
    _ensureInitialized();
    _episodic.clear();
  }

  // ========== Traços de Personalidade ==========

  /// Obtém um traço de personalidade
  PersonalityTrait? getTrait(String name) {
    _ensureInitialized();
    return _traits.getTrait(name);
  }

  /// Obtém score de um traço
  double getTraitScore(String name) {
    _ensureInitialized();
    return _traits.getScore(name);
  }

  /// Obtém todos os traços
  Map<String, PersonalityTrait> getAllTraits() {
    _ensureInitialized();
    return _traits.getAllTraits();
  }

  /// Obtém traços dominantes
  Map<String, PersonalityTrait> getDominantTraits() {
    _ensureInitialized();
    return _traits.getDominantTraits();
  }

  /// Obtém descrição da personalidade
  String getPersonalityDescription() {
    _ensureInitialized();
    return _traits.getPersonalityDescription();
  }

  /// Re-aprende traços de todas as memórias
  Future<void> retrainTraits() async {
    _ensureInitialized();

    _traits.reset();
    final memories = await _longTerm.getAll();
    _traits.learnFromMemories(memories);

    print('[MemoryManager] Traços re-treinados com ${memories.length} memórias');
  }

  // ========== Manutenção ==========

  /// Limpa memórias expiradas
  Future<int> cleanExpired() async {
    _ensureInitialized();
    return await _longTerm.cleanExpired();
  }

  /// Limpa memórias antigas
  Future<int> clearOlderThan(int days) async {
    _ensureInitialized();
    return await _longTerm.clearOlderThan(days);
  }

  /// Limpa todas as memórias
  Future<void> clearAll() async {
    _ensureInitialized();

    await _longTerm.clear();
    _episodic.clear();
    _traits.reset();

    print('[MemoryManager] Todas as memórias limpas');
  }

  /// Valida integridade do armazenamento
  Future<Map<String, dynamic>> validateIntegrity() async {
    _ensureInitialized();
    return await _longTerm.validateIntegrity();
  }

  /// Repara armazenamento
  Future<int> repair() async {
    _ensureInitialized();
    return await _longTerm.repair();
  }

  // ========== Exportação/Importação ==========

  /// Exporta todas as memórias para JSON
  Future<String> export() async {
    _ensureInitialized();
    return await _longTerm.export();
  }

  /// Importa memórias de JSON
  Future<int> import(String jsonString, {bool retrainTraits = true}) async {
    _ensureInitialized();

    final count = await _longTerm.import(jsonString);

    if (retrainTraits) {
      await this.retrainTraits();
    }

    return count;
  }

  // ========== Estatísticas ==========

  /// Obtém estatísticas completas do sistema de memória
  Future<Map<String, dynamic>> getStatistics() async {
    _ensureInitialized();

    final longTermStats = await _longTerm.getStatistics();
    final episodicStats = _episodic.getStatistics();
    final traitStats = _traits.getStatistics();

    return {
      'long_term': longTermStats,
      'episodic': episodicStats,
      'traits': traitStats,
      'total_active_memories': await _longTerm.countActive(),
      'total_memories': await _longTerm.count(),
    };
  }

  /// Obtém resumo do sistema
  Future<String> getSummary() async {
    _ensureInitialized();

    final stats = await getStatistics();
    final longTerm = stats['long_term'] as Map<String, dynamic>;
    final episodic = stats['episodic'] as Map<String, dynamic>;
    final personality = getPersonalityDescription();

    return '''
Sistema de Memória AURYN
========================
Memórias Ativas: ${stats['total_active_memories']}
Memórias Totais: ${stats['total_memories']}

Memória Episódica: ${episodic['total_episodes']}/${episodic['max_size']}
Preenchimento: ${(episodic['fill_percentage'] * 100).toStringAsFixed(1)}%

Personalidade: $personality

Categorias (Longo Prazo):
${_formatCategories(longTerm['by_category'] as Map)}
''';
  }

  String _formatCategories(Map categories) {
    final buffer = StringBuffer();
    categories.forEach((key, value) {
      buffer.writeln('  - $key: $value');
    });
    return buffer.toString();
  }

  // ========== Acesso Direto aos Componentes ==========

  /// Acesso direto à memória de longo prazo (para casos avançados)
  LongTermMemory get longTermMemory {
    _ensureInitialized();
    return _longTerm;
  }

  /// Acesso direto à memória episódica (para casos avançados)
  EpisodicMemory get episodicMemory {
    _ensureInitialized();
    return _episodic;
  }

  /// Acesso direto aos traços (para casos avançados)
  MemoryTraits get memoryTraits {
    _ensureInitialized();
    return _traits;
  }

  @override
  String toString() {
    return 'MemoryManager(initialized: $_isInitialized)';
  }
}
