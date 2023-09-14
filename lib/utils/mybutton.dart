import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MyButton extends StatefulWidget {
  final String iconPath;
  final String buttonText;
  final String isAdmin;
  final String documentId;

  MyButton({
    Key? key,
    required this.iconPath,
    required this.buttonText,
    required this.isAdmin,
    required this.documentId,
  }) : super(key: key);

  @override
  State<MyButton> createState() => _MyButtonState();
}

class _MyButtonState extends State<MyButton> {
  String name = '';
  int phone = 0;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    // Fetch the data from Firestore when the widget is initialized
    fetchNoticeAndContent();
  }

  Future<void> fetchNoticeAndContent() async {
    try {
      // Reference to the Firestore collection
      CollectionReference servicesCollection = firestore.collection('services');

      // Get the document with the specific documentId
      DocumentSnapshot document =
          await servicesCollection.doc(widget.documentId).get();

      if (document.exists) {
        Map<String, dynamic> data = document.data() as Map<String, dynamic>;
        setState(() {
          name = data['name'];
          phone = data['phone'];

          // Set the initial values for the controllers
          _nameController.text = name;
          _phoneController.text = phone.toString();
        });
      } else {
        print('Document does not exist');
      }
    } catch (e) {
      print('Error fetching document from Firestore: $e');
    }
  }

  void _openEditDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return BackdropFilter(
          filter: ColorFilter.mode(
              Colors.black.withOpacity(0.8), BlendMode.overlay),
          child: Dialog(
            backgroundColor: Colors.grey.shade900.withOpacity(0.98),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Text(
                    "Edit Services",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontWeight: FontWeight.bold,
                        fontSize: 25),
                  ),
                  TextField(
                      controller: _nameController,
                      style: TextStyle(color: Colors.grey),
                      decoration: InputDecoration(
                        icon: Icon(
                          CupertinoIcons.person,
                          color: Colors.grey,
                        ),
                        labelText: "Name",
                        labelStyle: GoogleFonts.poppins(
                            color: Colors.grey,
                            fontSize: 18,
                            fontWeight: FontWeight.w600),
                      )),
                  TextField(
                      style: TextStyle(color: Colors.grey),
                      keyboardType: TextInputType.phone,
                      controller: _phoneController,
                      decoration: InputDecoration(
                        icon: Icon(
                          CupertinoIcons.phone,
                          color: Colors.grey,
                        ),
                        labelText: "Phone",
                        labelStyle: GoogleFonts.poppins(
                            color: Colors.grey,
                            fontSize: 18,
                            fontWeight: FontWeight.w600),
                      )),
                  SizedBox(
                    height: 15,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.green.shade300.withOpacity(0.8),
                        ),
                        width: 75,
                        height: 45,
                        // color: Colors.grey.shade700.withOpacity(0.8),
                        child: IconButton(
                          onPressed: () async {
                            // Save the edited data here
                            String newName = _nameController.text;
                            String newPhone = _phoneController.text;

                            if (widget.isAdmin == 'admin') {
                              try {
                                await firestore
                                    .collection('services')
                                    .doc(widget.documentId)
                                    .update({
                                  'name': newName,
                                  'phone': int.parse(newPhone), // Parse to int
                                });
                                Navigator.of(context).pop(); // Close the dialog
                              } catch (e) {
                                print("Error updating data: $e");
                                // Handle error as needed
                              }
                            }
                          },
                          icon: Icon(
                            CupertinoIcons.checkmark_alt,
                            size: 30,
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.red.shade300.withOpacity(0.8),
                        ),
                        width: 75,
                        height: 45,
                        // color: Colors.grey.shade700.withOpacity(0.8),
                        child: IconButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          icon: Icon(
                            CupertinoIcons.xmark,
                            size: 30,
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showServicesDialog(
      BuildContext context, String service, String name, int phone) {
    showDialog(
      context: context,
      builder: (BuildContext context) => BackdropFilter(
        filter:
            ColorFilter.mode(Colors.black.withOpacity(0.8), BlendMode.overlay),
        child: Dialog(
          backgroundColor: Colors.grey.shade900.withOpacity(0.98),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  service,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontWeight: FontWeight.bold,
                      fontSize: 25),
                ),
                Text(
                  "Name: $name",
                  style: GoogleFonts.poppins(
                      color: Colors.grey,
                      fontSize: 18,
                      fontWeight: FontWeight.w600),
                ),
                Text(
                  "Phone: $phone",
                  style: GoogleFonts.poppins(
                      color: Colors.grey,
                      fontSize: 18,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          padding: const EdgeInsets.all(8),
          child: IconButton(
            onPressed: () {
              if (widget.isAdmin == 'admin') {
                _openEditDataDialog(context); // Open edit dialog for admin
              } else {
                _showServicesDialog(
                  context,
                  widget.buttonText,
                  name,
                  phone,
                );
              }
            },
            icon: Image.asset(widget.iconPath),
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey.shade500,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade400,
                blurRadius: 40,
                spreadRadius: 10,
              )
            ],
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Text(
          widget.buttonText,
          style: GoogleFonts.poppins(
            color: Colors.black54,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        )
      ],
    );
  }
}
