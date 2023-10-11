import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class AuthController extends GetxController {
  Rx<User?> user = FirebaseAuth.instance.currentUser.obs;
  RxDouble maintenance = 0.0.obs;
  RxDouble predefinedAmount = 100.0.obs;
  Razorpay razorpay = Razorpay();
  RxInt flatNumber = 0.obs;
  RxString name = ''.obs;
  RxString userid = ''.obs;
  RxBool isInitialized = false.obs;
  RxString isAdmin = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUserData();
    user.bindStream(FirebaseAuth.instance.userChanges());
  }

  Future<void> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      clearUserData();
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  void clearUserData() {
    user.value = null;
    maintenance.value = 0.0;
    predefinedAmount.value = 100.0;
    flatNumber.value = 0;
    name.value = '';
    isAdmin.value = 'user';
    userid.value = '';
  }

  Future<void> initializeFirebase() async {
    try {
      await Firebase.initializeApp();
      isInitialized.value = true;
    } catch (e) {
      print('Error initializing Firebase: $e');
    }
  }

  Future<void> fetchUserData() async {
    try {
      final uid = user.value?.uid;
      if (uid != null) {
        clearUserData();

        final userSnapshot =
            await FirebaseFirestore.instance.collection('users').doc(uid).get();

        if (userSnapshot.exists) {
          print(uid);
          final userData = userSnapshot.data() as Map<String, dynamic>;
          print(userData);
          flatNumber.value = (userData['flat'] ?? 0); // Convert to int
          maintenance.value =
              (userData['maintenance'] ?? 0.0).toDouble(); // Convert to double
          name.value = userData['name'] ?? '';
          userid.value = userData['uid'] ?? '';
          isAdmin.value = userData['role'] ?? '';
        }
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }
}
