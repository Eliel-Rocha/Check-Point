import 'package:checkpointapp/root.dart';
import 'package:checkpointapp/sobre_o_app.dart';
import 'package:flutter/material.dart';
import 'root.dart';
import 'login/login_page.dart';
import 'login/startpage.dart';
import 'login/signup.page.dart';
import 'login/reset-password.page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Checkpoint App',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple)),
      debugShowCheckedModeBanner: false, // <-- remove o banner
      routes: {
        '/start': (context) => StartPage(), // Página inicial
        '/login': (context) => LoginPage(), // Página de login
        '/cadastro': (context) => SignupPage(), // Página de cadastro
        '/reset-password': (context) => ResetPasswordPage(), // Página de redefinição de senha
        '/tela_principal': (context) => RootPage(),
        '/sobre_o_app': (context) => SobreoApp(),
      },
      home: StartPage(),

    );
  }
}