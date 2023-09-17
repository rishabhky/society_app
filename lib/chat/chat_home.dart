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
  String name = '';
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  TextEditingController _searchController = TextEditingController();
  List<String> userNames = [];
  List<int> flatNo = [];
  List<String> searchResults = [];
  List<int> flats = [];

  @override
  void initState() {
    super.initState();
    _loadUserNames();
  }

  void _loadUserNames() async {
    final usersSnapshot = await _firestore.collection('users').get();
    final users = usersSnapshot.docs;

    setState(() {
      userNames = users.map((user) => user.data()!['name'] as String).toList();
      flatNo = users.map((user) => user.data()!['flat'] as int).toList();
      _searchUsers('');
    });
  }

  void _searchUsers(String query) async {
    setState(() {
      searchResults = userNames
          .where((userName) =>
              userName.toLowerCase().contains(query.toLowerCase()))
          .toList();
      flats = flatNo.where((flat) => flat != null).toList();
    });
  }

  Future<String> fetchReceiverId(String userName) async {
    try {
      final userSnapshot = await _firestore
          .collection('users')
          .where('name', isEqualTo: userName)
          .get();
      final user = userSnapshot.docs.first;

      if (user.exists) {
        return user.data()!['uid'] as String;
      } else {
        // Handle the case when the user with the given name is not found
        // You can show an error message or return a default value as needed
        return '';
      }
    } catch (e) {
      // Handle any errors that may occur during the fetch
      print('Error fetching receiver ID: $e');
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white60,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextFormField(
                  controller: _searchController,
                  onChanged: (value) {
                    _searchUsers(value);
                  },
                  style: GoogleFonts.poppins(
                    color: Colors.grey.shade800,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                  cursorColor: Colors.grey.shade800,
                  decoration: InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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
                    fillColor: Colors.grey.shade300,
                    filled: true,
                    hintStyle: GoogleFonts.poppins(
                      color: Colors.grey.shade800,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: searchResults.length,
              itemBuilder: (context, index) {
                final userName = searchResults[index];
                final userData = {};

                final userId = '';
                final userEmail = '';
                final flat = flats[index];

                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          boxShadow: [
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
                          title: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Text(
                              "${userName} - ${flat}",
                              style: GoogleFonts.poppins(
                                fontSize: 22,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade800,
                              ),
                            ),
                          ),
                          trailing: Icon(
                            CupertinoIcons.person_fill,
                            size: 30,
                          ),
                          onTap: () async {
                            // Fetch the receiver's ID here and set it as reuid
                            final receiverId = await fetchReceiverId(userName);
                            setState(() {
                              reuid = receiverId;
                            });

                            // Create a chat and navigate to the chat page
                            createChat(reuid);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatPage(
                                  senderId: widget.uid,
                                  receiverId: receiverId,
                                  receiverEmail: userEmail,
                                  receiverName: userName,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(
          CupertinoIcons.add,
          size: 35,
        ),
        onPressed: () {
          // Implement functionality to create a new chat here
          // You can show a dialog to search for a user's name and create a chat with them.
        },
      ),
    );
  }

  Future<bool> check(String reid) async {
    try {
      final documentSnapshot = await FirebaseFirestore.instance
          .collection('chat_messages')
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

  Future<void> createChat(String reid) async {
    try {
      // Create the "messages" subcollection
      await FirebaseFirestore.instance
          .collection('chat_messages')
          .doc('${widget.uid}_${reid}')
          .collection('messages')
          .doc(
              'initial_message') // You can add an initial message here if needed
          .set({
        'text': 'Welcome to the chat!',
        'timestamp': FieldValue.serverTimestamp(),
      });
      print('Document created successfully.');
    } catch (e) {
      print('Error creating document: $e');
    }
  }
}
