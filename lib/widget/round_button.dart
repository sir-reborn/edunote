import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:edunote/utils/colour.dart';

class RoundButton extends StatelessWidget {
  const RoundButton({
    super.key,
    this.onPressed,
    required this.text,
    this.bgColor,
    this.textColor,
  });
  final VoidCallback? onPressed;
  final String text;
  final Color? bgColor;
  final Color? textColor;
  @override
  Widget build(BuildContext context) {
    Size w = MediaQuery.of(context).size;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: bgColor ?? Colors.white,
        minimumSize: Size(w.width * 0.9, w.height * 0.06),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      onPressed: onPressed,
      child: Text(
        text,
        maxLines: 1,
        softWrap: false,
        overflow: TextOverflow.fade,
        textAlign: TextAlign.center,
        style: GoogleFonts.poppins(
          fontSize: 20.sp,
          fontWeight: FontWeight.w600,
          color: textColor ?? Colour.blue,
          letterSpacing: 1,
        ),
      ),
    );
  }
}
