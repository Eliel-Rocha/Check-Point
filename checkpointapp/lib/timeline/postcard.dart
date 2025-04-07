
import 'package:checkpointapp/timeline/pagina_comentarios.dart';
import 'package:checkpointapp/timeline/timeline.dart';
import 'package:flutter/cupertino.dart';
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
          Image.asset(post['image'], fit: BoxFit.cover, width: double.infinity),
          Padding(
            padding: const EdgeInsets.all(10.0),
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
                  onTap: () async {
                    List<Map<String, String>> updatedComments =
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CommentScreen(
                          post: post,
                          postIndex: postIndex,
                          currentUser: currentUser,
                        ),
                      ),
                    );

                    updateComments(postIndex, updatedComments);
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
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(post['caption']),
          ),
        ],
      ),
    );
  }
}
