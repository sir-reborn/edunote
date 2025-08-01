import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'ui_text.dart';
import 'white_space.dart';
import 'package:edunote/utils/colour.dart';

class TextBox extends StatelessWidget {
  const TextBox({
    super.key,
    required this.textBoxName,
    required this.hintText,
    required this.prefixIcon,
    required this.obscureRequired,
    this.controllerr,
  });

  final String textBoxName;
  final String hintText;
  final IconData prefixIcon;
  final bool obscureRequired;
  final TextEditingController? controllerr;
  @override
  Widget build(BuildContext context) {
    if (obscureRequired && !Get.isRegistered<ObTextController>()) {
      Get.put(ObTextController());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        UiText(
          textBoxName,
          fontSize: 17,
          color: Colors.black.withOpacity(0.7),
          textAlign: TextAlign.left,
          // fontWeight: FontWeight.w500
        ),
        WhiteSpace(height: 10),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.sp),
            border: Border.all(color: Colour.purple, width: 2.w),
          ),
          child: obscureRequired
              ? Obx(() {
                  final controller = Get.find<ObTextController>();
                  return TextField(
                    controller: controllerr,
                    obscureText: controller.obscureText.value,
                    cursorColor: Colors.black.withOpacity(0.7),
                    style: TextStyle(color: Colors.black.withOpacity(0.7)),
                    decoration: _inputDecoration(controller),
                  );
                })
              : TextField(
                  controller: controllerr,
                  obscureText: false,
                  keyboardType: TextInputType.emailAddress,
                  cursorColor: Colors.black.withOpacity(0.7),
                  style: TextStyle(color: Colors.black.withOpacity(0.7)),
                  decoration: _inputDecoration(null),
                ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(ObTextController? controller) {
    return InputDecoration(
      contentPadding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 10.w),
      hintText: hintText,
      hintStyle: GoogleFonts.poppins(
        textStyle: TextStyle(
          fontSize: 15.sp,
          fontWeight: FontWeight.normal,
          color: Colors.grey,
        ),
      ),
      prefixIcon: Icon(prefixIcon, color: Colors.grey, size: 20.sp),
      suffixIcon: obscureRequired
          ? IconButton(
              onPressed: () {
                controller?.toggle();
              },
              icon: Icon(
                controller!.obscureText.value
                    ? Icons.visibility_off
                    : Icons.visibility,
                color: Colors.grey,
                size: 20.sp,
              ),
            )
          : SizedBox.shrink(),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.sp),
        borderSide: BorderSide(color: Colors.white),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.sp),
        borderSide: BorderSide(color: Colors.white),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.sp),
        borderSide: BorderSide(color: Colors.white),
      ),
    );
  }
}

class ObTextController extends GetxController {
  var obscureText = true.obs;
  toggle() => obscureText.value = !obscureText.value;
}
