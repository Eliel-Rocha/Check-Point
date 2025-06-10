import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BottomNavBar extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  BottomNavBar({required this.selectedIndex, required this.onItemTapped});

  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Feed'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Mapa'),
        BottomNavigationBarItem(icon: Icon(Icons.star), label: 'Medalhas'),
      ],
      currentIndex: widget.selectedIndex,
      selectedItemColor: Colors.amber[800], // Cor do item selecionado
      unselectedItemColor: Colors.purple, // Cor dos itens não selecionados
      onTap: widget.onItemTapped,
      type: BottomNavigationBarType.fixed, // Para mostrar todos os rótulos
    );
  }
}
