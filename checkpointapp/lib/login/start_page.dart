import 'package:flutter/material.dart';

class StartPage extends StatefulWidget {
  const StartPage({super.key});

  static String routeName = 'HomePage';
  static String routePath = '/homePage';

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {


  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return GestureDetector(

      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },

      child: Stack(

        children: [
          // Gradiente de fundo _____________________________________________________________________________________________________

          Container(
            width: screenWidth,
            height: screenHeight,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF4B39EF),
                  Color(0xFFFF5963),
                  Color(0xFFEE8B60)
                ],
                stops: [0, 0.5, 1],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // Camada semitransparente com gradiente (de cima para baixo) _____________________________________________________________
          Container(
            width: screenWidth,
            height: screenHeight,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromRGBO(255, 255, 255, 0), // Começa transparente
                  Color.fromRGBO(255, 255, 255, 0.7), // Termina semitransparente
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // Conteúdo centralizado sobre a camada semitransparente __________________________________________________________________
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // Centraliza o conteúdo
              crossAxisAlignment: CrossAxisAlignment.center, // Centraliza horizontalmente
              children: [
                // Fotos stackadas (logo) ___________________________________________________________________________________________
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.asset(
                      "assets/circulos.png",
                      width: 300,
                      height: 300,
                      fit: BoxFit.contain,
                    ),
                    Image.asset(
                      "assets/CheckPoint.png",
                      width: 220,
                      height: 220,
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
                // Texto em baixo da logo ___________________________________________________________________________________________
                Text(
                  "Let's connect together",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    decoration: TextDecoration.none, // tirar o sublinhado
                  ),
                ),
                SizedBox(height: 16),
                // Botão Login_______________________________________________________________________________________________________
                Container(
                  width: screenWidth * 0.7, // 70% da largura da tela
                  child: Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 8),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/login'); // Navega para a página de login
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFF07D00),
                        padding: EdgeInsets.all(0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Login',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
                // Botao Cadastro ___________________________________________________________________________________________________
                Container(
                  width: screenWidth * 0.7, // 70% da largura da tela
                  child: Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 8),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/cadastro'); // Navega para a página de login
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFF07D00),
                        padding: EdgeInsets.all(0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Cadastrar',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
