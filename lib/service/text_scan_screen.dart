import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';

class TextScanScreen extends StatefulWidget {
  @override
  _TextScanScreenState createState() => _TextScanScreenState();
}

class _TextScanScreenState extends State<TextScanScreen> {
  String scannedText = '';
  bool isScanning = false;
  final FlutterTts flutterTts = FlutterTts();

  Future<void> _pickImageAndScan() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);

    if (pickedFile == null) return;

    setState(() {
      isScanning = true;
      scannedText = '';
    });

    final inputImage = InputImage.fromFile(File(pickedFile.path));
    final textDetector = GoogleMlKit.vision.textRecognizer();
    final RecognizedText recognizedText = await textDetector.processImage(inputImage);
    await textDetector.close();

    setState(() {
      scannedText = recognizedText.text;
      isScanning = false;
    });

    _speak(scannedText);
  }

  Future<void> _speak(String text) async {
    await flutterTts.setLanguage('es-ES');
    await flutterTts.setPitch(1.0);
    await flutterTts.speak(text);
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Escáner de Texto')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton.icon(
              icon: Icon(Icons.camera_alt),
              label: Text('Escanear con Cámara'),
              onPressed: _pickImageAndScan,
            ),
            SizedBox(height: 10),
            ElevatedButton.icon(
              icon: Icon(Icons.volume_up),
              label: Text('Repetir Voz'),
              onPressed: scannedText.isNotEmpty ? () => _speak(scannedText) : null,
            ),
            SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  scannedText.isEmpty
                      ? (isScanning ? 'Escaneando...' : 'No se ha escaneado texto.')
                      : scannedText,
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
