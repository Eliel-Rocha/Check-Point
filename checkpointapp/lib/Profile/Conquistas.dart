import 'package:flutter/material.dart';

class AchievementsGrid extends StatefulWidget {
  @override
  _AchievementsGridState createState() => _AchievementsGridState();
}

class _AchievementsGridState extends State<AchievementsGrid> {
  final List<Map<String, dynamic>> achievements = [
    {
      'title': 'Primeiro retaurante',
      'description': 'Visite um Restaurante.',
      'imagePath': 'assets/comida-e-restaurante.png',
      'colorOne': Colors.green.shade900,
      'colorTwo': Colors.green.shade300,
    },
    {
      'title': 'Cinco Fotos',
      'description': 'Adicionou cinco fotos ao álbum.',
      'imagePath': 'assets/fotos.png',
      'colorOne': Colors.green,
      'colorTwo': Colors.lightGreen,
    },
    {
      'title': 'Inicio da Jornada',
      'description': 'Conhecer 3 cidades.',
      'imagePath': 'assets/documento.png',
      'colorOne': Colors.red,
      'colorTwo': Colors.pink,
    },
    {
      'title': 'Dez Curtidas',
      'description': 'Recebeu dez curtidas em suas fotos.',
      'imagePath': 'assets/coracao.png',
      'colorOne': Colors.orange,
      'colorTwo': Colors.deepOrange,
    },
    {
      'title': 'Compartilhador',
      'description': 'Compartilhou uma foto.',
      'imagePath': 'assets/compartilhar.png',
      'colorOne': Colors.purple,
      'colorTwo': Colors.deepPurple,
    },
    {
      'title': 'Mestre da Galeria',
      'description': 'Adicionou 20 fotos ao álbum.',
      'imagePath': 'assets/album.png',
      'colorOne': Colors.teal,
      'colorTwo': Colors.cyan,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.all(10.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10.0,
        crossAxisSpacing: 10.0,
        childAspectRatio: 1.0,
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
                ShaderMask(
                  blendMode: BlendMode.srcATop,
                  shaderCallback: (Rect bounds) {
                    return LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        achievement['colorOne'],
                        achievement['colorTwo'],
                      ],
                    ).createShader(bounds);
                  },
                  child: Image.asset(
                    achievement['imagePath'],
                    width: 48,
                    height: 48,

                  ),
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