import 'package:checkpointapp/timeline/pagina_comentarios.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PostCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final username = post['username'] ?? 'Usuário';
    final handle = post['handle'] ?? '@usuario';
    final caption = post['caption'] ?? '';
    final imagePath = post['image'] ?? 'assets/CheckPoint.png';
    final likedBy = (post['likedBy'] ?? []) as List;
    final likes = post['likes'] ?? 0;
    final comments = post['comments'] ?? [];
    final time = post['time'] ?? '';

    //********************************************************************************************
    // TODO: Lógica limpa que busca os dados do usuario de acordo com o UID fornecido
    // DEVERIA ESTAR no init state??
    //final usuarioDoc = await FirebaseFirestore.instance.collection('usuarios').doc(currentUser.uid).get();
    //final foto = usuarioDoc.data()?['foto_perfil'] ?? 'assets/profile-picture2.png';

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
                const CircleAvatar(
                  backgroundImage: AssetImage('assets/galinha.png'),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(username, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(handle, style: const TextStyle(color: Colors.grey)),
                  ],
                ),
              ],
            ),
          ),

          // Conquista
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    caption,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
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

          // Ações
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => toggleLike(postIndex),
                  child: Row(
                    children: [
                      Icon(
                        likedBy.contains(currentUser) ? Icons.favorite : Icons.favorite_border,
                        color: likedBy.contains(currentUser) ? Colors.red : Colors.grey,
                      ),
                      const SizedBox(width: 5),
                      Text('$likes'),
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
                            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                          ),
                          child: DraggableScrollableSheet(
                            expand: false,
                            initialChildSize: 0.85,
                            minChildSize: 0.5,
                            maxChildSize: 0.95,
                            builder: (context, scrollController) {
                              return CommentScreen(
                                post: post,
                                postIndex: postIndex,
                                currentUser: currentUser,
                                updateComments: updateComments,
                              );
                            },
                          ),
                        );
                      },
                    ).then((updatedComments) {
                      if (updatedComments != null) {
                        updateComments(postIndex, updatedComments as List<Map<String, String>>);
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