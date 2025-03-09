import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:smartscalex/firebase_options.dart';

import 'screens/splash/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(SmartScaleX());
}

class SmartScaleX extends StatelessWidget {
  const SmartScaleX({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: SplashScreen());
  }
}
