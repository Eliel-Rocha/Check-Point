import 'package:checkpointapp/BancoDeDados/user_preferences_services.dart';
import 'package:checkpointapp/Profile/configuracoes_perfil.dart';
import 'package:checkpointapp/root.dart';
import 'package:checkpointapp/sobre_o_app.dart';
import 'package:flutter/material.dart';
import 'package:checkpointapp/BancoDeDados/user_firestore_service.dart';

import 'BancoDeDados/user_firestore_service.dart';

class ConfigPage extends StatefulWidget {
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
    //final savedImagePath = await UserPreferencesService.getProfileImage();
    setState(() {
      // Se houver uma imagem salva, use-a. Caso contrário, _currentSelectedProfileImagePath será null.
      //_currentSelectedProfileImagePath = savedImagePath;
    });
  }

  // Função para apenas *selecionar* a imagem na UI, sem salvar ainda
  void _selectProfileImage(String imagePath) {
    setState(() {
      _currentSelectedProfileImagePath = imagePath;
    });
  }

  // Função para *salvar* a imagem de perfil selecionada
  Future<void> _saveSelectedProfileImage() async {
    if (_currentSelectedProfileImagePath != null && _currentSelectedProfileImagePath!.isNotEmpty) {
      //await UserPreferencesService.setProfileImage(_currentSelectedProfileImagePath!);
      // Exibe um feedback ao usuário
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto de perfil salva com sucesso!')), // Adicionado 'const'
      );
      // Opcional: Você pode querer navegar para outra tela ou recarregar a tela principal
      // para que a nova foto de perfil apareça imediatamente. Exemplo:
      // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const RootPage()));
    } else {
      // Exibe um feedback se nenhuma foto for selecionada
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecione uma foto de perfil.')), // Adicionado 'const'
      );
    }
  }



  final List<String> profileImageOptions = [
    'assets/flamingo.png',
    'assets/pinguim.png',
    'assets/galinha.png',
  ];

  String _currentSelectedProfileImagePath = '';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        // Sem AppBar conforme solicitado
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [

              Align(
                alignment: Alignment.centerLeft,
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
                    backgroundColor: _currentSelectedProfileImagePath != null
                        ? UserPreferencesService.getThemeColor().first
                        : Colors.grey,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),

              SizedBox(height: 16),


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
                onPressed: _currentSelectedProfileImagePath != null
                    ? _saveSelectedProfileImage // Chama a função de salvar
                    : null, // Desabilita o botão se nenhuma foto for selecionada
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  backgroundColor: _currentSelectedProfileImagePath != null
                      ? UserPreferencesService.getThemeColor().first
                      : Colors.grey,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Salvar Foto de Perfil'),
              ),

              // Final da pagina
              Spacer(),

              //TODO: implementar ir pra pagina de configurações do perfil
              // Botão de configurações do perfil
              /*ListTile(
                  leading: Icon(Icons.settings),
                  title: Text('Configurações do Perfil'),
                  onTap: () {
                    //var dados = UserFirestoreService.getDadosUsuarioLogado();
                    /*Navigator.push(
                      context,
                      SettingsScreen(
                          initialName: dados[],
                          initialImagePath: initialImagePath,
                        initialBio: initialBio,
                        onSave: onSave)
                  )*/
                  }
              ),
*/

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
        ),
      ),
    );
  }
}