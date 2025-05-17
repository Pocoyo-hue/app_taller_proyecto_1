import 'package:app_face_auth/dbHelper/constant.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;

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
    final db = await mongo.Db.create(MONGO_CONN_URL);
    await db.open();
    
    final userCollection = db.collection(USER_COLLECTION);

    await userCollection.insertOne({
      'usuario': 'demoUser',
      'autenticado': true,
      'fecha': DateTime.now().toIso8601String(),
    });

    await db.close();

    setState(() {
      status = 'Datos enviados correctamente a MongoDB';
    });
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
