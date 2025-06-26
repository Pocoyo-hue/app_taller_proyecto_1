import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';
import 'package:flutter/foundation.dart';
import 'dart:typed_data';

class ObstacleDetectorScreen extends StatefulWidget {
  @override
  State<ObstacleDetectorScreen> createState() => _ObstacleDetectorScreenState();
}

class _ObstacleDetectorScreenState extends State<ObstacleDetectorScreen> {
  late CameraController _cameraController;
  late ObjectDetector _objectDetector;
  bool _isBusy = false;
  final FlutterTts flutterTts = FlutterTts();
  bool _obstacleDetected = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _initializeDetector();
  }

  void _initializeDetector() {
    final options = ObjectDetectorOptions(
      classifyObjects: true,
      multipleObjects: true,
      mode: DetectionMode.stream,
    );
    _objectDetector = ObjectDetector(options: options);
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final camera = cameras.firstWhere((cam) => cam.lensDirection == CameraLensDirection.back);

    _cameraController = CameraController(camera, ResolutionPreset.low, enableAudio: false);
    await _cameraController.initialize();
    _cameraController.startImageStream(_processImage);

    setState(() {});
  }

  void _processImage(CameraImage image) async {
    if (_isBusy) return;
    _isBusy = true;

    try {
      final WriteBuffer allBytes = WriteBuffer();
      for (final plane in image.planes) {
        allBytes.putUint8List(plane.bytes);
      }
      final bytes = allBytes.done().buffer.asUint8List();

      final inputImage = InputImage.fromBytes(
        bytes: bytes,
        metadata: InputImageMetadata(
          size: Size(image.width.toDouble(), image.height.toDouble()),
          rotation: InputImageRotation.rotation0deg, // O usa una función para obtener el real
          format: InputImageFormat.nv21,
          bytesPerRow: image.planes.first.bytesPerRow,
        ),
      );


      final objects = await _objectDetector.processImage(inputImage);

      if (objects.isNotEmpty && !_obstacleDetected) {
        _obstacleDetected = true;
        _announceObstacle();
        await Future.delayed(Duration(seconds: 3)); // evita repetir seguido
        _obstacleDetected = false;
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      _isBusy = false;
    }
  }

  Future<void> _announceObstacle() async {
    await flutterTts.setLanguage('es-ES');
    await flutterTts.setPitch(1.0);
    await flutterTts.speak('¡Cuidado! Hay un obstáculo adelante.');
  }

  @override
  void dispose() {
    _cameraController.dispose();
    _objectDetector.close();
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_cameraController.value.isInitialized) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: Text('Detección de Obstáculos')),
      body: CameraPreview(_cameraController),
    );
  }
}
