import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

class MathCameraPage extends StatefulWidget {
  @override
  _MathCameraPageState createState() => _MathCameraPageState();
}

class _MathCameraPageState extends State<MathCameraPage> {
  final FlutterTts flutterTts = FlutterTts();
  String _recognizedText = '';

  Future<void> _scanTextFromCamera() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile == null) return;

    final inputImage = InputImage.fromFile(File(pickedFile.path));
    final textRecognizer = TextRecognizer();
    final recognizedText = await textRecognizer.processImage(inputImage);
    await textRecognizer.close();

    setState(() => _recognizedText = recognizedText.text);
    await _speak(_recognizedText);
  }

  Future<void> _speak(String text) async {
    if (text.isEmpty) return;
    await flutterTts.setLanguage('es-ES');
    await flutterTts.setPitch(1.0);
    await flutterTts.speak('La operación detectada es: $text');
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Leer Operación Matemática')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.camera_alt),
              label: const Text('Escanear con Cámara'),
              onPressed: _scanTextFromCamera,
            ),
            const SizedBox(height: 12),

            // 🔊 Botón para repetir la voz
            ElevatedButton.icon(
              icon: const Icon(Icons.volume_up),
              label: const Text('Repetir voz'),
              onPressed: _recognizedText.isEmpty ? null : () => _speak(_recognizedText),
            ),
            const SizedBox(height: 20),

            const Text('Texto detectado:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  _recognizedText,
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
