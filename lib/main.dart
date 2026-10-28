import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app.dart';
import 'core/localization/language_manager.dart';

Future<void> main() async {
  // Ensure bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  await LanguageManager.instance.init();
  await Firebase.initializeApp();
  // Lock to Portrait (Up and Down)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Or lock to Landscape only:
  // await SystemChrome.setPreferredOrientations([
  //   DeviceOrientation.landscapeLeft,
  //   DeviceOrientation.landscapeRight,
  // ]);
  runApp(const DakshApp());
}
