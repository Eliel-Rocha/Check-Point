import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';

import '../BancoDeDados/user_firestore_service.dart';

class AchievementsGrid extends StatefulWidget {
  @override
  _AchievementsGridState createState() => _AchievementsGridState();
}

class _AchievementsGridState extends State<AchievementsGrid> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Map<String, dynamic>> userAchievements = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    carregarConquistasDoUsuario();
  }


  Future<void> testarConquistaPorLocalizacao() async {
    try {
      // Solicita a localização atual
      Position posicaoAtual = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      double latitudeAtual = posicaoAtual.latitude;
      double longitudeAtual = posicaoAtual.longitude;

      final userService = UserFirestoreService();

      int? predioProximo = await userService.verificarProximidadeComPredios(
        latitude: latitudeAtual,
        longitude: longitudeAtual,
        raioMetros: 50, // ajustar conforme necessário
      );

      if (predioProximo != null) {
        await userService.adicionarPredioConquistado(predioProximo);
        await carregarConquistasDoUsuario();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Conquista do prédio $predioProximo adicionada!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Nenhum prédio próximo encontrado.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao obter localização: $e')),
      );
    }
  }


  Future<void> carregarConquistasDoUsuario() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('Usuário não logado');

      final usuarioDoc = await _db.collection('usuarios').doc(userId).get();
      final dadosUsuario = usuarioDoc.data();

      if (dadosUsuario == null || !dadosUsuario.containsKey('conquistas')) {
        setState(() {
          userAchievements = [];
          isLoading = false;
        });
        return;
      }

      // Corrigido aqui: campo era 'Conquitas' errado + agora trata null
      List<dynamic> prediosConquistados = dadosUsuario['conquistas'] ?? [];
      List<Map<String, dynamic>> conquistas = [];


      for (var predioId in prediosConquistados) {
        final doc = await _db.collection('predios').doc(predioId.toString()).get();
        if (doc.exists) {
          var data = doc.data()!;
          conquistas.add({
            'title': data['predio']?.toString() ?? 'Prédio $predioId',
            'description': data['conquista'] ?? data['descricao'] ?? '',
            'imagePath': data['imagem'] ?? 'assets/CheckPoint.png'
          });
        }
      }

      setState(() {
        userAchievements = conquistas;
        isLoading = false;
      });
    } catch (e) {
      print('Erro ao carregar conquistas: $e');
      setState(() {
        userAchievements = [];
        isLoading = false;
      });
    }
  }


  @override
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        isLoading
            ? Center(child: CircularProgressIndicator())
            : userAchievements.isEmpty
            ? Center(child: Text('Nenhuma conquista encontrada'))
            : GridView.builder(
          padding: EdgeInsets.all(10.0),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 10.0,
            crossAxisSpacing: 10.0,
            childAspectRatio: 1.0,
          ),
          itemCount: userAchievements.length,
          itemBuilder: (BuildContext context, int index) {
            final achievement = userAchievements[index];
            return Card(
              elevation: 4.0,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      achievement['imagePath'],
                      height: 80,
                      errorBuilder: (context, error, stackTrace) {
                        // Se a imagem não for encontrada no caminho especificado, mostra um ícone de erro
                        return Icon(Icons.error_outline, size: 80, color: Colors.red);
                      },
                    ),
                    SizedBox(height: 8),
                    Text(
                      achievement['title'],
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    SizedBox(height: 4),
                    Text(
                      achievement['description'],
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        Positioned(
          bottom: 20,
          right: 20,
          child: FloatingActionButton(
            child: Icon(Icons.location_on),
            onPressed: () async {
              await testarConquistaPorLocalizacao();
            },
          ),
        ),
      ],
    );
  }

}
