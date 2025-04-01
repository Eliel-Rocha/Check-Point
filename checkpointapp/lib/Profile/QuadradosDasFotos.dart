import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PhotoTile extends StatelessWidget {
  final String path;
  final bool isLiked;
  final VoidCallback onLike; // Adicionando o callback de curtir

  PhotoTile({required this.path, required this.isLiked, required this.onLike});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8.0),
            image: DecorationImage(
              image: FileImage(File(path)),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          right: 5,
          top: 5,
          child: GestureDetector(
            // Tornando o ícone clicável
            onTap: onLike, // Chamando a função de curtir
            child: Icon(
              Icons.favorite,
              color: isLiked ? Colors.orange : Colors.grey,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }
}
