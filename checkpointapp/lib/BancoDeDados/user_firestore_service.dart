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
    required String userId,
    required String nome,
    required String email,
    required String username,
  }) async {
    try {
      await _db.collection('usuarios').doc(userId).set({
        'nome': 'Name',
        'email': email,
        'username': username.toLowerCase(),
        'bio': 'Olá! Sou novo por aqui.',
        'data_cadastro': FieldValue.serverTimestamp(),
        'foto_deperfil' : 'assets/images/perfil1.png'
      });
    } catch (e) {
      print('Erro ao salvar dados iniciais do usuário: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getDadosUsuarioLogado() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return null;
    try {
      DocumentSnapshot doc = await _db.collection('usuarios').doc(userId).get();
      return doc.exists ? doc.data() as Map<String, dynamic> : null;
    } catch (e) {
      print('Erro ao obter dados do usuário: $e');
      rethrow;
    }
  }

  Future<bool> isUsernameAvailable(String username) async {
    // Tenta ler um documento cujo ID é o próprio nome de usuário
    final doc = await _db.collection('usernames').doc(username.toLowerCase()).get();

    // Se o documento NÃO existe, o nome de usuário está disponível
    return !doc.exists;
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


//--------------------------metodos nome e bio-----------------------------
  Future<void> atualizarDadosUsuario(Map<String, dynamic> dadosParaAtualizar) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('Usuário não está logado.');
    try {
      await _db.collection('usuarios').doc(userId).update(dadosParaAtualizar);
    } catch (e) {
      print('[ERRO] Falha ao atualizar dados do usuário: $e');
      rethrow;
    }
  }

}

//-----------------Time line-----------------------
class TimelineService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<void> publicarConquistaNaTimeline(String tituloConquista, String imagemConquista) async {
    final user = _auth.currentUser;

    if (user == null) {
      print('[ERRO] Usuário não está logado.');
      return;
    }

    print('Publicando conquista "$tituloConquista" para o usuário ${user.uid}');

    final usuarioDoc = await _db.collection('usuarios').doc(user.uid).get();
    final nomeUsuario = usuarioDoc.data()?['nome'] ?? 'Usuário';
    final handleUsuario = usuarioDoc.data()?['username'] ?? '@usuario';

    final novoPost = {
      'username': nomeUsuario,
      'handle': '@$handleUsuario',
      'userId': user.uid,
      'caption': 'Acabei de conquistar: $tituloConquista! 🏆',
      'likes': 0,
      'likedBy': [],
      'commentsNum': 0,
      'comments': [],
      'image': imagemConquista,
      'timestamp': FieldValue.serverTimestamp()
    };

    try {
      await _db.collection('timeline_posts').add(novoPost);
      print('[SUCESSO] Post enviado para timeline.');
    } catch (e) {
      print('[ERRO] Falha ao enviar post para timeline: $e');
    }
  }
}