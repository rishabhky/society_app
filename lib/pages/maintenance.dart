import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vmg/controllers/auth_controller.dart'; // Import your AuthController
import 'package:vmg/pages/home_page.dart';
import 'package:vmg/utils/mybutton.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MaintenanceScreen extends StatefulWidget {
  const MaintenanceScreen({Key? key}) : super(key: key);

  @override
  State<MaintenanceScreen> createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends State<MaintenanceScreen> {
  final AuthController authController = Get.find(); // Add this line
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  String noticeTitle = "";
  String noticeContent = "";

  @override
  void initState() {
    super.initState();
    // Fetch the notice and content from Firestore when the widget is initialized
    fetchNoticeAndContent();
  }

  Future<void> fetchNoticeAndContent() async {
    try {
      // Reference to the Firestore collection
      CollectionReference noticeSelected = firestore.collection('selected');

      // Get the document with the specific flat number (assuming the document ID is the flat number)
      DocumentSnapshot document = await noticeSelected.doc('selected').get();

      if (document.exists) {
        Map<String, dynamic> data = document.data() as Map<String, dynamic>;
        setState(() {
          noticeTitle = data['title'];
          noticeContent = data['content'];
        });
      } else {
        print('Document does not exist');
      }
    } catch (e) {
      print('Error fetching document from Firestore: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Obx(
                      () => Text(
                        " Hello ${authController.name.value}\n Flat No: ${authController.flatNumber.value}",
                        style: GoogleFonts.poppins(
                          color: Colors.grey.shade900,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const Icon(
                      FontAwesomeIcons.houseChimneyCrack,
                      size: 100,
                    )
                  ],
                ),
                const SizedBox(
                  height: 15,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    MyButton(
                        iconPath: "assets/images/electrician.png",
                        buttonText: "Electrician",
                        isAdmin: authController.isAdmin.value,
                        documentId: 'electrician'),
                    MyButton(
                        iconPath: "assets/images/plumber.png",
                        buttonText: "Plumber",
                        isAdmin: authController.isAdmin.value,
                        documentId: 'plumber'),
                    MyButton(
                        iconPath: "assets/images/security.png",
                        buttonText: "Security",
                        isAdmin: authController.isAdmin.value,
                        documentId: 'security'),
                    MyButton(
                        iconPath: "assets/images/man.png",
                        buttonText: "Caretaker",
                        isAdmin: authController.isAdmin.value,
                        documentId: 'caretaker'),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Container(
                  width: double.maxFinite,
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: const Color(0xFF1F1D20).withOpacity(0.3),
                        width: 2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1F1D20).withOpacity(0.3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "   My Pending Due",
                            style: GoogleFonts.poppins(
                                color: Colors.grey.shade900,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 5),
                          Container(
                            padding: const EdgeInsets.all(10),
                            width: double.maxFinite,
                            decoration: BoxDecoration(
                              color: const Color(0xFF1f1d20).withOpacity(0.9),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Maintenance Due",
                                  style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey.shade400,
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "₹ ${authController.maintenance.value}",
                                      style: GoogleFonts.poppins(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey.shade400,
                                      ),
                                    ),
                                    ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white70,
                                        shadowColor: Colors.white70,
                                        elevation: 8,
                                      ),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) =>
                                              PaymentDialog(
                                                  authController.razorpay,
                                                  authController
                                                      .predefinedAmount.value),
                                        );
                                      },
                                      icon: const Icon(Icons.payment),
                                      label: const Text(
                                        "Pay",
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  width: double.maxFinite,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300, width: 2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1f1d20).withOpacity(0.9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      children: [
                        Text(
                          noticeTitle,
                          style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          noticeContent,
                          textAlign: TextAlign.justify,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
