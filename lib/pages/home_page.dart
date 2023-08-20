import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:vmg/utils/routes.dart';

class HomePage extends StatefulWidget {
  final String username;
  final String uid;

  HomePage({required this.username, required this.uid, Key? key})
      : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int flatNumber = 0;
  Razorpay _razorpay = Razorpay();

  @override
  void initState() {
    super.initState();
    fetchUserData();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    Fluttertoast.showToast(
      msg: "Payment Success : ${response.paymentId}",
      timeInSecForIosWeb: 4,
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    Fluttertoast.showToast(
      msg: "Payment Failed : ${response.code} - ${response.message}",
      timeInSecForIosWeb: 4,
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    Fluttertoast.showToast(
      msg: "External wallet is : ${response.walletName}",
      timeInSecForIosWeb: 4,
    );
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
        iconTheme: IconThemeData(color: Colors.white),
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
            "Home",
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
                  border: Border.all(color: Colors.white, width: 2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.all(10),
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
                    builder: (BuildContext context) => PaymentDialog(_razorpay),
                  );
                },
                icon: Icon(Icons.payment),
                label: Text(
                  "Payment",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.bold),
                ),
              )
            ],
          ),
        ),
      ),
      drawer: MyDrawer(username: widget.username),
    );
  }
}

class PaymentDialog extends StatelessWidget {
  final Razorpay _razorpay;

  PaymentDialog(this._razorpay);

  final TextEditingController _amountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Enter Payment Amount'),
      content: TextField(
        controller: _amountController,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(labelText: 'Amount'),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            _startPayment(context);
          },
          child: Text('Pay'),
        ),
      ],
    );
  }

  void _startPayment(BuildContext context) {
    double amount = double.tryParse(_amountController.text) ?? 0.0;

    if (amount <= 0) {
      // Show an error message
      return;
    }

    // Configure payment options
    var options = {
      'key': 'rzp_test_ugZrbmLHkEGjBy',
      'amount': (amount * 100).toInt(),
      'name': 'V.M Grandeur',
      'description': 'Payment for services',
      'prefill': {'contact': '', 'email': ''},
    };

    _razorpay.open(options);
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
            decoration: BoxDecoration(color: Colors.black),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: AssetImage('assets/images/profile.png'),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  "Hello $username!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
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
