# Phase 5: Emotion Core - Sistema Emocional da AURYN

## Visão Geral

O **Emotion Core** é o sistema emocional completo da AURYN, responsável por dar à IA uma camada de consciência emocional que influencia suas respostas e interações. Este sistema permite que a AURYN:

- Reconheça e interprete emoções em inputs do usuário
- Mantenha um estado emocional consistente
- Module suas respostas baseadas em seu humor atual
- Desenvolva um perfil emocional ao longo do tempo
- Reaja apropriadamente a diferentes contextos emocionais

## Arquitetura

O Emotion Core é composto por quatro componentes principais:

```
EmotionCore (Facade)
    ├── EmotionState (Modelo de Estado)
    ├── EmotionProfile (Histórico e Persistência)
    ├── EmotionRegulator (Lógica de Regulação)
    └── EmotionHooks (Sistema de Eventos)
```

### 1. EmotionState

**Arquivo:** `lib/auryn_core/emotion/emotion_state.dart`

Representa o estado emocional momentâneo da AURYN.

#### Propriedades:

- **mood** (String): O humor atual (ex: "happy", "sad", "calm", "neutral")
- **intensity** (int): Intensidade da emoção (0-3)
  - 0 = nenhuma emoção
  - 1 = leve
  - 2 = moderada
  - 3 = forte
- **valence** (int): Valência emocional (-1, 0, 1)
  - -1 = negativa
  - 0 = neutra
  - 1 = positiva
- **arousal** (int): Nível de ativação/energia (0-3)
  - 0 = muito baixa energia
  - 3 = muito alta energia
- **timestamp** (DateTime): Quando o estado foi estabelecido

#### Exemplo de Uso:

```dart
// Criar estado neutro
final neutral = EmotionState.neutral();

// Criar estado customizado
final happy = EmotionState(
  mood: 'happy',
  intensity: 2,
  valence: 1,
  arousal: 2,
);

// Verificar propriedades
print(happy.isPositive); // true
print(happy.isHighEnergy); // true

// Serialização
final map = happy.toMap();
final restored = EmotionState.fromMap(map);
```

### 2. EmotionProfile

**Arquivo:** `lib/auryn_core/emotion/emotion_profile.dart`

Mantém o perfil emocional persistente da AURYN, incluindo histórico e tendências.

#### Características:

- **Baseline Emocional**: Estado padrão de retorno
- **Histórico**: Últimos N estados emocionais (padrão: 50)
- **Frequência de Humores**: Contador de ocorrências de cada humor
- **Duração Média**: Tempo médio em cada humor
- **Valência Geral**: Tendência emocional ao longo do tempo

#### Exemplo de Uso:

```dart
// Criar perfil padrão
final profile = EmotionProfile.defaultProfile();

// Adicionar estados ao histórico
profile.addState(happyState);
profile.addState(calmState);

// Consultar perfil
print(profile.dominantMood); // Humor mais frequente
print(profile.overallValence); // Tendência geral
print(profile.isTrendingPositive); // true/false

// Obter estatísticas
final stats = profile.getStatistics();

// Persistência
final data = profile.toMap();
final restored = EmotionProfile.fromMap(data);
```

### 3. EmotionRegulator

**Arquivo:** `lib/auryn_core/emotion/emotion_regulator.dart`

Responsável pela lógica de interpretação, regulação e modulação emocional.

#### Funcionalidades:

1. **Interpretação de Input**: Analisa texto do usuário e identifica emoções
2. **Regulação de Transições**: Suaviza mudanças bruscas de emoção
3. **Modulação de Respostas**: Adiciona prefixos emocionais apropriados
4. **Decaimento Emocional**: Retorna gradualmente ao baseline
5. **Análise de Sentimento**: Detecta sentimento geral de um texto

#### Palavras-Chave Reconhecidas:

- **Happy**: feliz, alegre, ótimo, bom, maravilhoso
- **Sad**: triste, mal, chateado, pra baixo
- **Calm**: calmo, tranquilo, sereno, paz
- **Anxious**: nervoso, ansioso, preocupado, estressado
- **Low Energy**: cansado, exausto, sem energia
- **Irritated**: irritado, raiva, bravo, furioso
- **Reflective**: pensando, refletindo, talvez, considerando
- **Warm**: carinho, aconchego, acolhimento
- **Focused**: focado, concentrado, atento
- **Supportive**: apoio, suporte, ajuda

