import 'package:flutter/material.dart';

class TimelineScreen extends StatefulWidget {
  const TimelineScreen({super.key});

  @override
  State<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> {
  final String currentUser = 'Usuário Logado';

  final List<Map<String, dynamic>> posts = List.generate(
    10,
        (index) => {
      'username': 'Gabriela Adriana $index',
      'handle': '@gabiadriana$index',
      'image': 'assets/Chiquinha.jpg',
      'likes': 0,
      'likedBy': <String>{},
      'comments': 0,
      'time': '${index + 1} min atrás',
      'caption': 'A Chiquinha é linda <3 ',
      'commentList': <Map<String, String>>[],
    },
  );

  void updateComments(int index, List<Map<String, String>> newComments) {
    setState(() {
      posts[index]['commentList'] = List.from(newComments);
      posts[index]['comments'] = newComments.length;
    });
  }

  void toggleLike(int index) {
    setState(() {
      if (posts[index]['likedBy'].contains(currentUser)) {
        posts[index]['likedBy'].remove(currentUser);
        posts[index]['likes'] -= 1;
      } else {
        posts[index]['likedBy'].add(currentUser);
        posts[index]['likes'] += 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Timeline'),
        backgroundColor: Colors.orange,
      ),
      body: ListView.builder(
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];
          return PostCard(
            post: post,
            postIndex: index,
            currentUser: currentUser,
            updateComments: updateComments,
            toggleLike: toggleLike,
          );
        },
      ),
    );
  }
}

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

class CommentScreen extends StatefulWidget {
  final Map<String, dynamic> post;
  final int postIndex;
  final String currentUser;

  const CommentScreen({
    super.key,
    required this.post,
    required this.postIndex,
    required this.currentUser,
  });

  @override
  _CommentScreenState createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  final TextEditingController _commentController = TextEditingController();

  late List<Map<String, String>> comments;

  @override
  void initState() {
    super.initState();
    comments = List.from(widget.post['commentList']);
  }

  void _addComment() {
    if (_commentController.text.isNotEmpty) {
      setState(() {
        comments.add({
          'user': widget.currentUser,
          'comment': _commentController.text,
        });
        _commentController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, comments);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Comentários'),
          backgroundColor: Colors.orange,
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: comments.length,
                itemBuilder: (context, index) {
                  var comment = comments[index];
                  return ListTile(
                    title: Text(
                      comment['user']!,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(comment['comment']!),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: const InputDecoration(
                        hintText: 'Escreva um comentário...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.orange),
                    onPressed: _addComment,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
