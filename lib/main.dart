import 'package:edunote/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:edunote/services/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get_storage/get_storage.dart';
import 'services/auth_controller.dart';
import 'package:edunote/widget/text_box.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ).then((value) => Get.put(AuthController()));
  runApp(
    kReleaseMode
        ? MyApp()
        : DevicePreview(enabled: !kReleaseMode, builder: (context) => MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    Size s = MediaQuery.of(context).size;
    debugPrint(s.toString());
    return ScreenUtilInit(
      designSize: const Size(428.3, 951.7),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        return GetMaterialApp(
          useInheritedMediaQuery: true,
          locale: DevicePreview.locale(context),
          builder: DevicePreview.appBuilder,
          debugShowCheckedModeBanner: false,
          home: const SplashScreen(),
          initialBinding: BindingsBuilder(() {
            Get.put<ObTextController>(
              ObTextController(),
              permanent: true,
            ); // 👈 stays alive
          }),
        );
      },
    );
  }
}
