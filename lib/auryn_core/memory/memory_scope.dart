/// lib/auryn_core/memory/memory_scope.dart
/// MemoryScope - Sistema de categorização e escopo de memórias.
///
/// Define os escopos e categorias disponíveis para organização de memórias,
/// permitindo busca e filtragem eficientes.

/// {@template memory_scope}
/// Define o escopo temporal de uma memória.
/// {@endtemplate}
enum MemoryScope {
  /// Memória de curto prazo (última sessão/interação)
  shortTerm,

  /// Memória de médio prazo (últimos dias/semanas)
  mediumTerm,

  /// Memória de longo prazo (permanente ou de longo período)
  longTerm,

  /// Memória episódica (sequências de eventos)
  episodic,
}

/// {@template memory_category}
/// Categorias predefinidas de memória.
/// {@endtemplate}
class MemoryCategory {
  /// Categoria de interação com o usuário
  static const String interaction = 'interaction';

  /// Categoria de estado emocional
  static const String emotion = 'emotion';

  /// Categoria de aprendizado/insights
  static const String learning = 'learning';

  /// Categoria de personalidade/preferências
  static const String personality = 'personality';

  /// Categoria de contexto/ambiente
  static const String context = 'context';

  /// Categoria de eventos/episódios
  static const String event = 'event';

  /// Categoria de configuração/sistema
  static const String system = 'system';

  /// Lista de todas as categorias disponíveis
  static const List<String> all = [
    interaction,
    emotion,
    learning,
    personality,
    context,
    event,
    system,
  ];

  /// Verifica se uma categoria é válida
  static bool isValid(String category) {
    return all.contains(category);
  }
}

/// {@template memory_filter}
/// Filtro para busca de memórias.
/// {@endtemplate}
class MemoryFilter {
  /// Categorias a buscar (null = todas)
  final List<String>? categories;

  /// Tags que devem estar presentes (AND)
  final List<String>? requiredTags;

  /// Tags das quais pelo menos uma deve estar presente (OR)
  final List<String>? optionalTags;

  /// Filtro de peso emocional mínimo
  final double? minEmotionalWeight;

  /// Filtro de peso emocional máximo
  final double? maxEmotionalWeight;

  /// Filtrar apenas positivas
  final bool? onlyPositive;

  /// Filtrar apenas negativas
  final bool? onlyNegative;

  /// Filtrar apenas neutras
  final bool? onlyNeutral;

  /// Data mínima (from)
  final DateTime? fromDate;

  /// Data máxima (to)
  final DateTime? toDate;

  /// Limite de resultados
  final int? limit;

  /// Ordenação ('timestamp', 'emotional_weight', 'access_count')
  final String? orderBy;

  /// Direção da ordenação (true = ascendente, false = descendente)
  final bool ascending;

  /// Incluir memórias expiradas
  final bool includeExpired;

  const MemoryFilter({
    this.categories,
    this.requiredTags,
    this.optionalTags,
    this.minEmotionalWeight,
    this.maxEmotionalWeight,
    this.onlyPositive,
    this.onlyNegative,
    this.onlyNeutral,
    this.fromDate,
    this.toDate,
    this.limit,
    this.orderBy,
    this.ascending = false,
    this.includeExpired = false,
  });

  /// Filtro vazio (retorna todas as memórias)
  factory MemoryFilter.all() => const MemoryFilter();

  /// Filtro para memórias recentes
  factory MemoryFilter.recent({int days = 7, int? limit}) {
    return MemoryFilter(
      fromDate: DateTime.now().subtract(Duration(days: days)),
      orderBy: 'timestamp',
      ascending: false,
      limit: limit,
    );
  }

  /// Filtro para memórias por categoria
  factory MemoryFilter.byCategory(String category, {int? limit}) {
    return MemoryFilter(
      categories: [category],
      orderBy: 'timestamp',
      ascending: false,
      limit: limit,
    );
  }

  /// Filtro para memórias por tags
  factory MemoryFilter.byTags(List<String> tags, {int? limit}) {
    return MemoryFilter(
      requiredTags: tags,
      orderBy: 'timestamp',
      ascending: false,
      limit: limit,
    );
  }

  /// Filtro para memórias emocionais
  factory MemoryFilter.byEmotion({
    bool? onlyPositive,
    bool? onlyNegative,
    double? minWeight,
    double? maxWeight,
    int? limit,
  }) {
    return MemoryFilter(
      categories: [MemoryCategory.emotion],
      onlyPositive: onlyPositive,
      onlyNegative: onlyNegative,
      minEmotionalWeight: minWeight,
      maxEmotionalWeight: maxWeight,
      orderBy: 'emotional_weight',
      ascending: false,
      limit: limit,
    );
  }

  /// Filtro para memórias mais acessadas
  factory MemoryFilter.mostAccessed({int? limit}) {
    return MemoryFilter(
      orderBy: 'access_count',
      ascending: false,
      limit: limit ?? 10,
    );
  }

