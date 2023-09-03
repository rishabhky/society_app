import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

import '../utils/routes.dart';

class EditScreen extends StatefulWidget {
  final String documentId;

  const EditScreen({
    Key? key,
    required this.documentId,
  }) : super(key: key);

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  late Stream<QuerySnapshot> noticesStream;
  List<String> notices = [];
  late TextEditingController titleController;
  late TextEditingController noticeController;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController();
    noticeController = TextEditingController();
    fetchNoticeDetails();
  }

  Future<void> fetchNoticeDetails() async {
    try {
      final documentSnapshot = await FirebaseFirestore.instance
          .collection('notices')
          .doc(widget.documentId)
          .get();

      if (documentSnapshot.exists) {
        final noticeData = documentSnapshot.data() as Map<String, dynamic>;
        final title = noticeData['title'] as String?;
        final notice = noticeData['text'] as String?;

        titleController.text = title ?? '';
        noticeController.text = notice ?? '';
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

  Future<void> updateNotice() async {
    try {
      await FirebaseFirestore.instance
          .collection('notices')
          .doc(widget.documentId)
          .update({
        'title': titleController.text,
        'text': noticeController.text,
      });

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    noticeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: EdgeInsets.fromLTRB(16, 40, 16, 0),
        child: Column(
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  padding: const EdgeInsets.all(0),
                  icon: Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                          color: Colors.grey.shade900.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(10)),
                      child: Icon(
                        Icons.arrow_back_ios,
                        color: Colors.grey.shade400,
                      ))),
            ]),
            Expanded(
                child: ListView(
              children: [
                TextField(
                  controller: titleController,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "Title",
                    hintStyle: TextStyle(
                        color: Colors.grey.withOpacity(0.8), fontSize: 30),
                  ),
                ),
                TextField(
                  controller: noticeController,
                  maxLines: null,
                  style: const TextStyle(color: Colors.grey, fontSize: 18),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "Notice Content",
                    hintStyle: TextStyle(
                        color: Colors.grey.withOpacity(0.8), fontSize: 18),
                  ),
                )
              ],
            ))
          ],
        ),
      ),
      floatingActionButton: SpeedDial(
          elevation: 10,
          backgroundColor: Color(0xFF1f1d20),
          icon: Icons.auto_awesome_mosaic,
          isOpenOnStart: false,
          overlayColor: Colors.black,
          children: [
            SpeedDialChild(
                backgroundColor: const Color(0xFF1f1d20),
                child: const Icon(
                  Icons.save,
                  color: Colors.grey,
                ),
                label: "Save",
                labelBackgroundColor: Color(0xFF1f1d20),
                labelStyle: TextStyle(color: Colors.grey),
                onTap: () {
                  updateNotice();
                }),
            SpeedDialChild(
                backgroundColor: const Color(0xFF1f1d20),
                child: const Icon(
                  CupertinoIcons.delete,
                  color: Colors.grey,
                ),
                label: "Delete",
                labelBackgroundColor: Color(0xFF1f1d20),
                labelStyle: TextStyle(color: Colors.grey),
                onTap: () {
                  FirebaseFirestore.instance
                      .collection('notices')
                      .doc(widget.documentId)
                      .delete();
                  Navigator.pop(context);
                }),
            SpeedDialChild(
              backgroundColor: const Color(0xFF1f1d20),
              child: const Icon(
                CupertinoIcons.plus,
                color: Colors.grey,
              ),
              label: "Add",
              labelBackgroundColor: Color(0xFF1f1d20),
              labelStyle: TextStyle(color: Colors.grey),
              onTap: () {
                _addNoticeToFirestore(
                  titleController.text,
                  noticeController.text,
                  UniqueKey().toString(),
                );
                Navigator.of(context).pop();
              },
            ),
          ],
          iconTheme:
              IconThemeData(color: Colors.grey.shade400.withOpacity(0.8))),
    );
  }
}
