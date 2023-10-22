import 'package:razorpay_flutter/razorpay_flutter.dart';

class UserData {
  final int maintenance; // Correct the typo here
  final double predefinedAmount;
  final Razorpay razorpay;
  final int flatNumber;
  final String name;
  final String isAdmin;

  UserData(
      {required this.maintenance,
      required this.predefinedAmount,
      required this.razorpay,
      required this.flatNumber,
      required this.name,
      required this.isAdmin});
}
