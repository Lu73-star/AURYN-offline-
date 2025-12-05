# Phase 7: Memory Layer - Sistema de Memória da AURYN

## Visão Geral

O **Memory Layer** é o sistema de memória completo da AURYN, responsável por armazenar, recuperar e gerenciar memórias de curto e longo prazo. Este sistema permite que a AURYN:

- Armazene interações e experiências persistentemente (offline-first)
- Mantenha contexto de conversações recentes (memória episódica)
- Adapte traços de personalidade baseado em memórias
- Gerencie expiração automática de memórias antigas
- Busque e filtre memórias por múltiplos critérios
- Exporte e importe memórias para backup

## Objetivos

- **Persistência Offline**: Todo armazenamento é local usando Hive
- **Privacidade**: Nenhuma transmissão externa, sem internet
- **Eficiência**: Índices otimizados para busca rápida
- **Flexibilidade**: Múltiplas categorias e tags para organização
- **Adaptação**: Traços de personalidade emergem das memórias
- **Manutenção**: Expiração automática e limpeza de memórias antigas

## Arquitetura

```
MemoryManager (Facade)
    ├── LongTermMemory (Persistência de longo prazo)
    │   ├── MemoryRepository (Acesso a dados)
    │   │   ├── Hive Box (auryn_memories)
    │   │   └── MemoryIndex (Índices de busca)
    │   └── MemoryExpiration (Políticas de expiração)
    ├── EpisodicMemory (Memória de curto prazo)
    │   └── Lista FIFO de últimas N entradas
    └── MemoryTraits (Adaptação de personalidade)
        └── Traços aprendidos das memórias

Componentes de Suporte:
    ├── MemoryEntry (Estrutura de dados)
    ├── MemorySerializer (Serialização Hive)
    ├── MemoryScope (Categorias e filtros)
    └── MemoryExpiration (Gerenciamento de expiração)
```

## Componentes

### 1. MemoryEntry

**Arquivo:** `lib/auryn_core/memory/memory_entry.dart`

Estrutura fundamental de entrada de memória.

#### Propriedades:

- **id** (String): Identificador único (UUID v4)
- **timestamp** (DateTime): Quando foi criada
- **category** (String): Categoria ('interaction', 'emotion', 'learning', etc.)
- **emotionalWeight** (double): Peso emocional (-1.0 a 1.0)
- **content** (Map<String, dynamic>): Conteúdo da memória
- **tags** (List<String>): Tags para busca
- **lastUpdated** (DateTime?): Última atualização
- **accessCount** (int): Quantas vezes foi acessada
- **expiresAt** (DateTime?): Data de expiração

#### Exemplo de Uso:

```dart
// Criar entrada de interação
final entry = MemoryEntry.interaction(
  userInput: 'Como você está?',
  aurynResponse: 'Estou bem, obrigada por perguntar!',
  emotionalWeight: 0.5,
  tags: ['greeting', 'casual'],
);

// Criar entrada emocional
final emotion = MemoryEntry.emotion(
  mood: 'happy',
  intensity: 2,
  tags: ['positive'],
);

// Criar entrada de aprendizado
final learning = MemoryEntry.learning(
  topic: 'Flutter',
  insight: 'Widgets são imutáveis',
  tags: ['programming', 'flutter'],
);

// Verificar propriedades
print(entry.isPositive); // true
print(entry.ageInDays); // 0
print(entry.isExpired); // false

// Incrementar acesso
final updated = entry.incrementAccess();

// Serialização
final map = entry.toMap();
final restored = MemoryEntry.fromMap(map);
```

### 2. MemoryScope

**Arquivo:** `lib/auryn_core/memory/memory_scope.dart`

Sistema de categorização e filtros para memórias.

#### Categorias Predefinidas:

- **interaction**: Interações com o usuário
- **emotion**: Estados emocionais
- **learning**: Insights e aprendizados
- **personality**: Preferências e traços
- **context**: Informações contextuais
- **event**: Eventos e episódios
- **system**: Configurações do sistema

#### MemoryFilter:

