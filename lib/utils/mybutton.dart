import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MyButton extends StatelessWidget {
  final String iconPath;
  final String buttonText;

  const MyButton({Key? key, required this.iconPath, required this.buttonText})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          padding: const EdgeInsets.all(8),
          child: IconButton(
            onPressed: () {},
            icon: Image.asset(iconPath),
          ),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey.shade500,
              boxShadow: [
                BoxShadow(
                    color: Colors.grey.shade400,
                    blurRadius: 40,
                    spreadRadius: 10)
              ]),
        ),
        SizedBox(
          height: 10,
        ),
        Text(
          buttonText,
          style: GoogleFonts.poppins(
              color: Colors.black54, fontSize: 12, fontWeight: FontWeight.bold),
        )
      ],
    );
  }
}
