import 'package:checkpointapp/timeline/postcard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TimelineScreen extends StatefulWidget {
  const TimelineScreen({super.key});

  @override
  State<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> {
  String currentUserId = '';
  String currentUserName = '';

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      currentUserId = user.uid;
      FirebaseFirestore.instance.collection('usuarios').doc(user.uid).get().then((doc) {
        setState(() {
          //currentUserName = doc.data()?['nome'] ?? 'Usuário';
          currentUserName = doc.data()?['username'] ?? 'Usuário';
        });
      });
    }
  }

  void updateComments(String postId, List<Map<String, String>> updatedList) {
    FirebaseFirestore.instance.collection('timeline_posts').doc(postId).update({
      'commentsNum': updatedList.length,
      'comments': updatedList,
    });
  }

  void toggleLike(String postId, List<dynamic> likedBy, int likes) async {
    final postRef = FirebaseFirestore.instance.collection('timeline_posts').doc(postId);

    if (likedBy.contains(currentUserId)) {
      likedBy.remove(currentUserId);
      likes -= 1;
    } else {
      likedBy.add(currentUserId);
      likes += 1;
    }

    await postRef.update({
      'likedBy': likedBy,
      'likes': likes,
    });

    // Força reconstrução da interface
    setState(() {});
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
                currentUser: currentUserName, //currentUserName
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