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
  String reuid = '';
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<DocumentSnapshot>> fetchUsers() async {
    final usersSnapshot = await _firestore.collection('users').get();
    final users = usersSnapshot.docs;

    return users;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      body: FutureBuilder<List<DocumentSnapshot>>(
        future: fetchUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          final users = snapshot.data ?? [];

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final userData = users[index].data() as Map<String, dynamic>;
              final userId = users[index].id;
              reuid = userId;

              final userEmail = userData['username'] as String?;
              final userName = userData['name'] as String;
              final flat = userData['flat'] as int;

              if (userId != widget.uid && userEmail != null) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      TextFormField(
                        style: GoogleFonts.poppins(
                            color: Colors.grey.shade800,
                            fontSize: 15,
                            fontWeight: FontWeight.w500),
                        cursorColor: Colors.grey.shade800,
                        decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 10),
                            prefixIcon: Icon(
                              CupertinoIcons.search,
                              color: Colors.grey.shade800,
                              size: 26,
                            ),
                            hintText: "Search users . . .",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                            fillColor: Colors.grey.shade500,
                            filled: true,
                            hintStyle: GoogleFonts.poppins(
                                color: Colors.grey.shade800,
                                fontSize: 15,
                                fontWeight: FontWeight.w500)),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Container(
                        decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.grey,
                                  blurRadius: 10,
                                  offset: Offset(5, 5))
                            ],
                            color: Colors.grey.shade400,
                            borderRadius: BorderRadius.circular(10)),
                        child: FutureBuilder<bool>(
                          future: check(reuid),
                          builder: (BuildContext context,
                              AsyncSnapshot<bool> snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return CircularProgressIndicator();
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else {
                              final chatExists = snapshot.data ?? false;

                              return chatExists
                                  ? ListTile(
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
                                      trailing: Icon(CupertinoIcons.person_fill,
                                          size: 30),
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
                                    )
                                  : SizedBox(
                                      height: 0,
                                      width: 0,
                                    );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                return SizedBox.shrink();
              }
            },
          );
        },
      ),
    );
  }

  Future<bool> check(String reid) async {
    try {
      final documentSnapshot = await FirebaseFirestore.instance
          .collection('chat_rooms')
          .doc('${widget.uid}_${reid}')
          .get();

      return documentSnapshot.exists;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
      return false;
    }
  }
}
