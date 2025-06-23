import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'conquistas.dart';
import 'grade_de_fotos.dart';

class ProfileScreen extends StatefulWidget {
  final String name;
  final String bio;
  final String username;
  final String? imagePath;

  ProfileScreen({
    Key? key,
    required this.name,
    required this.bio,
    required this.username,
    this.imagePath,
  }) : super(key: key);

  @override
  ProfileScreenState createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  // Constantes de Cor
  static const Color sunsetOrange = Color(0xFFFF9933);
  static const Color sunsetPurple = Color(0xFF663399);
  static const Color sunsetYellow = Color(0xFFFFCC33);
  static const Color sunsetLightOrange = Color(0xFFFFB366);
  static const Color sunsetDarkPurple = Color(0xFF4D2973);

  // Estado interno da UI da tela
  late String _profileName;
  late String _profileBio;
  late String _profileUsername;
  late String? _profileImagePath;

  // Variáveis para a galeria de fotos local
  List<String> _photoPaths = [];
  List<bool> _likes = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Inicializa o estado interno com os dados recebidos da root.dart
    _profileName = widget.name;
    _profileBio = widget.bio;
    _profileUsername = widget.username;
    _profileImagePath = widget.imagePath;
  }

  // Garante que a tela se atualize se os dados na root.dart mudarem
  @override
  void didUpdateWidget(covariant ProfileScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.name != oldWidget.name ||
        widget.bio != oldWidget.bio ||
        widget.username != oldWidget.username ||
        widget.imagePath != oldWidget.imagePath) {
      setState(() {
        _profileName = widget.name;
        _profileBio = widget.bio;
        _profileUsername = widget.username;
        _profileImagePath = widget.imagePath;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        body: Container(
          width:
              double.infinity, // Garante que o container ocupe toda a largura
          height:
              double.infinity, // Garante que o container ocupe toda a altura
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFFE1BEE7), // Mantém o lavanda suave
                const Color(0xFFFFE0B2),  // Transita para o seu laranja claro na base
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            image: DecorationImage(
              // Caminho para a imagem que você adicionou
              image: AssetImage('assets/mapadefundo.png'),
              // Faz a imagem se repetir para preencher todo o fundo
              repeat: ImageRepeat.repeat,
              // MUITO IMPORTANTE: Deixa a imagem bem sutil e transparente
              opacity: 0.05,
            ),
          ),
          child: SafeArea(
            top: true,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                SizedBox(height: 20),
                Align(
                  alignment: AlignmentDirectional(0, 0),
                  child: GestureDetector(
                    // Não seleciona mais fotos de perfil !!!
                    //onTap: _showImageSourceDialog,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: SweepGradient(
                          colors: [sunsetPurple, sunsetOrange, sunsetPurple],
                          stops: [0.0, 0.5, 1.0],
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                          child: ClipOval(
                            child: SizedBox(
                              width: 90,
                              height: 90,
                              child:
                                  _profileImagePath != null
                                      ? Image.asset(_profileImagePath!)
                                      : Icon(
                                        Icons.person,
                                        size: 60,
                                        color: Colors.grey,
                                      ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  _profileName.isNotEmpty ? _profileName : 'Nome',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    color: sunsetDarkPurple,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  '@$_profileUsername',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    color: Colors.grey.shade600,
                    fontSize: 16,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10.0,
                    vertical: 10.0,
                  ),
                  child: Text(
                    _profileBio,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      color: Colors.black87,
                      fontSize: 16,
                    ),
                  ),
                ),
                // --- A ESTRUTURA ANTIGA (ROW E FLEXIBLE) FOI SUBSTITUÍDA POR ESTA ---
                Column(
                  children: [
                    SizedBox(height: 4),
                    Text(
                      'Medalhas',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      height: 4, // Altura (espessura) da linha
                      width: 50, // Largura da linha
                      decoration: BoxDecoration(
                        color: Colors.deepPurple, // A cor da linha
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: AchievementsGrid(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
