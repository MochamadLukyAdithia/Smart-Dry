import 'package:smart_dry/features/kadar_air/model/kadarair_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Kadaraircontroller {
  static final supabase = Supabase.instance.client;
  static Future<bool> updateKadarAir(KadarairModel kadar) async {
    try {
      final response = await supabase.from("Kadar_Air").update({
        "kadar_air": kadar.kadar_air,
        "status_kadar_air": kadar.status_kadar_air,
      }).eq("id_kadar_air", 1);

      if (response.error == null) {
        print('Update success: ${response.data}');
        return true;
      } else {
        print('Update failed: ${response.error!.message}');
        return false;
      }
    } catch (e) {
      print('Update exception: $e');
      return false;
    }
  }
  static Future<KadarairModel?> getDataKadarAir() async {
    try {
      final data =
          await supabase.from("Kadar_Air").select().limit(1).maybeSingle();

      if (data != null) {
        print('Data fetch success: $data');
        return KadarairModel.fromJson(data);
      } else {
        print('No data found.');
        return null;
      }
    } catch (e) {
      print('Fetch error: $e');
      return null;
    }
  }
}
