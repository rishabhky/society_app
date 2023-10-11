import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../pages/admin_home.dart';

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
                const CircleAvatar(
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
                  builder: (context) => AdminHome(
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
                  builder: (context) => AdminHome(
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
                  builder: (context) => AdminHome(
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
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(30),
            bottomRight: Radius.circular(30),
            topLeft: Radius.circular(30),
            bottomLeft: Radius.circular(30),
          ),
          color: currentIndex == initialSelectedScreen
              ? const Color(0xFF1f1d20).withOpacity(0.85)
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