```dart
// Filtro para memórias recentes
final recent = MemoryFilter.recent(days: 7, limit: 10);

// Filtro por categoria
final interactions = MemoryFilter.byCategory('interaction');

// Filtro por tags
final tagged = MemoryFilter.byTags(['greeting', 'casual']);

// Filtro por emoção
final positive = MemoryFilter.byEmotion(
  onlyPositive: true,
  minWeight: 0.5,
  limit: 20,
);

// Filtro customizado
final custom = MemoryFilter(
  categories: ['interaction', 'emotion'],
  requiredTags: ['important'],
  minEmotionalWeight: 0.3,
  fromDate: DateTime.now().subtract(Duration(days: 30)),
  orderBy: 'emotional_weight',
  ascending: false,
  limit: 50,
);
```

#### MemoryQuery Builder:

```dart
// Query builder fluente
final memories = await memoryManager.queryBuilder((query) => query
  .withCategories(['interaction'])
  .withTags(['greeting'])
  .withEmotionalWeight(min: 0.0, max: 1.0)
  .between(startDate, endDate)
  .orderBy('timestamp', ascending: false)
  .limit(10)
);
```

### 3. MemoryExpiration

**Arquivo:** `lib/auryn_core/memory/memory_expiration.dart`

Gerenciamento de expiração de memórias.

#### Políticas de Expiração:

1. **never**: Nunca expira
2. **afterDays**: Expira após N dias
3. **afterAccesses**: Expira após N acessos
4. **ifNotAccessedFor**: Expira se não acessada por N dias
5. **emotionalWeight**: Neutras expiram mais rápido

#### Políticas Pré-configuradas:

```dart
// Política padrão: neutras expiram em 30 dias
final standard = ExpirationPolicies.standard();

// Agressiva: todas expiram em 7 dias
final aggressive = ExpirationPolicies.aggressive();

// Conservadora: só expira se não acessada por 90 dias
final conservative = ExpirationPolicies.conservative();

// Balanceada: neutras em 30 dias, não acessadas em 60 dias
final balanced = ExpirationPolicies.balanced();

// Nunca expira
final never = ExpirationPolicies.never();
```

#### Exemplo de Uso:

```dart
final expiration = MemoryExpiration(configs: ExpirationPolicies.balanced());

// Verificar se deve expirar
if (expiration.shouldExpire(entry)) {
  // Remover memória
}

// Filtrar expiradas
final active = expiration.filterExpired(allMemories);

// Calcular data de expiração
final expiresAt = expiration.calculateExpirationDate(entry);
```

### 4. MemorySerializer

**Arquivo:** `lib/auryn_core/memory/memory_serializer.dart`

Serialização de memórias para Hive.

#### Funcionalidades:

- Serialização/Deserialização de MemoryEntry
- Salvamento em boxes do Hive
- Exportação/Importação JSON
- Validação de integridade
- Reparo de entradas corrompidas
- Índices para busca rápida

#### Exemplo de Uso:

```dart
// Abrir box
final box = await Hive.openBox(MemorySerializer.boxName);

// Salvar entrada
await MemorySerializer.saveToBox(box, entry);

// Carregar entrada
final loaded = MemorySerializer.loadFromBox(box, id);

// Salvar múltiplas
await MemorySerializer.saveManyToBox(box, entries);

// Carregar todas
final all = MemorySerializer.loadAllFromBox(box);

// Exportar para JSON
final json = MemorySerializer.exportToJson(entries);

// Importar de JSON
final imported = MemorySerializer.importFromJson(json);

// Validar integridade
final validation = await MemorySerializer.validateBox(box);
print('Integrity: ${validation['integrity_score']}');

// Reparar box
final repaired = await MemorySerializer.repairBox(box);
print('Repaired $repaired entries');
```

### 5. MemoryRepository

**Arquivo:** `lib/auryn_core/memory/memory_repository.dart`

Camada de acesso a dados para memórias.

#### Funcionalidades:

- CRUD completo de memórias
- Busca otimizada com índices
- Filtros avançados
- Estatísticas
- Validação e reparo
- Exportação/Importação

#### Exemplo de Uso:

