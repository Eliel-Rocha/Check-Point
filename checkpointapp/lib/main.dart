import 'package:checkpointapp/root.dart';
import 'package:flutter/material.dart';
import 'login/login.page.dart';
import 'login/startpage.dart';
import 'login/signup.page.dart';
import 'login/reset-password.page.dart';
import 'timeline/timeline.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple)),
      debugShowCheckedModeBanner: false, // <-- remove o banner
      routes: {
        '/start': (context) => StartPage(), // Página inicial
        '/login': (context) => LoginPage(), // Página de login
        '/cadastro': (context) => SignupPage(), // Página de cadastro
        '/reset-password': (context) => ResetPasswordPage(), // Página de redefinição de senha
        '/timeline': (context) => RootPage(),
        '/tela_principal': (context) => RootPage(),
      },
      home: StartPage(),

    );
  }
}