import 'package:app_face_auth/dbHelper/constant.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:app_face_auth/pages/home_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login',
      home: BiometricMongoScreen(),
    );
  }
}

class BiometricMongoScreen extends StatefulWidget {
  @override
  State<BiometricMongoScreen> createState() => _BiometricMongoScreenState();
}


class _BiometricMongoScreenState extends State<BiometricMongoScreen> {
  final LocalAuthentication auth = LocalAuthentication();
  final TextEditingController _usernameController = TextEditingController();
  String status = 'Esperando autenticación...';

  Future<void> _authenticateAndSave() async {
    try {
      bool canCheckBiometrics = await auth.canCheckBiometrics;
      if (!canCheckBiometrics) {
        setState(() {
          status = 'Dispositivo no soporta biometría';
        });
        return;
      }

      bool authenticated = await auth.authenticate(
        localizedReason: 'Escanea tu rostro o huella para continuar',
        options: const AuthenticationOptions(biometricOnly: true),
      );

      if (authenticated) {
        setState(() {
          status = 'Autenticación exitosa. Enviando a MongoDB...';
        });

        await _sendDataToMongo();
      } else {
        setState(() {
          status = 'Autenticación fallida';
        });
      }
    } catch (e) {
      setState(() {
        status = 'Error: $e';
      });
    }
  }

  Future<void> _sendDataToMongo() async {
    
    try {
    final db = await mongo.Db.create(MONGO_CONN_URL);
    await db.open();

    final userCollection = db.collection(USER_COLLECTION);

    final username = _usernameController.text.trim();
    if (username.isEmpty) {
      setState(() {
        status = 'Por favor ingresa un nombre de usuario';
      });
      return;
    }

    final existingUser = await userCollection.findOne({'usuario': username});

    if (existingUser == null) {
      // Usuario nuevo, registrar
      await userCollection.insertOne({
        'usuario': username,
        'autenticado': true,
        'fecha': DateTime.now().toIso8601String(),
      });
      setState(() {
        status = 'Usuario nuevo registrado y autenticado.';
      });
    } else {
      setState(() {
        status = 'Usuario ya autenticado anteriormente.';
      });
    }

      await db.close();

      // Navegar a HomePage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );

    } catch (e) {
      setState(() {
        status = '❌ Error de conexión o escritura en MongoDB: $e';
      });
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(status),
            SizedBox(height: 20),

            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Nombre de usuario',
                border: OutlineInputBorder(),
              ),
            ),

            SizedBox(height: 20),

            ElevatedButton(
              onPressed: _authenticateAndSave,
              child: Text('Autenticarse'),
            ),
          ],
        ),
      ),
    );
  }
}
