import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Singleton
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // CADASTRO COMPLETO (Auth + Firestore)
  Future<UserCredential> cadastrarComEmailSenha({
    required String email,
    required String senha,
    required String nome,
  }) async {
    try {
      // 1. Cria usuário no Auth (senha fica aqui)
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: senha,
      );

      // 2. Atualiza nome no perfil do Auth
      await userCredential.user?.updateDisplayName(nome);


      return userCredential;
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      throw Exception('Erro durante o cadastro: $e');
    }
  }

  // LOGIN (Mantém seguro no Auth)
  Future<UserCredential> loginComEmailSenha({
    required String email,
    required String senha,
  }) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(), // Adiciona trim() para remover espaços
        password: senha,
      );

      // Verifica se o e-mail foi verificado
      if (!userCredential.user!.emailVerified) {
        await logout();
        throw FirebaseAuthException(
          code: 'email-not-verified',
          message: 'Por favor, verifique seu e-mail antes de fazer login',
        );
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      // Adiciona tratamento para usuário desabilitado
      if (e.code == 'user-disabled') {
        throw FirebaseAuthException(
          code: 'user-disabled',
          message: 'Esta conta foi desativada',
        );
      }
      rethrow;
    }
  }

  //RESETAR SENHA
  Future<void> enviarEmailDeRedefinicaoDeSenha({
    required String email})

    async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw e;
    } catch (e) {
      throw Exception('Erro ao enviar email de redefinição: $e');
    }
  }


  // LOGOUT
  Future<void> logout() async {
    await _auth.signOut();
  }

  // EXCLUIR CONTA
  Future<void> excluirConta({
    required String email,
    required String senha,
  }) async {
    try {
      User? currentUser = _auth.currentUser;

      if (currentUser != null) {
        // Reautenticar o usuário
        final credenciais = EmailAuthProvider.credential(email: email, password: senha);
        await currentUser.reauthenticateWithCredential(credenciais);

        // Excluir do Firestore
        await _firestore.collection('usuarios').doc(currentUser.uid).delete();

        // Excluir do Auth
        await currentUser.delete();

        print('Conta excluída com sucesso.');
      } else {
        throw Exception('Nenhum usuário logado para excluir.');
      }
    } on FirebaseAuthException catch (e) {
      print('Erro ao excluir conta: ${e.code} - ${e.message}');
      throw FirebaseAuthException(code: e.code, message: traduzirErro(e.code));
    } catch (e) {
      print('Erro inesperado ao excluir conta: $e');
      throw Exception('Erro inesperado ao excluir conta: $e');
    }
  }




  // STREAM DE AUTENTICAÇÃO
  Stream<User?> get userChanges => _auth.authStateChanges();

  // TRADUÇÃO DE ERROS 
  String traduzirErro(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'E-mail já cadastrado.';
      case 'weak-password':
        return 'Senha fraca (mínimo 6 caracteres).';
      case 'invalid-email':
        return 'E-mail inválido.';
      case 'user-not-found':
        return 'Usuário não encontrado.';
      case 'wrong-password':
        return 'Senha incorreta.';
      case 'network-request-failed':
        return 'Sem conexão com a internet.';
      default:
        return 'Erro: ${code.replaceAll('-', ' ')}';
    }
  }
}