import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vmg/controllers/auth_controller.dart';

class ChatPage extends StatefulWidget {
  final String? senderId;
  final String? receiverId;
  final String? receiverEmail;
  final String? receiverName;

  const ChatPage(
      {super.key,
      required this.senderId,
      required this.receiverId,
      required this.receiverEmail,
      required this.receiverName});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _messageController = TextEditingController();
  final AuthController authController = Get.find();

  @override
  Widget build(BuildContext context) {
    if (widget.senderId == null || widget.receiverId == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Chat Page - Error'),
        ),
        body: const Center(
          child: Text(
              'An error occurred. Missing sender or receiver information.'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white60),
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(widget.receiverName ?? "Unknown User",
            style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Colors.white60)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('chat_messages')
                    .doc(getChatRoomId())
                    .collection('messages')
                    .orderBy('timestamp', descending: false)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    // Handle Firestore error here.
                    return Text('Error: ${snapshot.error}');
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No messages.'));
                  }

                  final messages = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final messageData =
                          messages[index].data() as Map<String, dynamic>;
                      final messageText = messageData['message'] as String;
                      final senderId = messageData['senderId'] as String;
                      final isSender = senderId == authController.userid.value;

                      // Set background color and alignment based on sender
                      final backgroundColor =
                          isSender ? Colors.blue : Colors.grey;
                      final alignment = isSender
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start;

                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: isSender
                              ? MainAxisAlignment.end
                              : MainAxisAlignment.start,
                          children: [
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.all(
                                    10.0), // Adjust padding as needed
                                decoration: BoxDecoration(
                                  color: backgroundColor,
                                  borderRadius: BorderRadius.circular(
                                      10.0), // Make it circular
                                ),
                                child: Text(
                                  messageText,
                                  style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
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
                      style: GoogleFonts.poppins(color: Colors.white54),
                      controller: _messageController,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(10)),
                          filled: true,
                          fillColor: Colors.grey.shade800,
                          contentPadding: const EdgeInsets.all(16),
                          hintText: 'Type your message...',
                          hintStyle:
                              GoogleFonts.poppins(color: Colors.grey.shade700)),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      CupertinoIcons.arrow_right,
                      size: 30,
                      shadows: const [
                        Shadow(color: Colors.white54, blurRadius: 5)
                      ],
                      color: Colors.grey.shade600,
                    ),
                    onPressed: () {
                      final messageText = _messageController.text.trim();
                      if (messageText.isNotEmpty) {
                        sendMessage(messageText);
                        _messageController.clear();
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String getChatRoomId() {
    if (widget.senderId == null || widget.receiverId == null) {
      return ''; // Return an empty string or handle this case appropriately.
    }
    // Generate a chat room ID based on sender and receiver IDs.
    final List<String> ids = [
      authController.userid.value.trim(),
      widget.receiverId!
    ];
    ids.sort();

    return ids.join('_');
  }

  Future<void> sendMessage(String messageText) async {
    if (widget.senderId == null || widget.receiverId == null) {
      // Handle the case where senderId or receiverId is null.
      return;
    }

    final Timestamp timestamp = Timestamp.now();

    // Generate the chat room ID
    final chatRoomId = getChatRoomId();

    final messageData = {
      'message': messageText,
      'senderId': widget.senderId!,
      'receiverId': widget.receiverId!,
      'timestamp': timestamp,
    };

    // Specify the chat room ID as the document ID when adding the message to the collection
    await _firestore
        .collection('chat_messages')
        .doc(chatRoomId)
        .collection('messages')
        .add(messageData);
  }
}
