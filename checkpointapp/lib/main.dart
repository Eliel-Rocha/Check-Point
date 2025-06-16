import 'package:checkpointapp/root.dart';
import 'package:checkpointapp/sobre_o_app.dart';
import 'package:flutter/material.dart';
import 'BancoDeDados/user_preferences_services.dart';
import 'Login/login_page.dart';
import 'Login/start_page.dart';
import 'Login/signup_page.dart';
import 'Login/reset_password_page.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    // Tema e configurações iniciais
    await UserPreferencesService.loadPreferences();

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase inicializado com sucesso!');
  } catch (e) {
    print('Erro ao inicializar Firebase: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Checkpoint App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      debugShowCheckedModeBanner: false,

      // Rotas
      routes: {
        '/start': (context) => StartPage(),
        '/login': (context) => LoginPage(),
        '/cadastro': (context) => SignupPage(),
        '/reset-password': (context) => ResetPasswordPage(),
        '/tela_principal': (context) => RootPage(),
        '/sobre_o_app': (context) => SobreoApp(),
      },

      // O 'home' agora verifica o estado de autenticação(se ta logado ou não)
      home: StreamBuilder<User?>(
        // O stream do Firebase Authentication para observar as mudanças de estado.
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // Verifica o estado da conexão com o stream.
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Enquanto o Firebase está verificando, exibe um indicador de carregamento.
            return Scaffold(body: Center(child: CircularProgressIndicator()));
          } else if (snapshot.hasData) {
            // Se há dados no snapshot (um objeto User não nulo), o usuário está logado.
            // Retorna a sua tela principal (RootPage, conforme suas rotas).
            return RootPage();
          } else {
            // Se não há dados no snapshot, o usuário não está logado.
            // Retorna a tela inicial ou de login.escolher entre StartPage e LoginPage.
            return StartPage(); // Ou LoginPage()
          }
        },
      ),
    );
  }
}
