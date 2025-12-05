# Phase 6: Personality Layer - Sistema de Personalidade da AURYN

## Visão Geral

O **Personality Layer** é o sistema que define como a AURYN se comporta, responde e interage com o usuário. Ele integra traços de personalidade, estilos de diálogo, e modulação emocional para criar uma IA com uma presença consistente e adaptável.

## Objetivos

- **Consistência**: Manter um comportamento coerente baseado em traços de personalidade
- **Adaptabilidade**: Ajustar estilo de comunicação baseado em emoções e contexto
- **Modularidade**: Permitir troca entre diferentes perfis de personalidade
- **Privacidade**: Persistência opt-in apenas, tudo offline
- **Integração**: Trabalhar harmonicamente com o Emotion Core (Phase 5)

## Arquitetura

```
PersonaManager (Gerenciador)
    ├── PersonalityProfile (Perfil completo)
    │   ├── PersonalityTraits (8 traços)
    │   ├── DialogStyle (6 dimensões)
    │   └── EmotionState (baseline emocional)
    ├── BehaviorShaping (Computação de diretivas)
    │   ├── BehaviorContext (contexto de interação)
    │   └── BehavioralDirective (diretiva resultante)
    └── PersonalityEvents (Sistema de eventos)
        ├── OnTraitAdjustment
        ├── OnProfileShift
        └── OnBehaviorComputed
```

## Componentes

### 1. PersonalityTraits

**Arquivo:** `lib/auryn_core/personality/personality_traits.dart`

Define os traços fundamentais de personalidade da AURYN, normalizados para escala 0.0-1.0.

#### Traços (8 dimensões):

1. **Openness** (Abertura): Curiosidade, criatividade, vontade de explorar
   - 0.0 = conservador, cauteloso
   - 1.0 = altamente curioso, criativo

2. **Conscientiousness** (Conscienciosidade): Organização, confiabilidade, atenção aos detalhes
   - 0.0 = espontâneo, flexível
   - 1.0 = metódico, preciso

3. **Extraversion** (Extroversão): Energia em interação social, expressividade
   - 0.0 = reservado, introspectivo
   - 1.0 = extrovertido, expressivo

4. **Agreeableness** (Amabilidade): Empatia, cooperação, bondade
   - 0.0 = analítico, direto
   - 1.0 = caloroso, suportivo

5. **Neuroticism** (Neuroticismo): Estabilidade emocional, resposta ao estresse
   - 0.0 = calmo, estável
   - 1.0 = sensível, reativo

6. **Assertiveness** (Assertividade): Confiança em expressar opiniões
   - 0.0 = gentil, acomodador
   - 1.0 = direto, assertivo

7. **Playfulness** (Alegria): Humor, leveza na interação
   - 0.0 = sério, formal
   - 1.0 = brincalhão, humorado

8. **Intellectualism** (Intelectualismo): Profundidade de raciocínio, pensamento abstrato
   - 0.0 = prático, concreto
   - 1.0 = filosófico, abstrato

#### Exemplo de Uso:

```dart
// Criar traços customizados
final traits = PersonalityTraits(
  openness: 0.75,
  conscientiousness: 0.70,
  extraversion: 0.55,
  agreeableness: 0.85,
  neuroticism: 0.30,
  assertiveness: 0.60,
  playfulness: 0.45,
  intellectualism: 0.80,
);

// Usar traços padrão da AURYN
final aurynTraits = PersonalityTraits.aurynDefault();

// Ajustar um traço específico
final adjusted = traits.adjustTrait('openness', 0.10);

// Obter valor de um traço
final value = traits.getTrait('agreeableness'); // 0.85

// Calcular similaridade entre traços
final similarity = traits1.similarityTo(traits2); // 0.0-1.0

// Serialização
final map = traits.toMap();
final restored = PersonalityTraits.fromMap(map);
```

### 2. DialogStyle

**Arquivo:** `lib/auryn_core/personality/dialog_style.dart`

Define o estilo de comunicação da AURYN: tom emocional, nível de detalhe, ritmo, e expressividade.

