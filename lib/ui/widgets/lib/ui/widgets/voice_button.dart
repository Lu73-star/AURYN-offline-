import 'package:flutter/material.dart';
import 'package:auryn_offline/voice/auryn_voice.dart';

class VoiceButton extends StatefulWidget {
  const VoiceButton({super.key});

  @override
  State<VoiceButton> createState() => _VoiceButtonState();
}

class _VoiceButtonState extends State<VoiceButton>
    with SingleTickerProviderStateMixin {
  
  bool _active = false;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _toggle() async {
    final voice = AurynVoice();

    if (_active) {
      await voice.stopListening();
    } else {
      await voice.startListening();
    }

    setState(() => _active = !_active);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _active ? Colors.deepPurpleAccent : Colors.grey.shade800,
          boxShadow: _active
              ? [
                  BoxShadow(
                    color: Colors.purpleAccent.withOpacity(0.6),
                    blurRadius: 25,
                    spreadRadius: 8,
                  ),
                ]
              : [],
        ),
        child: Center(
          child: ScaleTransition(
            scale: Tween(begin: 1.0, end: 1.2).animate(
              CurvedAnimation(
                parent: _controller,
                curve: Curves.easeInOut,
              ),
            ),
            child: Icon(
              _active ? Icons.mic : Icons.mic_none,
              color: Colors.white,
              size: 45,
            ),
          ),
        ),
      ),
    );
  }
}
