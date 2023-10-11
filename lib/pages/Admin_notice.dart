import 'dart:math';

import 'package:easy_pdf_viewer/easy_pdf_viewer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vmg/pages/edit_page.dart';
import 'package:vmg/utils/colors.dart';

class AdminNoticeBoard extends StatefulWidget {
  const AdminNoticeBoard({Key? key}) : super(key: key);

  @override
  State<AdminNoticeBoard> createState() => _AdminNoticeBoardState();
}

class _AdminNoticeBoardState extends State<AdminNoticeBoard> {
  late PDFDocument pdfDocument;
  bool isLoading = true;
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
    fetchNoticeDetails();
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

  Future<void> _addNoticeToFirestore(
      String title, String newNotice, String documentId) async {
    try {
      final documentRef =
          FirebaseFirestore.instance.collection('notices').doc(documentId);
      await documentRef.set({
        'title': title,
        'text': newNotice,
        'createdAt': FieldValue.serverTimestamp(),
      });
      print('Notice added to Firestore with ID: $documentId');
      fetchNotices();
    } catch (e) {
      print('Error adding notice to Firestore: $e');
    }
  }

  Future<void> _deleteNoticeFromFirestore(String documentId) async {
    try {
      await FirebaseFirestore.instance
          .collection('notices')
          .doc(documentId)
          .delete();
      print('Notice deleted from Firestore with ID: $documentId');
      fetchNotices();
    } catch (e) {
      print('Error deleting notice from Firestore: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0x0fffffff),
      body: Column(
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
                    final notice =
                        notices[index].data() as Map<String, dynamic>;
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
                          onTap: () async {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    EditScreen(documentId: noticeId),
                              ),
                            );
                          },
                          contentPadding: const EdgeInsets.all(10),
                          // leading: IconButton(
                          //   icon: Icon(
                          //     Icons.picture_as_pdf,
                          //     color: Colors.grey.shade900,
                          //   ),
                          //   onPressed: () async {
                          //     if (pdfUrl != null) {
                          //       PDFDocument pdfDocument =
                          //           await PDFDocument.fromURL(pdfUrl);
                          //       Navigator.push(
                          //         context,
                          //         MaterialPageRoute(
                          //           builder: (context) =>
                          //               PDFViewer(document: pdfDocument),
                          //         ),
                          //       );
                          //     } else {
                          //       // Handle case where the PDF URL is not available.
                          //     }
                          //   },
                          // ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const SizedBox(
                                height: 5,
                              ),
                              Text(
                                noticeText ?? '',
                                textAlign: TextAlign.justify,
                                style: GoogleFonts.ubuntu(
                                    color: Colors.black54, fontSize: 15),
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
                                                  builder: (context) =>
                                                      PDFViewer(
                                                          document:
                                                              pdfDocument),
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
                                  IconButton(
                                    icon: Icon(
                                      Icons.delete,
                                      color: Colors.grey.shade900,
                                    ),
                                    onPressed: () {
                                      _deleteNoticeFromFirestore(noticeId);
                                    },
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

                          // trailing: // Align icons vertically centered

                          //     IconButton(
                          //   icon: Icon(
                          //     Icons.delete,
                          //     color: Colors.grey.shade900,
                          //   ),
                          //   onPressed: () {
                          //     _deleteNoticeFromFirestore(noticeId);
                          //   },
                          // ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF1F1D20),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => const EditScreen(documentId: ''),
            ),
          );
          if (result == true) {
            // Refresh the notices when you return from the EditScreen
            fetchNotices();
          }
        },
        key: UniqueKey(),
        child: const Icon(
          CupertinoIcons.plus,
          size: 32,
          color: Colors.white54,
        ),
      ),
    );
  }
}
