# Fase 4 — Awareness Layer

## Diagrama de responsabilidades

- **AwarenessCore** <-> ContextManager
              |       <-> ShortTermMemory
              |       <-> EpisodicMemory (opt-in)
              |       <-> PersonalityController
              |       <-> IntentFilter
              |       <-> VoiceHooks

## Exemplo de uso

```dart
final awareness = AwarenessCore();
awareness.initialize();
final ctx = awareness.contextManager.getCurrentContext();
awareness.handleIntent('fala', {...});
```

## Fluxo de privacidade

- Todo registro de memória episódica exige opt-in.
- Nada é enviado para servidores externos.
- Configurações de privacidade e consentimento devem ser documentadas.

## Testes

- Testes básicos para AwarenessCore e ContextManager.
- dart analyze executado e clean.

## TODO

- Implementar rotinas concretas nas próximas fases.
