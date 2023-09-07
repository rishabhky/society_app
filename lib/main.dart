import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vmg/firebase_options.dart';
import 'package:vmg/pages/admin_home.dart';
import 'package:vmg/pages/admin_page.dart';
import 'package:vmg/pages/auth_page.dart';
import 'package:vmg/pages/edit_page.dart';
import 'package:vmg/pages/home_page.dart';
import 'package:vmg/pages/login_page.dart';
import 'package:vmg/pages/Admin_notice.dart';
import 'package:vmg/utils/routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.grey,
        fontFamily: GoogleFonts.lato().fontFamily,
      ),
      debugShowCheckedModeBanner: false,
      routes: {
        '/': (context) => const AuthPage(),
        MyRoutes.homeRoute: (context) => HomePage(
              uid: ModalRoute.of(context)!.settings.arguments as String,
              username: '',
              initialSelectedScreen: 0,
            ),
        MyRoutes.loginRoute: (context) => LoginPage(),
        MyRoutes.regRoute: (context) => const Adminpage(),
        MyRoutes.adminRoute: (context) => AdminHome(
              uid: ModalRoute.of(context)!.settings.arguments as String,
              username: '',
              initialSelectedScreen: 0,
            ),
        MyRoutes.adminNotice: (context) => AdminNoticeBoard(),
        MyRoutes.editPage: (context) => EditScreen(
              documentId: '',
            ),
      },
    );
  }
}
