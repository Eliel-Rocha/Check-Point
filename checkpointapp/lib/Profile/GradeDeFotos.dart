import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'ImagemAmpliada.dart';
import 'QuadradosDasFotos.dart';

class PhotoGrid extends StatefulWidget {
  final List<String> photoPaths;
  final List<bool> likes;
  final Function(String) addPhoto;
  final Function(int) removePhoto;
  final Function(int) toggleLike;

  PhotoGrid({
    required this.photoPaths,
    required this.likes,
    required this.addPhoto,
    required this.removePhoto,
    required this.toggleLike,
  });

  @override
  _PhotoGridState createState() => _PhotoGridState();
}

class _PhotoGridState extends State<PhotoGrid> {
  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      widget.addPhoto(pickedFile.path);
    }
  }

  void _deleteImage(int index) {
    widget.removePhoto(index);
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: <Widget>[
        SliverPadding(
          padding: EdgeInsets.all(10.0),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 10.0,
              crossAxisSpacing: 10.0,
              childAspectRatio: 1.0,
            ),
            delegate: SliverChildBuilderDelegate((
                BuildContext context,
                int index,
                ) {
              if (index == widget.photoPaths.length) {
                // Botão de adicionar
                return GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    color: Colors.grey[200],
                    child: Icon(Icons.add, color: Colors.grey),
                  ),
                );
              } else {
                // Imagem
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => ImageScreen(
                          path: widget.photoPaths[index],
                          isLiked: widget.likes[index],
                          onLike: () => widget.toggleLike(index),
                        ),
                      ),
                    );
                  },
                  onLongPress: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Excluir Imagem'),
                          content: Text(
                            'Você tem certeza que deseja excluir esta imagem?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text('Cancelar'),
                            ),
                            TextButton(
                              onPressed: () {
                                _deleteImage(index);
                                Navigator.of(context).pop();
                              },
                              child: Text('Excluir'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: PhotoTile(
                    path: widget.photoPaths[index],
                    isLiked: widget.likes[index],
                    onLike:
                        () => widget.toggleLike(
                      index,
                    ), // Passando a função de curtir
                  ),
                );
              }
            }, childCount: widget.photoPaths.length + 1),
          ),
        ),
      ],
    );
  }
}