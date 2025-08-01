import 'package:edunote/services/auth_controller.dart';
import 'package:edunote/utils/colour.dart';
import 'package:edunote/screens/creator/recording_screen.dart';
import 'package:edunote/widget/round_button.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: SingleChildScrollView(
        child: SizedBox(
          height: size.height,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colour.purple1, Colour.purple2, Colour.purple3],
                begin: const FractionalOffset(0.0, 0.4),
                end: Alignment.topRight,
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: size.width,
                  height: size.height * (2 / 5),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                    ).copyWith(bottom: size.height * 0.03),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Spacer(flex: 3),
                        Text(
                          'EduNote\nAssistant',
                          style: GoogleFonts.poppins(
                            fontSize: 45,
                            fontWeight: FontWeight.bold,
                            color: Colour.kwhite,
                          ),
                        ),
                        Spacer(),
                        Text(
                          'Transform your lectures and speeches into organised documents.',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.normal,
                            color: Colour.kwhite,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    width: size.width,
                    decoration: BoxDecoration(
                      color: Colour.kwhite,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(60),
                        topRight: Radius.circular(60),
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Tap to Record',
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.normal,
                              color: Colour.purple2,
                            ),
                          ),
                          SizedBox(height: size.height * 0.02),
                          GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const RecordingScreen(),
                              ),
                            ),
                            child: Image(image: AssetImage('assets/mic.png')),
                          ),
                          SizedBox(height: size.height * 0.02),
                          RoundButton(
                            text: 'Log Out',
                            bgColor: Colour.blue,
                            textColor: Colors.white,
                            onPressed: () {
                              AuthController.instance.logOut();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
