import 'package:smart_dry/features/kadar_air/model/kadarair_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Kadaraircontroller {
  Future<List<KadarairModel>> fetchData() async {
    final response = await Supabase.instance.client.from('Kadar_Air').select();

    final List<KadarairModel> data =
        (response as List).map((item) => KadarairModel.fromJson(item)).toList();

    return data;
  }

  void processInput(String input) {
    // Logic to process user input
  }
}