#### Dimensões (6 atributos):

1. **Warmth** (Calor): Temperatura emocional das respostas
   - 0.0 = clínico, distante
   - 1.0 = caloroso, emocionalmente presente

2. **Precision** (Precisão): Nível de detalhe e exatidão
   - 0.0 = geral, aproximado
   - 1.0 = detalhado, preciso

3. **Cadence** (Cadência): Ritmo e velocidade da fala
   - 0.0 = lento, deliberado
   - 1.0 = rápido, energético

4. **Expressiveness** (Expressividade): Uso de linguagem emocional e modificadores
   - 0.0 = neutro, factual
   - 1.0 = expressivo, colorido

5. **Formality** (Formalidade): Nível de linguagem formal
   - 0.0 = casual, informal
   - 1.0 = formal, profissional

6. **Verbosity** (Verbosidade): Comprimento e elaboração das respostas
   - 0.0 = conciso, breve
   - 1.0 = elaborado, detalhado

#### Exemplo de Uso:

```dart
// Criar estilo padrão AURYN
final style = DialogStyle.aurynDefault();

// Ajustar para um humor específico
final happyStyle = style.adjustForMood('happy');
// Aumenta warmth, cadence, expressiveness

final sadStyle = style.adjustForMood('sad');
// Aumenta warmth, diminui cadence

// Ajustar para intensidade emocional
final intenseStyle = style.adjustForIntensity(3);
// Aumenta expressiveness e warmth

// Labels descritivos
print(style.warmthLabel); // "warm"
print(style.cadenceLabel); // "moderate"

// Serialização
final map = style.toMap();
final restored = DialogStyle.fromMap(map);
```

### 3. PersonalityProfile

**Arquivo:** `lib/auryn_core/personality/personality_profile.dart`

Combina traços, baseline emocional, e estilo de diálogo em um perfil completo de personalidade.

#### Propriedades:

- **id**: Identificador único
- **name**: Nome do perfil
- **description**: Descrição
- **traits**: PersonalityTraits
- **emotionalBaseline**: EmotionState padrão
- **dialogStyle**: DialogStyle padrão
- **contextPreferences**: Preferências contextuais

#### Perfis Pré-definidos:

1. **AURYN Default**: Perfil padrão - calorosa, pensativa, presente, honesta
2. **Supportive Mode**: Empatia e calor aumentados para suporte emocional
3. **Analytical Mode**: Precisão e profundidade intelectual aumentadas

#### Exemplo de Uso:

```dart
// Criar perfil padrão
final profile = PersonalityProfile.aurynDefault();

// Criar perfil customizado
final custom = PersonalityProfile(
  id: 'custom',
  name: 'Custom Profile',
  description: 'My custom personality',
  traits: PersonalityTraits.aurynDefault(),
  emotionalBaseline: EmotionState.neutral(),
  dialogStyle: DialogStyle.aurynDefault(),
);

// Modular uma emoção baseada na personalidade
final emotion = EmotionState(mood: 'sad', intensity: 1, valence: -1, arousal: 1);
final modulated = profile.modulateEmotion(emotion);
// Personalidade influencia como emoção é expressa

// Ajustar trait
final adjusted = profile.adjustTrait('openness', 0.10);

// Atualizar baseline emocional
final newBaseline = EmotionState(mood: 'warm', intensity: 1, valence: 1, arousal: 1);
final updated = profile.updateEmotionalBaseline(newBaseline);

// Preferências contextuais
final value = profile.getPreference<bool>('prefer_depth');
final withPref = profile.setPreference('new_pref', 'value');

// Compatibilidade entre perfis
final compatibility = profile1.compatibilityWith(profile2); // 0.0-1.0

// Serialização
final map = profile.toMap();
final restored = PersonalityProfile.fromMap(map);
```

### 4. BehaviorShaping

**Arquivo:** `lib/auryn_core/personality/behavior_shaping.dart`

Mapeia (Emoção + Personalidade + Contexto) → Diretiva Comportamental.

#### BehaviorContext:

