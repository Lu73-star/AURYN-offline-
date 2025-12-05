/// lib/auryn_core/memory/memory_expiration.dart
/// MemoryExpiration - Sistema de expiração e limpeza de memórias.
///
/// Gerencia políticas de expiração, limpeza automática e manutenção
/// do espaço de armazenamento da memória.

import 'memory_entry.dart';

/// {@template expiration_policy}
/// Política de expiração de memórias.
/// {@endtemplate}
enum ExpirationPolicy {
  /// Nunca expira
  never,

  /// Expira após N dias
  afterDays,

  /// Expira após N acessos
  afterAccesses,

  /// Expira se não acessada por N dias
  ifNotAccessedFor,

  /// Expira baseado em peso emocional (neutras expiram mais rápido)
  emotionalWeight,
}

/// {@template expiration_config}
/// Configuração de política de expiração.
/// {@endtemplate}
class ExpirationConfig {
  /// Política de expiração
  final ExpirationPolicy policy;

  /// Número de dias para expiração (para afterDays, ifNotAccessedFor)
  final int? days;

  /// Número de acessos para expiração (para afterAccesses)
  final int? accessCount;

  /// Categorias afetadas pela política (null = todas)
  final List<String>? categories;

  /// Se deve aplicar apenas a memórias neutras
  final bool onlyNeutral;

  const ExpirationConfig({
    required this.policy,
    this.days,
    this.accessCount,
    this.categories,
    this.onlyNeutral = false,
  });

  /// Configuração padrão: não expira
  factory ExpirationConfig.never() {
    return const ExpirationConfig(policy: ExpirationPolicy.never);
  }

  /// Expira após N dias
  factory ExpirationConfig.afterDays(int days, {List<String>? categories}) {
    return ExpirationConfig(
      policy: ExpirationPolicy.afterDays,
      days: days,
      categories: categories,
    );
  }

  /// Expira se não acessada por N dias
  factory ExpirationConfig.ifNotAccessedFor(int days,
      {List<String>? categories}) {
    return ExpirationConfig(
      policy: ExpirationPolicy.ifNotAccessedFor,
      days: days,
      categories: categories,
    );
  }

  /// Expira baseado em peso emocional
  /// Memórias neutras expiram em 'days' dias
  /// Memórias emocionais (positivas/negativas) não expiram
  factory ExpirationConfig.emotionalWeight(int daysForNeutral) {
    return ExpirationConfig(
      policy: ExpirationPolicy.emotionalWeight,
      days: daysForNeutral,
      onlyNeutral: true,
    );
  }
}

/// {@template memory_expiration}
/// Gerenciador de expiração de memórias.
/// {@endtemplate}
class MemoryExpiration {
  /// Configurações de expiração
  final List<ExpirationConfig> _configs;

  /// Construtor
  MemoryExpiration({List<ExpirationConfig>? configs})
      : _configs = configs ?? [ExpirationConfig.never()];

  /// Adiciona uma configuração de expiração
  void addConfig(ExpirationConfig config) {
    _configs.add(config);
  }

  /// Remove uma configuração
  void removeConfig(ExpirationConfig config) {
    _configs.remove(config);
  }

  /// Limpa todas as configurações
  void clearConfigs() {
    _configs.clear();
  }

  /// Verifica se uma memória deve ser expirada baseado nas políticas
  bool shouldExpire(MemoryEntry entry) {
    // Se já está expirada naturalmente, retorna true
    if (entry.isExpired) return true;

    // Verifica cada configuração
    for (final config in _configs) {
      // Verifica se a configuração se aplica à categoria da entrada
      if (config.categories != null &&
          !config.categories!.contains(entry.category)) {
        continue;
      }

      // Verifica se deve aplicar apenas a neutras
      if (config.onlyNeutral && !entry.isNeutral) {
        continue;
      }

      // Aplica a política específica
      switch (config.policy) {
        case ExpirationPolicy.never:
          continue;

        case ExpirationPolicy.afterDays:
          if (config.days != null && entry.ageInDays >= config.days!) {
            return true;
          }
          break;

        case ExpirationPolicy.afterAccesses:
          if (config.accessCount != null &&
              entry.accessCount >= config.accessCount!) {
            return true;
          }
          break;

        case ExpirationPolicy.ifNotAccessedFor:
          if (config.days != null && entry.lastUpdated != null) {
            final daysSinceAccess =
                DateTime.now().difference(entry.lastUpdated!).inDays;
            if (daysSinceAccess >= config.days!) {
              return true;
            }
          } else if (config.days != null && entry.ageInDays >= config.days!) {
            // Se nunca foi acessada, usa timestamp de criação
            return true;
          }
          break;

        case ExpirationPolicy.emotionalWeight:
          if (entry.isNeutral && config.days != null) {
            if (entry.ageInDays >= config.days!) {
              return true;
            }
          }
          break;
      }
    }

    return false;
  }

