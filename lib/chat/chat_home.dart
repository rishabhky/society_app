import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vmg/pages/chat_page.dart';

class ChatHome extends StatefulWidget {
  final String uid;

  const ChatHome({super.key, required this.uid});

  @override
  _ChatHomeState createState() => _ChatHomeState();
}

class _ChatHomeState extends State<ChatHome> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Text('No users available.');
          }

          final users = snapshot.data!.docs;
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final userData = users[index].data() as Map<String, dynamic>;
              final userId = users[index].id;
              final userEmail = userData['username'] as String?;
              final userName = userData['name'] as String;

              // Exclude the currently logged-in user.
              if (userId != widget.uid && userEmail != null) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.grey,
                          blurRadius: 10,
                          offset: Offset(5, 5),
                        ),
                      ],
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      style: ListTileStyle.list,
                      title: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Text(
                          userName,
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ),
                      trailing:
                          const Icon(CupertinoIcons.person_fill, size: 30),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatPage(
                              senderId:
                                  widget.uid, // Sender ID is the logged-in user
                              receiverId:
                                  userId, // Receiver ID is the user being tapped
                              receiverEmail: userEmail,
                              receiverName: userName,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              } else {
                // Handle the case where userEmail is null or the same as the logged-in user.
                return const SizedBox
                    .shrink(); // This will create an empty ListTile for these cases.
              }
            },
          );
        },
      ),
    );
  }
}
