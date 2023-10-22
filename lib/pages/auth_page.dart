import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'home_page.dart';
import 'login_page.dart';
import 'admin_home.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({Key? key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future:
            FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            // Handle the case when data is still loading
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else if (userSnapshot.hasError) {
            // Handle errors
            return const Scaffold(
              body: Center(child: Text("Error loading data")),
            );
          } else if (userSnapshot.hasData &&
              userSnapshot.data?.exists == true) {
            final userData = userSnapshot.data!.data()!;
            final userRole = userData['role'] ?? ''; // Provide a default value

            if (userRole == 'admin') {
              return AdminHome(
                uid: user.uid,
                username: '',
                initialSelectedScreen: 0,
              );
            } else {
              return HomePage(
                uid: user.uid,
                username: '',
                initialSelectedScreen: 0,
              );
            }
          } else {
            FirebaseAuth.instance.signOut();
            return const LoginPage();
          }
        },
      );
    } else {
      return const LoginPage();
    }
  }
}
