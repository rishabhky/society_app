import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:home_widget/home_widget.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:vmg/controllers/auth_controller.dart';

class HomeWidgetConfig {
  final AuthController authController = Get.find();

  Future<void> update(
      BuildContext context, double percent, int daysLeft) async {
    final widget = CircularPercentIndicator(
      radius: 60,
      lineWidth: 12,
      backgroundColor: Colors.white38,
      center: authController.PaymentDone == true.obs
          ? Icon(
              Icons.check,
              color: Colors.green,
              size: 40,
            )
          : Text(
              "$daysLeft days",
              style: GoogleFonts.ubuntu(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color:
                    daysLeft < 5 ? Colors.red.shade500 : Colors.grey.shade800,
              ),
            ),
      progressColor: Colors.grey.shade800,
      percent: percent, // Assuming 30 days in a month
      circularStrokeCap: CircularStrokeCap.round,
    );
    await HomeWidget.saveWidgetData('widget_id', widget);
    await HomeWidget.updateWidget(
        iOSName: 'YourWidgetName', androidName: 'YourWidgetName');
  }

  static Future<void> initialize() async {
    await HomeWidget.setAppGroupId('your_app_group_id');
  }
}
