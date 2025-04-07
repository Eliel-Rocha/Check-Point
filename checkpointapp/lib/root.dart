import 'package:flutter/material.dart';
import '../timeline/timeline.dart';
import '../Profile/TelaPerfil.dart';
import '../Profile/ConfiguracoesPerfil.dart';

class RootPage extends StatefulWidget {
  @override
  _RootPageState createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  int _selectedIndex = 0;

  // Dados do perfil compartilhados
  String _profileName = 'Nome_perfil';
  String? _profileImagePath;
  String _profileBio = "";

  final GlobalKey<ProfileScreenState> _profileKey = GlobalKey();

  final List<String> _titles = ['Início', 'Perfil', 'Mapa'];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SettingsScreen(
          initialName: _profileName,
          initialImagePath: _profileImagePath,
          initialBio: _profileBio,
          onSave: (newName, newImagePath, newBio) {
            setState(() {
              _profileName = newName;
              _profileImagePath = newImagePath;
              _profileBio = newBio;
            });
            _profileKey.currentState?.updateProfile(
              newName,
              newImagePath,
              newBio,
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      TimelineScreen(),
      ProfileScreen(
        key: _profileKey,
        name: _profileName,
        imagePath: _profileImagePath,
        bio: _profileBio,
      ),
      TimelineScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFFF9933), // sunsetOrange
                Color(0xFF663399), // sunsetPurple
              ],
            ),
          ),
        ),
        leading: _selectedIndex != 0
            ? IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            setState(() {
              _selectedIndex = 0;
            });
          },
        )
            : null,
        title: Text(
          _titles[_selectedIndex],
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: _selectedIndex == 1
            ? [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: _openSettings,
          ),
        ]
            : null,
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Início',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Mapa',
          ),
        ],
      ),
    );
  }
}
