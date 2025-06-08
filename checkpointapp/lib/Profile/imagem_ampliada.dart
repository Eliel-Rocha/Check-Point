import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ImageScreen extends StatefulWidget {
  final String path;
  final bool isLiked;
  final VoidCallback onLike;

  ImageScreen({
    required this.path,
    required this.isLiked,
    required this.onLike,
  });

  @override
  _ImageScreenState createState() => _ImageScreenState();
}

class _ImageScreenState extends State<ImageScreen> {
  late bool isLiked;

  @override
  void initState() {
    super.initState();
    isLiked = widget.isLiked;
  }

  void _toggleLike() {
    setState(() {
      isLiked = !isLiked;
    });
    widget
        .onLike(); // Chama o callback para atualizar o estado na tela anterior
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Visualizar Imagem')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(child: Image.file(File(widget.path), fit: BoxFit.contain)),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: GestureDetector(
                onTap: _toggleLike,
                child: Icon(
                  Icons.favorite,
                  color: isLiked ? Colors.orange : Colors.grey,
                  size: 40,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
