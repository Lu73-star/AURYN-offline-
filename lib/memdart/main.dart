import 'package:flutter/material.dart';
import 'auryn_core/auryn_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa o núcleo da AURYN
  final auryn = AurynCore();
  await auryn.initialize();

  runApp(AurynApp(auryn));
}

class AurynApp extends StatelessWidget {
  final AurynCore auryn;

  const AurynApp(this.auryn, {super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AURYN Falante (Offline)',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        primaryColor: const Color(0xFF1E88E5),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.white),
        ),
      ),
      home: HomeScreen(auryn: auryn),
    );
  }
}

class HomeScreen extends StatelessWidget {
  final AurynCore auryn;

  const HomeScreen({super.key, required this.auryn});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AURYN Falante"),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            final resposta = await auryn.processarTexto("Olá Auryn!");
            debugPrint("AURYN respondeu: $resposta");
          },
          child: const Text("Testar Núcleo"),
        ),
      ),
    );
  }
}
