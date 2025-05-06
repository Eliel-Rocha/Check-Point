import 'package:checkpointapp/timeline/timeline.dart';
import 'package:circle_nav_bar/circle_nav_bar.dart';
import 'package:flutter/material.dart';

import 'Profile/ConfiguracoesPerfil.dart';
import 'Profile/TelaPerfil.dart';
import 'map.dart';

class RootPage extends StatefulWidget {
  @override
  State createState() => RootPageState();
}

class RootPageState extends State<RootPage> {
  late int tabIndex = 1;
  late PageController pageController;
  final List<String> _titles = ['Perfil', 'Início', 'Mapa'];
  final List<Color> _colorBottomNav = [
  //Color(0xFFFF9933),
  Color(0xFFFF9933),
  //Color(0xFFC885BA),
  //Color(0xFF663399),
  Color(0xFF663399)
];
  final Color _colorTextAppBar = Colors.white;

  // Dados do perfil compartilhados
  String _profileName = 'Nome_perfil';
  String? _profileImagePath;
  String _profileBio = "";

  final GlobalKey<ProfileScreenState> _profileKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: tabIndex);
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
    List<Map<String, dynamic>> items = [
      {'icon': Icons.person, 'label': 'Perfil'},
      {'icon': Icons.home, 'label': 'Início'},
      {'icon': Icons.map, 'label': 'Mapa'},
    ];

    final List<Widget> _pages = [
      ProfileScreen(
        key: _profileKey,
        name: _profileName,
        imagePath: _profileImagePath,
        bio: _profileBio,
      ),
      TimelineScreen(),
      FullMap(),
    ];

    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(8),
              bottomRight: Radius.circular(8),
            ),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: _colorBottomNav,
            ),
          ),
        ),
        leading: tabIndex != 1
            ? IconButton(
          icon: Icon(Icons.arrow_back, color: _colorTextAppBar),
          onPressed: () {
            setState(() {
              tabIndex = 1;
            });
            pageController.jumpToPage(tabIndex); // Move o PageView para a página correta
          },
        )
            : null,
        title: Text(
          _titles[tabIndex],
          style: TextStyle(
            color: _colorTextAppBar,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: tabIndex == 0
            ? [
          IconButton(
            icon: Icon(Icons.settings, color: _colorTextAppBar),
            onPressed: _openSettings,
          ),
        ]
            : null,
      ),
      body: PageView(
        controller: pageController,
        physics: NeverScrollableScrollPhysics(),
        onPageChanged: (v) {
          setState(() {
            tabIndex = v;
          });
        },
        children: _pages,
      ),
      bottomNavigationBar: CircleNavBar(
        inactiveIcons: List.generate(items.length, (index) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                items[index]['icon'],
                size: 25,
                color: _colorTextAppBar,
              ),
              SizedBox(height: 4),
              Text(
                items[index]['label'],
                style: TextStyle(color: _colorTextAppBar, fontSize: 12,),
              ),
            ],
          );
        }),
        activeIcons: List.generate(items.length, (index) {
          return Icon(
            items[index]['icon'],
            size: 25,
            color: _colorTextAppBar,
          );
        }),
        padding: EdgeInsets.zero,
        color: Colors.white,
        circleColor: Colors.white,
        height: 60,
        circleWidth: 60,
        activeIndex: tabIndex,
        onTap: (index) {
          setState(() {
            tabIndex = index;
          });
          pageController.jumpToPage(tabIndex);
        },
        cornerRadius: const BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
        shadowColor: Colors.deepPurple,
        circleShadowColor: Colors.deepPurple,
        elevation: 10,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _colorBottomNav,
        ),
        circleGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _colorBottomNav,
        ),
      ),
    );
  }
}