/// lib/auryn_core/core_utils/logger.dart
/// Sistema de logging simples para o AURYN Core.
/// Totalmente offline, sem envio de telemetria.

import 'dart:collection';
import 'package:flutter/foundation.dart';

/// Níveis de log
enum LogLevel {
  debug,
  info,
  warning,
  error,
  critical,
}

/// Logger simples e offline
class AurynLogger {
  static final AurynLogger _instance = AurynLogger._internal();
  factory AurynLogger() => _instance;
  AurynLogger._internal();

  /// Nível mínimo de log (por padrão, info)
  LogLevel minLevel = LogLevel.info;

  /// Buffer de logs recentes (usando Queue para O(1) removeFirst)
  final Queue<Map<String, dynamic>> _logBuffer = Queue<Map<String, dynamic>>();
  final int _maxBufferSize = 100;

  /// Habilita/desabilita logs
  bool enabled = true;

  /// Log de debug
  void debug(String message, {String? module, Map<String, dynamic>? data}) {
    _log(LogLevel.debug, message, module: module, data: data);
  }

  /// Log de info
  void info(String message, {String? module, Map<String, dynamic>? data}) {
    _log(LogLevel.info, message, module: module, data: data);
  }

  /// Log de warning
  void warning(String message, {String? module, Map<String, dynamic>? data}) {
    _log(LogLevel.warning, message, module: module, data: data);
  }

  /// Log de error
  void error(String message, {String? module, Map<String, dynamic>? data}) {
    _log(LogLevel.error, message, module: module, data: data);
  }

  /// Log crítico
  void critical(String message, {String? module, Map<String, dynamic>? data}) {
    _log(LogLevel.critical, message, module: module, data: data);
  }

  /// Log interno
  void _log(
    LogLevel level,
    String message, {
    String? module,
    Map<String, dynamic>? data,
  }) {
    if (!enabled) return;
    if (level.index < minLevel.index) return;

    final logEntry = {
      'timestamp': DateTime.now().toIso8601String(),
      'level': level.toString().split('.').last,
      'module': module ?? 'unknown',
      'message': message,
      'data': data,
    };

    // Adicionar ao buffer (Queue para melhor performance)
    _logBuffer.add(logEntry);
    if (_logBuffer.length > _maxBufferSize) {
      _logBuffer.removeFirst();
    }

    // Print no console em modo debug
    if (kDebugMode) {
      final levelStr = level.toString().split('.').last.toUpperCase();
      final moduleStr = module != null ? '[$module]' : '';
      debugPrint('[$levelStr] $moduleStr $message');
      if (data != null && data.isNotEmpty) {
        debugPrint('  Data: $data');
      }
    }
  }

  /// Retorna os logs recentes
  List<Map<String, dynamic>> getRecentLogs({int? limit}) {
    if (limit == null) return _logBuffer.toList();
    return _logBuffer.take(limit).toList();
  }

  /// Filtra logs por nível
  List<Map<String, dynamic>> getLogsByLevel(LogLevel level) {
    final levelStr = level.toString().split('.').last;
    return _logBuffer.where((log) => log['level'] == levelStr).toList();
  }

  /// Filtra logs por módulo
  List<Map<String, dynamic>> getLogsByModule(String module) {
    return _logBuffer.where((log) => log['module'] == module).toList();
  }

  /// Limpa o buffer de logs
  void clear() {
    _logBuffer.clear();
  }

  /// Retorna estatísticas de logs
  Map<String, dynamic> getStats() {
    final byLevel = <String, int>{};
    final byModule = <String, int>{};

    for (final log in _logBuffer) {
      final level = log['level'] as String;
      final module = log['module'] as String;

      byLevel[level] = (byLevel[level] ?? 0) + 1;
      byModule[module] = (byModule[module] ?? 0) + 1;
    }

    return {
      'total_logs': _logBuffer.length,
      'by_level': byLevel,
      'by_module': byModule,
      'buffer_size': _maxBufferSize,
      'enabled': enabled,
      'min_level': minLevel.toString().split('.').last,
    };
  }
}
