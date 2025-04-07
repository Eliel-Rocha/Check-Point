import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class SobreoApp extends StatefulWidget {
  @override
  _SobreoAppState createState() => _SobreoAppState();
}

class _SobreoAppState extends State<SobreoApp> {
  final PageController _controller = PageController();

  void _onContinue() {
    Navigator.pushReplacementNamed(context, '/tela_principal');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _controller,
              children: [
                _buildPage(
                  "Bem-vindo!",
                  "Aqui você explora lugares incríveis.",
                  "assets/mapa-de-viagem.png",
                ),
                _buildPage(
                  "Compartilhe",
                  "Publique fotos dos locais visitados.",
                  "assets/voar.png",
                ),
                _buildPage(
                  "Conquiste",
                  "Ganhe medalhas e veja sua evolução!",
                  "assets/medalha.png",
                ),
                _buildCreditosPage(showButton: true),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SmoothPageIndicator(
              controller: _controller,
              count: 4,
              effect: WormEffect(
                dotColor: Colors.grey,
                activeDotColor: Colors.deepOrange,
                dotHeight: 10,
                dotWidth: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreditosPage({bool showButton = false}) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Desenvolvido por:',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          Text(
            'Kathleen',
            style: TextStyle(fontSize: 18),
          ),
          Text(
            'Larissa',
            style: TextStyle(fontSize: 18),
          ),
          Text(
            'Eliel',
            style: TextStyle(fontSize: 18),
          ),
          Text(
            'Ana Késia',
            style: TextStyle(fontSize: 18),
          ),
          Text(
            'Gabriela',
            style: TextStyle(fontSize: 18),
          ),
          if (showButton) ...[
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: _onContinue,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                elevation: 5,
              ),
              child: Text('Continuar'),
            )
          ]
        ],
      ),
    );
  }

  Widget _buildPage(String title, String subtitle, String imagePath) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ShaderMask(
            shaderCallback: (Rect bounds) {
              return LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.purple,
                  Colors.deepOrange,
                ],
              ).createShader(bounds);
            },
            child: ImageIcon(
              AssetImage(imagePath),
              size: 100,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 24),
          Text(title, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          SizedBox(height: 12),
          Text(subtitle, style: TextStyle(fontSize: 18), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}