```dart
final repository = MemoryRepository();
await repository.initialize();

// Salvar memória
await repository.save(entry);

// Buscar por ID
final found = await repository.findById(id);

// Buscar com filtro
final filter = MemoryFilter.byCategory('interaction');
final results = await repository.find(filter);

// Deletar
await repository.delete(id);

// Estatísticas
final stats = await repository.getStatistics();
print('Total: ${stats['total_entries']}');
print('Por categoria: ${stats['by_category']}');

// Validar e reparar
final validation = await repository.validateIntegrity();
if (validation['corrupted_entries'] > 0) {
  await repository.repair();
}

await repository.close();
```

### 6. EpisodicMemory

**Arquivo:** `lib/auryn_core/memory/episodic_memory.dart`

Memória de curto prazo (últimas N interações).

#### Características:

- Fila FIFO de tamanho limitado (padrão: 50)
- Acesso rápido a contexto recente
- Análise de padrões de interação
- Resumo de sentimento

#### Exemplo de Uso:

```dart
final episodic = EpisodicMemory(maxSize: 50);

// Adicionar interação
episodic.addInteraction(
  userInput: 'Olá!',
  aurynResponse: 'Olá! Como posso ajudar?',
  emotionalWeight: 0.3,
  tags: ['greeting'],
);

// Obter últimas N
final recent = episodic.getRecent(count: 10);

// Obter por categoria
final interactions = episodic.getByCategory('interaction');

// Resumo de sentimento
final sentiment = episodic.getSentimentSummary(lastN: 10);
print('Average weight: ${sentiment['average_weight']}');
print('Positive ratio: ${sentiment['positive_ratio']}');

// Padrões de interação
final patterns = episodic.getInteractionPatterns();
print('Emotional trend: ${patterns['emotional_trend']}');

// Buscar por conteúdo
final searched = episodic.search('Flutter');

// Limpar antigas
episodic.removeOlderThan(7); // Remove > 7 dias

// Estatísticas
final stats = episodic.getStatistics();
print(stats);
```

### 7. LongTermMemory

**Arquivo:** `lib/auryn_core/memory/long_term_memory.dart`

Armazenamento persistente de longo prazo.

#### Funcionalidades:

- Persistência com Hive
- Expiração automática
- Busca por tag, categoria, emoção
- Limpeza de memórias antigas
- Exportação/Importação

#### Exemplo de Uso:

```dart
final longTerm = LongTermMemory();
await longTerm.initialize();

// Salvar memória
await longTerm.save(entry);

// Buscar por ID
final found = await longTerm.find(id);

// Buscar por tag
final tagged = await longTerm.queryByTag('important', limit: 10);

// Buscar por categoria
final interactions = await longTerm.queryByCategory('interaction');

// Buscar por emoção
final positive = await longTerm.queryByEmotion(
  positive: true,
  minWeight: 0.5,
);

// Buscar recentes
final recent = await longTerm.queryRecent(days: 7);

// Mais acessadas
final popular = await longTerm.getMostAccessed(limit: 10);

// Deletar
await longTerm.delete(id);

// Limpar expiradas
final cleaned = await longTerm.cleanExpired();
print('Cleaned $cleaned expired memories');

// Limpar antigas
final removed = await longTerm.clearOlderThan(90);

// Estatísticas
final stats = await longTerm.getStatistics();

// Exportar/Importar
final json = await longTerm.export();
await longTerm.import(json);

await longTerm.close();
```

### 8. MemoryTraits

**Arquivo:** `lib/auryn_core/memory/memory_traits.dart`

Adaptação persistente de personalidade via memória.

#### Traços Rastreados:

1. **openness**: Abertura a novas ideias
2. **conscientiousness**: Conscienciosidade e organização
3. **extraversion**: Extroversão
4. **agreeableness**: Amabilidade e cooperação
5. **emotional_stability**: Estabilidade emocional
6. **warmth**: Calor e acolhimento
7. **curiosity**: Curiosidade
8. **playfulness**: Alegria e humor

#### Exemplo de Uso:

