import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vmg/controllers/auth_controller.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:widget_circular_animator/widget_circular_animator.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthController authController = Get.find();
  int selectedIndex = 0;
  DateTime services = DateTime.now().add(Duration(days: 1));

  DateTime firstOfMonth =
      DateTime(DateTime.now().year, DateTime.now().month + 1, 1);

  @override
  Widget build(BuildContext context) {
    int daysLeft = (firstOfMonth.difference(DateTime.now()).inDays) - 1;
    int dayServices = services.difference(services).inDays;

    //print();
    print("EE${services}");

    //print("days : ${daysLeft}");
    //double percent_services=;
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
                        shape: BoxShape.circle, color: Colors.grey.shade400),
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onLongPress: () {},
                        child: Container(
                          width: double.maxFinite,
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade400,
                            borderRadius: BorderRadius.circular(5),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.shade500,
                                blurRadius: 30,
                                spreadRadius: 5,
                              )
                            ],
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
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.shade500,
                                blurRadius: 30,
                                spreadRadius: 5,
                              )
                            ],
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
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.shade500,
                                blurRadius: 30,
                                spreadRadius: 5,
                              )
                            ],
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
                        padding: EdgeInsets.all(6),
                        decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(10)),
                        width: 180,
                        height: 160,
                        child: GridView.count(
                            crossAxisCount: 2,
                            mainAxisSpacing: 6,
                            semanticChildCount: 4,
                            childAspectRatio: 6 / 5.2,
                            crossAxisSpacing: 6,
                            children: [
                              for (int index = 0; index < 4; index++)
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedIndex = index;
                                    });
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: selectedIndex == index
                                          ? Colors.grey.shade700
                                          : Colors.grey.shade400,
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.shade500,
                                          blurRadius: 10,
                                          spreadRadius: 5,
                                        ),
                                      ],
                                    ),
                                    height: 10,
                                    width: 10,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        // Icon and Text widgets for each item
                                        // Customize as needed based on the selected index
                                        Icon(
                                          index == 0
                                              ? FontAwesomeIcons.umbrellaBeach
                                              : index == 1
                                                  ? Icons.electric_meter_sharp
                                                  : index == 2
                                                      ? Icons.water_damage_sharp
                                                      : Icons
                                                          .electric_bolt_rounded,
                                          size: index == 0 ? 30 : 40,
                                          color: selectedIndex == index
                                              ? Colors.grey.shade400
                                              : Colors.grey.shade700,
                                        ),
                                        Text(
                                          index == 0
                                              ? "Swimming Pool"
                                              : index == 1
                                                  ? "Generator"
                                                  : index == 2
                                                      ? "Tank Cleaning"
                                                      : "Electricity Bill",
                                          style: GoogleFonts.ubuntu(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 13,
                                            color: selectedIndex == index
                                                ? Colors.grey.shade400
                                                : Colors.grey.shade700,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ]),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade400,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        width: 150,
                        height: 160,
                        child: GestureDetector(
                          onTap: () async {
                            DateTime? selectedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(DateTime.now().year),
                              lastDate: DateTime(DateTime.now().year + 1),
                            );

                            if (selectedDate != null) {
                              setState(() {
                                services = selectedDate;
                              });
                            }
                          },
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
                                    "89 days", // Calculate the difference
                                    style: GoogleFonts.ubuntu(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: daysLeft < 5
                                          ? Colors.red.shade500
                                          : Colors.grey.shade800,
                                    ),
                                  ),
                            progressColor: Colors.grey.shade800,
                            percent: 15 / 30, // Calculate the percentage
                            circularStrokeCap: CircularStrokeCap.round,
                          ),
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
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Row(
                children: [
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: authController.isAdmin == 'admin'
                        ? Container(
                            height: double.maxFinite,
                            width: 180,
                            decoration: BoxDecoration(
                                color: Colors.grey.shade600,
                                borderRadius: BorderRadius.circular(10)),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Container(
                                  width: 165,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade400,
                                    borderRadius: BorderRadius.circular(6),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.shade500,
                                        blurRadius: 30,
                                        spreadRadius: 5,
                                      )
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Text(
                                        "Add Resident",
                                        style: GoogleFonts.ubuntu(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 16,
                                            color: Colors.black54),
                                      ),
                                      Icon(
                                        CupertinoIcons.check_mark_circled_solid,
                                        color: Colors.grey.shade600,
                                      )
                                    ],
                                  ),
                                ),
                                Container(
                                  width: 170,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade400,
                                    borderRadius: BorderRadius.circular(6),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.shade500,
                                        blurRadius: 30,
                                        spreadRadius: 5,
                                      )
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Text(
                                        "Remove Resident",
                                        style: GoogleFonts.ubuntu(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 16,
                                            color: Colors.black54),
                                      ),
                                      Icon(
                                        CupertinoIcons.xmark_circle_fill,
                                        color: Colors.grey.shade600,
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                          )
                        : Container(
                            height: double.maxFinite,
                            width: 180,
                            decoration: BoxDecoration(
                                color: Colors.grey.shade500,
                                borderRadius: BorderRadius.circular(10))),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Container(
                      height: double.maxFinite,
                      width: 150,
                      decoration: BoxDecoration(
                          color: Colors.grey.shade500,
                          borderRadius: BorderRadius.circular(10)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            width: 140,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade400,
                              borderRadius: BorderRadius.circular(6),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.shade500,
                                  blurRadius: 30,
                                  spreadRadius: 5,
                                )
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text(
                                  "Edit Details",
                                  style: GoogleFonts.ubuntu(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 16,
                                      color: Colors.black54),
                                ),
                                Icon(
                                  CupertinoIcons.pencil_circle_fill,
                                  color: Colors.grey.shade600,
                                )
                              ],
                            ),
                          ),
                          Container(
                            width: 140,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade400,
                              borderRadius: BorderRadius.circular(6),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.shade500,
                                  blurRadius: 30,
                                  spreadRadius: 5,
                                )
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text(
                                  "Add Admin",
                                  style: GoogleFonts.ubuntu(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 16,
                                      color: Colors.black54),
                                ),
                                Icon(
                                  CupertinoIcons.checkmark_shield_fill,
                                  color: Colors.grey.shade600,
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
