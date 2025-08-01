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
import 'package:edunote/screens/authentication/sign_up_screen.dart';
import 'package:edunote/services/auth_controller.dart';

import 'package:edunote/utils/colour.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  var emailController = TextEditingController();

  var passwordController = TextEditingController();

  Widget build(BuildContext context) {
    Size w = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  alignment: AlignmentDirectional.center,
                  child: Column(
                    children: [
                      SizedBox(height: w.height * 1 / 12),
                      Image(
                        width: w.width * 1 / 4,
                        fit: BoxFit.fitWidth,
                        image: AssetImage('assets/logoo.png'),
                      ),
                      SizedBox(height: 8),
                      UiText(
                        'Welcome back',
                        fontSize: 30,
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: w.height * 1 / 20),
                TextBox(
                  textBoxName: 'Email',
                  obscureRequired: false,
                  hintText: 'Enter email',
                  prefixIcon: Icons.email,
                  controllerr: emailController,
                ),
                SizedBox(height: 25),
                TextBox(
                  textBoxName: 'Password',
                  hintText: 'Enter Password',
                  prefixIcon: Icons.lock,
                  obscureRequired: true,
                  controllerr: passwordController,
                ),
                SizedBox(height: 11),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(),
                    UiText(
                      'Forgot password?',
                      fontSize: 16,
                      color: Colour.purple,
                      fontWeight: FontWeight.w500,
                    ),
                  ],
                ),
                SizedBox(height: w.height * 1 / 20),
                RoundButton(
                  text: 'LOGIN',
                  bgColor: Colour.purple,
                  textColor: Colors.white,
                  onPressed: () {
                    AuthController.instance.login(
                      emailController.text.trim(),
                      passwordController.text.trim(),
                    );
                  },
                ),
                SizedBox(height: 11),
                Center(
                  child: RichText(
                    text: TextSpan(
                      text: 'Don\'t have an account?',
                      style: GoogleFonts.poppins(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.black.withOpacity(0.7),
                        letterSpacing: 0.001,
                      ),
                      children: [
                        TextSpan(
                          text: ' sign up',
                          style: GoogleFonts.poppins(
                            decoration: TextDecoration.underline,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                            color: Colour.purple,
                            letterSpacing: 0.001,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () => Get.off(() => SignUpScreen()),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    //);
  }
}
