# Personality Layer Tests

## Overview

This directory contains comprehensive tests for AURYN's Personality Layer (Phase 6).

## Test Files

### 1. personality_traits_test.dart

Tests for `PersonalityTraits` class:
- ✅ Creating traits with valid values
- ✅ Validation of trait ranges (0.0-1.0)
- ✅ AURYN default traits
- ✅ Serialization/deserialization
- ✅ Value normalization from different types
- ✅ copyWith functionality
- ✅ Individual trait adjustment
- ✅ Clamping to valid ranges
- ✅ Getting trait values by name
- ✅ Trait similarity calculation
- ✅ Equals and hashCode implementation

**Total Tests**: 15+

### 2. personality_profile_test.dart

Tests for `PersonalityProfile` class:
- ✅ Creating default AURYN profile
- ✅ Creating supportive profile
- ✅ Creating analytical profile
- ✅ Serialization/deserialization
- ✅ copyWith functionality
- ✅ Emotion modulation based on neuroticism
- ✅ Emotion modulation based on agreeableness
- ✅ Emotion modulation based on extraversion
- ✅ Trait adjustment
- ✅ Emotional baseline updates
- ✅ Dialog style updates
- ✅ Contextual preferences
- ✅ Profile compatibility calculation
- ✅ Equals and hashCode implementation

**Total Tests**: 18+

### 3. dialog_style_test.dart

Tests for `DialogStyle` class:
- ✅ Creating neutral style
- ✅ Creating AURYN default style
- ✅ Value validation
- ✅ Serialization/deserialization
- ✅ Value normalization
- ✅ copyWith functionality
- ✅ Mood adjustments (happy, sad, calm, anxious, excited, reflective)
- ✅ Unknown mood handling
- ✅ Intensity adjustments
- ✅ Descriptive labels
- ✅ Value clamping
- ✅ Equals and hashCode implementation

**Total Tests**: 16+

### 4. behavior_shaping_test.dart

Tests for `BehaviorShaping` and related classes:
- ✅ BehaviorContext creation (casual, support, learning)
- ✅ Context serialization
- ✅ Basic behavioral directive computation
- ✅ Dialog style adjustment for emotions
- ✅ Tone indicators for positive emotions
- ✅ Tone indicators for negative emotions
- ✅ Context-based tone indicators
- ✅ Pacing determination
- ✅ Response strategy selection
- ✅ Emotional engagement calculation
- ✅ acknowledgeEmotion flag
- ✅ Length factor calculation
- ✅ Priority aspects determination
- ✅ Directive serialization

**Total Tests**: 20+

### 5. persona_manager_test.dart

Tests for `PersonaManager` class:
- ✅ Manager initialization
- ✅ StateError when not initialized
- ✅ Default profiles availability
- ✅ Getting profiles by ID
- ✅ Adding custom profiles
- ✅ Removing profiles
- ✅ Profile switching
- ✅ OnProfileShift event firing
- ✅ Trait adjustment
- ✅ OnTraitAdjustment event firing
- ✅ Current profile updates
- ✅ Emotion modulation
- ✅ Behavioral directive computation
- ✅ OnBehaviorComputed event firing
- ✅ Profile export/import
- ✅ Multiple callbacks
- ✅ PersistenceOptions

**Total Tests**: 20+

## Running Tests

### Run All Personality Tests

```bash
flutter test test/personality/
```

### Run Specific Test File

```bash
flutter test test/personality/personality_traits_test.dart
flutter test test/personality/personality_profile_test.dart
flutter test test/personality/dialog_style_test.dart
flutter test test/personality/behavior_shaping_test.dart
flutter test test/personality/persona_manager_test.dart
```

### Run with Coverage

```bash
flutter test --coverage test/personality/
```

## Test Coverage

The test suite provides comprehensive coverage of:

### Core Functionality
- ✅ Trait normalization and validation
- ✅ Profile creation and management
- ✅ Dialog style adjustments
- ✅ Behavior directive computation
- ✅ Profile switching
- ✅ Event system

