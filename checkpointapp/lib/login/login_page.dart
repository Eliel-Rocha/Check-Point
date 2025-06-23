import 'dart:async';

import 'reset_password_page.dart';
import 'signup_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:checkpointapp/BancoDeDados/auth_service.dart';
import 'package:checkpointapp/sobre_o_app.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Variáveis para controle de estado
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  @override
  // Limpa os campos ao sair da tela
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  //-------------------------Função de login--------------------------------------------------------------------------------
  Future<void> _login() async {
    // Verifica se o formulário é válido
    if (!mounted) return;
    if (_formKey.currentState == null || !_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, preencha os campos corretamente')),
      );
      return;
    }

    // Inicia o login
    setState(() => _isLoading = true);

    // Tenta fazer o login
    try {
      print('Tentando login com: ${_emailController.text}');

      // Use o AuthService para fazer o login
      final userCredential = await _authService
          .loginComEmailSenha(
            email: _emailController.text.trim(),
            senha: _passwordController.text,
          )
          .timeout(Duration(seconds: 15));

      // Verifica se o e-mail foi verificado
      print('Login bem sucedido: ${userCredential.user?.uid}');

      if (!mounted) return;

      // Navega para a tela de sobre o app
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => SobreoApp()),
        (Route<dynamic> route) => false,
      );
    }
    // Trata erros
    on FirebaseAuthException catch (e) {
      print('Erro Firebase: ${e.code}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_authService.traduzirErro(e.code)),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
    // Trata outros erros kkkk
    on TimeoutException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tempo excedido. Verifique sua conexão.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
    // Trata outros erros tbm kkkk
    catch (e) {
      print('Erro desconhecido: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro durante o login: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
  //-----------------------fim da função de login--------------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.black38,
          onPressed: () => Navigator.pushNamed(context, '/start'),
        ),
      ),
      body: Container(
        padding: EdgeInsets.only(top: 60, left: 40, right: 40),
        color: Colors.white,
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              SizedBox(
                width: 100,
                height: 100,
                child: Image.asset("assets/CheckPoint.png"),
              ),
              SizedBox(height: 20),

              //--------------------------Email---------------------------------
              TextFormField(
                //controler para pegar o valor do campo
                controller: _emailController,
                keyboardType:
                    TextInputType
                        .emailAddress, //keyboard para o teclado do celular

                decoration: InputDecoration(
                  labelText: "E-mail",
                  labelStyle: TextStyle(
                    color: Colors.black38,
                    fontWeight: FontWeight.w400,
                    fontSize: 20,
                  ),
                ),

                //-----------validação do campo de e-mail------------------------------------------------------------------------------------------------
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira seu e-mail';
                  }
                  if (!value.contains('@')) {
                    return 'E-mail inválido';
                  }
                  return null;
                },

                style: TextStyle(fontSize: 20),
              ),
              //------------------fim da validação do campo e do e-mail------------------------------------------------------------------------------------------------

              //-----------------------------------Senha------------------------------------------------------------------------------------------------
              SizedBox(height: 10),
              TextFormField(
                controller:
                    _passwordController, //controler para pegar o valor do campo
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Senha",
                  labelStyle: TextStyle(
                    color: Colors.black38,
                    fontWeight: FontWeight.w400,
                    fontSize: 20,
                  ),
                ),

                //------------validação do campo de senha-----------------------//
                //validação do campo de senha
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira sua senha';
                  }
                  if (value.length < 6) {
                    return 'Senha deve ter pelo menos 6 caracteres';
                  }
                  return null;
                },

                style: TextStyle(fontSize: 20),
              ),

              //--------------------fim da senha------------------------------------------------------------------------------------------------
              Container(
                height: 40,
                alignment: Alignment.centerRight,
                child: TextButton(
                  child: Text("Recuperar Senha", textAlign: TextAlign.right),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ResetPasswordPage(),
                      ),
                    );
                  },
                ),
              ),

              SizedBox(height: 40),

              // Botão Login
              Container(
                height: 60,
                alignment: Alignment.centerLeft,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    stops: [0.3, 1],
                    colors: [Color(0xFFF58524), Color(0XFFF92B7F)],
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                ),
                child: SizedBox.expand(
                  child: TextButton(
                    //-------------------------------função de login------------------------------------------------------------------------------------------------
                    onPressed: _isLoading ? null : _login,

                    //----------fima da função de login------------------------------------------------------------------------------------------------
                    child:
                        _isLoading
                            ? CircularProgressIndicator(color: Colors.white)
                            : Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  "Login",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 20,
                                  ),
                                ),
                                Image.asset(
                                  "assets/login-icon.png",
                                  height: 28,
                                  width: 28,
                                ),
                              ],
                            ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
