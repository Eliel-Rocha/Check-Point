import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:checkpointapp/BancoDeDados/auth_service.dart';
import 'package:checkpointapp/Login/start_page.dart';

class SettingsScreen extends StatefulWidget {
  final String initialName;
  final String? initialImagePath;
  final String initialBio;
  final Function(String, String?, String) onSave;

  SettingsScreen({
    required this.initialName,
    required this.initialImagePath,
    required this.initialBio,
    required this.onSave,
  });

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  String? _imagePath;
  final ImagePicker _picker = ImagePicker();
  late String _tempName;
  late String? _tempImagePath;
  late String _tempBio;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _bioController = TextEditingController(text: widget.initialBio);
    _imagePath = widget.initialImagePath;
    _tempName = widget.initialName;
    _tempImagePath = widget.initialImagePath;
    _tempBio = widget.initialBio;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
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
            if (_imagePath != null)
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
        _imagePath = pickedFile.path;
        _tempImagePath = pickedFile.path;
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
      _imagePath = null;
      _tempImagePath = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Configurações'),
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () {
              widget.onSave(_tempName, _tempImagePath, _tempBio);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: _showImageSourceDialog,
              child: CircleAvatar(
                radius: 50,
                backgroundImage:
                    _imagePath != null ? FileImage(File(_imagePath!)) : null,
                child: _imagePath == null ? Icon(Icons.person, size: 50) : null,
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Nome'),
              onChanged: (value) {
                _tempName = value;
              },
            ),
            SizedBox(height: 20),
            TextField(
              controller: _bioController,
              decoration: InputDecoration(labelText: 'Biografia'),
              maxLines: 3,
              onChanged: (value) {
                _tempBio = value;
              },
            ),

            //---------------logout---------------------------------------------------
            SizedBox(height: 20),
            TextButton(
              // Usando TextButton para uma ação secundária em configurações
              onPressed: () async {
                try {
                  // Use a instância correta do AuthService
                  final AuthService authService = AuthService();
                  await authService.logout(); // metodo deslogar

                  // Navega para a tela inicial e remove todas as rotas anteriores
                  // Isso acionará o AuthWrapper para navegar para a tela de login/cadastro
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => StartPage(),
                    ), // tela inicial
                    (Route<dynamic> route) => false, // Remove todas as rotas
                  );
                } catch (e) {
                  print('Erro ao fazer logout: $e');
                  // Mostrar um Snackbar ou AlertDialog para o usuário
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erro ao fazer logout: $e'),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                }
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
                textStyle: TextStyle(fontSize: 18),
              ),
              child: Text('Sair'),
            ),

            //--------------------------------------fim do logout--------------------------------------------------
          ],
        ),
      ),
    );
  }
}
