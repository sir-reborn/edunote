import 'package:edunote/services/auth_controller.dart';
import 'package:edunote/utils/colour.dart';
import 'package:edunote/widget/round_button.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile', style: TextStyle(color: Colors.white)),
      ),
      body: Center(
        child: RoundButton(
          text: 'LOGOUT',
          bgColor: Colour.purple,
          textColor: Colors.white,
          onPressed: () {
            AuthController.instance.logOut();
          },
        ),
      ),
    );
  }
}
