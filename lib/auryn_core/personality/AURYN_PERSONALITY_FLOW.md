# AURYN Personality Flow

## Overview

This document describes the complete flow of AURYN's Personality Layer (Phase 6) and its integration with the Emotion Core (Phase 5).

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                      AURYN PERSONALITY LAYER                    │
└─────────────────────────────────────────────────────────────────┘
                                 │
                    ┌────────────┴────────────┐
                    │                         │
          ┌─────────▼──────────┐    ┌────────▼─────────┐
          │  PersonaManager    │    │  Personality     │
          │   (Singleton)      │◄───┤    Events        │
          └─────────┬──────────┘    └──────────────────┘
                    │
                    │ manages
                    │
          ┌─────────▼──────────┐
          │ PersonalityProfile │
          │  - id, name        │
          │  - traits          │
          │  - emotionalBase   │
          │  - dialogStyle     │
          └─────────┬──────────┘
                    │
        ┌───────────┼───────────┐
        │           │           │
  ┌─────▼─────┐ ┌──▼───────┐ ┌─▼──────────┐
  │Personality│ │ Dialog   │ │  Emotion   │
  │  Traits   │ │  Style   │ │  Baseline  │
  │  (8 dims) │ │ (6 dims) │ │  (State)   │
  └───────────┘ └──────────┘ └────────────┘
```

## Component Flow

### 1. Initialization Flow

```
User/System Start
      ↓
PersonaManager.initialize()
      ↓
Load default profiles:
  - AURYN Default
  - Supportive Mode
  - Analytical Mode
      ↓
[Optional] Load from storage
      ↓
Set currentProfile
      ↓
Ready for use
```

### 2. Behavior Computation Flow

```
User Input → EmotionCore
      ↓
EmotionState detected
      ↓
BehaviorContext created
  - interactionType
  - userEnergy
  - urgency
  - topicComplexity
      ↓
PersonaManager.computeBehavior()
      ↓
BehaviorShaping.computeDirective()
      ├─→ Combine EmotionState
      ├─→ Apply PersonalityTraits
      └─→ Consider BehaviorContext
      ↓
BehavioralDirective
  - dialogStyle (adjusted)
  - toneIndicators
  - pacing
  - responseStrategy
  - emotionalEngagement
  - lengthFactor
  - priorityAspects
      ↓
[Event] OnBehaviorComputed fired
      ↓
Response Generation
```

### 3. Emotion Integration Flow

```
EmotionCore.processInput(text)
      ↓
EmotionState computed
      ↓
PersonaManager.modulateEmotion(state)
      ↓
PersonalityProfile.modulateEmotion()
  ├─→ High neuroticism → amplify negative
  ├─→ Low neuroticism → dampen extreme
  ├─→ High agreeableness → bias positive
  ├─→ High extraversion → increase arousal
  └─→ Low extraversion → decrease arousal
      ↓
Modulated EmotionState
      ↓
Applied to response
```

### 4. Profile Switching Flow

```
Trigger (manual/automatic)
      ↓
PersonaManager.switchProfile(id)
      ↓
Validate profile exists
      ↓
previousProfile ← currentProfile
      ↓
currentProfile ← newProfile
      ↓
[Event] OnProfileShift fired
  - previousProfile
  - newProfile
  - reason
      ↓
[Optional] Save to storage
      ↓
Profile active
```

### 5. Trait Adjustment Flow

```
Adjustment request
      ↓
PersonaManager.adjustTrait(name, delta)
      ↓
oldValue ← currentProfile.traits.getTrait(name)
      ↓
newTraits ← traits.adjustTrait(name, delta)
  - Clamp to [0.0, 1.0]
      ↓
newProfile ← profile.copyWith(traits: newTraits)
      ↓
currentProfile ← newProfile
      ↓
[Event] OnTraitAdjustment fired
  - traitName
  - oldValue
  - newValue
  - delta
      ↓
[Optional] Save to storage
      ↓
Trait updated
```

## Integration Points

### With Emotion Core

```
┌────────────────┐         ┌──────────────────┐
│  Emotion Core  │◄───────►│ Personality Layer│
└────────────────┘         └──────────────────┘
        │                           │
        │ EmotionState              │ modulateEmotion()
        ├──────────────────────────►│
        │                           │
        │ Modulated EmotionState    │
        │◄──────────────────────────┤
        │                           │
        │ currentState              │ computeBehavior()
        ├──────────────────────────►│
        │                           │
        │ BehavioralDirective       │
        │◄──────────────────────────┤
```

### With Response Generation

```
Input Processing
      ↓
Emotion Detection
      ↓
┌─────────────────────────────┐
│  Personality Integration    │
│                             │
│  1. Modulate Emotion        │
│  2. Compute Behavior        │
│  3. Apply Dialog Style      │
│  4. Determine Strategy      │
└─────────────────────────────┘
      ↓
Response Templates
      ↓
Apply BehavioralDirective:
  - Adjust warmth/tone
  - Set pacing
  - Choose strategy
  - Apply length factor
      ↓
