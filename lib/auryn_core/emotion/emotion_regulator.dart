/// lib/auryn_core/emotion/emotion_regulator.dart
/// Regulador emocional da AURYN - gerencia transições e modulação emocional.
/// 
/// O EmotionRegulator é responsável por:
/// - Interpretar inputs e determinar emoções apropriadas
/// - Regular transições entre estados emocionais (evita mudanças bruscas)
/// - Modular respostas textuais baseadas no estado emocional
/// - Aplicar decaimento emocional (retorno ao baseline ao longo do tempo)

import 'emotion_state.dart';
import 'emotion_profile.dart';

class EmotionRegulator {
  /// Perfil emocional associado
  final EmotionProfile profile;

  /// Taxa de decaimento emocional (0.0 = nenhum, 1.0 = instantâneo)
  final double decayRate;

  /// Mapeamento de palavras-chave para emoções
  static const Map<String, Map<String, dynamic>> emotionKeywords = {
    'happy': {
      'keywords': ['feliz', 'alegre', 'ótimo', 'bom', 'maravilhoso', 'excelente'],
      'valence': 1,
      'arousal': 2,
      'intensity': 2,
    },
    'sad': {
      'keywords': ['triste', 'mal', 'chateado', 'pra baixo', 'melancólico'],
      'valence': -1,
      'arousal': 1,
      'intensity': 2,
    },
    'calm': {
      'keywords': ['calmo', 'tranquilo', 'sereno', 'paz', 'relaxado'],
      'valence': 1,
      'arousal': 0,
      'intensity': 1,
    },
    'anxious': {
      'keywords': ['nervoso', 'ansioso', 'preocupado', 'estressado', 'tenso'],
      'valence': -1,
      'arousal': 3,
      'intensity': 2,
    },
    'low_energy': {
      'keywords': ['cansado', 'exausto', 'sem energia', 'esgotado', 'fadigado'],
      'valence': -1,
      'arousal': 0,
      'intensity': 1,
    },
    'irritated': {
      'keywords': ['irritado', 'raiva', 'bravo', 'furioso', 'chateado'],
      'valence': -1,
      'arousal': 3,
      'intensity': 2,
    },
    'reflective': {
      'keywords': ['pensando', 'refletindo', 'talvez', 'considerando', 'ponderando'],
      'valence': 0,
      'arousal': 1,
      'intensity': 1,
    },
    'warm': {
      'keywords': ['carinho', 'aconchego', 'acolhimento', 'conforto', 'ternura'],
      'valence': 1,
      'arousal': 1,
      'intensity': 2,
    },
    'focused': {
      'keywords': ['focado', 'concentrado', 'atento', 'determinado', 'engajado'],
      'valence': 0,
      'arousal': 2,
      'intensity': 1,
    },
    'supportive': {
      'keywords': ['apoio', 'suporte', 'ajuda', 'solidário', 'presente'],
      'valence': 1,
      'arousal': 1,
      'intensity': 1,
    },
  };

  /// Construtor
  EmotionRegulator({
    required this.profile,
    this.decayRate = 0.3,
  });

  /// Interpreta input do usuário e determina emoção apropriada
  EmotionState interpretInput(String input) {
    final lowerInput = input.toLowerCase();

    // Busca por palavras-chave que indiquem emoção
    for (final entry in emotionKeywords.entries) {
      final mood = entry.key;
      final config = entry.value;
      final keywords = config['keywords'] as List<String>;

      if (_containsAny(lowerInput, keywords)) {
        return EmotionState(
          mood: mood,
          intensity: config['intensity'] as int,
          valence: config['valence'] as int,
          arousal: config['arousal'] as int,
        );
      }
    }

    // Se não detectou nenhuma emoção específica, retorna estado neutro
    return EmotionState.neutral();
  }

  /// Regula transição entre estado atual e novo estado
  /// (evita mudanças emocionais muito bruscas)
  EmotionState regulateTransition(EmotionState current, EmotionState target) {
    // Se intensidades são muito diferentes, suaviza a transição
    final intensityDiff = (target.intensity - current.intensity).abs();

    if (intensityDiff <= 1) {
      // Transição direta se a diferença é pequena
      return target;
    }

    // Transição gradual - move 1 ponto em direção ao target
    final newIntensity = current.intensity < target.intensity
        ? current.intensity + 1
        : current.intensity - 1;

    return EmotionState(
      mood: target.mood,
      intensity: newIntensity,
      valence: target.valence,
      arousal: target.arousal,
    );
  }

