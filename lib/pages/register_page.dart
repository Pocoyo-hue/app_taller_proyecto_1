import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:app_face_auth/dbHelper/constant.dart';
import 'package:app_face_auth/pages/home_page.dart';

class RegisterPage extends StatefulWidget {
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final LocalAuthentication auth = LocalAuthentication();
  final TextEditingController _dniController = TextEditingController();
  String status = 'Registro mediante biometría...';

  Future<void> _registerUser() async {
    try {
      bool authenticated = await auth.authenticate(
        localizedReason: 'Regístrate con biometría',
        options: const AuthenticationOptions(biometricOnly: true),
      );

      if (!authenticated) {
        setState(() {
          status = 'Autenticación fallida';
        });
        return;
      }

      final dni = _dniController.text.trim();
      if (dni.isEmpty) {
        setState(() {
          status = 'Ingresa el DNI del usuario';
        });
        return;
      }

      final db = await mongo.Db.create(MONGO_CONN_URL);
      await db.open();
      final userCollection = db.collection(USER_COLLECTION);

      final existing = await userCollection.findOne({'dni': dni});
      if (existing == null) {
        await userCollection.insertOne({
          'dni': dni,
          'autenticado': true,
          'fecha': DateTime.now().toIso8601String(),
        });

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomePage()),
        );
      } else {
        setState(() {
          status = 'Usuario ya registrado';
        });
      }

      await db.close();
    } catch (e) {
      setState(() {
        status = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Registro')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(status),
            SizedBox(height: 20),
            TextField(
              controller: _dniController,
              keyboardType: TextInputType.number,
              maxLength: 8,
              decoration: InputDecoration(
                labelText: 'DNI',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
                onPressed: _registerUser,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 18, horizontal: 50),
                  textStyle: TextStyle(fontSize: 20),
                ),
              child: Text('Registrar con Biometría'),
            ),
          ],
        ),
      ),
    );
  }
}
