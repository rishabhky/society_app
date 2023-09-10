import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vmg/chat/message.dart';
import 'package:vmg/pages/auth_page.dart';

class ChatService extends AuthPage {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> sendMessage(String receiverid, String message) async {
    final String currentUserId = _firebaseAuth.currentUser!.uid;
    final String currentUserEmail = _firebaseAuth.currentUser!.email.toString();
    final Timestamp timestamp = Timestamp.now();
    final String receiverId = "NJ81EqXKQtWRKBnIqmMdwPEXF4R2";

    Message newMessage = Message(
        senderId: currentUserId,
        username: currentUserEmail,
        receiverId: receiverId,
        message: message,
        time: timestamp);

    List<String> ids = [currentUserId, receiverid];
    ids.sort();
    String chatRoomId = ids.join("_");

    await _firestore
        .collection('chat_room')
        .doc(chatRoomId)
        .collection('messages')
        .add(newMessage.toMap());
  }

  Stream<QuerySnapshot> getMessages(String userId, String adminId) {
    List<String> ids = [userId, adminId];
    ids.sort();
    String chatRoomId = ids.join("_");

    return _firestore
        .collection('chat_room')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }
}
