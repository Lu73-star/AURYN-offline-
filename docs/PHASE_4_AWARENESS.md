# Fase 4 — Awareness Layer

## Visão Geral

A Awareness Layer (Camada de Consciência) é o sistema central que coordena o contexto, memória e personalidade da AURYN. Esta camada permite que a AURYN mantenha consciência situacional, aprenda com interações e adapte seu comportamento.

## Arquitetura

### Diagrama de Responsabilidades

```
AwarenessCore (Coordenador Central)
    ├── ContextManager (Gerenciamento de Contexto)
    ├── ShortTermMemory (Memória de Curto Prazo)
    ├── EpisodicMemory (Memória Episódica - OPT-IN)
    ├── PersonalityController (Controle de Personalidade)
    ├── IntentFilter (Filtro de Intenções)
    └── VoiceHooks (Ganchos de Voz)
```

### Componentes

#### AwarenessCore
- Coordenador central de todos os módulos de awareness
- Gerencia inicialização e atualização de estado
- Processa intents e distribui para submódulos
- Interface principal para o sistema de awareness

#### ContextManager
- Mantém snapshot do estado atual
- Armazena preferências e condições do ambiente
- Fornece acesso rápido ao contexto dinâmico

#### ShortTermMemory
- Armazena interações e eventos recentes
- Mantém cache volátil em memória RAM
- Implementa eviction automática (FIFO)
- Capacidade: 100 items por padrão

#### EpisodicMemory
- Armazena sequências de experiências passadas
- **REQUER OPT-IN EXPLÍCITO DO USUÁRIO**
- Permite filtragem por critérios
- Usuário pode limpar memória a qualquer momento

#### PersonalityController
- Gerencia traços de personalidade da AURYN
- Traits ajustáveis: friendliness, formality, verbosity, empathy, humor
- Permite customização e adaptação dinâmica

#### IntentFilter
- Classifica inputs em tipos de intent
- Filtra intents irrelevantes
- Suporta padrões customizáveis
- Processamento totalmente local

#### VoiceHooks
- Define callbacks para eventos de voz
- Integra transcrições com awareness
- Mantém histórico de interações vocais

## Exemplos de Uso

### Inicialização Básica

```dart
import 'package:auryn_offline/auryn_core/awareness/awareness.dart';

// Criar e inicializar awareness core
final awareness = AwarenessCoreImpl();
awareness.initialize();

// Verificar contexto inicial
final context = awareness.contextManager.getCurrentContext();
print('Contexto atual: $context');
```

### Manipulação de Intent

```dart
// Processar intent de voz
awareness.handleIntent('voice_input', {
  'transcript': 'Olá AURYN',
  'confidence': 0.95,
});

// Verificar memória de curto prazo
final recentItems = awareness.shortTermMemory.getRecentItems(limit: 5);
print('Interações recentes: $recentItems');
```

### Configuração de Personalidade

```dart
// Obter traits atuais
final traits = awareness.personalityController.getTraits();

// Ajustar trait específico
awareness.personalityController.updateTrait('friendliness', 0.9);

// Obter trait individual
final empathy = awareness.personalityController.getTrait('empathy');
```

### Memória Episódica (Opt-in)

```dart
// IMPORTANTE: Requer consentimento explícito do usuário
// antes de habilitar em produção

// Habilitar memória episódica (após obter consentimento)
awareness.episodicMemory.enable();

// Adicionar episódio
awareness.episodicMemory.addEpisode({
  'type': 'conversation',
  'duration': 120,
  'satisfaction': 'high',
});

// Recuperar episódios
final episodes = awareness.episodicMemory.getEpisodes(
  criteria: {'type': 'conversation'}
);

// Limpar todos os episódios
awareness.episodicMemory.clearAllEpisodes();
```

### Voice Hooks

```dart
// Configurar callbacks
awareness.voiceHooks.setVoiceInputCallback((transcript) {
  print('Voz recebida: $transcript');
});

awareness.voiceHooks.setVoiceFeedbackCallback((feedback) {
  print('Feedback: $feedback');
});

// Processar input de voz
awareness.voiceHooks.onVoiceInput('Como você está?');
```

