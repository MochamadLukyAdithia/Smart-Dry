
import 'package:get/get.dart';

class Logincontroller extends GetxController {
  var isLoading = false.obs;
  void login(String email, String password) async {
    isLoading.value = true;
    await Future.delayed(const Duration(seconds: 2), () {
      isLoading.value = false;
      Get.snackbar('Login Success', 'Welcome ');
    });
  }
}
