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
                  Icons.map,
                ),
                _buildPage(
                  "Compartilhe",
                  "Publique fotos dos locais visitados.",
                  Icons.photo,
                ),
                _buildPage(
                  "Conquiste",
                  "Ganhe medalhas e veja sua evolução!",
                  Icons.emoji_events,
                  showButton: true,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SmoothPageIndicator(
              controller: _controller,
              count: 3,
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

  Widget _buildPage(String title, String subtitle, IconData icon, {bool showButton = false}) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 100, color: Colors.deepOrange),
          SizedBox(height: 24),
          Text(title, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          SizedBox(height: 12),
          Text(subtitle, style: TextStyle(fontSize: 18), textAlign: TextAlign.center),
          if (showButton) ...[
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: _onContinue,
              child: Text('Continuar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
            )
          ]
        ],
      ),
    );
  }
}
