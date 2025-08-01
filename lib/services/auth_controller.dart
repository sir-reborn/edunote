import 'package:edunote/screens/creator/home_page.dart';
import 'package:edunote/screens/creator/tab_view_control.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:edunote/utils/colour.dart';

import '../../screens/authentication/login_screen.dart';

class AuthController extends GetxController {
  static AuthController instance = Get.find();
  final deviceStorage = GetStorage();
  late Rx<User?> _user;
  FirebaseAuth auth = FirebaseAuth.instance;

  @override
  //onReady is called after the contr is initialised hence the best place to initialise the user
  void onReady() {
    super.onReady();

    _user = Rx<User?>(auth.currentUser);
    _user.bindStream(auth.userChanges());
    // ever process the stream,or notification from firebase,user is the listener,
    //initScreen is the callback func called if user notices a change
    ever(_user, _initiaScreen);
  }

  // initial settings if a user is logged in or not, it will be accessible everywhere in the app
  _initiaScreen(User? user) async {
    await Future.delayed(const Duration(seconds: 3));
    if (user == null) {
      print('login page');
      Get.offAll(() => LoginScreen());
    } else {
      Get.offAll(() => TabViewControl());
    }
    print(user?.uid);
  }

  void register(String email, password) async {
    try {
      await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      Get.snackbar(
        'About User',
        'User message',
        backgroundColor: Colour.purple,
        snackPosition: SnackPosition.TOP,
        titleText: Text(
          'Account creation failed',
          style: TextStyle(color: Colors.white),
        ),
        messageText: Text(e.toString(), style: TextStyle(color: Colors.white)),
      );
    }
  }

  void login(String email, password) async {
    try {
      await auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      Get.snackbar(
        'About Login',
        'Login message',
        backgroundColor: Colour.purple,
        snackPosition: SnackPosition.TOP,
        titleText: Text('Login failed', style: TextStyle(color: Colors.white)),
        messageText: Text(e.toString(), style: TextStyle(color: Colors.white)),
      );
    }
  }

  void logOut() async {
    await auth.signOut();
  }

  //.
}