```dart
final traits = MemoryTraits.withDefaults(learningRate: 0.1);

// Aprender de uma memória
traits.learnFromMemory(entry);

// Aprender de múltiplas
traits.learnFromMemories(memories);

// Obter traço
final openness = traits.getTrait('openness');
print('Openness: ${openness?.score}');

// Obter score
final score = traits.getScore('curiosity');

// Obter todos os traços
final all = traits.getAllTraits();

// Obter dominantes (score > 0.6)
final dominant = traits.getDominantTraits();

// Obter fracos (score < 0.4)
final weak = traits.getWeakTraits();

// Ordenar por score
final sorted = traits.getTraitsSortedByScore(descending: true);

// Descrição textual
final description = traits.getPersonalityDescription();
print(description); 
// "muito aberta a novas ideias, bastante curiosa, calorosa e acolhedora."

// Estatísticas
final stats = traits.getStatistics();

// Serialização
final map = traits.toMap();
final restored = MemoryTraits.fromMap(map);
```

### 9. MemoryManager (Facade)

**Arquivo:** `lib/auryn_core/memory/memory_manager.dart`

Interface principal unificada do sistema de memória.

#### Exemplo de Uso Completo:

```dart
// Inicializar
final manager = MemoryManager();
await manager.initialize(
  episodicSize: 50,
  expirationPolicies: ExpirationPolicies.balanced(),
  traitLearningRate: 0.1,
);

// Armazenar interação
await manager.storeInteraction(
  userInput: 'Como você está?',
  aurynResponse: 'Estou bem, obrigada!',
  emotionalWeight: 0.5,
  tags: ['greeting', 'casual'],
);

// Armazenar memória genérica
await manager.store(entry);

// Buscar por tag
final tagged = await manager.queryByTag('important');

// Buscar por categoria
final interactions = await manager.queryByCategory('interaction');

// Buscar por emoção
final positive = await manager.queryByEmotion(positive: true);

// Buscar recentes
final recent = await manager.queryRecent(days: 7);

// Query builder
final filtered = await manager.queryBuilder((q) => q
  .withCategories(['interaction'])
  .withTags(['important'])
  .limit(10)
);

// Memória episódica
final episodes = manager.getRecentEpisodes(count: 10);
final sentiment = manager.getEpisodicSentiment();
final patterns = manager.getInteractionPatterns();

// Traços de personalidade
final traits = manager.getAllTraits();
final dominant = manager.getDominantTraits();
final personality = manager.getPersonalityDescription();

// Re-treinar traços
await manager.retrainTraits();

// Manutenção
await manager.cleanExpired();
await manager.clearOlderThan(90);
await manager.validateIntegrity();
await manager.repair();

// Exportar/Importar
final json = await manager.export();
await manager.import(json);

// Estatísticas
final stats = await manager.getStatistics();
final summary = await manager.getSummary();
print(summary);

// Fechar
await manager.close();
```

## Fluxo de Dados

```
1. User Input → MemoryManager.storeInteraction()
       ↓
2. Criar MemoryEntry
       ↓
3. Adicionar a EpisodicMemory (FIFO)
       ↓
4. Salvar em LongTermMemory
       ↓
5. LongTermMemory → MemoryRepository
       ↓
6. Calcular expiração (MemoryExpiration)
       ↓
7. Serializar (MemorySerializer)
       ↓
8. Persistir em Hive Box
       ↓
9. Atualizar índices (MemoryIndex)
       ↓
10. Aprender traços (MemoryTraits)

Busca:
User Query → MemoryFilter → MemoryRepository
     ↓
Usar índices para candidatos
     ↓
Aplicar filtros adicionais
     ↓
Filtrar expiradas
     ↓
Ordenar e limitar
     ↓
Retornar resultados
```

## Regras de Serialização

### MemoryEntry → Hive

1. **id**: String (UUID v4)
2. **timestamp**: ISO 8601 String
3. **category**: String
4. **emotional_weight**: Double
5. **content**: JSON String (codificado)
6. **tags**: List<String>
7. **last_updated**: ISO 8601 String (nullable)
8. **access_count**: Int
9. **expires_at**: ISO 8601 String (nullable)
10. **version**: Int (versão do formato)

### Boxes do Hive

- **auryn_memories**: Armazena todas as entradas de memória
- **auryn_memory_indices**: Armazena índices para busca rápida