## Fluxo de Privacidade e Segurança

### Princípios Fundamentais

1. **Processamento Local**: Todo processamento ocorre no dispositivo
2. **Sem Transmissão Externa**: Nenhum dado é enviado para servidores
3. **Opt-in para Persistência**: Memória episódica requer consentimento
4. **Controle do Usuário**: Usuário pode limpar dados a qualquer momento

### Dados em Memória

| Componente | Persistência | Opt-in Necessário | Controlado pelo Usuário |
|------------|-------------|-------------------|------------------------|
| ContextManager | Volátil (RAM) | Não | Sim (clearContext) |
| ShortTermMemory | Volátil (RAM) | Não | Sim (clear) |
| EpisodicMemory | Pode ser persistente | **SIM** | Sim (clearAllEpisodes) |
| PersonalityController | Volátil (RAM) | Não | Sim (resetToDefaults) |

### Implementação de Opt-in

Para usar memória episódica em produção:

1. **Obter Consentimento Explícito**
   - Mostrar diálogo claro explicando o que será gravado
   - Oferecer opções de aceitar/rejeitar
   - Documentar política de retenção de dados

2. **Informar o Usuário**
   - Quais dados são armazenados
   - Por quanto tempo
   - Como podem ser excluídos

3. **Fornecer Controles**
   - Botão para desabilitar gravação
   - Botão para limpar histórico
   - Indicador visual quando gravando

```dart
// Exemplo de implementação de opt-in
Future<void> requestEpisodicMemoryConsent(BuildContext context) async {
  final consent = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Habilitar Memória de Longo Prazo'),
      content: Text(
        'AURYN pode armazenar suas conversas para melhorar '
        'respostas futuras. Todos os dados ficam no seu dispositivo. '
        'Você pode limpar a qualquer momento.'
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text('Não'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text('Sim, permitir'),
        ),
      ],
    ),
  );

  if (consent == true) {
    awareness.episodicMemory.enable();
  }
}
```

## Testes

### Estrutura de Testes

Testes unitários estão disponíveis em:
- `test/awareness/awareness_core_test.dart`
- `test/awareness/context_manager_test.dart`

### Executar Testes

```bash
# Executar todos os testes de awareness
flutter test test/awareness/

# Executar teste específico
flutter test test/awareness/awareness_core_test.dart
```

### Cobertura de Testes

Os testes cobrem:
- Inicialização de componentes
- Operações básicas de contexto
- Armazenamento e recuperação de memória
- Classificação de intents
- Opt-in de memória episódica

## Validação de Código

```bash
# Análise estática
dart analyze

# Formatação
dart format lib/auryn_core/awareness/

# Verificação de dependências
flutter pub get
```

## Compatibilidade

- **Dart SDK**: >= 2.17.0 < 4.0.0
- **Flutter**: 3.x
- **Plataformas**: Android, iOS (offline-first)

## Roadmap Futuro

### Fase 5 (Futuro)
- Persistência de contexto com Hive
- Análise avançada de padrões
- Machine learning local para intent classification
- Integração com MemDart para memória de longo prazo
- Sincronização opcional entre dispositivos (opt-in)

### Melhorias Planejadas
- Filtros de intent baseados em ML
- Análise de sentimento em voice hooks
- Compressão automática de memória episódica
- Exportação de dados para backup

## Contribuindo

Para contribuir com a Awareness Layer:

1. Leia `AI_CONTRIBUTOR_GUIDE.md`
2. Mantenha princípios de privacidade
3. Adicione testes para novas funcionalidades
4. Documente mudanças no código
5. Verifique com `dart analyze`

## Referências

- [PHILOSOPHY.md](../PHILOSOPHY.md) - Filosofia do projeto
- [PROJECT_IDENTITY.md](../PROJECT_IDENTITY.md) - Identidade AURYN
- [AURYN_BEHAVIOR_STANDARD.md](../AURYN_BEHAVIOR_STANDARD.md) - Padrões de comportamento
- [AURYN_AWARENESS_FLOW.md](../lib/auryn_core/awareness/AURYN_AWARENESS_FLOW.md) - Fluxo detalhado