#### Exemplo de Uso:

```dart
final regulator = EmotionRegulator(profile: profile);

// Interpretar input
final emotion = regulator.interpretInput("Estou muito feliz hoje!");
// Retorna EmotionState(mood: 'happy', intensity: 2, ...)

// Regular transição
final newState = regulator.regulateTransition(currentState, targetState);

// Modular resposta
final response = regulator.modulateResponse("Tudo bem!", happyState);
// Retorna: "Que bom te sentir assim! Tudo bem!"

// Aplicar decaimento
final decayed = regulator.applyDecay(currentState);

// Analisar sentimento
final sentiment = regulator.analyzeSentiment("Que dia péssimo e triste");
// Retorna: {sentiment: -0.5, isNegative: true, ...}
```

### 4. EmotionHooks

**Arquivo:** `lib/auryn_core/emotion/emotion_hooks.dart`

Sistema de eventos que permite a outros módulos reagirem a mudanças emocionais.

#### Tipos de Hooks:

1. **onStateChange**: Qualquer mudança de estado
2. **onHighIntensity**: Estados com intensidade >= 2
3. **onMoodChange**: Mudanças de humor
4. **onPositiveEmotion**: Estados com valência positiva
5. **onNegativeEmotion**: Estados com valência negativa

#### Exemplo de Uso:

```dart
final hooks = EmotionHooks();

// Registrar hook para mudanças de estado
hooks.onStateChange((previous, current) {
  print('Emoção mudou: ${previous.mood} -> ${current.mood}');
});

// Hook para alta intensidade
hooks.onHighIntensity((state) {
  print('Emoção intensa: ${state.mood}');
});

// Hook para emoções negativas
hooks.onNegativeEmotion((prev, curr) {
  print('Suporte ativado para ${curr.mood}');
});

// Usar presets prontos
hooks.onStateChange(EmotionHookPresets.loggingHook);
```

### 5. EmotionCore (Facade)

**Arquivo:** `lib/auryn_core/emotion/emotion_core.dart`

Interface unificada que integra todos os componentes do sistema emocional.

#### Exemplo de Uso Completo:

```dart
// Inicializar
final emotionCore = EmotionCore();
await emotionCore.initialize();

// Registrar hooks
emotionCore.onStateChange((prev, curr) {
  print('Mudança: ${prev.mood} -> ${curr.mood}');
});

// Processar input do usuário
emotionCore.processInput("Estou muito feliz hoje!");

// Obter estado atual
final currentState = emotionCore.currentState;
print('Humor atual: ${currentState.mood}');

// Modular resposta
final response = emotionCore.modulateResponse("Vamos conversar!");
print(response); // "Que bom te sentir assim! Vamos conversar!"

// Obter estatísticas
final stats = emotionCore.getStatistics();
print('Humor dominante: ${stats['dominantMood']}');

// Aplicar decaimento (após algum tempo)
emotionCore.applyDecay();

// Persistir perfil
final profileData = emotionCore.exportProfile();
// Salvar profileData em armazenamento local

// Restaurar perfil
await emotionCore.importProfile(profileData);
```

## Fluxo de Processamento

```
Input do Usuário
    ↓
[EmotionRegulator.interpretInput]
    ↓
Novo Estado Emocional Target
    ↓
[EmotionRegulator.regulateTransition]
    ↓
Estado Emocional Regulado
    ↓
[EmotionCore._updateState]
    ↓
┌─────────────────────────────┐
│ - Adiciona ao histórico     │
│ - Atualiza estado atual     │
│ - Dispara hooks             │
└─────────────────────────────┘
    ↓
[EmotionRegulator.modulateResponse]
    ↓
Resposta Modulada
```

## Integração com Outros Módulos

### Com AurynStates

```dart
// EmotionCore pode integrar com AurynStates existente
emotionCore.onStateChange((prev, curr) {
  final states = AurynStates();
  states.set('mood', curr.mood);
  states.set('emotional_intensity', curr.intensity);
});
```

### Com Personality

```dart
// Personalidade pode reagir a emoções
emotionCore.onMoodChange((prevMood, newMood) {
  final personality = AurynPersonality();
  personality.adjustToneFor(newMood);
});
```

