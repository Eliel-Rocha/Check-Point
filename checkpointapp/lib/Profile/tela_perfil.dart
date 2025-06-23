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
  bool _isShowingAlbum = false;
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

  // Métodos para a galeria de fotos local (sem conexão com banco de dados ainda)
  void _addPhoto(String path) {
    setState(() {
      _photoPaths.add(path);
      _likes.add(false);
    });
  }

  void _removePhoto(int index) {
    setState(() {
      _photoPaths.removeAt(index);
      _likes.removeAt(index);
    });
  }

  void _toggleLike(int index) {
    setState(() {
      _likes[index] = !_likes[index];
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _profileImagePath = pickedFile.path;
        // Futuramente, esta ação também chamaria um método para salvar
        // a imagem no Firebase Storage e atualizar a URL no Firestore.
      });
    }
  }

  Future<void> _showImageSourceDialog() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Selecionar Imagem'),
          actions: <Widget>[
            TextButton(
              child: Text('Câmera'),
              onPressed: () {
                _pickImage(ImageSource.camera);
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Galeria'),
              onPressed: () {
                _pickImage(ImageSource.gallery);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
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
                            child: _profileImagePath != null
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
              SizedBox(height: 12),
              Text(
                _profileName.isNotEmpty ? _profileName : 'Nome',
                style: TextStyle(
                  fontFamily: 'Inter',
                  color: sunsetDarkPurple,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
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
                  horizontal: 20.0,
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
              /*
                  Flexible(
                    child: GestureDetector(

                      onTap: () {
                        setState(() {
                          _isShowingAlbum = true;
                        });
                      },
                      child: Column(
                        children: [
                          Icon(Icons.photo_album,
                              color:
                              _isShowingAlbum ? sunsetOrange : Colors.grey),
                          Text(
                            'Álbum',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              color:
                              _isShowingAlbum ? sunsetOrange : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
               */
                  Flexible(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _isShowingAlbum = false;
                        });
                      },
                      child: Column(
                        children: [
                          Icon(Icons.star,
                              color:
                              !_isShowingAlbum ? sunsetYellow : Colors.grey),
                          Text(
                            'Medalhas',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              color:
                              !_isShowingAlbum ? sunsetYellow : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: AchievementsGrid(),
                /*
                child: _isShowingAlbum
                    ? PhotoGrid(
                  photoPaths: _photoPaths,
                  likes: _likes,
                  addPhoto: _addPhoto,
                  removePhoto: _removePhoto,
                  toggleLike: _toggleLike,
                )
                    : AchievementsGrid(),
                 */
              ),
            ],
          ),
        ),
      ),
    );
  }
}