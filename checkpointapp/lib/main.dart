import 'package:flutter/material.dart';
import 'map.dart'; // Importe o widget MapaPersonalizado

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: FullMap(),
      ),
    );
  }
}