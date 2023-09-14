import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
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
      backgroundColor: Colors.grey.shade300,
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
              final userName = userData['name'] as String;
              final flat = userData['flat'] as int;

              // Exclude the currently logged-in user.
              if (userId != widget.uid && userEmail != null) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                              color: Colors.grey,
                              blurRadius: 10,
                              offset: Offset(5, 5))
                        ],
                        color: Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(10)),
                    child: ListTile(
                      style: ListTileStyle.list,
                      title: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Text(
                          "${userName} - ${flat}",
                          style: GoogleFonts.poppins(
                              fontSize: 22,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade800),
                        ),
                      ),
                      trailing: Icon(CupertinoIcons.person_fill, size: 30),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatPage(
                              senderId: widget.uid,
                              receiverId: userId,
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
