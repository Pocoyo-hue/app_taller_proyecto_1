import 'package:app_face_auth/pages/start_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'scan_menu_page.dart';
import 'math_page.dart';

class HomePage extends StatelessWidget {
  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();

    // Elimina el estado de autenticación y usuario guardado
    await prefs.remove('isAuthenticated');
    await prefs.remove('usuario');

    // Navega a StartPage y elimina el historial de navegación
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => StartPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inicio'),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.red, Colors.orange],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Text('Menú Principal',
              style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Inicio'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: Icon(Icons.document_scanner, color: Colors.amber),
              title: Text('Escanear texto', style: TextStyle(color: Colors.amber)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ScanMenuPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.warning, color: Colors.blue),
              title: Text('Matemática', style: TextStyle(color: Colors.blue)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MathVoiceScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.volume_up, color: Colors.green),
              title: Text('Reconocer objetos', style: TextStyle(color: Colors.green)),
              onTap: () {
                // Navega a la página correspondiente
              },
            ),
            ListTile(
              leading: Icon(Icons.warning),
              title: Text('Alerta de Obstáculos'),
              onTap: () {
                // Navega a la página correspondiente
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Cerrar sesión'),
              onTap: () => _logout(context),
            ),
          ],
        ),
      ),
      body: Center(
        child: Text('¡Bienvenido a la página principal!'),
      ),
    );
  }
}
