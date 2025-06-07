import 'package:checkpointapp/timeline/pagina_comentarios.dart';
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
                  backgroundImage: AssetImage('assets/Chiquinha.jpg'),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post['username'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      post['handle'],
                      style: const TextStyle(color: Colors.grey),
                    ),
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
                    post['caption'],
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
                const SizedBox(width: 10),
                Padding(
                  padding: const EdgeInsets.only(right: 20.0), // afasta da borda direita

                  child: ClipOval(
                    child: Image.asset(
                      post['image'],
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
                        post['likedBy'].contains(currentUser)
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: post['likedBy'].contains(currentUser)
                            ? Colors.red
                            : Colors.grey,
                      ),
                      const SizedBox(width: 5),
                      Text('${post['likes']}'),
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
                      Text('${post['comments']}'),
                    ],
                  ),
                ),
                Text(post['time']),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
