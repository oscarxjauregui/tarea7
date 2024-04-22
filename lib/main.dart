import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:tarea7/screens/login_screen.dart';
import 'package:tarea7/settigns/app_value_notifier.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyA1_-bc1Ii8W4IZXtGFiJsJtwnsrnNB9n0",
      appId: "com.pmsn2024.tarea7",
      messagingSenderId: "861803670908",
      projectId: "tarea7-pmsn2024",
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: AppValueNotifier.banTheme,
      builder: ((context, value, child) {
        return const MaterialApp(
          debugShowCheckedModeBanner: false,
            // theme: value
            //     ? ThemeApp.darkTheme(context)
            //     : ThemeApp.lightTheme(context),
            home: LoginScreen(),
        );
      }),
    );
  }
}