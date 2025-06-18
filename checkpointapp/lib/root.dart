import 'package:checkpointapp/BancoDeDados/user_preferences_services.dart';
import 'package:checkpointapp/BancoDeDados/user_firestore_service.dart'; // ADICIONADO
import 'package:checkpointapp/timeline/timeline.dart';
import 'package:circle_nav_bar/circle_nav_bar.dart';
import 'package:flutter/material.dart';
import 'configuracoes.dart';
import 'Profile/configuracoes_perfil.dart';
import 'Profile/tela_perfil.dart';
import 'Mapa/map.dart';


class RootPage extends StatefulWidget {
  @override
  State createState() => RootPageState();
}

class RootPageState extends State<RootPage> {
  late int tabIndex = 0;
  late PageController pageController;
  final List<String> _titles = ['Início','Perfil', 'Mapa', 'Configurações'];
  final List<Color> _colorBottomNav = UserPreferencesService.getThemeColor();
  final Color _colorTextAppBar = Colors.white;

 /* // Dados do perfil compartilhados
  String _profileName = 'Nome_perfil';
  String? _profileImagePath;
  String _profileBio = "";*/
  // MODIFICADO: Inicializa as variáveis como vazias
  String _profileName = '';
  String? _profileImagePath;
  String _profileBio = "";
  String _profileUsername = ''; // ADICIONADO: Variável para o username


  // ADICIONADO: Serviço do Firestore e estado de carregamento
  final UserFirestoreService _firestoreService = UserFirestoreService();
  bool _isLoading = true;

  final GlobalKey<ProfileScreenState> _profileKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: tabIndex);
    _loadUserData();
  }

  // ADICIONADO: Método para carregar dados do usuário do Firestore
  Future<void> _loadUserData() async {
    final userData = await _firestoreService.getDadosUsuarioLogado();
    if (mounted && userData != null) {
      setState(() {
        _profileImagePath = userData['foto_perfil'] ?? 'assets/profile-picture2.png';
        _profileName = userData['nome'] ?? 'Sem nome';
        _profileBio = userData['bio'] ?? '';
        _profileUsername = userData['username'] ?? 'sem_usuario'; // ADICIONADO: Carrega o username
        _isLoading = false;
      });
    } else if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SettingsScreen(
          initialName: _profileName,
          initialImagePath: _profileImagePath,
          initialBio: _profileBio,
        onSave: (newName, newImagePath, newBio) async {
          try {
            // 1. Salva no Firestore
            await _firestoreService.atualizarDadosUsuario({
              'nome': newName,
              'bio': newBio,
              // 'profileImageUrl': newImagePath, // Para quando implementar a imagem
            });

            // 2. Atualiza o estado local na RootPage (já fazia)
            setState(() {
              _profileName = newName;
              _profileImagePath = newImagePath;
              _profileBio = newBio;
            });

          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Erro ao salvar: $e")),
              );
            }
          }
        },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> items = [
      {'icon': Icons.home, 'label': 'Início'},
      {'icon': Icons.person, 'label': 'Perfil'},
      {'icon': Icons.map, 'label': 'Mapa'},
      {'icon': Icons.settings, 'label': 'Configurações'}
    ];

    final List<Widget> _pages = [
      TimelineScreen(),
      ProfileScreen(
          name: _profileName,
          imagePath: _profileImagePath,
          bio: _profileBio,
          username: _profileUsername,
      ),
      FullMap(),
      ConfigPage(),
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

        title: Text(
          _titles[tabIndex],
          style: TextStyle(
            color: _colorTextAppBar,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: tabIndex == 1
            ? [
          IconButton(
            icon: Icon(Icons.settings, color: _colorTextAppBar),
            onPressed: _openSettings,
          ),
        ]
            : null,
      ),
      body:_isLoading
          ? Center(child: CircularProgressIndicator())
          : PageView(
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