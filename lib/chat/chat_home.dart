import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vmg/pages/chat_page.dart';

class ChatHome extends StatefulWidget {
  final String uid;

  ChatHome({required this.uid});

  @override
  _ChatHomeState createState() => _ChatHomeState();
}

class _ChatHomeState extends State<ChatHome> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Text('No users available.');
          }

          final users = snapshot.data!.docs;
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final userData = users[index].data() as Map<String, dynamic>;
              final userId = users[index].id;
              final userEmail = userData['username'] as String?;

              // Exclude the currently logged-in user.
              if (userId != widget.uid && userEmail != null) {
                return ListTile(
                  title: Text(userEmail),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatPage(
                          senderId: widget.uid,
                          receiverId: userId,
                          receiverEmail: userEmail,
                        ),
                      ),
                    );
                  },
                );
              } else {
                // Handle the case where userEmail is null or the same as the logged-in user.
                return SizedBox
                    .shrink(); // This will create an empty ListTile for these cases.
              }
            },
          );
        },
      ),
    );
  }
}
