import 'package:checkpointapp/timeline/postcard.dart';
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