Define o contexto da interação:
- **interactionType**: Tipo ('casual', 'support', 'learning', 'reflection')
- **userEnergy**: Energia aparente do usuário (0.0-1.0)
- **urgency**: Nível de urgência (0.0-1.0)
- **topicComplexity**: Complexidade do tópico (0.0-1.0)

#### BehavioralDirective:

Diretiva resultante que guia a resposta:
- **dialogStyle**: Estilo de diálogo ajustado
- **toneIndicators**: Lista de tons (ex: 'supportive', 'curious')
- **pacing**: Ritmo ('slow', 'moderate', 'fast')
- **responseStrategy**: Estratégia ('empathetic', 'elaborate', 'questioning', etc.)
- **emotionalEngagement**: Nível de engajamento emocional (0.0-1.0)
- **lengthFactor**: Fator multiplicador de comprimento da resposta
- **acknowledgeEmotion**: Se deve reconhecer emoção
- **priorityAspects**: Aspectos prioritários a abordar

#### Exemplo de Uso:

```dart
// Criar contexto
final context = BehaviorContext.casual();
final supportContext = BehaviorContext.support();
final learningContext = BehaviorContext.learning();

// Computar diretiva comportamental
final directive = BehaviorShaping.computeDirective(
  emotionState: currentEmotion,
  traits: personalityTraits,
  context: context,
);

// Usar diretiva
print('Pacing: ${directive.pacing}');
print('Strategy: ${directive.responseStrategy}');
print('Tones: ${directive.toneIndicators.join(", ")}');
print('Engagement: ${directive.emotionalEngagement}');

if (directive.acknowledgeEmotion) {
  // Incluir reconhecimento emocional na resposta
}

// Aplicar length factor
final baseLength = 100;
final targetLength = (baseLength * directive.lengthFactor).round();
```

### 5. PersonaManager

**Arquivo:** `lib/auryn_core/personality/persona_manager.dart`

Gerenciador central que controla perfis, troca, ajustes, e persistência opt-in.

#### Funcionalidades:

- Gerenciar múltiplos perfis de personalidade
- Trocar entre perfis
- Ajustar traços dinamicamente
- Modular emoções baseado no perfil atual
- Computar diretivas comportamentais
- Sistema de eventos/hooks
- Persistência local opt-in (Hive)

#### Exemplo de Uso:

```dart
// Inicializar
final manager = PersonaManager();
await manager.initialize();

// Obter perfil atual
final current = manager.currentProfile;
print('Current: ${current.name}');

// Listar perfis disponíveis
final profiles = manager.availableProfiles;
for (final profile in profiles) {
  print('- ${profile.name}');
}

// Trocar perfil
await manager.switchProfile('supportive');

// Ajustar trait
manager.adjustTrait('agreeableness', 0.05);

// Modular emoção
final emotion = EmotionState.neutral();
final modulated = manager.modulateEmotion(emotion);

// Computar comportamento
final directive = manager.computeBehavior(
  emotionState: currentEmotion,
  context: BehaviorContext.casual(),
);

// Adicionar perfil customizado
final custom = PersonalityProfile(...);
manager.addProfile(custom);

// Remover perfil
manager.removeProfile('custom');

// Exportar/Importar
final exported = manager.exportCurrentProfile();
manager.importProfile(profileData, setAsCurrent: true);

// Persistência opt-in
await manager.initialize(
  persistenceOptions: PersistenceOptions(
    enabled: true,
    autoSave: true,
  ),
);
```

### 6. PersonalityEvents

**Arquivo:** `lib/auryn_core/personality/personality_events.dart`

Sistema de eventos para reagir a mudanças de personalidade.

#### Tipos de Eventos:

1. **OnTraitAdjustment**: Disparado quando um traço é ajustado
2. **OnProfileShift**: Disparado quando o perfil é trocado
3. **OnBehaviorComputed**: Disparado quando uma diretiva é computada

#### Exemplo de Uso:

