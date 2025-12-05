# Emotion Core - Instruções de Teste

## Executar Testes

Para executar todos os testes do Emotion Core:

```bash
flutter test test/emotion/
```

Para executar testes individuais:

```bash
# Testar EmotionCore
flutter test test/emotion/emotion_core_test.dart

# Testar EmotionRegulator
flutter test test/emotion/emotion_regulator_test.dart

# Testar EmotionProfile
flutter test test/emotion/emotion_profile_test.dart
```

## Cobertura de Testes

Os testes cobrem:

### emotion_core_test.dart
- Inicialização do sistema
- Processamento de inputs
- Modulação de respostas
- Aplicação de decaimento
- Reset ao baseline
- Atualização de baseline
- Estatísticas do perfil
- Histórico recente
- Análise de sentimento
- Ajuste de intensidade
- Emoções customizadas
- Limpeza de histórico
- Exportação/importação de perfil
- Sistema de hooks (todos os tipos)
- Informações de debug
- Reset completo

### emotion_regulator_test.dart
- Interpretação de inputs (todas as emoções)
- Regulação de transições (diretas e graduais)
- Aplicação de decaimento
- Modulação de respostas (todos os humores)
- Ajuste de intensidade
- Criação de estados customizados
- Análise de sentimento (positivo, negativo, neutro)

### emotion_profile_test.dart
- Criação de perfil (padrão e customizado)
- Adição de estados ao histórico
- Atualização de frequência
- Limite de histórico
- Estado atual
- Humor dominante
- Cálculo de valência geral
- Identificação de tendências (positiva, negativa, neutra)
- Histórico recente
- Limpeza de histórico
- Atualização de baseline
- Estatísticas
- Serialização/deserialização
- Cálculo de duração média

## Nota

O Flutter SDK não estava disponível no ambiente de desenvolvimento no momento da criação destes testes. Todos os testes foram escritos seguindo as melhores práticas do Dart 3.x e devem funcionar corretamente quando executados em um ambiente com Flutter SDK instalado.

## Problemas Conhecidos

Se você encontrar erros ao executar os testes, verifique:

1. **Flutter SDK instalado**: `flutter --version`
2. **Dependências instaladas**: `flutter pub get`
3. **Package imports corretos**: Verifique se o nome do package no `pubspec.yaml` está correto
4. **Dart SDK atualizado**: Versão >= 2.17.0

## Estrutura Esperada

```
test/emotion/
├── emotion_core_test.dart       (291 linhas, 25+ testes)
├── emotion_regulator_test.dart  (370 linhas, 30+ testes)
├── emotion_profile_test.dart    (318 linhas, 25+ testes)
└── README_TEST.md               (este arquivo)
```

## Relatório de Testes

Após executar os testes, você deve ver:

```
00:xx +80: All tests passed!
```

Se algum teste falhar, o relatório mostrará:
- Nome do teste que falhou
- Motivo da falha
- Stack trace para debugging

## Debugging

Para debugging mais detalhado:

```bash
# Verbose output
flutter test test/emotion/ --verbose

# Teste específico
flutter test test/emotion/emotion_core_test.dart --name "deve inicializar"
```

## Integração Contínua

Adicione ao seu workflow de CI:

```yaml
- name: Run Emotion Core tests
  run: flutter test test/emotion/
```
