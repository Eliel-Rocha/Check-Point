import 'package:checkpointapp/timeline/pagina_comentarios.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PostCard extends StatefulWidget {
  final Map<String, dynamic> post;
  final int postIndex;
  final String currentUser;
  final Function(int, List<Map<String, String>>) updateComments;
  final Function(int) toggleLike;

  const PostCard({
    super.key,
    required this.post,
    required this.postIndex,
    required this.currentUser,
    required this.updateComments,
    required this.toggleLike,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  String _profileImageUrl = 'assets/profile-picture2.png'; // Imagem padrão
  late List<dynamic> _likedBy;
  late int _likes;

  @override
  void initState() {
    super.initState();
    _fetchProfileImage(); // Chama a função para buscar a imagem
    _likedBy = List.from(
      widget.post['likedBy'] ?? [],
    ); // Copia os dados do post para essas variáveis locais
    _likes = widget.post['likes'] ?? 0;
  }

  Future<void> _fetchProfileImage() async {
    final postAuthorUid =
        widget.post['userId']; // <--- ESSENCIAL: PEGA O UID DO AUTOR DO POST

    if (postAuthorUid != null && postAuthorUid.isNotEmpty) {
      try {
        final userDoc =
            await FirebaseFirestore.instance
                .collection('usuarios')
                .doc(postAuthorUid)
                .get();
        if (userDoc.exists && userDoc.data()!.containsKey('foto_perfil')) {
          setState(() {
            _profileImageUrl = userDoc.data()!['foto_perfil'];
          });
        }
      } catch (e) {
        print('Erro ao buscar foto de perfil para $postAuthorUid: $e');
        // Você pode definir uma imagem de erro ou manter a padrão aqui
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final username = widget.post['username'] ?? 'Usuário';
    final handle = widget.post['handle'] ?? '@usuario';
    final caption = widget.post['caption'] ?? '';
    final imagePath = widget.post['image'] ?? 'assets/CheckPoint.png';
    final likedBy = (widget.post['likedBy'] ?? []) as List;
    final likes = widget.post['likes'] ?? 0;
    final comments = widget.post['comments'] ?? [];
    final time = widget.post['time'] ?? '';


    return Card(
      margin: const EdgeInsets.all(10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Usuário
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                CircleAvatar(
                  // AQUI É ONDE A MUDANÇA ACONTECE NO CIRCLEAVATAR
                  backgroundImage:
                      _profileImageUrl.startsWith('http')
                          ? NetworkImage(_profileImageUrl) as ImageProvider
                          : AssetImage(_profileImageUrl) as ImageProvider,
                  onBackgroundImageError: (exception, stackTrace) {
                    setState(() {
                      _profileImageUrl =
                          'assets/profile-picture2.png'; // Volta para a imagem padrão em caso de erro
                    });
                  },
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      username,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(handle, style: const TextStyle(color: Colors.grey)),
                  ],
                ),
              ],
            ),
          ),

          // Conquista
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 10.0,
              vertical: 6.0,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    caption,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Padding(
                  padding: const EdgeInsets.only(right: 40.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.zero, // totalmente quadrada
                    child: Image.asset(
                      imagePath,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Conquista
          // Ações
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 10.0,
              vertical: 8.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  // Acessando toggleLike através de 'widget.'
                  onTap: () async {
                    final user = widget.currentUser;

                    setState(() {
                      if (_likedBy.contains(user)) {
                        _likedBy.remove(user);
                        _likes--;
                      } else {
                        _likedBy.add(user);
                        _likes++;
                      }
                    });

                    // Atualiza no Firebase
                    await FirebaseFirestore.instance
                        .collection('timeline_posts')
                        .doc(
                          widget.post['id'],
                        ) // Certifique-se que seu post tem esse campo 'id'
                        .update({'likedBy': _likedBy, 'likes': _likes});
                  },

                  child: Row(
                    children: [
                      Icon(
                        _likedBy.contains(widget.currentUser)
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color:
                            _likedBy.contains(widget.currentUser)
                                ? Colors.red
                                : Colors.grey,
                      ),
                      const SizedBox(width: 5),
                      Text('$_likes'),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) {
                        return Container(
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(20),
                            ),
                          ),
                          child: DraggableScrollableSheet(
                            expand: false,
                            initialChildSize: 0.85,
                            minChildSize: 0.5,
                            maxChildSize: 0.95,
                            builder: (context, scrollController) {
                              return CommentScreen(
                                // Acessando as propriedades do widget através de 'widget.'
                                post: widget.post,
                                postIndex: widget.postIndex,
                                currentUser: widget.currentUser,
                                updateComments: widget.updateComments,
                              );
                            },
                          ),
                        );
                      },
                    ).then((updatedComments) {
                      if (updatedComments != null) {
                        // Acessando updateComments e postIndex através de 'widget.'
                        widget.updateComments(
                          widget.postIndex,
                          updatedComments as List<Map<String, String>>,
                        );
                      }
                    });
                  },
                  child: Row(
                    children: [
                      const Icon(Icons.comment, color: Colors.grey),
                      const SizedBox(width: 5),
                      Text('${comments.length}'),
                    ],
                  ),
                ),
                Text(time),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
