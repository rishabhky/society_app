import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatPage extends StatefulWidget {
  final String? senderId;
  final String? receiverId;
  final String? receiverEmail;

  ChatPage({
    required this.senderId,
    required this.receiverId,
    required this.receiverEmail,
  });

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    if (widget.senderId == null || widget.receiverId == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Chat Page - Error'),
        ),
        body: Center(
          child: Text(
              'An error occurred. Missing sender or receiver information.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with ${widget.receiverEmail ?? "Unknown User"}'),
      ),
      body: Column(
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
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  // Handle Firestore error here.
                  return Text('Error: ${snapshot.error}');
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No messages.'));
                }

                final messages = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final messageData =
                        messages[index].data() as Map<String, dynamic>;
                    final messageText = messageData['message'] as String;
                    final senderId = messageData['senderId'] as String;
                    final isSender = senderId == widget.senderId;

                    return ListTile(
                      title: Text(
                        messageText,
                        textAlign: isSender ? TextAlign.right : TextAlign.left,
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
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
    );
  }

  String getChatRoomId() {
    if (widget.senderId == null || widget.receiverId == null) {
      return ''; // Return an empty string or handle this case appropriately.
    }
    // Generate a chat room ID based on sender and receiver IDs.
    final List<String> ids = [widget.senderId!, widget.receiverId!];
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
