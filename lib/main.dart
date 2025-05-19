import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_face_auth/pages/home_page.dart';
import 'package:app_face_auth/pages/start_page.dart';

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
      title: 'App Face Auth',
      debugShowCheckedModeBanner: false,
      initialRoute: initialRoute,
      routes: {
        '/start': (context) => StartPage(),
        '/home': (context) => HomePage(),
      },
    );
  }
}