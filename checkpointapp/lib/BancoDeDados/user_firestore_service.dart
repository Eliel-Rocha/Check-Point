import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart'; // Para obter o ID do usuário logado

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

  //Obter dados do usuário logado
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

/*-------------------------------Metodo para as conquitas obtidas--------------------*/
                           /*cada usuario tera suas propris conquistas*/

  // busca as conquitas, por predio
  Future<List<int>> obterPrediosConquistados() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('Usuário não está logado.');

    final doc = await _db.collection('usuarios').doc(userId).get();
    final data = doc.data();

    if (data == null || !data.containsKey('conquistas')) {
      return [];
    }

    return List<int>.from(data['conquistas']);
  }

  //metodo para adicionar conquistas
  Future<void> adicionarPredioConquistado(int predioId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      print('[ERRO] Usuário não está logado.');
      throw Exception('Usuário não está logado.');
    }

    final userDocRef = _db.collection('usuarios').doc(userId);
    final userSnapshot = await userDocRef.get();

    if (!userSnapshot.exists) {
      print('[ERRO] Documento do usuário não encontrado.');
      throw Exception('Documento do usuário não encontrado.');
    }

    final data = userSnapshot.data() as Map<String, dynamic>? ?? {};
    List<int> conquistasAtuais = [];

    if (data.containsKey('conquistas') && data['conquistas'] != null) {
      conquistasAtuais = List<int>.from(data['conquistas']);
    }

    if (conquistasAtuais.contains(predioId)) {
      print('[INFO] Prédio $predioId já conquistado, não adicionando novamente.');
      return;
    }

    // Adiciona a nova conquista
    conquistasAtuais.add(predioId);

    try {
      // Se o campo não existia, ele será criado com merge:true
      await userDocRef.set({'conquistas': conquistasAtuais}, SetOptions(merge: true));
      print('[SUCESSO] Conquista do prédio $predioId adicionada ao usuário $userId.');
    } catch (e) {
      print('[ERRO] Falha ao atualizar conquistas: $e');
      rethrow;
    }
  }


  //para validar a conquitas
  Future<int?> verificarProximidadeComPredios({required double latitude, required double longitude, double raioMetros = 50}) async {
    final snapshot = await _db.collection('predios').get();

    for (var doc in snapshot.docs) {
      final data = doc.data();
      if (data.containsKey('localizacao')) {
        final geo = data['localizacao'] as GeoPoint;
        final distancia = Geolocator.distanceBetween(latitude, longitude, geo.latitude, geo.longitude);
        if (distancia <= raioMetros) {
          return data['predio']; // Retorna o número do prédio
        }
      }
    }
    return null;
  }
//--------------fim dos metodos de conquistas-------------------------------------




}