# AURYN Core - LWM Architecture

## Visão Geral

O AURYN Core implementa a arquitetura LWM (Living World Model) - um sistema de IA que mantém um "continuum interno" através de ciclos periódicos, estados emocionais e processamento contextual.

## Componentes Principais

### 1. Interfaces (`interfaces/`)

Define os contratos que todos os módulos devem seguir:

- **IAurynModule**: Interface base para todos os módulos
- **IProcessor**: Interface para processadores de entrada
- **IRuntimeManager**: Interface para gerenciadores de runtime
- **IEmotionModule**: Interface para módulos emocionais
- **INLPEngine**: Interface para engines de NLP

### 2. Sistema de Eventos (`events/`)

Sistema pub-sub para comunicação desacoplada entre módulos:

- **AurynEvent**: Classe base para eventos
- **EventBus**: Sistema de broadcast de eventos
- **Tipos de Eventos**:
  - `stateChange`: Mudanças de estado interno
  - `emotionalPulse`: Pulsos emocionais periódicos
  - `runtimePulse`: Pulsos do loop principal
  - `moodChange`: Mudanças de humor
  - `energyChange`: Mudanças de energia
  - `voiceStateChange`: Mudanças no fluxo de voz
  - `inputReceived`: Entrada recebida
  - `outputGenerated`: Resposta gerada
  - E mais...

### 3. Runtime (`runtime/`)

Gerencia o ciclo de vida e os "pulsos" internos da IA:

- **AurynRuntime**: Runtime básico com pulsos de 5 segundos
- **RuntimeManager**: Runtime avançado com callbacks e gestão de estado

#### LWM Loop

O loop LWM executa a cada 5 segundos:
1. Regeneração gradual de energia
2. Estabilização emocional automática
3. Execução de callbacks registrados
4. Publicação de eventos de pulso
5. Publicação de pulsos emocionais periódicos

### 4. Processamento (`processor/`)

Pipeline completo de processamento de entrada:

**AurynProcessor** segue este fluxo:
1. Sanitização de entrada (Security)
2. Criação de contexto de processamento
3. Análise NLP (intent + entities)
4. Interpretação emocional
5. Geração de insight
6. Resposta base
7. Modulação emocional
8. Estilização pela personalidade
9. Limitação de segurança
10. Salvamento em memória
11. Publicação de eventos

### 5. NLP (`nlp/`)

Processamento de linguagem natural offline:

- Detecção de intenções
- Extração de entidades
- Contexto de conversação (últimas 5 interações)
- Padrões em português brasileiro

### 6. Emoção (`emotion/`)

Gerenciamento de estados emocionais:

- 10 tipos de humor (neutral, calm, happy, sad, etc.)
- Intensidade emocional (0-3)
- Histórico emocional
- Cálculo de estabilidade emocional
- Modulação de respostas baseada em emoção

### 7. Personalidade (`personality/`)

Define a identidade e valores da AURYN:

- Valores centrais (truth, kindness, transparency, etc.)
- Identidade (nome, papel, tom, vínculo)
- Perfil dinâmico baseado em mood e energia
- Estilo de resposta adaptativo

### 8. Insight (`emotion/insight/`)

Camada intuitiva que detecta intenções emocionais profundas:
- Desabafo
- Positividade
- Busca de direção
- Insegurança
- Gratidão
- Reflexão

### 9. Estados (`states/`)

Armazena e gerencia estados internos:
- mood (humor)
- energy (energia)
- focus (foco)
- context_mode (modo de contexto)
- last_input (última entrada)

Publica eventos a cada mudança de estado.

### 10. Modelos (`models/`)

Estruturas de dados:

- **ProcessingContext**: Contexto completo de uma interação
- **EmotionalState**: Estado emocional com valência e arousal

## Fluxo de Dados

```
Input → Security → NLP → Emotion → Processor → Personality → Output
         ↓          ↓        ↓          ↓            ↓
      EventBus ← States ← Memory ← Insight ← Runtime
```

## Uso

### Inicialização

```dart
final core = AURYNCore();
await core.init();
```

### Processamento de Entrada

```dart
final response = core.respond("Olá, como você está?");
```

### Acesso ao Event Bus

```dart
final eventBus = core.eventBus;
eventBus.subscribe(AurynEventType.moodChange, (event) {
  print('Humor mudou: ${event.data}');
});
```

### Estatísticas do Sistema

```dart
final stats = core.getSystemStats();
print(stats);
```

### Shutdown

```dart
await core.shutdown();
```

## Integração com MemDart

O sistema de memória está integrado e suporta:
- Persistência local criptografada
- Indexação por prefixo, tag e tempo
- Queries avançadas
- Adaptadores plugáveis

## Integração com Voice

O módulo de voz (`voice/`) está integrado com:
- Estados de fluxo (idle → listening → processing → speaking)
- Eventos de mudança de estado
- Histórico de transições
- Estatísticas de uso

## Próximos Passos

1. Implementar testes unitários
2. Adicionar mais tipos de eventos
3. Expandir o sistema de insights
4. Melhorar o NLP com modelos locais
5. Adicionar suporte a plugins
