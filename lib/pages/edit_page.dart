import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:file_picker/file_picker.dart';
import 'package:easy_pdf_viewer/easy_pdf_viewer.dart';

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
  String? pdfUrl;
  bool hasPdf = false;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

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
        final pdfFileUrl = noticeData['pdfUrl'] as String?;

        titleController.text = title ?? '';
        noticeController.text = notice ?? '';
        pdfUrl = pdfFileUrl;

        if (pdfUrl != null) {
          setState(() {
            hasPdf = true;
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  }

  void addDocumentToCollection(String title, String content) async {
    try {
      CollectionReference selectedNotice = firestore.collection('selected');

      await selectedNotice.doc('selected').set({
        'title': title,
        'content': content,
      });

      print('Document added to Firestore successfully.');
    } catch (e) {
      print('Error adding document to Firestore: $e');
    }
  }

  Future<void> _uploadPDF() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null) {
        File pdfFile = File(result.files.single.path!);

        final storageRef = FirebaseStorage.instance
            .ref()
            .child('pdfs/${widget.documentId}.pdf');
        final uploadTask = storageRef.putFile(pdfFile);

        await uploadTask.whenComplete(() async {
          final downloadUrl = await storageRef.getDownloadURL();
          final pdfUrl = downloadUrl.toString();

          setState(() {
            this.pdfUrl = pdfUrl;
            hasPdf = true; // Set the flag to show the "View PDF" button
          });
        });
      }
    } catch (e) {
      print('Error uploading pdf: $e');
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
        'pdfUrl': pdfUrl,
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
        'pdfUrl': pdfUrl,
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
        padding: const EdgeInsets.fromLTRB(16, 40, 16, 0),
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
                ),

                if (hasPdf)
                  ElevatedButton(
                    onPressed: () async {
                      if (pdfUrl != null) {
                        PDFDocument pdfDocument =
                            await PDFDocument.fromURL(pdfUrl!);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                PDFViewer(document: pdfDocument),
                          ),
                        );
                      }
                    },
                    child: const Text('View PDF'),
                  ),
                // if (hasPdf == false)
                //   ElevatedButton(
                //     onPressed: _uploadPDF,
                //     child: Text('Upload PDF'),
                //   ),
              ],
            ))
          ],
        ),
      ),
      floatingActionButton: SpeedDial(
          elevation: 10,
          backgroundColor: const Color(0xFF1f1d20),
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
                labelBackgroundColor: const Color(0xFF1f1d20),
                labelStyle: const TextStyle(color: Colors.grey),
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
                labelBackgroundColor: const Color(0xFF1f1d20),
                labelStyle: const TextStyle(color: Colors.grey),
                onTap: () {
                  FirebaseFirestore.instance
                      .collection('notices')
                      .doc(widget.documentId)
                      .delete();
                  Navigator.pop(context);
                }),
            if (hasPdf == false)
              SpeedDialChild(
                backgroundColor: const Color(0xFF1f1d20),
                child: const Icon(
                  Icons.attach_file,
                  color: Colors.grey,
                ),
                label: "Add Pdf",
                labelBackgroundColor: const Color(0xFF1f1d20),
                labelStyle: const TextStyle(color: Colors.grey),
                onTap: _uploadPDF,
                //Navigator.of(context).pop();
              ),
            SpeedDialChild(
              backgroundColor: const Color(0xFF1f1d20),
              child: const Icon(
                CupertinoIcons.plus,
                color: Colors.grey,
              ),
              label: "Add",
              labelBackgroundColor: const Color(0xFF1f1d20),
              labelStyle: const TextStyle(color: Colors.grey),
              onTap: () {
                _addNoticeToFirestore(
                  titleController.text,
                  noticeController.text,
                  UniqueKey().toString(),
                );
                Navigator.of(context).pop();
              },
            ),
            SpeedDialChild(
              backgroundColor: const Color(0xFF1f1d20),
              child: const Icon(
                CupertinoIcons.bookmark_fill,
                color: Colors.grey,
              ),
              label: "Display On Home",
              labelBackgroundColor: const Color(0xFF1f1d20),
              labelStyle: const TextStyle(color: Colors.grey),
              onTap: () => addDocumentToCollection(
                  titleController.text, noticeController.text),
            )
          ],
          iconTheme:
              IconThemeData(color: Colors.grey.shade400.withOpacity(0.8))),
    );
  }
}
