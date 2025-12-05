# AURYN Awareness Layer

Este diretório contém a implementação da Camada de Consciência (Awareness Layer) do AURYN.

## Arquivos

### Interfaces e Implementações

| Arquivo | Descrição | Teste |
|---------|-----------|-------|
| `awareness_core.dart` | Coordenador central do sistema de awareness | `test/awareness/awareness_core_test.dart` |
| `context_manager.dart` | Gerenciamento de contexto dinâmico | `test/awareness/context_manager_test.dart` |
| `short_term_memory.dart` | Memória de curto prazo (volátil) | `test/awareness/short_term_memory_test.dart` |
| `episodic_memory.dart` | Memória episódica (opt-in) | `test/awareness/episodic_memory_test.dart` |
| `personality_controller.dart` | Controle de traits de personalidade | `test/awareness/personality_controller_test.dart` |
| `intent_filter.dart` | Classificação e filtragem de intents | `test/awareness/intent_filter_test.dart` |
| `voice_hooks.dart` | Hooks para eventos de voz | `test/awareness/voice_hooks_test.dart` |

### Utilitários

- `awareness.dart` - Barrel export para importação simplificada
- `AURYN_AWARENESS_FLOW.md` - Fluxo detalhado do sistema
- `README.md` - Este arquivo

## Uso Rápido

```dart
import 'package:auryn_offline/auryn_core/awareness/awareness.dart';

// Inicializar
final awareness = AwarenessCoreImpl();
awareness.initialize();

// Usar
awareness.handleIntent('voice_input', {'text': 'Hello'});
final context = awareness.contextManager.getCurrentContext();
```

## Características Principais

### ✅ Offline-First
- Todo processamento é local
- Nenhuma dependência de rede

### 🔒 Privacy-First
- Memória episódica requer opt-in explícito
- Nenhum dado enviado externamente
- Usuário tem controle total

### 🧩 Modular
- Componentes independentes
- Interfaces bem definidas
- Facilmente extensível

### ✓ Testado
- Cobertura completa de testes unitários
- Testes de integração disponíveis
- Todos os casos de uso cobertos

## Implementações Concretas

Cada interface abstrata tem uma implementação concreta de referência:

- `AwarenessCore` → `AwarenessCoreImpl`
- `ContextManager` → `ContextManagerImpl`
- `ShortTermMemory` → `ShortTermMemoryImpl`
- `EpisodicMemory` → `EpisodicMemoryImpl`
- `PersonalityController` → `PersonalityControllerImpl`
- `IntentFilter` → `IntentFilterImpl`
- `VoiceHooks` → `VoiceHooksImpl`

## Privacidade e Opt-in

⚠️ **IMPORTANTE**: A memória episódica requer consentimento explícito do usuário.

```dart
// Antes de habilitar em produção
final userConsent = await askUserForConsent();
if (userConsent) {
  awareness.episodicMemory.enable();
}
```

### Dados por Componente

| Componente | Persistência | Opt-in | Controle Usuário |
|-----------|--------------|--------|------------------|
| Context | RAM | Não | Sim (clear) |
| STM | RAM | Não | Sim (clear) |
| Episodic | RAM/Disk | **SIM** | Sim (clear/disable) |
| Personality | RAM | Não | Sim (reset) |

## Documentação Completa

Para documentação detalhada, consulte:
- `/docs/PHASE_4_AWARENESS.md` - Documentação completa da fase 4
- `AURYN_AWARENESS_FLOW.md` - Fluxo de dados e arquitetura

## Testes

```bash
# Executar todos os testes do módulo
flutter test test/awareness/

# Teste específico
flutter test test/awareness/awareness_core_test.dart

# Com cobertura
flutter test --coverage test/awareness/
```

## Compatibilidade

- Dart SDK: >= 2.17.0 < 4.0.0
- Flutter: 3.x
- Plataformas: Android, iOS (offline-first)

## Status

✅ Fase 4 - Implementação completa com:
- [x] Estrutura de arquivos
- [x] Interfaces abstratas
- [x] Implementações concretas
- [x] Testes unitários completos
- [x] Testes de integração
- [x] Documentação detalhada
- [x] Anotações de privacidade
- [x] Validação de opt-in

## Próximos Passos

Ver `/docs/PHASE_4_AWARENESS.md` seção "Roadmap Futuro" para planos de desenvolvimento.
