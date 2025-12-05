import 'package:flutter/material.dart';
import 'screens/auryn_home_screen.dart';

class AurynApp extends StatelessWidget {
  const AurynApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AURYN Falante',
      home: const AurynHomeScreen(),
      theme: ThemeData.dark(),
    );
  }
}