  /// Filtra uma lista de memórias removendo as expiradas
  List<MemoryEntry> filterExpired(List<MemoryEntry> entries) {
    return entries.where((entry) => !shouldExpire(entry)).toList();
  }

  /// Obtém lista de memórias expiradas
  List<MemoryEntry> getExpired(List<MemoryEntry> entries) {
    return entries.where((entry) => shouldExpire(entry)).toList();
  }

  /// Calcula data de expiração para uma nova entrada baseado nas políticas
  DateTime? calculateExpirationDate(MemoryEntry entry) {
    DateTime? earliestExpiration;

    for (final config in _configs) {
      // Verifica se a configuração se aplica
      if (config.categories != null &&
          !config.categories!.contains(entry.category)) {
        continue;
      }

      if (config.onlyNeutral && !entry.isNeutral) {
        continue;
      }

      DateTime? expiration;

      switch (config.policy) {
        case ExpirationPolicy.never:
          continue;

        case ExpirationPolicy.afterDays:
          if (config.days != null) {
            expiration = entry.timestamp.add(Duration(days: config.days!));
          }
          break;

        case ExpirationPolicy.ifNotAccessedFor:
          if (config.days != null) {
            expiration = entry.timestamp.add(Duration(days: config.days!));
          }
          break;

        case ExpirationPolicy.emotionalWeight:
          if (entry.isNeutral && config.days != null) {
            expiration = entry.timestamp.add(Duration(days: config.days!));
          }
          break;

        case ExpirationPolicy.afterAccesses:
          // Não pode calcular data de expiração para política baseada em acessos
          continue;
      }

      // Mantém a expiração mais próxima
      if (expiration != null) {
        if (earliestExpiration == null ||
            expiration.isBefore(earliestExpiration)) {
          earliestExpiration = expiration;
        }
      }
    }

    return earliestExpiration;
  }

  /// Estatísticas de expiração
  Map<String, dynamic> getStatistics(List<MemoryEntry> entries) {
    final expired = getExpired(entries);
    final active = filterExpired(entries);

    final expiredByCategory = <String, int>{};
    for (final entry in expired) {
      expiredByCategory[entry.category] =
          (expiredByCategory[entry.category] ?? 0) + 1;
    }

    return {
      'total_entries': entries.length,
      'active_entries': active.length,
      'expired_entries': expired.length,
      'expiration_rate':
          entries.isEmpty ? 0.0 : expired.length / entries.length,
      'expired_by_category': expiredByCategory,
      'policies_count': _configs.length,
    };
  }

  @override
  String toString() {
    return 'MemoryExpiration(policies: ${_configs.length})';
  }
}

/// Políticas de expiração pré-configuradas
class ExpirationPolicies {
  /// Política padrão: neutras expiram em 30 dias, outras não expiram
  static List<ExpirationConfig> standard() {
    return [
      ExpirationConfig.emotionalWeight(30),
    ];
  }

  /// Política agressiva: todas as memórias expiram em 7 dias
  static List<ExpirationConfig> aggressive() {
    return [
      ExpirationConfig.afterDays(7),
    ];
  }

  /// Política conservadora: só expira memórias não acessadas por 90 dias
  static List<ExpirationConfig> conservative() {
    return [
      ExpirationConfig.ifNotAccessedFor(90),
    ];
  }

  /// Política balanceada: neutras em 30 dias, não acessadas em 60 dias
  static List<ExpirationConfig> balanced() {
    return [
      ExpirationConfig.emotionalWeight(30),
      ExpirationConfig.ifNotAccessedFor(60),
    ];
  }

  /// Sem expiração
  static List<ExpirationConfig> never() {
    return [
      ExpirationConfig.never(),
    ];
  }
}
