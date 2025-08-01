import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:edunote/widget/round_button.dart';
import 'package:edunote/widget/text_box.dart';
import 'package:edunote/widget/ui_text.dart';
import 'package:edunote/widget/white_space.dart';
import 'package:edunote/screens/authentication/login_screen.dart';
import 'package:edunote/services/auth_controller.dart';

import 'package:edunote/utils/colour.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    Size w = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: w.height * 1 / 7),
            UiText(
              'Join EduNote Today',
              fontWeight: FontWeight.w500,
              fontSize: 30,
              color: Colors.black,
            ),
            WhiteSpace(height: 8),
            Text(
              'Sign up to unlock intelligent note-taking, instant lecture transcripts and more.',
              textAlign: TextAlign.left,
              style: GoogleFonts.poppins(
                fontSize: 15.sp,
                fontWeight: FontWeight.w400,
                color: Colors.black.withOpacity(0.7),
              ),
            ),
            SizedBox(height: w.height * 1 / 25),
            TextBox(
              textBoxName: 'Full name',
              hintText: 'Reborn Leo',
              prefixIcon: Icons.person,
              obscureRequired: false,
            ),
            WhiteSpace(height: 25),
            TextBox(
              controllerr: emailController,
              textBoxName: 'Email',
              hintText: 'RebornLeo@gmail.com',
              prefixIcon: Icons.email,
              obscureRequired: false,
            ),
            WhiteSpace(height: 25),
            TextBox(
              controllerr: passwordController,
              textBoxName: 'Password',
              hintText: '******',
              prefixIcon: Icons.lock,
              obscureRequired: true,
            ),
            WhiteSpace(height: 30),
            RoundButton(
              text: 'SIGN UP',
              bgColor: Colour.purple,
              textColor: Colors.white,
              onPressed: () {
                AuthController.instance.register(
                  emailController.text.trim(),
                  passwordController.text.trim(),
                );
              },
            ),
            WhiteSpace(height: 30),
            Center(
              child: RichText(
                text: TextSpan(
                  text: 'Already have Account?',
                  style: GoogleFonts.poppins(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.black.withOpacity(0.7),
                    letterSpacing: 0.001,
                  ),
                  children: [
                    TextSpan(
                      text: ' Log In',
                      style: GoogleFonts.poppins(
                        decoration: TextDecoration.underline,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        color: Colour.purple,
                        letterSpacing: 0.001,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () => Get.off(() => LoginScreen()),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
