import 'package:flutter/material.dart';
import 'package:auryn_offline/ui/widgets/voice_button.dart';

class AurynHomeScreen extends StatelessWidget {
  const AurynHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "AURYN Falante",
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 40),

            // 🔥 Botão de voz central
            const VoiceButton(),

            const SizedBox(height: 40),
            Text(
              "Toque para falar com a AURYN",
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
