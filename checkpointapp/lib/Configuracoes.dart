import 'package:checkpointapp/BancoDeDados/user_preferences_services.dart';
import 'package:checkpointapp/Profile/configuracoes_perfil.dart';
import 'package:checkpointapp/root.dart';
import 'package:checkpointapp/sobre_o_app.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:checkpointapp/BancoDeDados/user_firestore_service.dart';

class ConfigPage extends StatefulWidget {

  final VoidCallback onOpenProfileSettings;

  const ConfigPage({
    super.key,
    required this.onOpenProfileSettings
  });

  @override
  State<ConfigPage> createState() => _ConfigPageState();
}

class _ConfigPageState extends State<ConfigPage> {
  // Lista de cores selecionadas pelo usuário
  List<Color> selectedColors = [];

  // Opções de cores disponíveis
  final List<Color> colorOptions = [
    Color(0xFFFF9933),
    Color(0xFF663399),
    Colors.deepPurple.shade800,
    Colors.blue.shade800,
    Colors.green.shade800,
    Colors.red.shade900,
  ];

  /*
    Color(0xFFFF9933),
    Color(0xFFFF9933),
    Color(0xFFC885BA),
    Color(0xFF663399),
    Color(0xFF663399)
    */

  final List<String> profileImageOptions = [
    'assets/flamingo.png',
    'assets/pinguim.png',
    'assets/galinha.png',
    //'assets/profile-picture2.png',      // Imagem padrão de foto de perfil
  ];

  String _currentSelectedProfileImagePath = '';

  @override
  void initState() {
    super.initState();
    // Carrega cores salvas (se houver) e garante ao menos 2 cores
    final prefs = UserPreferencesService.getThemeColor();
    if (prefs.length >= 2) {
      selectedColors = List.from(prefs);
    }
    _loadInitialProfileImage();

  }

  void toggleColor(Color color) {
    setState(() {
      if (selectedColors.contains(color)) {
        selectedColors.remove(color);
      } else {
        selectedColors.add(color);
      }
    });
  }

  // Função para carregar a imagem de perfil salva e definir como a atualmente selecionada
  Future<void> _loadInitialProfileImage() async {
    // Obter a foto do banco!
    final usuarioDoc = await FirebaseFirestore.instance.collection('usuarios').doc(FirebaseAuth.instance.currentUser?.uid).get();
    //final usuarioDoc = await UserFirestoreService().getDadosUsuarioLogado();
    final foto = usuarioDoc.data()?['foto_perfil'] ?? 'assets/profile-picture2.png';

    setState(() {
      _currentSelectedProfileImagePath =  foto;
    });
  }


  // Função para apenas *selecionar* a imagem na UI, sem salvar ainda
  Future<void> _selectProfileImage(String imagePath) async {

    setState(() {
      _currentSelectedProfileImagePath =  imagePath;
    });
  }


  // Função para *salvar* a imagem de perfil selecionada
  Future<void> _saveSelectedProfileImage() async {

    // A imagem tem conteudo??
    if (_currentSelectedProfileImagePath != null && _currentSelectedProfileImagePath!.isNotEmpty) {
        await FirebaseFirestore.instance.collection('usuarios').doc(FirebaseAuth.instance.currentUser?.uid)
          .set({'foto_perfil': _currentSelectedProfileImagePath}, SetOptions(merge: true));

        // Exibe um feedback ao usuário
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto de perfil salva com sucesso!')),
      );
      // Recarregar a tela principal opcional(?)
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) =>  RootPage()));

    // Exibe um feedback se nenhuma foto for selecionada
    } else {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecione uma foto de perfil.')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(

        body: Container(
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
              image: AssetImage('assets/mapadefundo.png'),
              repeat: ImageRepeat.repeat,
              opacity: 0.05,
            ),
          ),
          child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [

              Align(
                alignment: Alignment.center,
                child: Text(
                  'Selecione ao menos 2 cores:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: selectedColors.isNotEmpty
                        ? selectedColors.first
                        : Colors.black,
                  ),
                ),
              ),


              // Botão de salvar tema

              SizedBox(height: 12),

              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: colorOptions.map((color) {
                  final isSelected = selectedColors.contains(color);
                  return GestureDetector(
                    onTap: () => toggleColor(color),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? Colors.black : Colors.transparent,
                          width: 3,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: ElevatedButton(
                  onPressed: selectedColors.length >= 2
                      ? () async {
                    await UserPreferencesService.setThemeColor(selectedColors);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Tema salvo com sucesso!')),
                    );

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => RootPage()),
                    );
                  } : null,

                  child: Text('Salvar Tema'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                    backgroundColor: UserPreferencesService.getThemeColor().first ,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),

              SizedBox(height: 30),


              Text(
                'Escolha sua Foto de Perfil:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: selectedColors.isNotEmpty
                      ? selectedColors.first
                      : Colors.black,
                ),
              ),
              const SizedBox(height: 12),

              //  OPCÕES DE FOTOSS ______
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: profileImageOptions.map((imagePath) {
                  final isSelected = _currentSelectedProfileImagePath == imagePath;
                  return GestureDetector(
                    onTap: () => _selectProfileImage(imagePath), // Apenas seleciona, não salva
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? UserPreferencesService.getThemeColor().first : Colors.grey.shade300,
                          width: isSelected ? 4 : 2,
                        ),
                        image: DecorationImage(
                          image: AssetImage(imagePath),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 15), // Espaço entre as miniaturas e o botão

              //BOTÃO DE SALVAR FOTO DE PERFIl ________
              ElevatedButton(
                onPressed: _saveSelectedProfileImage,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  backgroundColor: UserPreferencesService.getThemeColor().first,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Salvar Foto de Perfil'),
              ),

              // Final da pagina
              Spacer(),

              // Botão de configurações do perfil
              ListTile(
                  leading: Icon(Icons.settings),
                  title: Text('Configurações do Perfil'),
                  onTap: () {
                    //var dados = UserFirestoreService().getDadosUsuarioLogado();
                    widget.onOpenProfileSettings();

                  }
              ),


              // Botão "About the App"
              ListTile(
                leading: Icon(Icons.info),
                title: Text('Sobre o App'),
                onTap: () =>
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => SobreoApp()),
                    ),
              ),


            ],
          ),
        ),),
      ),
    );
  }
}