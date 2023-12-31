import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_pdf_viewer/easy_pdf_viewer.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../utils/colors.dart';

class UserNoticeBoard extends StatefulWidget {
  final List<String> notices;

  const UserNoticeBoard({super.key, required this.notices});

  @override
  State<UserNoticeBoard> createState() => _UserNoticeBoardState();
}

class _UserNoticeBoardState extends State<UserNoticeBoard> {
  late PDFDocument pdfDocument;
  late Stream<QuerySnapshot> noticesStream;
  List<String> notices = [];
  String? pdfUrl;

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

  Future<void> fetchNoticeDetails() async {
    try {
      final documentSnapshot = await FirebaseFirestore.instance
          .collection('notices')
          .doc(UniqueKey().toString())
          .get();

      if (documentSnapshot.exists) {
        final noticeData = documentSnapshot.data() as Map<String, dynamic>;

        final pdfFileUrl = noticeData['pdfUrl'] as String?;

        pdfUrl = pdfFileUrl;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
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
        const SizedBox(height: 20),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: noticesStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }

              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }

              final notices = snapshot.data?.docs ?? [];

              return ListView.builder(
                itemCount: notices.length,
                itemBuilder: (context, index) {
                  final notice = notices[index].data() as Map<String, dynamic>;
                  final noticeText = notice['text'] as String?;
                  final title = notice['title'] as String?;
                  final noticeId = notices[index].id;
                  final pdfUrl = notice['pdfUrl'] as String?;

                  return Padding(
                    padding: const EdgeInsets.only(left: 8, right: 8),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      margin: const EdgeInsets.all(7),
                      elevation: 5,
                      surfaceTintColor: Colors.white,
                      shadowColor: Colors.white,
                      color: getRandomColor(),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(10),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              noticeText ?? '',
                              style: GoogleFonts.ubuntu(
                                  color: Colors.black45, fontSize: 15),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                pdfUrl != null
                                    ? IconButton(
                                        icon: Icon(
                                          Icons.picture_as_pdf,
                                          color: Colors.grey.shade900,
                                        ),
                                        onPressed: () async {
                                          if (pdfUrl != null) {
                                            PDFDocument pdfDocument =
                                                await PDFDocument.fromURL(
                                                    pdfUrl);
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => PDFViewer(
                                                    document: pdfDocument),
                                              ),
                                            );
                                          } else {
                                            // Handle case where the PDF URL is not available.
                                          }
                                        },
                                      )
                                    : const SizedBox(
                                        width: 0,
                                      ),
                              ],
                            ),
                          ],
                        ),
                        title: Text(
                          title ?? '',
                          style: GoogleFonts.ubuntu(
                              color: Colors.black87,
                              fontSize: 19,
                              fontWeight: FontWeight.w700),
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
