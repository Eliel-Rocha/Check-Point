import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AchievementsGrid extends StatefulWidget {
  @override
  _AchievementsGridState createState() => _AchievementsGridState();
}

class _AchievementsGridState extends State<AchievementsGrid> {
  // Lista fictícia de conquistas
  final List<Map<String, dynamic>> achievements = [
    {
      'title': 'Primeira Foto',
      'description': 'Adicionou sua primeira foto ao álbum.',
      'icon': Icons.camera_alt,
      'color': Colors.blue,
    },
    {
      'title': 'Cinco Fotos',
      'description': 'Adicionou cinco fotos ao álbum.',
      'icon': Icons.photo_library,
      'color': Colors.green,
    },
    {
      'title': 'Primeira Curtida',
      'description': 'Curtiu sua primeira foto.',
      'icon': Icons.favorite,
      'color': Colors.red,
    },
    {
      'title': 'Dez Curtidas',
      'description': 'Recebeu dez curtidas em suas fotos.',
      'icon': Icons.favorite_border,
      'color': Colors.orange,
    },
    {
      'title': 'Compartilhador',
      'description': 'Compartilhou uma foto.',
      'icon': Icons.share,
      'color': Colors.purple,
    },
    {
      'title': 'Mestre da Galeria',
      'description': 'Adicionou 20 fotos ao álbum.',
      'icon': Icons.collections,
      'color': Colors.teal,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.all(10.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // Duas colunas
        mainAxisSpacing: 10.0,
        crossAxisSpacing: 10.0,
        childAspectRatio: 1.0, // Itens quadrados
      ),
      itemCount: achievements.length,
      itemBuilder: (BuildContext context, int index) {
        final achievement = achievements[index];
        return Card(
          elevation: 4.0,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  achievement['icon'],
                  size: 48,
                  color: achievement['color'],
                ),
                SizedBox(height: 8),
                Text(
                  achievement['title'],
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 4),
                Text(
                  achievement['description'],
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}