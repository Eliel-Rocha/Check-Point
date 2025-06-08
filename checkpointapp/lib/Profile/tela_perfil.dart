import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'conquistas.dart';
import 'grade_de_fotos.dart';

class ProfileScreen extends StatefulWidget {
  final String name;
  final String? imagePath;
  final String bio;

  ProfileScreen({
    Key? key,
    required this.name,
    this.imagePath,
    required this.bio,
  }) : super(key: key);



  @override
  ProfileScreenState createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  static const Color sunsetOrange = Color(0xFFFF9933);
  static const Color sunsetPurple = Color(0xFF663399);
  static const Color sunsetYellow = Color(0xFFFFCC33);
  static const Color sunsetLightOrange = Color(0xFFFFB366);
  static const Color sunsetDarkPurple = Color(0xFF4D2973);

  bool _isShowingAlbum = true;
  String _profileName = 'Nome_perfil';
  String? _profileImagePath;
  String _profileBio = "";
  List<String> _photoPaths = [];
  List<bool> _likes = [];
  final ImagePicker _picker = ImagePicker();

  void updateProfile(String name, String? imagePath, String bio) {
    setState(() {
      _profileName = name;
      _profileImagePath = imagePath;
      _profileBio = bio;
    });
  }


  void _updateProfileName(String newName) {
    setState(() {
      _profileName = newName;
    });
  }

  void _updateProfileImage(String? newImagePath) {
    setState(() {
      _profileImagePath = newImagePath;
    });
  }

  void _updateProfileBio(String newBio) {
    setState(() {
      _profileBio = newBio;
    });
  }

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


  Future<void> _showImageSourceDialog() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Selecionar Imagem'),
          content: Text('De onde você quer selecionar a imagem?'),
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
            if (_profileImagePath != null)
              TextButton(
                child: Text('Excluir'),
                onPressed: () {
                  Navigator.of(context).pop();
                  _showDeleteConfirmationDialog();
                },
              ),
          ],
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _profileImagePath = pickedFile.path;
      });
    }
  }

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Excluir Imagem'),
          content: Text('Você tem certeza que deseja excluir esta imagem?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                _deleteProfileImage();
                Navigator.of(context).pop();
              },
              child: Text('Excluir'),
            ),
          ],
        );
      },
    );
  }

  void _deleteProfileImage() {
    setState(() {
      _profileImagePath = null;
    });
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
                  onTap: _showImageSourceDialog,
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
                                    ? Image.file(
                                      File(_profileImagePath!),
                                      fit: BoxFit.cover,
                                    )
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
              Text(
                _profileName,
                style: TextStyle(
                  fontFamily: 'Inter',
                  color: sunsetDarkPurple,
                  letterSpacing: 0.0,
                ),
              ),
              Text(
                '@_do_perfil',
                style: TextStyle(
                  fontFamily: 'Inter',
                  color: sunsetPurple,
                  letterSpacing: 0.0,
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
                  Flexible(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _isShowingAlbum = true;
                        });
                      },
                      child: Column(
                        children: [
                          Icon(Icons.photo_album, color: sunsetOrange),
                          Text(
                            'Álbum',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              color: sunsetOrange,
                              letterSpacing: 0.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Flexible(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _isShowingAlbum = false;
                        });
                      },
                      child: Column(
                        children: [
                          Icon(Icons.star, color: sunsetYellow),
                          Text(
                            'Medalhas',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              color: sunsetYellow,
                              letterSpacing: 0.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child:
                    _isShowingAlbum
                        ? PhotoGrid(
                          photoPaths: _photoPaths,
                          likes: _likes,
                          addPhoto: _addPhoto,
                          removePhoto: _removePhoto,
                          toggleLike: _toggleLike,
                        )
                        : AchievementsGrid(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