  /// Aplica decaimento emocional - retorna gradualmente ao baseline
  EmotionState applyDecay(EmotionState current) {
    if (current.mood == profile.baseline.mood) {
      return current; // Já está no baseline
    }

    // Reduz intensidade gradualmente
    if (current.intensity > 0) {
      final newIntensity = (current.intensity - (1 * decayRate)).round();
      if (newIntensity <= 0) {
        // Retorna ao baseline quando intensidade chega a 0
        return profile.baseline;
      }

      return current.copyWith(intensity: newIntensity);
    }

    return profile.baseline;
  }

  /// Modula resposta textual baseada no estado emocional
  String modulateResponse(String text, EmotionState state) {
    // Se estado é neutro e intensidade baixa, retorna texto original
    if (state.mood == 'neutral' && state.intensity == 0) {
      return text;
    }

    // Prefixos emocionais baseados no humor
    final prefix = _getEmotionalPrefix(state);

    if (prefix.isEmpty) {
      return text;
    }

    return '$prefix $text';
  }

  /// Retorna prefixo emocional apropriado para o estado
  String _getEmotionalPrefix(EmotionState state) {
    // Só adiciona prefixo se intensidade for >= 1
    if (state.intensity < 1) return '';

    switch (state.mood) {
      case 'happy':
        return state.intensity >= 2 ? 'Que bom te sentir assim!' : 'Fico feliz!';
      case 'sad':
        return state.intensity >= 2
            ? 'Vem cá… eu tô contigo.'
            : 'Entendo como você se sente.';
      case 'calm':
        return 'Respira comigo…';
      case 'anxious':
        return state.intensity >= 2
            ? 'Vamos com calma, juntos.'
            : 'Vamos lidar com isso.';
      case 'low_energy':
        return 'Vamos no seu ritmo.';
      case 'irritated':
        return 'Eu vou te ajudar nisso.';
      case 'reflective':
        return 'Olha isso com calma…';
      case 'warm':
        return 'Fica aqui…';
      case 'focused':
        return 'Vamos focar nisso.';
      case 'supportive':
        return 'Estou aqui por você.';
      default:
        return '';
    }
  }

  /// Verifica se o texto contém alguma das palavras-chave
  bool _containsAny(String text, List<String> keywords) {
    return keywords.any((keyword) => text.contains(keyword));
  }

  /// Ajusta intensidade emocional com base em contexto adicional
  EmotionState adjustIntensity(EmotionState state, {int delta = 0}) {
    final newIntensity = (state.intensity + delta).clamp(0, 3);
    return state.copyWith(intensity: newIntensity);
  }

  /// Cria estado emocional personalizado
  EmotionState createCustomState({
    required String mood,
    int intensity = 1,
    int valence = 0,
    int arousal = 1,
  }) {
    return EmotionState(
      mood: mood,
      intensity: intensity.clamp(0, 3),
      valence: valence.clamp(-1, 1),
      arousal: arousal.clamp(0, 3),
    );
  }

  /// Analisa sentimento geral de um texto (simplificado)
  Map<String, dynamic> analyzeSentiment(String text) {
    final lowerText = text.toLowerCase();
    int positiveCount = 0;
    int negativeCount = 0;

    // Palavras positivas básicas
    final positiveWords = [
      'bom',
      'ótimo',
      'feliz',
      'alegre',
      'amor',
      'obrigado',
      'excelente'
    ];
    // Palavras negativas básicas
    final negativeWords = [
      'mal',
      'ruim',
      'triste',
      'péssimo',
      'ódio',
      'problema',
      'erro'
    ];

    for (final word in positiveWords) {
      if (lowerText.contains(word)) positiveCount++;
    }

    for (final word in negativeWords) {
      if (lowerText.contains(word)) negativeCount++;
    }

    final total = positiveCount + negativeCount;
    final sentiment = total > 0
        ? (positiveCount - negativeCount) / total
        : 0.0;

    return {
      'sentiment': sentiment, // -1.0 (negativo) a 1.0 (positivo)
      'positiveCount': positiveCount,
      'negativeCount': negativeCount,
      'isPositive': sentiment > 0.2,
      'isNegative': sentiment < -0.2,
      'isNeutral': sentiment >= -0.2 && sentiment <= 0.2,
    };
  }
}
