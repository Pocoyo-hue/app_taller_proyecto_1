import 'package:app_face_auth/pages/login_page.dart';
import 'package:app_face_auth/pages/register_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_face_auth/pages/home_page.dart';
import 'package:app_face_auth/pages/start_page.dart';
import 'package:app_face_auth/pages/scan_menu_page.dart';
import 'package:app_face_auth/pages/math_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final savedUser = prefs.getString('usuario');

  runApp(MyApp(initialRoute: savedUser != null ? '/home' : '/start'));
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Visión Inclusiva',
      theme: ThemeData(
        primaryColor: Colors.red.shade700,
        scaffoldBackgroundColor: Colors.yellow.shade100,
        appBarTheme: AppBarTheme(
          color: Colors.red.shade700,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange.shade400,
            foregroundColor: Colors.black,
            textStyle: TextStyle(fontSize: 20),
          ),
        ),
        textTheme: TextTheme(
          bodyMedium: TextStyle(fontSize: 18, color: Colors.black),
        ),
      ),
      initialRoute: initialRoute,
      routes: {
        '/start': (context) => StartPage(),
        '/login': (context) => LoginPage(),
        '/register': (context) => RegisterPage(),
        '/home': (context) => HomePage(),
        '/ocr': (context) => ScanMenuPage(),
        '/ocr': (context) => MathVoiceScreen(),
        // agrega más rutas si creas más páginas como configuración o navegación
      },
    );
  }
}