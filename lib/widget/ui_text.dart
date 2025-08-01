import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class UiText extends StatelessWidget {
  const UiText(this.text,
      {super.key,
      this.textAlign,
      required this.fontSize,
      this.fontWeight,
      required this.color});
  final String text;
  final TextAlign? textAlign;
  final double fontSize;
  final FontWeight? fontWeight;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: 1,
      softWrap: false,
      overflow: TextOverflow.fade,
      textAlign: textAlign ?? TextAlign.left,
      style: GoogleFonts.poppins(
          fontSize: fontSize.sp,
          fontWeight: fontWeight ?? FontWeight.normal,
          color: color),
    );
  }
}