### Índices

- **Categoria**: Map<String, Set<String>> (categoria → IDs)
- **Tags**: Map<String, Set<String>> (tag → IDs)

## Integração com Outros Módulos

### Com EmotionCore (Phase 5)

```dart
// EmotionCore processa input e gera estado emocional
emotionCore.processInput("Estou muito feliz!");
final emotion = emotionCore.currentState;

// Armazena interação com peso emocional
await memoryManager.storeInteraction(
  userInput: "Estou muito feliz!",
  aurynResponse: emotionCore.modulateResponse("Que bom!"),
  emotionalWeight: emotion.valence * (emotion.intensity / 3.0),
  tags: ['emotion', emotion.mood],
);
```

### Com PersonaManager (Phase 6)

```dart
// Traços de memória influenciam personalidade
final memoryTraits = memoryManager.getAllTraits();

// Ajustar traços de personalidade baseado em memória
for (final entry in memoryTraits.entries) {
  final traitName = entry.key;
  final score = entry.value.score;
  
  // Ajustar personalidade sutilmente
  personaManager.adjustTrait(traitName, (score - 0.5) * 0.1);
}
```

### Com Voice/TTS

```dart
// Usar padrões de interação para ajustar voz
final patterns = memoryManager.getInteractionPatterns();

if (patterns['emotional_trend'] == 'positive') {
  voiceEngine.setSpeed(1.05);
  voiceEngine.setPitch(1.05);
} else if (patterns['emotional_trend'] == 'negative') {
  voiceEngine.setSpeed(0.95);
  voiceEngine.setPitch(0.95);
}
```

## Persistência e Privacidade

### Offline-First

- **Todo o armazenamento é local** usando Hive
- **Nenhuma transmissão externa** de dados
- **Sem dependência de internet**
- **Privacidade completa** - dados nunca saem do dispositivo

### Opções de Privacidade

```dart
// Usuário pode limpar todas as memórias
await memoryManager.clearAll();

// Exportar para backup pessoal
final backup = await memoryManager.export();
// Salvar em arquivo local ou transferir manualmente

// Limpar memórias antigas
await memoryManager.clearOlderThan(90);

// Limpar apenas categoria específica
await longTerm.clearByCategory('system');
```

## Exemplos de Uso

### Exemplo 1: Conversa Casual

```dart
final manager = MemoryManager();
await manager.initialize();

// Usuário: "Olá!"
await manager.storeInteraction(
  userInput: "Olá!",
  aurynResponse: "Olá! Como você está?",
  emotionalWeight: 0.3,
  tags: ['greeting', 'casual'],
);

// Usuário: "Bem, e você?"
await manager.storeInteraction(
  userInput: "Bem, e você?",
  aurynResponse: "Estou ótima, obrigada!",
  emotionalWeight: 0.4,
  tags: ['greeting', 'reciprocal'],
);

// Obter contexto recente
final recent = manager.getRecentEpisodes(count: 5);

// Analisar sentimento da conversa
final sentiment = manager.getEpisodicSentiment();
// average_weight: 0.35, positive_ratio: 1.0
```

### Exemplo 2: Aprendizado Persistente

```dart
// Armazenar insight
final learning = MemoryEntry.learning(
  topic: 'Programação',
  insight: 'Flutter usa widgets imutáveis',
  emotionalWeight: 0.0,
  tags: ['programming', 'flutter', 'widgets'],
);
await manager.store(learning);

// Mais tarde, buscar insights sobre Flutter
final flutterInsights = await manager.queryByTag('flutter');

// Traços se adaptam
final traits = manager.getAllTraits();
// curiosity e openness aumentam devido a memórias de aprendizado
```

### Exemplo 3: Suporte Emocional

```dart
// Usuário expressa tristeza
await manager.storeInteraction(
  userInput: "Estou me sentindo triste...",
  aurynResponse: "Sinto muito que você esteja assim. Quer conversar?",
  emotionalWeight: -0.6,
  tags: ['emotional', 'sad', 'support'],
);

// Buscar memórias de suporte anteriores
final supportMemories = await manager.queryByTag('support');

// Verificar se houve padrão de tristeza recente
final negativeRecent = await manager.queryByEmotion(
  positive: false,
  minWeight: -1.0,
  maxWeight: -0.3,
);

// Ajustar tom baseado no histórico
if (negativeRecent.length > 3) {
  // Manter tom suportivo e empático
}
```

