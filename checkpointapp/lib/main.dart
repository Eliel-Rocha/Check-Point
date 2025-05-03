import 'package:checkpointapp/root.dart';
import 'package:checkpointapp/sobre_o_app.dart';
import 'package:flutter/material.dart';
import 'root.dart';
import 'login/login_page.dart';
import 'login/startpage.dart';
import 'login/signup.page.dart';
import 'login/reset-password.page.dart';

import 'package:firebase_core/firebase_core.dart';//precisa disso aqui
import 'firebase_options.dart'; // Arquivo gerado pelo flutterfire configure


void main() async {  // Adicione 'async' aqui
  // Inicialize o Firebase antes de rodar o app, para rodar junto com o firebase,so isso mesmo e as dependencias
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Checkpoint App',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple)),
      debugShowCheckedModeBanner: false,
      routes: {
        '/start': (context) => StartPage(),
        '/login': (context) => LoginPage(),
        '/cadastro': (context) => SignupPage(),
        '/reset-password': (context) => ResetPasswordPage(),
        '/tela_principal': (context) => RootPage(),
        '/sobre_o_app': (context) => SobreoApp(),
      },
      home: StartPage(),
    );
  }
}