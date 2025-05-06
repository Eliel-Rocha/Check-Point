import 'package:checkpointapp/sobre_o_app.dart';
import 'package:flutter/material.dart';
import 'package:checkpointapp/BancoDeDados/auth_service.dart';
import 'package:checkpointapp/BancoDeDados/user_firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'package:shared_preferences/shared_preferences.dart';

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {

  // Variáveis para armazenar os dados do usuário
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();

  //variaveis para o firebase, auth e firestore serve para acessar o banco de dados
  final AuthService _authService = AuthService();
  final UserFirestoreService _userFirestoreService = UserFirestoreService();

  // Variáveis para controle de estado
  bool _isLoading = false;
  String? _errorMessage;

  //-------------- função para cadastrar usuário -----------------//
  Future<void> _cadastrarUsuario() async {
    // Verifica se o formulário é válido
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        // Inicia o cadastro no Firebase Auth
        debugPrint('Iniciando cadastro...');

        // Cadastra o usuário no Firebase Auth
        final userCredential = await _authService.cadastrarComEmailSenha(
          email: _emailController.text.trim(),
          senha: _senhaController.text.trim(),
          nome: _nomeController.text.trim(),
        );

        // Salva os dados iniciais do usuário no Firestore
        debugPrint('Usuário criado no Auth: ${userCredential.user?.uid}');

        // Salva os dados iniciais do usuário no Firestore
        if (userCredential.user?.uid != null) {
          await _userFirestoreService.salvarDadosIniciaisUsuario(
            userId: userCredential.user!.uid,
            nome: _nomeController.text.trim(),
            email: _emailController.text.trim(),
          );
          debugPrint('Dados salvos no Firestore');
        }

        // Salva o ID do usuário no SharedPreferences
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => SobreoApp()),
        );
      } on FirebaseAuthException catch (e) {
        debugPrint('Erro no cadastro: ${e.code}');
        setState(() {
          _errorMessage = _authService.traduzirErro(e.code);
        });
      } catch (e) {
        debugPrint('Erro geral: $e');
        setState(() {
          _errorMessage = 'Erro ao cadastrar: $e';
        });
      } finally {
        setState(() => _isLoading = false);
      }
    } else {
      debugPrint('Formulário inválido');
    }
  }

  @override
  void dispose() {
    // Limpa os controladores quando o widget é destruído
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          padding: EdgeInsets.only(top: 10, left: 40, right: 40),
          color: Colors.white,
          child: Form( // Adicionei o Form aqui
            key: _formKey,
            child: ListView(
              children: <Widget>[
                // Foto de perfil
                Container(
                  width: 150,
                  height: 150,
                  alignment: Alignment(0.0, 1.15),
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/profile-picture2.png"),
                      fit: BoxFit.fitHeight,
                    ),
                  ),
                  child: Container(
                    height: 56,
                    width: 56,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        stops: [0.3, 1.0],
                        colors: [
                          Color(0xFFF58524),
                          Color(0XFFF92B7F),
                        ],
                      ),
                      border: Border.all(
                        width: 4.0,
                        color: const Color(0xFFFFFFFF),
                      ),
                      borderRadius: BorderRadius.all(
                        Radius.circular(56),
                      ),
                    ),
                    child: SizedBox.expand(
                      child: TextButton(
                        child: Icon(
                          Icons.add,
                          color: Colors.white,
                        ),
                        onPressed: () {},
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 20),

                // Input nome
                TextFormField(
                  //aqui é onde eu coloco o controlador e o validator,
                  // para validar se o campo está vazio ou não
                  controller: _nomeController,
                  validator: (value) => value!.isEmpty ? 'Informe seu nome' : null,
                  decoration: InputDecoration(
                    labelText: "Nome",
                    labelStyle: TextStyle(
                      color: Colors.black38,
                      fontWeight: FontWeight.w400,
                      fontSize: 20,
                    ),
                  ),
                  style: TextStyle(fontSize: 20),
                ),

                SizedBox(height: 10),

                // Input email
                TextFormField(
                  //aqui é onde eu coloco o controlador e o validator, para validar se o campo está vazio ou não
                  controller: _emailController,
                  validator: (value) {
                    if (value!.isEmpty) return 'Informe seu email';
                    if (!value.contains('@')) return 'Email inválido';
                    return null;
                  },
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: "E-mail",
                    labelStyle: TextStyle(
                      color: Colors.black38,
                      fontWeight: FontWeight.w400,
                      fontSize: 20,
                    ),
                  ),
                  style: TextStyle(fontSize: 20),
                ),

                SizedBox(height: 10),

                // Input senha
                TextFormField(
                  //aqui é onde eu coloco o controlador e o validator,
                  //para validar se o campo está vazio ou não
                  controller: _senhaController,
                  validator: (value) => value!.length < 6
                      ? 'Mínimo 6 caracteres'
                      : null,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "Senha",
                    labelStyle: TextStyle(
                      color: Colors.black38,
                      fontWeight: FontWeight.w400,
                      fontSize: 20,
                    ),
                  ),
                  style: TextStyle(fontSize: 20),
                ),

                // Mensagem de erro
                if (_errorMessage != null)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: Colors.red),
                    ),
                  ),

                SizedBox(height: 20),

                // Botão cadastrar - CORRIGIDO
                Container(
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      stops: [0.3, 1],
                      colors: [
                        Color(0xFFF58524),
                        Color(0XFFF92B7F),
                      ],
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                  ),
                  child: _isLoading
                      ? Center(child: CircularProgressIndicator(color: Colors.white))
                      : TextButton(
                    //aqui eu coloco a função de cadastrar, que está no auth_service.dart.
                    onPressed: _cadastrarUsuario,
                    child: Text(
                      "Cadastrar",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 10),

                // Botão cancelar
                Container(
                  height: 40,
                  alignment: Alignment.center,
                  child: TextButton(
                    child: Text("Cancelar"),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}