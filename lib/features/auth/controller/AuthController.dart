import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:smart_dry/features/auth/model/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Authcontroller extends GetxController {
  final isLoading = false.obs;

  Future<void> login(UserModel userModel) async {
    if (userModel.email == null || userModel.email!.isEmpty) {
      Get.snackbar('Error', 'Email cannot be empty');
      return;
    }

    if (userModel.password == null || userModel.password!.isEmpty) {
      Get.snackbar('Error', 'Password cannot be empty');
      return;
    }

    isLoading.value = true;

    try {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: userModel.email!,
        password: userModel.password!,
      );

      if (response.user != null) {
        Get.snackbar(
          'Success',
          'Login successful!',
          backgroundColor: Color.fromARGB(255, 220, 157, 134).withOpacity(0.2),
          colorText: Color.fromARGB(255, 118, 55, 32),
        );
        Get.offAllNamed('/home');
      } else {
        Get.snackbar('Error', 'Login failed: User is null');
      }
    } on AuthException catch (e) {
      Get.snackbar('Error', 'Login failed: ${e.message}');
    } catch (e) {
      Get.snackbar('Error', 'Login failed: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }
}
