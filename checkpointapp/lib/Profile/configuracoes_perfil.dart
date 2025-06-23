import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:checkpointapp/BancoDeDados/auth_service.dart';
import '../login/login_page.dart';

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
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 16.0,
          right: 16.0,
          top: 16.0,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child:  Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              // SELECIONAR FOTO DE PERFIl da camera/ galeria (destivado)
              //onTap: _showImageSourceDialog,
              child: CircleAvatar(
                radius: 50,
                //backgroundImage: FileImage(File(_imagePath!)),
                child: Image.asset(_imagePath!),
                //child: _imagePath == null ? Icon(Icons.person, size: 50) : null,
              )
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

            TextButton(
              onPressed: () async {
                final TextEditingController emailController =
                TextEditingController();
                final TextEditingController senhaController =
                TextEditingController();

                // Mostra um dialog para o usuário inserir email e senha
                await showDialog (
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text('Confirmação'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Digite seu e-mail e senha para confirmar a exclusão.',
                          ),
                          TextField(
                            controller: emailController,
                            decoration: InputDecoration(labelText: 'E-mail'),
                          ),
                          TextField(
                            controller: senhaController,
                            decoration: InputDecoration(labelText: 'Senha'),
                            obscureText: true,
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text('Cancelar'),
                        ),


                        TextButton(
                          onPressed: () async {

                            try {
                              final authService = AuthService();
                              await authService.excluirConta(
                                email: emailController.text.trim(),
                                senha: senhaController.text.trim(),
                              );


                              Navigator.of(context).pop();

                              // vai pra a StartPage
                              Navigator.of(
                                  context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                    builder: (context) => StartPage(),
                                  ),
                                      (route) => false
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('$e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                          child: Text('Confirmar'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: Text('Excluir Conta'),
            ),
          ],
        ),
      ),
    );
  }
}
