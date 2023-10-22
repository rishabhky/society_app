import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:get/get.dart';
import 'package:vmg/chat/chat_home.dart';
import 'package:vmg/controllers/auth_controller.dart';
import 'package:vmg/pages/Admin_notice.dart';
import 'package:vmg/pages/home_page.dart';
import 'package:vmg/pages/maintenance.dart';
import 'package:vmg/pages/profile.dart';
import 'package:vmg/utils/drawer.dart';
import 'package:vmg/utils/routes.dart';

class AdminHome extends StatefulWidget {
  final String username;
  final String uid;
  final int initialSelectedScreen;

  const AdminHome({
    required this.username,
    required this.uid,
    required this.initialSelectedScreen,
    Key? key,
  }) : super(key: key);

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  final AuthController authController = Get.find();
  //Razorpay _razorpay = Razorpay();
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialSelectedScreen;
    authController.fetchUserData();
    authController.razorpay = Razorpay();
    authController.razorpay
        .on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    authController.razorpay
        .on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    authController.razorpay
        .on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
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

  @override
  void dispose() {
    authController.razorpay.clear();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _getSelectedScreen(int index) {
    if (index == 0) {
      return SafeArea(
        child: MaintenanceScreen(),
      );
    } else if (index == 1) {
      return const SafeArea(child: NoticeBoardScreen());
    } else if (index == 2) {
      return SafeArea(
        child: ChatHome(uid: widget.uid),
      );
    } else if (index == 3) {
      return SafeArea(child: ProfileScreen());
    } else {
      return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xff4B5350)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            color: const Color(0xff4B5350),
            onPressed: () async {
              await authController.signOut();
              Navigator.pushReplacementNamed(context, MyRoutes.loginRoute);
            },
          ),
        ],
        backgroundColor: Colors.grey[300],
        title: Center(
          child: GlowingOverscrollIndicator(
            axisDirection: AxisDirection.down,
            color: Colors.white,
            child: Text(
              "Admin",
              style: GoogleFonts.poppins(
                  color: const Color(0xff4B5350),
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
          color: Colors.grey.shade800,
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
              icon: CupertinoIcons.person_2,
              text: 'Profile',
            )
          ],
          selectedIndex: _selectedIndex,
          onTabChange: _onItemTapped,
        ),
      ),
      drawer: MyDrawer(
        // MyDrawer code here...
        initialSelectedScreen: _selectedIndex,
        flatNumber: authController.flatNumber.value,
        predefinedAmount: authController.predefinedAmount.value,
        razorpay: authController.razorpay,
        uid: widget.uid,
        username: widget.username,
      ),
    );
  }
}

class NoticeBoardScreen extends StatelessWidget {
  const NoticeBoardScreen({Key? key}) : super(key: key);

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
              child:
                  const AdminNoticeBoard(), // Replace with your notice board widget.
            ),
          ),
        ],
      ),
    );
  }
}
