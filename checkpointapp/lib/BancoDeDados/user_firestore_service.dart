import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Para obter o ID do usuário logado

class UserFirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Singleton instance (opcional)
  static final UserFirestoreService _instance = UserFirestoreService._internal();
  factory UserFirestoreService() {
    return _instance;
  }
  UserFirestoreService._internal();


  // Método para salvar dados iniciais do usuário no Firestore
  Future<void> salvarDadosIniciaisUsuario({
    required String userId, // ID do usuário obtido do Firebase Auth
    required String nome,
    required String email,
    // Adicione outros campos que você coleta no cadastro
  }) async {
    try {
      await _db.collection('usuarios').doc(userId).set({
        'nome': nome,
        'email': email,
        'data_cadastro': FieldValue.serverTimestamp(), // Adiciona um timestamp do servidor
        // ... outros campos
      });
    } catch (e) {
      print('Erro ao salvar dados iniciais do usuário: $e');
      throw e;
    }
  }

  // Exemplo: Obter dados do usuário logado
  Future<Map<String, dynamic>?> getDadosUsuarioLogado() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      return null; // Retorna null se não houver usuário logado
    }
    try {
      DocumentSnapshot doc = await _db.collection('usuarios').doc(userId).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      } else {
        return null; // Retorna null se o documento do usuário não existir
      }
    } catch (e) {
      print('Erro ao obter dados do usuário: $e');
      throw e;
    }
  }

//--------------------------------metodo de logout--------------------------------//



}