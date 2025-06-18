import 'package:checkpointapp/sobre_o_app.dart';
import 'package:flutter/material.dart';
import 'package:checkpointapp/BancoDeDados/auth_service.dart';
import 'package:checkpointapp/BancoDeDados/user_firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}
//-----------------variaveis para controle de estado------------------------------------------------------------------------------------------------ -----------------------------------------------------------------------------------------------

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _usernameController = TextEditingController(); // ADICIONADO: Controller para o username

  final AuthService _authService = AuthService();
  final UserFirestoreService _userFirestoreService = UserFirestoreService();

  bool _isLoading = false;
  String? _errorMessage;

  bool _usuarioCadastrado = false;
  User? _usuarioAtual;
//-----------------------fim da variaveis para controle de estado------------------------------------------------------------------------------------------------ -----------------------------------------------------------------------------------------------



  //----------------------função de cadastro------------------------------------------------------------------------------------------------
  // MODIFICADO: Função de cadastro agora verifica o username
  Future<void> _cadastrarUsuario() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final usernameDesejado = _usernameController.text.trim();

      bool isAvailable = await _userFirestoreService.isUsernameAvailable(usernameDesejado);
      if (!mounted) return;

      if (!isAvailable) {
        setState(() {
          _errorMessage = 'Este nome de usuário já está em uso.';
          _isLoading = false;
        });
        return;
      }

      final userCredential = await _authService.cadastrarComEmailSenha(
        email: _emailController.text.trim(),
        senha: _senhaController.text.trim(),
        nome: _nomeController.text.trim(),
        username: usernameDesejado,
      );

      await userCredential.user?.sendEmailVerification();
      setState(() {
        _usuarioCadastrado = true;
        _usuarioAtual = userCredential.user;
      });

      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Verifique seu e-mail'),
          content: Text('Enviamos um link de verificação para o seu e-mail.'),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: Text('OK')),
          ],
        ),
      );

    } on FirebaseAuthException catch (e) {
      setState(() => _errorMessage = _authService.traduzirErro(e.code));
    } catch (e) {
      setState(() => _errorMessage = 'Erro ao cadastrar: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
  //----------------------fim da função de cadastro------------------------------------------------------------------------------------------------



  //--------------------------função de verificar email------------------------------------------------------------------------------------------------
  Future<void> _verificarEmailEContinuar() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _usuarioAtual?.reload();
      _usuarioAtual = FirebaseAuth.instance.currentUser;

      if (_usuarioAtual?.emailVerified == true) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => SobreoApp()),
        );
      } else {
        setState(() {
          _errorMessage = "Seu e-mail ainda não foi verificado.";
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Erro ao verificar e-mail: $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  //--------------------------fim da função de verificar email------------------------------------------------------------------------------------------------

  @override
  void dispose() {
    _nomeController.dispose();
    _usernameController.dispose();
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
          child: Form(
            key: _formKey,
            child: ListView(
              children: <Widget>[
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

                ),

                //------------------Email----------------------//
                SizedBox(height: 20),
                TextFormField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: "Nome de Usuário",
                      hintText: "seu_nome_123",
                      prefixText: "@", // Prefixo para indicar que é um handle
                      labelStyle: TextStyle(
                        color: Colors.black38,
                        fontWeight: FontWeight.w400,
                        fontSize: 20,
                      ),
                    ),
                  // Validador para o nome de usuário
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, crie um nome de usuário.';
                    }
                    if (value.contains(' ') || value.contains('@')) {
                      return 'Não pode conter espaços ou @';
                    }
                    if (value.length < 4) {
                      return 'Mínimo de 4 caracteres';
                    }
                    return null;
                  },
                  style: TextStyle(fontSize: 20),
                ),
                SizedBox(height: 10),

                //------------------verificar email----------------------//
                TextFormField(
                  controller: _emailController,
                  validator: (value) {
                    if (value!.isEmpty) return 'Informe seu email';
                    if (!value.contains('@')) return 'Email inválido';
                    return null;
                  },
                  //-----------------fim da validação do campo de e-mail-------------------
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
                //------------------fim emai----------------------//


                //---------------------------Senha-------------------------------
                SizedBox(height: 10),
                TextFormField(
                  controller: _senhaController,
                  //---------------validador de senha----------------------------------------------//
                  validator: (value) => value!.length < 6
                      ? 'Mínimo 6 caracteres'
                      : null,
                  //------------------fim da validação do campo de senha----------------------------------------------//
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

                if (_errorMessage != null)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                //-----------------fim da senha----------------------//


                //-----------------cadastrar----------------------//
                SizedBox(height: 20),

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
                  //---------------ver se o usuario ja esta cadastrado----------------------------------------------//
                  /* essa parte serve para verificar se o usuario ja esta cadastrado e se estiver,
                   ele vai para a tela de sobre o app*/
                  child: _isLoading
                      ? Center(child: CircularProgressIndicator(color: Colors.white))
                      : TextButton(
                    onPressed: _usuarioCadastrado ? _verificarEmailEContinuar : _cadastrarUsuario,
                    child: Text(
                      _usuarioCadastrado ? "Continuar" : "Cadastrar",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 10),

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