### Exemplo 4: Manutenção Automática

```dart
import 'dart:async';

// Limpar expiradas a cada hora
Timer.periodic(Duration(hours: 1), (_) async {
  final cleaned = await manager.cleanExpired();
  if (cleaned > 0) {
    print('Limpou $cleaned memórias expiradas');
  }
});

// Validar integridade diariamente
Timer.periodic(Duration(days: 1), (_) async {
  final validation = await manager.validateIntegrity();
  
  if (validation['corrupted_entries'] > 0) {
    print('Reparando ${validation['corrupted_entries']} entradas...');
    await manager.repair();
  }
});

// Backup semanal
Timer.periodic(Duration(days: 7), (_) async {
  final backup = await manager.export();
  // Salvar backup localmente
  await saveToLocalStorage(backup);
});
```

## Boas Práticas

### 1. Sempre Inicializar

```dart
// ✅ Correto
await manager.initialize();
await manager.storeInteraction(...);

// ❌ Errado - lança StateError
manager.storeInteraction(...);
```

### 2. Usar Tags Consistentes

```dart
// ✅ Correto - tags consistentes
tags: ['greeting', 'casual']
tags: ['learning', 'programming']

// ⚠️ Evitar - tags inconsistentes
tags: ['Greeting', 'CASUAL'] // Case-sensitive
```

### 3. Pesos Emocionais Apropriados

```dart
// ✅ Correto - peso proporcional
emotionalWeight: 0.5  // Levemente positivo
emotionalWeight: -0.8 // Bastante negativo

// ❌ Errado - fora do range
emotionalWeight: 1.5  // Lança assertion error
```

### 4. Limpeza Regular

```dart
// ✅ Correto - limpeza periódica
Timer.periodic(Duration(hours: 1), (_) {
  manager.cleanExpired();
});

// ⚠️ Evitar - acúmulo de memórias expiradas
```

### 5. Validar Importação

```dart
// ✅ Correto - validar após importar
try {
  await manager.import(jsonString);
  await manager.validateIntegrity();
} catch (e) {
  print('Erro ao importar: $e');
}
```

## Limitações e Considerações

1. **Armazenamento Local**: Limitado pela capacidade do dispositivo
2. **Busca por Conteúdo**: Busca simples por substring, não semântica
3. **Traços de Personalidade**: Baseado em regras simples, não ML
4. **Índices**: Mantidos em memória, podem consumir RAM em grandes volumes
5. **Expiração**: Baseada em políticas estáticas, não adaptativa

## Roadmap Futuro

- [ ] Busca semântica com embeddings
- [ ] Compressão de memórias antigas
- [ ] Clustering de memórias similares
- [ ] Sumarização automática de períodos
- [ ] Gráfico de conhecimento (knowledge graph)
- [ ] Aprendizado adaptativo de expiração
- [ ] Sincronização cross-device (opt-in)
- [ ] Visualização de memórias em timeline
- [ ] Detecção de padrões temporais
- [ ] Recomendações baseadas em memória

## Referências

- **Phase 5: Emotion Core** - Sistema emocional da AURYN
- **Phase 6: Personality Layer** - Sistema de personalidade da AURYN
- **Hive Documentation** - https://docs.hivedb.dev/

## Conclusão

O Memory Layer fornece à AURYN um sistema de memória sofisticado que:

- ✅ Armazena interações persistentemente (offline)
- ✅ Mantém contexto recente (episódico)
- ✅ Adapta personalidade via traços
- ✅ Gerencia expiração automática
- ✅ Permite busca e filtragem flexível
- ✅ Respeita privacidade (local-only)
- ✅ É extensível e modular

**"Código com consciência, privacidade com propósito, memória com significado."** 🌟

---

*Última atualização: 2025-12-05*  
*Versão: 1.0*  
*Fase: 7 - Memory Layer*
