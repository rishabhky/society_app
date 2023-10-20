import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vmg/controllers/auth_controller.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:widget_circular_animator/widget_circular_animator.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthController authController = Get.find();
  DateTime firstOfMonth =
      DateTime(DateTime.now().year, DateTime.now().month + 1, 1);

  @override
  Widget build(BuildContext context) {
    int daysLeft = (firstOfMonth.difference(DateTime.now()).inDays) - 1;
    //print("days : ${daysLeft}");
    double percent =
        authController.PaymentDone == true.obs ? 1.0 : daysLeft / 30;

    return Container(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                height: 150,
                width: 150,
                child: WidgetCircularAnimator(
                  innerColor: Colors.grey.shade700,
                  outerColor: Colors.grey.shade800,
                  size: 100,
                  child: Container(
                    decoration: BoxDecoration(
                        shape: BoxShape.circle, color: Colors.grey[200]),
                    child: Icon(
                      Icons.person_outline,
                      color: Colors.grey.shade800,
                      size: 60,
                    ),
                  ),
                ),
              ),
              Container(
                height: 170,
                width: 180,
                decoration: BoxDecoration(
                    color: Colors.grey.shade600,
                    borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        onLongPress: () {},
                        child: Container(
                          width: double.maxFinite,
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade400,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.perm_contact_cal_rounded,
                                size: 25,
                                color: Colors.black54,
                              ),
                              SizedBox(width: 10),
                              Text(
                                "${authController.name}",
                                style: GoogleFonts.ubuntu(
                                    fontSize: 15,
                                    color: Colors.grey.shade800,
                                    fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ),
                      ),
                      GestureDetector(
                        onLongPress: () {},
                        child: Container(
                          width: double.maxFinite,
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade400,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.apartment_rounded,
                                size: 25,
                                color: Colors.black54,
                              ),
                              SizedBox(width: 10),
                              Text(
                                "Flat No : ${authController.flatNumber}",
                                style: GoogleFonts.ubuntu(
                                    fontSize: 15,
                                    color: Colors.grey.shade800,
                                    fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ),
                      ),
                      GestureDetector(
                        onLongPress: () {},
                        child: Container(
                          width: double.maxFinite,
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade400,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                CupertinoIcons.money_dollar_circle_fill,
                                size: 25,
                                color: Colors.black54,
                              ),
                              SizedBox(width: 10),
                              Text(
                                "Due : ${authController.maintenance}",
                                style: GoogleFonts.ubuntu(
                                    fontSize: 15,
                                    color: Colors.grey.shade800,
                                    fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
          //SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(10),
              ),
              height: 150,
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    CircularPercentIndicator(
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
                                color: daysLeft < 5
                                    ? Colors.red.shade500
                                    : Colors.grey.shade800,
                              ),
                            ),
                      progressColor: Colors.grey.shade800,
                      percent: percent, // Assuming 30 days in a month
                      circularStrokeCap: CircularStrokeCap.round,
                    ),
                    SizedBox(width: 20),
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                            children: authController.PaymentDone == true.obs
                                ? <TextSpan>[
                                    TextSpan(
                                        text: "Payment Done",
                                        style: GoogleFonts.ubuntu(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.grey.shade900))
                                  ]
                                : <TextSpan>[
                                    TextSpan(
                                      text:
                                          'Days Left To Pay the maintenance: ',
                                      style: GoogleFonts.poppins(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.grey.shade900,
                                      ),
                                    ),
                                    TextSpan(
                                      text: " $daysLeft",
                                      style: GoogleFonts.ubuntu(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.red.shade400,
                                      ),
                                    ),
                                  ]),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          authController.isAdmin == 'admin'
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            color: Colors.grey.shade600,
                            borderRadius: BorderRadius.circular(10)),
                        width: 180,
                        height: 150,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            GestureDetector(
                              onLongPress: () {},
                              child: Container(
                                height: 40,
                                width: double.maxFinite,
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade400,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      FontAwesomeIcons.umbrellaBeach,
                                      size: 25,
                                      color: Colors.black54,
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      "Swimming Pool",
                                      style: GoogleFonts.ubuntu(
                                          fontSize: 15,
                                          color: Colors.grey.shade800,
                                          fontWeight: FontWeight.w700),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            GestureDetector(
                              onLongPress: () {},
                              child: Container(
                                height: 40,
                                width: double.maxFinite,
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade400,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.electric_meter_sharp,
                                      size: 25,
                                      color: Colors.black54,
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      "Generator",
                                      style: GoogleFonts.ubuntu(
                                          fontSize: 15,
                                          color: Colors.grey.shade800,
                                          fontWeight: FontWeight.w700),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            GestureDetector(
                              onLongPress: () {},
                              child: Container(
                                height: 40,
                                width: double.maxFinite,
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade400,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.water_damage_sharp,
                                      size: 25,
                                      color: Colors.black54,
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      "Tank Cleaning",
                                      style: GoogleFonts.ubuntu(
                                          fontSize: 15,
                                          color: Colors.grey.shade800,
                                          fontWeight: FontWeight.w700),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                            color: Colors.grey.shade400,
                            borderRadius: BorderRadius.circular(10)),
                        width: 150,
                        height: 150,
                        child: CircularPercentIndicator(
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
                                    color: daysLeft < 5
                                        ? Colors.red.shade500
                                        : Colors.grey.shade800,
                                  ),
                                ),
                          progressColor: Colors.grey.shade800,
                          percent: percent, // Assuming 30 days in a month
                          circularStrokeCap: CircularStrokeCap.round,
                        ),
                      )
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Container(
                    decoration: BoxDecoration(color: Colors.grey.shade700),
                    height: 150,
                    width: double.maxFinite,
                  ),
                ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(8),
              child: authController.isAdmin == 'admin'
                  ? Container(
                      height: double.maxFinite,
                      width: double.maxFinite,
                      decoration: BoxDecoration(
                          color: Colors.grey.shade600,
                          borderRadius: BorderRadius.circular(10)),
                    )
                  : Container(
                      height: double.maxFinite,
                      width: double.maxFinite,
                      decoration: BoxDecoration(
                          color: Colors.grey.shade600,
                          borderRadius: BorderRadius.circular(10))),
            ),
          )
        ],
      ),
    );
  }
}
