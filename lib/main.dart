import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vmg/controllers/auth_controller.dart';
import 'package:vmg/pages/admin_home.dart';
import 'package:vmg/pages/admin_page.dart';
import 'package:vmg/pages/auth_page.dart';
import 'package:vmg/pages/edit_page.dart';
import 'package:vmg/pages/home_page.dart';
import 'package:vmg/pages/login_page.dart';
import 'package:vmg/pages/Admin_notice.dart';
import 'package:vmg/pages/profile.dart';
import 'package:vmg/utils/routes.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  print('Firebase initialized successfully');

  Get.put(AuthController());

  runApp(GetMaterialApp(
    theme: ThemeData(
      primarySwatch: Colors.grey,
    ),
    debugShowCheckedModeBanner: false,
    initialRoute: MyRoutes.authRoute,
    getPages: [
      GetPage(
        name: MyRoutes.homeRoute,
        page: () => HomePage(
          uid: Get.arguments != null ? Get.arguments as String : '',
          username: '',
          initialSelectedScreen: 0,
        ),
      ),
      GetPage(
        name: MyRoutes.loginRoute,
        page: () => const LoginPage(),
      ),
      GetPage(
        name: MyRoutes.adminRoute,
        page: () => AdminHome(
          uid: Get.arguments != null ? Get.arguments as String : '',
          username: '',
          initialSelectedScreen: 0,
        ),
      ),
      GetPage(
        name: MyRoutes.editPage,
        page: () => const EditScreen(
          documentId: '',
        ),
      ),
      GetPage(
        name: MyRoutes.regRoute,
        page: () => const Adminpage(),
      ),
      GetPage(
        name: MyRoutes.adminNotice,
        page: () => const AdminNoticeBoard(),
      ),
      GetPage(
        name: MyRoutes.authRoute,
        page: () => const AuthPage(),
      ),
      GetPage(
        name: MyRoutes.proPage,
        page: () => const ProfileScreen(),
      ),
    ],
  ));
}
