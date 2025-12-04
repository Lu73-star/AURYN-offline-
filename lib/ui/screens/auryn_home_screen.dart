import 'package:flutter/material.dart';
import 'package:auryn_offline/auryn_core/auryn_core.dart';
import 'package:auryn_offline/voice/engine/voice_engine.dart';

class AurynHomeScreen extends StatefulWidget {
  const AurynHomeScreen({super.key});

  @override
  State<AurynHomeScreen> createState() => _AurynHomeScreenState();
}

class _AurynHomeScreenState extends State<AurynHomeScreen> {
  final AURYNCore auryn = AURYNCore();
  final VoiceEngine voice = VoiceEngine();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            // Pulso inicial da AURYN
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.blueAccent.withOpacity(0.8),
                    Colors.blueGrey.shade900,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blueAccent.withOpacity(0.6),
                    blurRadius: 25,
                    spreadRadius: 4,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            Text(
              "AURYN Falante",
              style: TextStyle(
                color: Colors.white.withOpacity(0.85),
                fontSize: 26,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              "Sistema inicial carregado",
              style: TextStyle(
                color: Colors.white.withOpacity(0.55),
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 40),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () async {
                await voice.speak(
                    "Estou aqui, meu irmão. Pode falar comigo.");
              },
              child: const Text(
                "Ativar",
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