  @override
  String toString() {
    return 'MemoryFilter(categories: $categories, '
        'requiredTags: $requiredTags, limit: $limit)';
  }
}

/// {@template memory_query}
/// Query builder para busca de memórias.
/// {@endtemplate}
class MemoryQuery {
  MemoryFilter _filter = const MemoryFilter();

  /// Define as categorias a buscar
  MemoryQuery withCategories(List<String> categories) {
    _filter = MemoryFilter(
      categories: categories,
      requiredTags: _filter.requiredTags,
      optionalTags: _filter.optionalTags,
      minEmotionalWeight: _filter.minEmotionalWeight,
      maxEmotionalWeight: _filter.maxEmotionalWeight,
      onlyPositive: _filter.onlyPositive,
      onlyNegative: _filter.onlyNegative,
      onlyNeutral: _filter.onlyNeutral,
      fromDate: _filter.fromDate,
      toDate: _filter.toDate,
      limit: _filter.limit,
      orderBy: _filter.orderBy,
      ascending: _filter.ascending,
      includeExpired: _filter.includeExpired,
    );
    return this;
  }

  /// Define tags obrigatórias
  MemoryQuery withTags(List<String> tags) {
    _filter = MemoryFilter(
      categories: _filter.categories,
      requiredTags: tags,
      optionalTags: _filter.optionalTags,
      minEmotionalWeight: _filter.minEmotionalWeight,
      maxEmotionalWeight: _filter.maxEmotionalWeight,
      onlyPositive: _filter.onlyPositive,
      onlyNegative: _filter.onlyNegative,
      onlyNeutral: _filter.onlyNeutral,
      fromDate: _filter.fromDate,
      toDate: _filter.toDate,
      limit: _filter.limit,
      orderBy: _filter.orderBy,
      ascending: _filter.ascending,
      includeExpired: _filter.includeExpired,
    );
    return this;
  }

  /// Define filtro de peso emocional
  MemoryQuery withEmotionalWeight({double? min, double? max}) {
    _filter = MemoryFilter(
      categories: _filter.categories,
      requiredTags: _filter.requiredTags,
      optionalTags: _filter.optionalTags,
      minEmotionalWeight: min,
      maxEmotionalWeight: max,
      onlyPositive: _filter.onlyPositive,
      onlyNegative: _filter.onlyNegative,
      onlyNeutral: _filter.onlyNeutral,
      fromDate: _filter.fromDate,
      toDate: _filter.toDate,
      limit: _filter.limit,
      orderBy: _filter.orderBy,
      ascending: _filter.ascending,
      includeExpired: _filter.includeExpired,
    );
    return this;
  }

  /// Define período de busca
  MemoryQuery between(DateTime from, DateTime to) {
    _filter = MemoryFilter(
      categories: _filter.categories,
      requiredTags: _filter.requiredTags,
      optionalTags: _filter.optionalTags,
      minEmotionalWeight: _filter.minEmotionalWeight,
      maxEmotionalWeight: _filter.maxEmotionalWeight,
      onlyPositive: _filter.onlyPositive,
      onlyNegative: _filter.onlyNegative,
      onlyNeutral: _filter.onlyNeutral,
      fromDate: from,
      toDate: to,
      limit: _filter.limit,
      orderBy: _filter.orderBy,
      ascending: _filter.ascending,
      includeExpired: _filter.includeExpired,
    );
    return this;
  }

  /// Define limite de resultados
  MemoryQuery limit(int count) {
    _filter = MemoryFilter(
      categories: _filter.categories,
      requiredTags: _filter.requiredTags,
      optionalTags: _filter.optionalTags,
      minEmotionalWeight: _filter.minEmotionalWeight,
      maxEmotionalWeight: _filter.maxEmotionalWeight,
      onlyPositive: _filter.onlyPositive,
      onlyNegative: _filter.onlyNegative,
      onlyNeutral: _filter.onlyNeutral,
      fromDate: _filter.fromDate,
      toDate: _filter.toDate,
      limit: count,
      orderBy: _filter.orderBy,
      ascending: _filter.ascending,
      includeExpired: _filter.includeExpired,
    );
    return this;
  }

  /// Define ordenação
  MemoryQuery orderBy(String field, {bool ascending = false}) {
    _filter = MemoryFilter(
      categories: _filter.categories,
      requiredTags: _filter.requiredTags,
      optionalTags: _filter.optionalTags,
      minEmotionalWeight: _filter.minEmotionalWeight,
      maxEmotionalWeight: _filter.maxEmotionalWeight,
      onlyPositive: _filter.onlyPositive,
      onlyNegative: _filter.onlyNegative,
      onlyNeutral: _filter.onlyNeutral,
      fromDate: _filter.fromDate,
      toDate: _filter.toDate,
      limit: _filter.limit,
      orderBy: field,
      ascending: ascending,
      includeExpired: _filter.includeExpired,
    );
    return this;
  }

  /// Constrói o filtro final
  MemoryFilter build() => _filter;
}
