# Memory Layer Tests

Testes unitários para o sistema de memória da AURYN (Phase 7).

## Estrutura de Testes

### memory_manager_test.dart
**33 casos de teste** cobrindo o MemoryManager (facade principal):

- Inicialização e configuração
- Armazenamento de interações
- Memória episódica (FIFO, tamanho máximo)
- Consultas por tag, categoria, emoção
- Query builder
- Sentimento episódico
- Padrões de interação
- Traços de personalidade
- Exportação/Importação
- Validação de integridade
- Estatísticas e resumos

### long_term_memory_test.dart
**35 casos de teste** cobrindo LongTermMemory e persistência:

- Operações CRUD (save, find, delete)
- Consultas com filtros diversos
- Busca por tag, categoria, emoção
- Memórias mais acessadas
- Expiração automática
- Limpeza de memórias antigas
- Exportação/Importação
- Validação e reparo de integridade
- Contador de acessos
- Políticas de expiração

### memory_traits_test.dart
**47 casos de teste** cobrindo MemoryTraits e adaptação de personalidade:

- PersonalityTrait (criação, atualização, serialização)
- MemoryTraits com traços padrão (Big Five + extras)
- Aprendizado de memórias (interação, aprendizado, emoção)
- Aprendizado baseado em tags (curious, supportive, playful)
- Traços dominantes e fracos
- Ordenação por score
- Reset de traços
- Descrição textual de personalidade
- Estatísticas
- Learning rate customizado
- Range clamping (0.0-1.0)

## Executar Testes

```bash
# Todos os testes de memória
flutter test test/memory/

# Teste específico
flutter test test/memory/memory_manager_test.dart

# Com cobertura
flutter test --coverage test/memory/
```

## Cobertura Esperada

- **MemoryEntry**: 100% (estrutura de dados simples)
- **MemoryScope**: 100% (enums e constantes)
- **MemoryExpiration**: 95% (políticas e filtros)
- **MemorySerializer**: 90% (serialização/deserialização)
- **MemoryRepository**: 85% (CRUD e consultas)
- **EpisodicMemory**: 90% (FIFO e consultas)
- **LongTermMemory**: 85% (persistência e expiração)
- **MemoryTraits**: 90% (adaptação de traços)
- **MemoryManager**: 80% (integração complexa)

## Dependências de Teste

Os testes usam:
- `flutter_test`: Framework de testes do Flutter
- `hive`: Para persistência (mockado em testes)
- Hive usa diretórios temporários para testes (`/tmp/hive_test_*`)

## Notas Importantes

1. **Limpeza de Hive**: Cada teste limpa suas boxes do Hive no tearDown
2. **Timestamps**: Alguns testes usam datas manipuladas para testar funcionalidades temporais
3. **Políticas de Expiração**: Testes usam políticas customizadas (geralmente "never") para controle
4. **Learning Rate**: Testes usam learning rate maior (0.2) para mudanças mais visíveis
5. **Episodic Size**: Testes usam tamanho menor (10) para facilitar validação

## Padrões de Teste

### Setup Típico
```dart
setUp(() async {
  Hive.init('/tmp/hive_test_${DateTime.now().millisecondsSinceEpoch}');
  manager = MemoryManager();
  await manager.initialize();
});

tearDown(() async {
  await manager.close();
  await Hive.deleteFromDisk();
});
```

### Asserções Comuns
```dart
expect(result, isNotNull);
expect(result.length, equals(expected));
expect(value, greaterThan(threshold));
expect(trait.score, closeTo(expected, delta));
expect(() => operation(), throwsStateError);
```

## Troubleshooting

### Erro: "Hive box already open"
- **Causa**: Box não foi fechada no teste anterior
- **Solução**: Garantir que `await manager.close()` está no tearDown

### Erro: "StateError: not initialized"
- **Causa**: Esqueceu de chamar `await manager.initialize()`
- **Solução**: Adicionar inicialização no setUp

### Testes falham com "corrupted entries"
- **Causa**: Dados residuais de teste anterior
- **Solução**: `await Hive.deleteFromDisk()` no tearDown

### Timestamps não batem
- **Causa**: Testes de expiração usando datas relativas
- **Solução**: Usar `DateTime.now()` consistentemente ou mockar

## Integração com CI/CD

Para CI/CD, adicionar ao pipeline:

```yaml
test:
  script:
    - flutter test test/memory/ --coverage
    - lcov --summary coverage/lcov.info
```

## Manutenção

Ao adicionar novos recursos:
1. Adicionar testes unitários para o novo código
2. Atualizar testes existentes se houver breaking changes
3. Manter cobertura acima de 80%
4. Documentar casos especiais neste README

---

*Última atualização: 2025-12-05*  
*Total de testes: 115*  
*Fase: 7 - Memory Layer*
