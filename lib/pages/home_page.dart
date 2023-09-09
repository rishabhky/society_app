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

import '../utils/drawer.dart';
import 'maintenance.dart';

class HomePage extends StatefulWidget {
  final String username;
  final String uid;
  final int initialSelectedScreen;

  HomePage(
      {required this.username,
      required this.uid,
      required this.initialSelectedScreen,
      Key? key})
      : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int flatNumber = 0;
  String isAdmin = "";
  double predefinedAmount = 100.0; // Replace with your predefined amount
  Razorpay _razorpay = Razorpay();
  int _selectedIndex = 0;
  int maintenance = 0;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialSelectedScreen;
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
          maintenance = userData['maintenance'] ?? 0;
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
      return NoticeBoardScreen(isAdmin: isAdmin == 'admin');
    } else if (index == 1) {
      return MaintenanceScreen(
        maintenance: maintenance,
        predefinedAmount: predefinedAmount,
        razorpay: _razorpay,
        flatNumber: flatNumber,
      );
    } else if (index == 2) {
      return ProfileScreen(username: widget.username);
    } else {
      return Container(); // Placeholder, add other screens as needed
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFffffff),
      appBar: AppBar(
        elevation: 0,
        iconTheme: IconThemeData(color: Color(0xff4B5350)),
        actions: [
          IconButton(
            icon: const Icon(Icons.login),
            color: Color(0xff4B5350),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, MyRoutes.loginRoute);
            },
          ),
        ],
        backgroundColor: Color(0xFFffffff),
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
          tabBackgroundColor: Color(0xFF1F1D20),
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
      drawer: MyDrawer(
        initialSelectedScreen: _selectedIndex,
        username: widget.username,
        predefinedAmount: predefinedAmount,
        razorpay: _razorpay,
        flatNumber: flatNumber,
        uid: widget.uid,
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

class NoticeBoardScreen extends StatelessWidget {
  final bool isAdmin;

  const NoticeBoardScreen({Key? key, required this.isAdmin}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          SizedBox(
            height: 20,
          ),
          Text(
            'Notice Screen',
            style: TextStyle(fontSize: 24, color: Color(0xff0a0b0a)),
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
  final int initialSelectedScreen; // Updated property
  final double predefinedAmount;
  final Razorpay razorpay;
  final int flatNumber;
  final String uid;

  const MyDrawer({
    required this.username,
    required this.initialSelectedScreen,
    required this.predefinedAmount,
    required this.razorpay,
    required this.flatNumber,
    required this.uid,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.black.withOpacity(0.85),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
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
          customListItem(
            leading: CupertinoIcons.news,
            title: "Notices",
            currentIndex: 0,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HomePage(
                      username: username,
                      uid: uid,
                      initialSelectedScreen: 0), // Updated index to 0
                ),
              );
            },
          ),
          customListItem(
            leading: CupertinoIcons.money_dollar,
            title: "Maintenance",
            currentIndex: 1,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HomePage(
                      username: username,
                      uid: uid,
                      initialSelectedScreen: 1), // Updated index to 0
                ),
              );
            },
          ),
          customListItem(
            leading: CupertinoIcons.person,
            title: "Profile",
            currentIndex: 2,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HomePage(
                      username: username,
                      uid: uid,
                      initialSelectedScreen: 2), // Updated index to 0
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget customListItem({
    required IconData leading,
    required String title,
    required int currentIndex,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(30),
            bottomRight: Radius.circular(30),
            topLeft: Radius.circular(30),
            bottomLeft: Radius.circular(30),
          ),
          color: currentIndex == initialSelectedScreen
              ? Color(0xFF1f1d20).withOpacity(0.85)
              : Colors.transparent,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50.0),
          child: ListTile(
            leading: Icon(
              leading,
              color: Colors.white,
            ),
            title: Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.ubuntu(
                fontSize: 17,
                color: currentIndex == initialSelectedScreen
                    ? Colors.white
                    : Colors.grey, // Set text color
              ),
            ),
            onTap: onTap,
          ),
        ),
      ),
    );
  }
}
