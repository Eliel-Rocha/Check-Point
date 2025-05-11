import 'package:checkpointapp/BancoDeDados/UserPreferencesServices.dart';
import 'package:checkpointapp/root.dart';
import 'package:checkpointapp/sobre_o_app.dart';
import 'package:flutter/material.dart';

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

  @override
  void initState() {
    super.initState();
    // Carrega cores salvas (se houver) e garante ao menos 2 cores
    final prefs = UserPreferencesService.getThemeColor();
    if (prefs.length >= 2) {
      selectedColors = List.from(prefs);
    }
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
                    minimumSize: Size(double.infinity, 48),
                    backgroundColor: selectedColors.isNotEmpty
                        ? Colors.orange.shade800
                        : Colors.grey,
                  ),
                ),
              ),


              // Final da pagina
              Spacer(),

              // Botão "About the App"
              ListTile(
                leading: Icon(Icons.info),
                title: Text('Sobre o App'),
                onTap: () => Navigator.push(
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
