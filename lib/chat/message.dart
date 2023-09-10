import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String senderId;
  final String username;
  final String receiverId;
  final String message;
  final Timestamp time;

  Message(
      {required this.senderId,
      required this.username,
      required this.receiverId,
      required this.message,
      required this.time});

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'username': username,
      'receiverId': receiverId,
      'message': message,
      'time': time,
    };
  }
}
