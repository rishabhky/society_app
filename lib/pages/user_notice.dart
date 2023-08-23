import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../utils/colors.dart';

class UserNoticeBoard extends StatefulWidget {
  final List<String> notices;

  UserNoticeBoard({required this.notices});

  @override
  State<UserNoticeBoard> createState() => _UserNoticeBoardState();
}

class _UserNoticeBoardState extends State<UserNoticeBoard> {
  late Stream<QuerySnapshot> noticesStream;
  List<String> notices = [];
  getRandomColor() {
    Random random = Random();
    return backgroundColor[random.nextInt(backgroundColor.length)];
  }

  @override
  void initState() {
    super.initState();
    noticesStream =
        FirebaseFirestore.instance.collection('notices').snapshots();
  }

  Future<void> fetchNotices() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('notices')
          .orderBy('createdAt', descending: true)
          .get();

      setState(() {
        notices =
            querySnapshot.docs.map((doc) => doc['text'] as String).toList();
      });
    } catch (e) {
      print('Error fetching notices: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 20),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: noticesStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              }

              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }

              final notices = snapshot.data?.docs ?? [];

              return ListView.builder(
                itemCount: notices.length,
                itemBuilder: (context, index) {
                  final notice = notices[index].data() as Map<String, dynamic>;
                  final noticeText = notice['text'] as String;
                  final noticeId = notices[index].id;

                  return Padding(
                    padding: const EdgeInsets.only(left: 8, right: 8),
                    child: Card(
                      elevation: 5,
                      shadowColor: Colors.white,
                      color: getRandomColor(),
                      child: ListTile(
                        title: Text(
                          noticeText,
                          style: GoogleFonts.poppins(color: Colors.black87),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
