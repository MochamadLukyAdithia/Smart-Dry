import 'package:smart_dry/features/setting/model/suhu_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SettingController {
  static final supabase = Supabase.instance.client;

  static Future<bool> updateBatasanSuhu(int batasanSuhu, {int userId = 1}) async {
  try {
    final response = await supabase
        .from("Suhu")
        .update({
          "batasan_suhu": batasanSuhu,
        })
        .eq("id_user", userId);

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


  static Future<SuhuModel> getBatasanSuhu({int userId = 1}) async {
    try {
      final response = await supabase
          .from("Suhu")
          .select("batasan_suhu, current_temperatur")
          .eq("id_user", userId)
          .order("id_suhu", ascending: false)
          .limit(1)
          .maybeSingle();
      print(response);
      if (response != null) {
        return SuhuModel.fromJson(response);
      } else {
        print('No data found for userId: $userId');
        return SuhuModel(
          id_suhu: 0,
          id_user: userId,
          batasan_suhu: 0,
          current_temperature: 0,
        );
      }
    } catch (e) {
      print('Get error: $e');
      return SuhuModel(
        id_suhu: 0,
        id_user: userId,
        batasan_suhu: 0,
        current_temperature: 0,
      );
    }
  }
  static Stream<SuhuModel> listenToSuhu({int userId = 1}) {
  return supabase
      .from("Suhu")
      .stream(primaryKey: ["id_suhu"])
      .eq("id_user", userId)
      .order("id_suhu", ascending: false)
      .limit(1)
      .map((event) {
        if (event.isNotEmpty) {
          return SuhuModel.fromJson(event.first);
        } else {
          return SuhuModel(
            id_suhu: 0,
            id_user: userId,
            batasan_suhu: 0,
            current_temperature: 0,
          );
        }
      });
}

}
