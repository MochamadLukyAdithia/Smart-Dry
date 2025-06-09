import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthController {
  static final supabase = Supabase.instance.client;

  static Future<bool> login(String username, String password) async {
    try {
      final response = await supabase 
          .from("Akun")
          .select()
          .eq("username", username)
          .eq("password", password)
          .maybeSingle();

      if (response != null) {
        return true;
      } else {
        Get.snackbar("Gagal", "Username atau password salah",
            snackPosition: SnackPosition.BOTTOM);
        return false;
      }
    } catch (e) {
      print('Login error: $e');
      Get.snackbar("Error", "Terjadi kesalahan saat login",
          snackPosition: SnackPosition.BOTTOM);
      return false;
    }
  }

  static Future<bool> logout() async {
    try {
      await supabase.auth.signOut();
      Get.snackbar("Berhasil", "Anda telah logout",
          snackPosition: SnackPosition.BOTTOM);
      return true;
    } catch (e) {
      print('Logout error: $e');
      Get.snackbar("Error", "Terjadi kesalahan saat logout",
          snackPosition: SnackPosition.BOTTOM);
      return false;
    }
  }
}
