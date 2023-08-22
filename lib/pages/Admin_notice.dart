import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminNoticeBoard extends StatefulWidget {
  const AdminNoticeBoard({Key? key}) : super(key: key);

  @override
  State<AdminNoticeBoard> createState() => _AdminNoticeBoardState();
}

class _AdminNoticeBoardState extends State<AdminNoticeBoard> {
  late Stream<QuerySnapshot> noticesStream;
  List<String> notices = [];

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
      String newNotice, String documentId) async {
    try {
      final documentRef =
          FirebaseFirestore.instance.collection('notices').doc(documentId);
      await documentRef.set({
        'text': newNotice,
        'createdAt': FieldValue.serverTimestamp(),
      });
      print('Notice added to Firestore with ID: $documentId');
      fetchNotices(); // Refresh the notices after addition
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
      fetchNotices(); // Refresh the notices after deletion
    } catch (e) {
      print('Error deleting notice from Firestore: $e');
    }
  }

  void _showAddNoticeDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String newNotice = '';

        return AlertDialog(
          title: Text('Add Notice'),
          content: TextField(
            onChanged: (value) {
              newNotice = value;
            },
            decoration: InputDecoration(labelText: 'Enter new notice'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _addNoticeToFirestore(newNotice,
                    'AxBOX1ZHZTe43exskazA'); // Provide a unique document ID
                Navigator.of(context).pop();
              },
              child: Text('Add'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
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
                      child: ListTile(
                        title: Text(
                          noticeText,
                          style: TextStyle(color: Colors.black87),
                        ),
                        trailing: IconButton(
                          icon: Icon(
                            Icons.delete,
                            color: Colors.grey.shade700,
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
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Align(
            alignment: Alignment.bottomRight,
            child: FloatingActionButton(
              key: UniqueKey(),
              onPressed: _showAddNoticeDialog,
              child: Icon(
                Icons.add,
                size: 38,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
