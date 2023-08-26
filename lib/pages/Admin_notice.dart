import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vmg/utils/colors.dart';

class AdminNoticeBoard extends StatefulWidget {
  const AdminNoticeBoard({Key? key}) : super(key: key);

  @override
  State<AdminNoticeBoard> createState() => _AdminNoticeBoardState();
}

class _AdminNoticeBoardState extends State<AdminNoticeBoard> {
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

  void _showAddNoticeDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String title = '';
        String newNotice = '';

        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
          child: AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            backgroundColor: Colors.grey.shade900.withOpacity(0.85),
            title: Center(
              child: Text(
                'Add Notice',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  color: Colors.white54,
                ),
              ),
            ),
            content: SingleChildScrollView(
              child: Container(
                width: double.maxFinite,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      cursorColor: Colors.white,
                      onChanged: (value) {
                        title = value;
                      },
                      style: TextStyle(
                        color: Colors.white54,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Enter notice title',
                        labelStyle: TextStyle(
                          color: Colors.white54,
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      onChanged: (value) {
                        newNotice = value;
                      },
                      maxLines: null,
                      style: TextStyle(
                        color: Colors.white54,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Enter new notice',
                        labelStyle: TextStyle(
                          color: Colors.white54,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          style: ButtonStyle(
                              shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20))),
                              backgroundColor: MaterialStatePropertyAll(
                                  Colors.grey.shade700)),
                          onPressed: () {
                            _addNoticeToFirestore(
                              title,
                              newNotice,
                              UniqueKey().toString(),
                            );
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            'Add',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.white54,
                            ),
                          ),
                        ),
                        SizedBox(width: 20), // Add spacing between buttons
                        TextButton(
                          style: ButtonStyle(
                              shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20))),
                              backgroundColor: MaterialStatePropertyAll(
                                  Colors.grey.shade700)),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            'Cancel',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.white54,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      body: Column(
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
                    final notice =
                        notices[index].data() as Map<String, dynamic>;
                    final noticeText = notice['text'] as String?;
                    final title = notice['title'] as String?;
                    final noticeId = notices[index].id;

                    return Padding(
                      padding: const EdgeInsets.only(left: 8, right: 8),
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        margin: EdgeInsets.all(7),
                        elevation: 5,
                        surfaceTintColor: Colors.white,
                        shadowColor: Colors.white,
                        color: getRandomColor(),
                        child: ListTile(
                          contentPadding: EdgeInsets.all(10),
                          subtitle: Text(
                            noticeText ?? '',
                            style: GoogleFonts.ubuntu(
                                color: Colors.black45, fontSize: 15),
                          ),
                          title: Text(
                            title ?? '',
                            style: GoogleFonts.ubuntu(
                                color: Colors.black87,
                                fontSize: 19,
                                fontWeight: FontWeight.w700),
                          ),
                          trailing: IconButton(
                            icon: Icon(
                              Icons.delete,
                              color: Colors.grey.shade900,
                            ),
                            onPressed: () {
                              _deleteNoticeFromFirestore(noticeId);
                            },
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
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.grey.shade800,
        onPressed: _showAddNoticeDialog,
        key: UniqueKey(),
        child: Icon(
          Icons.add,
          size: 38,
          color: Colors.white54,
        ),
      ),
    );
  }
}
