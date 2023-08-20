import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:vmg/utils/routes.dart';

class AdminHome extends StatefulWidget {
  final String username;
  final String uid;

  AdminHome({required this.username, required this.uid, Key? key})
      : super(key: key);

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  int flatNumber = 0;
  Razorpay? _razorpay;
  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    Fluttertoast.showToast(
        msg: "Payment Success : ${response.paymentId}", timeInSecForIosWeb: 4);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    Fluttertoast.showToast(
        msg: "Payment Failed : ${response.code} - ${response.message}",
        timeInSecForIosWeb: 4);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    Fluttertoast.showToast(
        msg: "External wallet is : ${response.walletName}",
        timeInSecForIosWeb: 4);
  }

  var amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchUserData();
    _razorpay = Razorpay();
    _razorpay?.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay?.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay?.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void makepayment() async {
    var options = {
      'key': 'rzp_test_ugZrbmLHkEGjBy',
      'amount': (int.parse(amountController.text) * 100)
          .toString(), //in the smallest currency sub-unit.
      'name': 'V.M Grandeur',
      'order_id': 'order_EMBFqjDHEEn80l', // Generate order_id using Orders API
      'timeout': 300, // in seconds
      'prefill': {'contact': '', 'email': ''}
    };
    try {
      _razorpay?.open(options);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> fetchUserData() async {
    try {
      final userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .get();

      if (userSnapshot.exists) {
        final userData = userSnapshot.data() as Map<String, dynamic>;
        setState(() {
          flatNumber = userData['flat'] ?? 0;
        });
        print('User data exists: $userData');
      } else {
        print("No such user");
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.login),
            color: Colors.white,
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, MyRoutes.loginRoute);
            },
          ),
        ],
        backgroundColor: Colors.black,
        title: const Center(
          child: Text(
            "Admin",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              Text(
                "Welcome ${widget.username}!",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Text(
                "Flat No: $flatNumber",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                      color: Colors.white, width: 2), // Border color and width
                  borderRadius:
                      BorderRadius.circular(10), // Adjust the radius as needed
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.transparent, // Transparent background color
                    borderRadius: BorderRadius.circular(
                        10), // Same radius as the outer container
                  ),
                  padding: EdgeInsets.all(
                      10), // Optional: Add padding inside the inner container
                  child: Column(
                    children: [
                      Text(
                        "Notice ",
                        style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "Below are the maintenance details for your flat, the payment button opens a dialog box, enter the right amount and continue with RazorPay safe payment ...",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shadowColor: Colors.white,
                    elevation: 8,
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Payment',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 24,
                                fontWeight: FontWeight.w500,
                              )),
                          content: TextFormField(
                            controller: amountController,
                            decoration: const InputDecoration(
                                hintText: "Enter Maintenance Amount:",
                                labelText: "Amount "),
                            keyboardType: TextInputType.number,
                          ),
                          actions: [
                            Center(
                              child: TextButton(
                                onPressed: () {
                                  makepayment(); // Close the dialog
                                },
                                child: Text('Pay'),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  icon: const Icon(Icons.payment),
                  label: const Text(
                    "Payment",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.bold),
                  )),
              const SizedBox(
                height: 20,
              )
            ],
          ),
        ),
      ),
      drawer: MyDrawer(username: widget.username),
    );
  }
}

class MyDrawer extends StatelessWidget {
  final String username;

  const MyDrawer({required this.username, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Colors.black),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 39,
                  backgroundImage: AssetImage('assets/images/profile.png'),
                ),
                Text(
                  "Hello Admin $username!",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
