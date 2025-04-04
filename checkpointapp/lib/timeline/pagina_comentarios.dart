import 'package:checkpointapp/timeline/timeline.dart';
import 'package:flutter/material.dart';

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
