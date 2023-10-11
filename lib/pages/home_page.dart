import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:vmg/pages/Admin_notice.dart';
import 'package:vmg/pages/user_notice.dart';
import 'package:vmg/utils/routes.dart';
import '../chat/chat_home.dart';
import '../utils/drawer.dart';
import 'maintenance.dart';
import 'package:get/get.dart';
import 'package:vmg/controllers/auth_controller.dart';

class HomePage extends StatefulWidget {
  final String username;
  final String uid;
  final int initialSelectedScreen;

  const HomePage({
    required this.username,
    required this.uid,
    required this.initialSelectedScreen,
    Key? key,
  }) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AuthController authController = Get.find();
  Razorpay _razorpay = Razorpay();
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialSelectedScreen;
    authController.fetchUserData();
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

  // Future<void> fetchUserData() async {
  //   try {
  //     final userSnapshot = await FirebaseFirestore.instance
  //         .collection('users')
  //         .doc(widget.uid)
  //         .get();

  //     if (userSnapshot.exists) {
  //       final userData = userSnapshot.data() as Map<String, dynamic>;
  //       setState(() {
  //         flatNumber = userData['flat'] ?? 0;
  //         isAdmin = userData['role'] ?? '';
  //         maintenance = userData['maintenance'] ?? 0;
  //         name = userData['name'] ?? '';
  //       });
  //       print('User data exists: $userData');
  //     } else {
  //       print("No such user");
  //     }
  //   } catch (e) {
  //     print('Error fetching user data: $e');
  //   }
  // }

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
      return const SafeArea(
        child: MaintenanceScreen(),
      );
    } else if (index == 1) {
      return const SafeArea(child: NoticeBoardScreen(isAdmin: false));
    } else if (index == 2) {
      return SafeArea(child: ChatHome(uid: widget.uid));
    } else if (index == 3) {
      return SafeArea(
          child: ProfileScreen(username: authController.name.value));
    } else {
      return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      appBar: AppBar(
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xff4B5350)),
        actions: [
          IconButton(
            icon: const Icon(Icons.login),
            color: const Color(0xff4B5350),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, MyRoutes.loginRoute);
            },
          ),
        ],
        backgroundColor: Colors.grey.shade300,
        title: const Center(
          child: Text(
            "Home",
            style: TextStyle(
                color: Color(0xff4B5350), fontWeight: FontWeight.bold),
          ),
        ),
      ),
      body: _getSelectedScreen(_selectedIndex),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: GNav(
          color: Colors.grey.shade600,
          activeColor: Colors.white,
          tabBackgroundColor: Colors.grey.shade800,
          gap: 8,
          padding: const EdgeInsets.all(16),
          tabs: const [
            GButton(
              icon: CupertinoIcons.home,
              text: 'Home',
              textColor: Color(0xffefedec),
            ),
            GButton(
              icon: CupertinoIcons.bell,
              text: 'Notices',
            ),
            GButton(
              icon: CupertinoIcons.chat_bubble_2,
              text: 'Chat',
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
      drawer: MyDrawer(
        initialSelectedScreen: _selectedIndex,
        username: widget.username,
        predefinedAmount: authController.predefinedAmount.value,
        razorpay: _razorpay,
        flatNumber: authController.flatNumber.value,
        uid: widget.uid,
      ),
    );
  }
}

class PaymentDialog extends StatelessWidget {
  final Razorpay _razorpay;
  final double predefinedAmount;
  final AuthController authController = Get.find();

  PaymentDialog(this._razorpay, this.predefinedAmount, {super.key});

  final TextEditingController _amountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter:
          ColorFilter.mode(Colors.black.withOpacity(0.8), BlendMode.overlay),
      child: AlertDialog(
        contentPadding: EdgeInsets.all(10),
        backgroundColor: Colors.grey.shade900.withOpacity(0.98),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        title: Text(
          'Maintenance Payment',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 25,
            color: Colors.white70,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text.rich(
              TextSpan(children: <InlineSpan>[
                TextSpan(
                  text: 'Maintenance Due : ',
                  style: GoogleFonts.poppins(
                      color: Colors.white60,
                      fontWeight: FontWeight.w600,
                      fontSize: 17),
                ),
                TextSpan(
                  text: ' \u{20B9} ${authController.maintenance.value}',
                  style: GoogleFonts.poppins(
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                      fontSize: 17),
                )
              ]),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _amountController,
              style: GoogleFonts.poppins(color: Colors.white60, fontSize: 16),
              cursorColor: Colors.white60,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Payment Amount',
                labelStyle:
                    GoogleFonts.poppins(color: Colors.white38, fontSize: 14),
              ),
            ),
          ],
        ),
        actions: [
          Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.red.shade400.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(10)),
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.poppins(
                            color: Colors.white70, fontWeight: FontWeight.w800),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.green.shade400.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(10)),
                    child: TextButton(
                      onPressed: () {
                        _startPayment(context);
                      },
                      child: Text(
                        'Pay',
                        style: GoogleFonts.poppins(
                            color: Colors.white70, fontWeight: FontWeight.w800),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              )
            ],
          ),
        ],
      ),
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

class NoticeBoardScreen extends StatelessWidget {
  final bool isAdmin;

  const NoticeBoardScreen({Key? key, required this.isAdmin}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const SizedBox(
            height: 5,
          ),
          GlowingOverscrollIndicator(
            axisDirection: AxisDirection.down,
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Notice Board',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    color: const Color(0xff4B5350),
                    fontWeight: FontWeight.w400,
                    shadows: [
                      const Shadow(
                        offset: Offset(0, 2),
                        blurRadius: 10,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  width: 5,
                ),
                Icon(
                  CupertinoIcons.doc_on_clipboard,
                  color: Colors.grey.shade800,
                )
              ],
            ),
          ),
          Expanded(
            child: Container(
              child: isAdmin
                  ? const AdminNoticeBoard()
                  : const UserNoticeBoard(
                      notices: [],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  final String username;

  const ProfileScreen({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Profile Screen\nUsername: $username',
        style: const TextStyle(fontSize: 24),
      ),
    );
  }
}
