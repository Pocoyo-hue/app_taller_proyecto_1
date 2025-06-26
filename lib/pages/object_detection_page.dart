import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:image_picker/image_picker.dart';

class ObjectDetectionScreen extends StatefulWidget {
  @override
  State<ObjectDetectionScreen> createState() => _ObjectDetectionScreenState();
}

class _ObjectDetectionScreenState extends State<ObjectDetectionScreen> {
  final picker = ImagePicker();
  final FlutterTts tts = FlutterTts();
  String resultText = '';
  String lastSpoken = '';

  // Traducción (inglés → español)
  final Map<String, String> tr = {
    'book': 'libro',
    'notebook': 'cuaderno',
    'pen': 'lapicero',
    'ballpoint pen': 'lapicero',
    'pencil': 'lápiz',
    'backpack': 'mochila',
    'bag': 'mochila',
    'case': 'estuche',
  };

  Future<void> _scan() async {
    final picked = await picker.pickImage(source: ImageSource.camera);
    if (picked == null) return;

    final inputImage = InputImage.fromFile(File(picked.path));

    final labeler = ImageLabeler(
      options: ImageLabelerOptions(confidenceThreshold: 0.5),
    );
    final labels = await labeler.processImage(inputImage);
    await labeler.close();

    if (labels.isEmpty) {
      setState(() {
        resultText = 'No se detectaron objetos.';
        lastSpoken = '';
      });
      await _say('No se detectaron objetos');
      return;
    }

    // ➜ Elegir la etiqueta con mayor confianza
    final best = labels.reduce(
        (a, b) => a.confidence > b.confidence ? a : b);

    final name   = best.label.toLowerCase();
    final esp    = tr[name] ?? name;
    final conf   = (best.confidence * 100).toStringAsFixed(1);

    setState(() {
      resultText = 'Objeto: $esp\nConfianza: $conf %';
      lastSpoken = esp;
    });

    await _say(esp);
  }

  Future<void> _say(String txt) async {
    if (txt.isEmpty) return;
    await tts.setLanguage('es-ES');
    await tts.setPitch(1.0);
    await tts.speak(txt);
  }

  @override
  void dispose() {
    tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reconocer objetos')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: _scan,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Detectar objeto'),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: lastSpoken.isEmpty ? null : () => _say(lastSpoken),
              icon: const Icon(Icons.volume_up),
              label: const Text('Repetir voz'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  resultText,
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
