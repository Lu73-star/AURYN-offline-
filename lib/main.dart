import 'package:flutter/material.dart';
import 'package:auryn_offline/ui/auryn_app.dart';
import 'package:auryn_offline/auryn_core/auryn_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa o núcleo da IA antes de abrir o app
  await AURYNCore().init();

  runApp(const AurynApp());
}