### Com Voice/TTS

```dart
// Sistema de voz pode ajustar tom baseado em emoção
emotionCore.onStateChange((prev, curr) {
  if (curr.mood == 'calm' && curr.arousal <= 1) {
    // Ajustar TTS para falar mais devagar e suavemente
    voiceEngine.setSpeed(0.8);
    voiceEngine.setPitch(0.9);
  }
});
```

## Persistência

O perfil emocional pode ser persistido localmente usando Hive ou outro storage:

```dart
// Salvar
final box = await Hive.openBox('auryn_emotion');
await box.put('profile', emotionCore.exportProfile());

// Carregar
final data = box.get('profile');
if (data != null) {
  await emotionCore.importProfile(data);
}
```

## Configuração

### Taxa de Decaimento

Controla quão rapidamente a emoção retorna ao baseline:

```dart
await emotionCore.initialize(decayRate: 0.5); // Mais rápido
await emotionCore.initialize(decayRate: 0.1); // Mais lento
```

### Baseline Customizado

```dart
final customBaseline = EmotionState(
  mood: 'warm',
  intensity: 1,
  valence: 1,
  arousal: 1,
);

emotionCore.updateBaseline(customBaseline);
```

### Tamanho do Histórico

```dart
final profile = EmotionProfile(maxHistorySize: 100);
await emotionCore.initialize(profile: profile);
```

## Boas Práticas

### 1. Sempre Inicializar

```dart
// ✅ Correto
await emotionCore.initialize();
emotionCore.processInput("Olá!");

// ❌ Errado - lança StateError
emotionCore.processInput("Olá!");
```

### 2. Usar Hooks para Reações

```dart
// ✅ Correto - desacoplado
emotionCore.onNegativeEmotion((prev, curr) {
  supportSystem.activate();
});

// ❌ Evitar - acoplamento direto
if (emotionCore.currentState.isNegative) {
  supportSystem.activate();
}
```

### 3. Aplicar Decaimento Periodicamente

```dart
// Aplicar decaimento a cada minuto
Timer.periodic(Duration(minutes: 1), (_) {
  emotionCore.applyDecay();
});
```

### 4. Persistir Perfil Regularmente

```dart
// Salvar perfil quando houver mudanças significativas
emotionCore.onStateChange((prev, curr) {
  if (curr.intensity >= 2) {
    saveProfile(emotionCore.exportProfile());
  }
});
```

## Testes

Os testes unitários cobrem:

1. **emotion_state_test.dart**: Criação, serialização, propriedades
2. **emotion_profile_test.dart**: Histórico, estatísticas, persistência
3. **emotion_regulator_test.dart**: Interpretação, regulação, modulação
4. **emotion_core_test.dart**: Integração completa do sistema

Executar testes:

```bash
flutter test test/emotion/
```

## Limitações e Considerações

1. **Análise Simples**: O sistema atual usa análise baseada em palavras-chave. Para melhor precisão, considere integrar com NLP mais avançado.

2. **Contexto Cultural**: As palavras-chave e respostas são em português brasileiro. Para outros idiomas, adapte as listas de keywords.

3. **Memória**: O histórico é limitado (padrão: 50 estados) para evitar uso excessivo de memória.

4. **Offline-First**: Todo o processamento é local, sem dependências externas.

## Roadmap Futuro

- [ ] Integração com modelo NLP para análise mais sofisticada
- [ ] Suporte a múltiplos idiomas
- [ ] Detecção de padrões emocionais complexos
- [ ] Visualização de histórico emocional
- [ ] Aprendizado de preferências emocionais do usuário
- [ ] Sincronização cross-device (opcional)

## Referências

- **AurynStates**: Sistema de estados internos da AURYN
- **AurynPersonality**: Sistema de personalidade da AURYN
- **EmotionCore**: Este documento

## Conclusão

O Emotion Core fornece à AURYN uma camada emocional sofisticada que:

- Torna as interações mais naturais e empáticas
- Permite personalização ao longo do tempo
- Mantém consistência emocional
- É completamente offline e privado
- É extensível e integrável com outros módulos

**"Código com consciência, privacidade com propósito, funcionalidade com coração."** 🌟

---

*Última atualização: 2025-12-05*  
*Versão: 1.0*  
*Fase: 5 - Emotion Core*