Generated Response
```

## Event System

### Event Types and Flow

```
PersonalityEvents
      │
      ├─→ OnTraitAdjustment
      │   └─ Fired when: trait value changes
      │
      ├─→ OnProfileShift
      │   └─ Fired when: profile switches
      │
      └─→ OnBehaviorComputed
          └─ Fired when: directive computed
```

### Hook Registration

```
PersonaManager.initialize()
      ↓
Register hooks:
      │
      ├─→ onTraitAdjustment((event) {
      │     // React to trait changes
      │     // Update UI, log, etc.
      │   })
      │
      ├─→ onProfileShift((event) {
      │     // React to profile changes
      │     // Update voice, UI theme, etc.
      │   })
      │
      └─→ onBehaviorComputed((event) {
          // React to behavior computation
          // Adjust TTS, logging, etc.
        })
```

## Dialog Style Application

### Mood-Based Adjustments

```
DialogStyle.aurynDefault()
      ↓
adjustForMood(emotionState.mood)
      │
      ├─ 'happy'     → ↑warmth, ↑cadence, ↑expressiveness
      ├─ 'sad'       → ↑warmth, ↓cadence, ↓expressiveness
      ├─ 'calm'      → ↑warmth, ↓cadence, ↑precision
      ├─ 'anxious'   → ↑warmth, ↓cadence, ↑precision, ↓verbosity
      ├─ 'excited'   → ↑cadence, ↑expressiveness, ↓formality
      └─ 'reflective'→ ↓cadence, ↑precision, ↑verbosity
      ↓
adjustForIntensity(emotionState.intensity)
      ↓
Final DialogStyle applied
```

### Trait-to-Style Mapping

```
PersonalityTraits → DialogStyle

warmth        = agreeableness × 0.7 + extraversion × 0.3
precision     = conscientiousness × 0.6 + intellectualism × 0.4
cadence       = extraversion × 0.5 + (1 - neuroticism) × 0.3
expressiveness= extraversion × 0.4 + playfulness × 0.4 + openness × 0.2
formality     = conscientiousness × 0.5 + (1 - playfulness) × 0.3
verbosity     = intellectualism × 0.5 + conscientiousness × 0.3
```

## Complete Interaction Flow

```
1. User Input
      ↓
2. Emotion Detection (EmotionCore)
      ↓
3. Emotion Modulation (PersonalityProfile)
      ↓
4. Context Analysis
   - Interaction type
   - User energy
   - Urgency
   - Topic complexity
      ↓
5. Behavior Computation
   - Combine emotion + traits + context
   - Generate BehavioralDirective
      ↓
6. Dialog Style Application
   - Apply mood adjustments
   - Apply intensity adjustments
      ↓
7. Response Strategy Selection
   - empathetic / elaborate / questioning / etc.
      ↓
8. Response Generation
   - Apply tone indicators
   - Apply pacing
   - Apply length factor
      ↓
9. Response Output
```

## Persistence Flow (Opt-in)

```
PersistenceOptions(enabled: true)
      ↓
On profile change / trait adjustment:
      ↓
Auto-save check
      ↓
[If enabled]
      ↓
Serialize profiles
      ↓
Save to Hive storage
  - Key: 'auryn_personality'
  - Data: {profiles, currentId}
      ↓
Persisted

On startup:
      ↓
[If persistence enabled]
      ↓
Load from Hive storage
      ↓
Deserialize profiles
      ↓
Set currentProfile
      ↓
Ready with saved state
```

## Privacy Considerations

- **Opt-in Only**: Persistence is disabled by default
- **Local Storage**: All data stored locally using Hive
- **No External Calls**: Everything runs offline
- **User Control**: Users can clear/export profiles at any time
- **Transparent**: All personality data is accessible and modifiable

## Performance Optimization

### Lazy Loading
- Profiles loaded only when needed
- Traits computed on-demand

### Caching
- Current profile cached in memory
- Dialog style cached until profile change

### Event Batching
- Multiple trait adjustments can be batched
- Events fired after batch completion

## Error Handling

```
Try: Operation
      ↓
Catch: Error
      ↓
Log error
      ↓
Notify hooks (if registered)
      ↓
Fallback to safe defaults
      ↓
Continue operation
```

## Testing Strategy

### Unit Tests
- Trait normalization and clamping
- Emotion modulation logic
- Dialog style adjustments
- Behavior directive computation
- Profile serialization/deserialization

### Integration Tests
- Emotion Core + Personality integration
- Profile switching with event hooks
- End-to-end behavior computation

### Edge Cases
- Invalid trait values
- Missing profile data
- Extreme emotion states
- Concurrent trait adjustments

## Future Enhancements

1. **Learning**: Adapt traits based on user feedback
2. **Context-Aware Switching**: Auto-switch profiles based on interaction patterns
3. **Multi-Language**: Support for different cultural personality norms
4. **Advanced Modulation**: ML-based emotion modulation
5. **Personality Visualization**: UI for viewing/editing traits
6. **Import/Export**: Share personality profiles

---

*Last Updated: 2025-12-05*  
*Phase: 6 - Personality Layer*  
*Version: 1.0*