### Edge Cases
- ✅ Invalid input values
- ✅ Out-of-range values
- ✅ Null values
- ✅ Type conversions
- ✅ Uninitialized state access
- ✅ Unknown trait/mood names

### Integration
- ✅ Emotion modulation
- ✅ Context-based behavior
- ✅ Event propagation
- ✅ Multiple callbacks
- ✅ Profile compatibility

### Data Handling
- ✅ Serialization
- ✅ Deserialization
- ✅ Data normalization
- ✅ Import/export

## Test Patterns

### Standard Test Structure

```dart
group('ComponentName', () {
  late ComponentType component;

  setUp(() {
    // Setup before each test
    component = ComponentType();
  });

  tearDown(() {
    // Cleanup after each test
  });

  test('should do something', () {
    // Test implementation
    expect(actual, matcher);
  });
});
```

### Event Testing Pattern

```dart
test('should fire event on action', () {
  EventType? capturedEvent;

  manager.onEventType((event) {
    capturedEvent = event;
  });

  // Trigger action
  manager.doSomething();

  // Verify event
  expect(capturedEvent, isNotNull);
  expect(capturedEvent!.property, expectedValue);
});
```

## Test Assertions

Common matchers used:
- `equals(value)` - Exact equality
- `isNotNull` - Not null check
- `isTrue/isFalse` - Boolean checks
- `greaterThan(value)` - Numeric comparison
- `lessThan(value)` - Numeric comparison
- `contains(value)` - Collection/string contains
- `throwsStateError` - Exception checking
- `throwsArgumentError` - Exception checking
- `isA<Type>()` - Type checking

## Best Practices

### 1. Isolated Tests
Each test should be independent and not rely on the state from other tests.

### 2. Clear Descriptions
Test descriptions should clearly state what is being tested:
```dart
test('deve ajustar trait e atualizar lastModified', () { ... });
```

### 3. Setup and Teardown
Use `setUp()` and `tearDown()` to manage test state:
```dart
setUp(() async {
  manager = PersonaManager();
  await manager.reset();
  await manager.initialize();
});
```

### 4. Edge Case Testing
Always test boundary conditions:
- Minimum values
- Maximum values
- Null values
- Invalid inputs

### 5. Event Testing
Verify events are fired correctly:
```dart
manager.onProfileShift((event) {
  capturedEvent = event;
});
// ... trigger action
expect(capturedEvent, isNotNull);
```

## Continuous Integration

These tests are designed to run in CI/CD pipelines:

```yaml
# Example CI configuration
test:
  script:
    - flutter test test/personality/
  coverage: '/lines.*: \d+\.\d+%/'
```

## Troubleshooting

### Tests Timing Out

If tests timeout, increase the timeout:
```dart
test('slow operation', () async {
  // ...
}, timeout: Timeout(Duration(seconds: 30)));
```

### Async Issues

Ensure all async operations are properly awaited:
```dart
test('async operation', () async {
  await manager.initialize();
  // ...
});
```

### State Pollution

If tests affect each other, ensure proper cleanup:
```dart
tearDown(() async {
  await manager.reset();
});
```

## Adding New Tests

When adding new features to the Personality Layer:

1. Create test file: `feature_name_test.dart`
2. Follow existing test patterns
3. Cover all public methods
4. Test edge cases
5. Test integration points
6. Run and verify tests pass
7. Update this README

## Contributing

When contributing tests:
- Follow Dart/Flutter testing conventions
- Use Portuguese for test descriptions (matching project language)
- Ensure tests are deterministic
- Add comments for complex test logic
- Update test counts in this README

## Related Documentation

- [Phase 6 Personality Documentation](../../docs/PHASE_6_PERSONALITY.md)
- [Personality Flow Diagrams](../../lib/auryn_core/personality/AURYN_PERSONALITY_FLOW.md)
- [Emotion Core Tests](../emotion/README_TEST.md)

---

**Total Test Count**: 89+ tests across 5 files

*Last Updated: 2025-12-05*  
*Phase: 6 - Personality Layer*
