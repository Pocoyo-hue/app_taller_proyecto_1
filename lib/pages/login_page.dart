import 'package:app_face_auth/dbHelper/constant.dart';
import 'package:app_face_auth/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final LocalAuthentication auth = LocalAuthentication();
  final TextEditingController _dniController = TextEditingController();
  String status = 'Autenticación con biometría requerida...';

  Future<void> _authenticateAndLogin() async {
  final dni = _dniController.text.trim();

  if (dni.isEmpty) {
    setState(() {
      status = 'Por favor ingrese su DNI.';
    });
    return;
  }

  // 🔧 Para pruebas: omitimos autenticación biométrica
  setState(() {
    status = 'Autenticación omitida. Verificando usuario...';
  });

  await _verifyUserInMongo(dni);

  // ---------------------------------------------
  // 🧬 AUTENTICACIÓN BIOMÉTRICA COMENTADA PARA PRUEBAS
  
  try {
    bool canCheckBiometrics = await auth.canCheckBiometrics;
    if (!canCheckBiometrics) {
      setState(() {
        status = 'El dispositivo no soporta autenticación biométrica.';
      });
      return;
    }

    bool authenticated = await auth.authenticate(
      localizedReason: 'Escanea tu huella o rostro para iniciar sesión',
      options: const AuthenticationOptions(biometricOnly: true),
    );

    if (authenticated) {
      setState(() {
        status = 'Autenticación exitosa. Verificando usuario...';
      });

      await _verifyUserInMongo(dni);
    } else {
      setState(() {
        status = 'Autenticación fallida.';
      });
    }
  } catch (e) {
    setState(() {
      status = 'Error durante la autenticación: $e';
    });
  }
  
  // ---------------------------------------------
}

  Future<void> _verifyUserInMongo(String dni) async {
    try {
      final db = await mongo.Db.create(MONGO_CONN_URL);
      await db.open();
      final userCollection = db.collection(USER_COLLECTION);

      final user = await userCollection.findOne({'dni': dni});

      await db.close();

      if (user != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('dni', dni);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      } else {
        setState(() {
          status = '❌ Usuario no encontrado en la base de datos.';
        });
      }
    } catch (e) {
      setState(() {
        status = 'Error al verificar usuario en MongoDB: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Iniciar sesión')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                status,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 30),
              TextField(
                controller: _dniController,
                keyboardType: TextInputType.number,
                maxLength: 8,
                style: TextStyle(fontSize: 24),
                decoration: InputDecoration(
                  labelText: 'DNI',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                ),
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: _authenticateAndLogin,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 18, horizontal: 50),
                  textStyle: TextStyle(fontSize: 20),
                ),
                child: Text('Iniciar sesión con biometría'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
