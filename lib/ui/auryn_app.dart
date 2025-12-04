import 'package:flutter/material.dart';
import 'package:auryn_offline/voice/auryn_voice.dart';

class AurynApp extends StatefulWidget {
  const AurynApp({super.key});

  @override
  State<AurynApp> createState() => _AurynAppState();
}

class _AurynAppState extends State<AurynApp> {
  final AurynVoice _voice = AurynVoice();
  final TextEditingController _ctrl = TextEditingController();
  String _response = "";

  Future<void> _send() async {
    final text = _ctrl.text.trim();

    if (text.isEmpty) return;

    final reply = _voice.processText(text);

    setState(() {
      _response = reply;
    });

    _ctrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("AURYN OFFLINE"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _ctrl,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: "Digite algo...",
                hintStyle: TextStyle(color: Colors.white54),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white38),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
              onSubmitted: (_) => _send(),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: _send,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
              ),
              child: const Text("Enviar"),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  _response,
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
