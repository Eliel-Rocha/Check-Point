import 'package:checkpointapp/timeline/postcard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TimelineScreen extends StatefulWidget {
  const TimelineScreen({super.key});

  @override
  State<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> {
  final String currentUser = 'Usuário Logado';

  void updateComments(String postId, List<Map<String, String>> updatedList) {
    FirebaseFirestore.instance.collection('timeline_posts').doc(postId).update({
      'commentsNum': updatedList.length,
      'comments': updatedList,
    });
  }

  void toggleLike(String postId, List<dynamic> likedBy, int likes) {
    final postRef = FirebaseFirestore.instance.collection('timeline_posts').doc(postId);

    if (likedBy.contains(currentUser)) {
      likedBy.remove(currentUser);
      likes -= 1;
    } else {
      likedBy.add(currentUser);
      likes += 1;
    }

    postRef.update({
      'likedBy': likedBy,
      'likes': likes,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('timeline_posts')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final post = doc.data() as Map<String, dynamic>;

              return PostCard(
                post: post,
                postIndex: index,
                currentUser: currentUser,
                updateComments: (i, list) => updateComments(doc.id, list),
                toggleLike: (i) => toggleLike(doc.id, post['likedBy'] ?? [], post['likes'] ?? 0),
              );
            },
          );
        },
      ),
    );
  }
}