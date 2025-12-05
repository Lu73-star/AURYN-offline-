# AURYN Core Awareness Flow

Este módulo explora os principais componentes da consciência artificial AURYN.

## Estrutura

- **awareness_core.dart:** Responsável por coordenar todos os submódulos de consciência.
- **context_manager.dart:** Gerencia o contexto dinâmico durante interações.
- **short_term_memory.dart:** Manipula dados recentes e transitórios.
- **episodic_memory.dart:** Armazena sequências e experiências do passado (OPT-IN).
- **personality_controller.dart:** Controla traços de personalidade virtuais.
- **intent_filter.dart:** Detecta e filtra intenções do usuário.
- **voice_hooks.dart:** Integra eventos de voz e interações faladas.
- **awareness.dart:** Barrel export para facilitar importação.

## Fluxo de Dados

```
Entrada do Usuário
       ↓
   VoiceHooks / Input
       ↓
   IntentFilter (classifica)
       ↓
   AwarenessCore (coordena)
       ↓
   ├→ ContextManager (atualiza estado)
   ├→ ShortTermMemory (armazena recente)
   ├→ EpisodicMemory (armazena longo prazo - opt-in)
   └→ PersonalityController (ajusta resposta)
       ↓
   Resposta Personalizada
```

## Interfaces e Implementações

Cada módulo fornece:
- **Interface abstrata**: Define o contrato público
- **Implementação concreta**: Fornece funcionalidade básica
- **Testes unitários**: Valida comportamento

### AwarenessCore

Coordenador central que:
- Inicializa todos os submódulos
- Distribui intents para processamento
- Mantém referências aos componentes
- Fornece API unificada

### ContextManager

Gerencia estado dinâmico:
- Armazena contexto atual (volátil)
- Permite consulta e atualização
- Sem persistência (apenas RAM)

### ShortTermMemory

Cache de interações recentes:
- Capacidade: 100 items
- Eviction: FIFO
- Armazenamento: RAM apenas
- Acesso: Ordem reversa (novo → velho)

### EpisodicMemory

Memória de longo prazo:
- **OPT-IN OBRIGATÓRIO**
- Filtragem por critérios
- Timestamps automáticos
- Limpeza sob demanda

### PersonalityController

Controle de traits:
- Traits padrão: friendliness, formality, verbosity, empathy, humor
- Valores ajustáveis dinamicamente
- Reset para defaults disponível

### IntentFilter

Classificação de intenções:
- Keywords pré-configurados
- Patterns customizáveis
- Filtragem de duplicatas
- Suporte a múltiplos idiomas

### VoiceHooks

Integração com voz:
- Callbacks para input/feedback
- Histórico de interações
- Eventos de recording
- Totalmente local

## Princípios de Design

### 1. Offline-First
Todo processamento ocorre localmente no dispositivo.

### 2. Privacy-First
- Nenhuma transmissão externa de dados
- Memória episódica requer opt-in explícito
- Usuário tem controle total dos dados

### 3. Modular
- Componentes independentes
- Interfaces bem definidas
- Fácil extensão e teste

### 4. Testável
- Todos os módulos têm testes
- Interfaces permitem mocking
- Testes de integração disponíveis

## Uso Básico

```dart
// Importar módulo completo
import 'package:auryn_offline/auryn_core/awareness/awareness.dart';

// Criar e inicializar
final awareness = AwarenessCoreImpl();
awareness.initialize();

// Processar intent
awareness.handleIntent('voice_input', {
  'transcript': 'Olá AURYN',
});

// Acessar contexto
final ctx = awareness.contextManager.getCurrentContext();

// Acessar memória recente
final recent = awareness.shortTermMemory.getRecentItems(limit: 5);
```

## Compatibilidade

> Compatível com Dart/Flutter 3.x
> SDK: >= 2.17.0 < 4.0.0

## Desenvolvimento Futuro

- Persistência com Hive/Isar
- ML local para classificação
- Compressão de memória
- Sincronização P2P (opt-in)

## Referências

Ver também:
- `/docs/PHASE_4_AWARENESS.md` - Documentação completa
- `/test/awareness/` - Suite de testes
