import 'package:flutter/material.dart';
import '../service/text_scan_screen.dart';

class ScanMenuPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Escanear Texto'),
      ),
      body: Center(
        child: ElevatedButton.icon(
          icon: Icon(Icons.document_scanner, size: 40),
          label: Text('Escanear y Leer Texto', style: TextStyle(fontSize: 24)),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
            textStyle: TextStyle(fontSize: 20),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => TextScanScreen()),
            );
          },
        ),
      ),
    );
  }
}
