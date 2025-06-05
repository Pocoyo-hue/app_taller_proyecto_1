import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:math_expressions/math_expressions.dart';

class MathVoiceScreen extends StatefulWidget {
  @override
  _MathVoiceScreenState createState() => _MathVoiceScreenState();
}

class _MathVoiceScreenState extends State<MathVoiceScreen> {
  final TextEditingController _controller = TextEditingController();
  String _result = '';
  final FlutterTts flutterTts = FlutterTts();

  void _calculateAndSpeak() {
    String input = _controller.text;
    try {
      Parser p = Parser();
      Expression exp = p.parse(input);
      ContextModel cm = ContextModel();
      double eval = exp.evaluate(EvaluationType.REAL, cm);

      setState(() {
        _result = eval.toString();
      });

      _speak(input, eval);
    } catch (e) {
      setState(() {
        _result = 'Error: operación inválida';
      });
      flutterTts.speak('No se pudo entender la operación');
    }
  }

  Future<void> _speak(String operation, double result) async {
    await flutterTts.setLanguage('es-ES');
    await flutterTts.setPitch(1.0);

    String texto = 'La operación $operation es igual a ${result.toString()}';
    await flutterTts.speak(texto);
  }

  @override
  void dispose() {
    flutterTts.stop();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Operaciones Matemáticas con Voz')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Escribe una operación (ej: 3 + 4 * 2)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.text,
            ),
            SizedBox(height: 10),
            ElevatedButton.icon(
              icon: Icon(Icons.calculate),
              label: Text('Calcular y Leer'),
              onPressed: _calculateAndSpeak,
            ),
            SizedBox(height: 20),
            Text(
              _result,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            )
          ],
        ),
      ),
    );
  }
}
