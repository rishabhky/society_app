import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:vmg/pages/user_notice.dart';
import 'package:vmg/utils/routes.dart';

import 'Admin_notice.dart';

class AdminHome extends StatefulWidget {
  final String username;
  final String uid;

  AdminHome({required this.username, required this.uid, Key? key})
      : super(key: key);

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  String isAdmin = "";
  int flatNumber = 0;
  double predefinedAmount = 100.0; // Replace with your predefined amount
  Razorpay _razorpay = Razorpay();
  int _selectedIndex = 0;

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
          isAdmin = userData['role'] ?? '';
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
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _getSelectedScreen(int index) {
    if (index == 0) {
      return SafeArea(child: NoticeBoardScreen(isAdmin: true));
    } else if (index == 1) {
      return SafeArea(
        child: MaintenanceScreen(
          username: widget.username,
          predefinedAmount: predefinedAmount,
          razorpay: _razorpay,
          flatNumber: flatNumber,
        ),
      );
    } else if (index == 2) {
      return SafeArea(child: ProfileScreen(username: widget.username));
    } else {
      return Container(); // Placeholder, add other screens as needed
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      appBar: AppBar(
        elevation: 0,
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
        backgroundColor: Colors.grey.shade900,
        title: Center(
          child: GlowingOverscrollIndicator(
            axisDirection: AxisDirection.down,
            color: Colors.white,
            child: Text(
              "Admin",
              style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  shadows: [
                    const Shadow(
                      offset: Offset(0, 1),
                      blurRadius: 7,
                      color: Colors.white,
                    ),
                  ]),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(child: _getSelectedScreen(_selectedIndex)),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: GNav(
          color: Colors.white60,
          activeColor: Colors.white,
          tabBackgroundColor: Colors.grey.shade800,
          gap: 8,
          padding: EdgeInsets.all(16),
          tabs: const [
            GButton(
              icon: CupertinoIcons.bell,
              text: 'Notice',
            ),
            GButton(
              icon: CupertinoIcons.home,
              text: 'Maintenance',
            ),
            GButton(
              icon: CupertinoIcons.person_2_fill,
              text: 'Profile',
            )
          ],
          selectedIndex: _selectedIndex,
          onTabChange: _onItemTapped,
        ),
      ),
      drawer: MyDrawer(username: widget.username),
    );
  }
}

class MaintenanceScreen extends StatelessWidget {
  final String username;
  final double predefinedAmount;
  final Razorpay razorpay;
  final int flatNumber;

  MaintenanceScreen({
    required this.username,
    required this.predefinedAmount,
    required this.razorpay,
    required this.flatNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            Text(
              "Welcome $username!",
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
                  builder: (BuildContext context) =>
                      PaymentDialog(razorpay, predefinedAmount),
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
            ),
          ],
        ),
      ),
    );
  }
}

class NoticeBoardScreen extends StatelessWidget {
  final bool isAdmin;

  const NoticeBoardScreen({Key? key, required this.isAdmin}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          SizedBox(
            height: 5,
          ),
          GlowingOverscrollIndicator(
            axisDirection: AxisDirection.down,
            color: Colors.white,
            child: Text(
              'Notice Board',
              style: GoogleFonts.poppins(
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.w300,
                shadows: [
                  const Shadow(
                    offset: Offset(0, 2),
                    blurRadius: 10,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(
              child: isAdmin
                  ? AdminNoticeBoard()
                  : UserNoticeBoard(
                      notices: [],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class PaymentDialog extends StatelessWidget {
  final Razorpay _razorpay;
  final double predefinedAmount;

  PaymentDialog(this._razorpay, this.predefinedAmount);

  final TextEditingController _amountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Maintenance Payment',
        style: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w500,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
              'Maintenance Due this Month: \u{20B9}${predefinedAmount.toStringAsFixed(2)}'),
          SizedBox(height: 10),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: 'Payment Amount'),
          ),
        ],
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
    double paymentAmount = double.tryParse(_amountController.text) ?? 0.0;

    if (paymentAmount <= 0) {
      // Show an error message
      Fluttertoast.showToast(
        msg: "Invalid payment amount",
        timeInSecForIosWeb: 4,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }

    // Configure payment options
    var options = {
      'key': 'rzp_test_ugZrbmLHkEGjBy',
      'amount': (paymentAmount * 100).toInt(),
      'name': 'V.M Grandeur',
      'subscription_id': 'sub_MSOdGYZ9PmO29d',
      'description': 'Payment for services',
      'prefill': {'contact': '', 'email': ''},
    };

    _razorpay.open(options);
  }
}

class ProfileScreen extends StatelessWidget {
  final String username;

  ProfileScreen({required this.username});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Profile Screen\nUsername: $username',
        style: TextStyle(fontSize: 24),
      ),
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
                CircleAvatar(
                  radius: 40,
                  backgroundImage: AssetImage('assets/images/profile.png'),
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  "Hello $username!",
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
