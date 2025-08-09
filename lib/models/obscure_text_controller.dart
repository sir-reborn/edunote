import 'package:get/get.dart';

class ObTextController extends GetxController {
  var obscureText = true.obs;
  toggle() => obscureText.value = !obscureText.value;
}
