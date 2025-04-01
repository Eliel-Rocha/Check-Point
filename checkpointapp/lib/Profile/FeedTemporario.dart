import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'BarraNavegacao.dart';
import 'TelaPerfil.dart';



class FeedScreen extends StatefulWidget {
  @override
  _FeedScreenState createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  int _selectedIndex = 0; // Índice do item selecionado na BottomNavBar

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Navegação para as diferentes telas
    switch (index) {
      case 0:
      // Já estamos no Feed, então não faz nada
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProfileScreen()),
        );
        break;
      case 2:
      // Navegar para a tela de Mapa
      //Navigator.push(
      //  context,
      //  MaterialPageRoute(builder: (context) => MapScreen()),
      //);
        break;
      case 3:
      // Navegar para a tela de Medalhas
      //Navigator.push(
      //  context,
      //  MaterialPageRoute(builder: (context) => MedalsScreen()),
      //);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Feed'),
        automaticallyImplyLeading: false, // Remove a seta de voltar
      ),
      body: Center(
        child: Text(
          'Conteúdo do Feed',
        ), // Substitua isso pelo conteúdo real do feed
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}