```dart
final manager = PersonaManager();
await manager.initialize();

// Registrar hook para ajuste de trait
manager.onTraitAdjustment((event) {
  print('Trait ${event.traitName} changed: '
        '${event.oldValue} → ${event.newValue}');
});

// Registrar hook para troca de perfil
manager.onProfileShift((event) {
  print('Profile changed: ${event.previousProfile?.name} '
        '→ ${event.newProfile.name}');
  
  // Ajustar UI, voz, etc.
  updateVoiceSettings(event.newProfile);
});

// Registrar hook para comportamento computado
manager.onBehaviorComputed((event) {
  print('Behavior: ${event.directive.responseStrategy}');
  print('Emotion: ${event.emotionMood}');
  print('Context: ${event.contextType}');
});

// Usar hooks pré-definidos
manager.hooks.onAnyEvent(PersonalityHookPresets.loggingHook);
```

## Integração com Emotion Core

A camada de personalidade integra-se perfeitamente com o Emotion Core (Phase 5):

```dart
// Inicializar ambos os sistemas
final emotionCore = EmotionCore();
await emotionCore.initialize();

final personaManager = PersonaManager();
await personaManager.initialize();

// Processar input
emotionCore.processInput("Estou muito feliz hoje!");

// Obter emoção atual
final emotion = emotionCore.currentState;

// Modular emoção baseada na personalidade
final modulated = personaManager.modulateEmotion(emotion);

// Computar comportamento
final context = BehaviorContext.casual();
final directive = personaManager.computeBehavior(
  emotionState: modulated,
  context: context,
);

// Gerar resposta usando diretiva
final response = generateResponse(
  input: userInput,
  emotion: modulated,
  directive: directive,
);

// Modular resposta emocionalmente
final final_response = emotionCore.modulateResponse(response);
```

## Fluxo Completo de Interação

```
1. User Input
      ↓
2. EmotionCore.processInput()
   → Detecta EmotionState
      ↓
3. PersonaManager.modulateEmotion()
   → Personalidade influencia emoção
      ↓
4. Criar BehaviorContext
   → Analisa tipo de interação
      ↓
5. PersonaManager.computeBehavior()
   → Gera BehavioralDirective
      ↓
6. Gerar Resposta
   → Aplica diretiva comportamental
      ↓
7. EmotionCore.modulateResponse()
   → Adiciona prefixos emocionais
      ↓
8. Resposta Final
```

## Persistência (Opt-in)

A persistência é **desabilitada por padrão** e requer opt-in explícito:

```dart
// Habilitar persistência
await manager.initialize(
  persistenceOptions: PersistenceOptions(
    enabled: true,          // Opt-in
    autoSave: true,         // Salvar automaticamente
    storagePrefix: 'auryn', // Prefixo da chave
  ),
);

// Persistência usa Hive local
// Dados salvos:
// - Lista de perfis
// - ID do perfil atual
// - Traços ajustados

// Limpar dados (se usuário desejar)
// await Hive.box('auryn_personality').clear();
```

## Exemplos de Uso

### Exemplo 1: Chat Casual

```dart
final manager = PersonaManager();
await manager.initialize();

// Input do usuário
final userInput = "Como você está?";

// Detectar emoção
emotionCore.processInput(userInput);
final emotion = emotionCore.currentState;

// Contexto casual
final context = BehaviorContext.casual();

// Computar comportamento
final directive = manager.computeBehavior(
  emotionState: emotion,
  context: context,
);

// Gerar resposta baseada na diretiva
// - Usar warmth = 0.75
// - Pacing = moderate
// - Strategy = balanced
```

### Exemplo 2: Suporte Emocional

```dart
// Trocar para modo supportive
await manager.switchProfile('supportive');

// Input do usuário indicando tristeza
final userInput = "Estou me sentindo muito triste...";

emotionCore.processInput(userInput);
final emotion = emotionCore.currentState; // mood: 'sad'

// Contexto de suporte
final context = BehaviorContext.support();

// Computar comportamento
final directive = manager.computeBehavior(
  emotionState: emotion,
  context: context,
);

// Diretiva resultante:
// - toneIndicators: ['compassionate', 'supportive']
// - responseStrategy: 'empathetic'
// - acknowledgeEmotion: true
// - Warmth aumentado
```

### Exemplo 3: Aprendizado

```dart
// Trocar para modo analytical
await manager.switchProfile('analytical');

// Input complexo
final userInput = "Explique-me sobre física quântica";

// Contexto de aprendizado
final context = BehaviorContext.learning();

// Computar comportamento
final directive = manager.computeBehavior(
  emotionState: EmotionState(mood: 'focused', ...),
  context: context,
);

// Diretiva resultante:
// - toneIndicators: ['instructive', 'thoughtful']
// - responseStrategy: 'elaborate'
// - Precision aumentado
// - Verbosity aumentado
```

## Boas Práticas

### 1. Sempre Inicializar

```dart
// ✅ Correto
await manager.initialize();
final profile = manager.currentProfile;

// ❌ Errado - lança StateError
final profile = manager.currentProfile;
```

### 2. Usar Hooks para Reações

```dart
// ✅ Correto - desacoplado
manager.onProfileShift((event) {
  updateUITheme(event.newProfile);
});

// ❌ Evitar - verificação constante
if (manager.currentProfile.id != lastProfileId) {
  updateUITheme(manager.currentProfile);
}
```

### 3. Modular Emoções Antes de Usar

```dart
// ✅ Correto
final emotion = emotionCore.currentState;
final modulated = manager.modulateEmotion(emotion);
// Use 'modulated'

// ⚠️ Perda de personalização
final emotion = emotionCore.currentState;
// Use 'emotion' diretamente
```

### 4. Criar Contextos Apropriados

```dart
// ✅ Correto - contexto específico
final context = BehaviorContext.support();

// ⚠️ Menos efetivo - contexto genérico
final context = BehaviorContext.casual();
```

## Testes

Os testes cobrem:

1. **personality_traits_test.dart**: Normalização, ajustes, serialização
2. **personality_profile_test.dart**: Modulação emocional, compatibilidade
3. **dialog_style_test.dart**: Ajustes de humor, labels
4. **behavior_shaping_test.dart**: Computação de diretivas, contextos
5. **persona_manager_test.dart**: Troca de perfis, eventos, persistência

Executar testes:

```bash
flutter test test/personality/
```

## Limitações e Considerações

1. **Simplicidade**: Sistema atual usa lógica baseada em regras. Para comportamentos mais sofisticados, considere ML.

2. **Idioma**: Implementação focada em português brasileiro. Adapte para outros idiomas.

3. **Persistência Opt-in**: Usuário deve explicitamente habilitar para salvar dados.

4. **Offline-First**: Todo processamento é local, sem dependências externas.

5. **Performance**: Cálculos são leves, mas podem ser otimizados para dispositivos muito limitados.

## Roadmap Futuro

- [ ] Aprendizado adaptativo baseado em feedback do usuário
- [ ] Troca automática de perfis baseada em contexto
- [ ] Suporte a múltiplos idiomas e normas culturais
- [ ] Visualização gráfica de traços de personalidade
- [ ] Templates de perfis para diferentes casos de uso
- [ ] Sincronização cross-device (opcional, opt-in)
- [ ] Integração com sistema de voz para ajuste de TTS

## Referências

- **Phase 5: Emotion Core** - Sistema emocional da AURYN
- **AURYN_PERSONALITY_FLOW.md** - Diagramas de fluxo detalhados
- **AURYN_BEHAVIOR_STANDARD.md** - Padrões comportamentais gerais

## Conclusão

O Personality Layer fornece à AURYN uma camada de personalidade sofisticada que:

- ✅ Mantém consistência comportamental
- ✅ Adapta-se a emoções e contextos
- ✅ Permite customização e troca de perfis
- ✅ Integra-se perfeitamente com Emotion Core
- ✅ Respeita privacidade (opt-in, offline)
- ✅ É extensível e modular

**"Código com consciência, privacidade com propósito, personalidade com coração."** 🌟

---

*Última atualização: 2025-12-05*  
*Versão: 1.0*  
*Fase: 6 - Personality Layer*
