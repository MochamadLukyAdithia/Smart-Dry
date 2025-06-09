import 'package:smart_dry/features/setting/model/suhu_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Homecontroller {
  static final supabase = Supabase.instance.client;

  // Method untuk update protect mode secara terpisah
  static Future<void> updateProtectMode(bool isActive) async {
    try {
      final response = await supabase.from('Pengeringan').update({
        'status_hujan': isActive,
      }).eq('id_pengeringan', 1);

      if (response.error == null) {
        print('Protect mode updated successfully: $isActive');
      } else {
        print('Error updating protect mode: ${response.error!.message}');
      }
    } catch (e) {
      print('Exception updating protect mode: $e');
    }
  }

  // Method untuk update heater mode secara terpisah
  static Future<void> updateHeaterMode(bool isActive) async {
    try {
      final response = await supabase.from('Pengeringan').update({
        'status_pemanas': isActive,
      }).eq('id_pengeringan', 1);

      if (response.error == null) {
        print('Heater mode updated successfully: $isActive');
      } else {
        print('Error updating heater mode: ${response.error!.message}');
      }
    } catch (e) {
      print('Exception updating heater mode: $e');
    }
  }

  // Method untuk update fan status secara terpisah
  static Future<void> updateFanStatus(bool isActive) async {
    try {
      final response = await supabase.from('Pengeringan').update({
        'status_kipas': isActive,
      }).eq('id_pengeringan', 1);

      if (response.error == null) {
        print('Fan status updated successfully: $isActive');
      } else {
        print('Error updating fan status: ${response.error!.message}');
      }
    } catch (e) {
      print('Exception updating fan status: $e');
    }
  }

  // Method untuk update semua status sekaligus (untuk mode auto)
  static Future<void> updateAllStatus({
    bool? statusHujan,
    bool? statusPemanas,
    bool? statusKipas,
  }) async {
    try {
      Map<String, dynamic> updateData = {};

      if (statusHujan != null) updateData['status_hujan'] = statusHujan;
      if (statusPemanas != null) updateData['status_pemanas'] = statusPemanas;
      if (statusKipas != null) updateData['status_kipas'] = statusKipas;

      if (updateData.isNotEmpty) {
        final response = await supabase
            .from('Pengeringan')
            .update(updateData)
            .eq('id_pengeringan', 1);

        if (response.error == null) {
          print('All status updated successfully: $updateData');
        } else {
          print('Error updating all status: ${response.error!.message}');
        }
      }
    } catch (e) {
      print('Exception updating all status: $e');
    }
  }

  // Deprecated - untuk backward compatibility, akan dihapus di versi mendatang
  @deprecated
  static Future<void> updateDataHujanAuto(
      bool status_hujan, bool status_pemanas, bool status_kipas) async {
    await updateAllStatus(
      statusHujan: status_hujan,
      statusPemanas: status_pemanas,
      statusKipas: status_kipas,
    );
  }

  // Deprecated - untuk backward compatibility, akan dihapus di versi mendatang
  @deprecated
  static Future<void> updateDataHujanManual(
      bool status_hujan, bool status_pemanas, bool status_kipas) async {
    await updateAllStatus(
      statusHujan: status_hujan,
      statusPemanas: status_pemanas,
      statusKipas: status_kipas,
    );
  }

  static Future<void> updateModePengeringan(String mode) async {
    try {
      final response = await supabase.from('Pengeringan').update({
        'mode': mode,
      }).eq('id_pengeringan', 1);

      if (response.error == null) {
        print('Mode pengeringan updated successfully: $mode');
      } else {
        print('Error updating mode pengeringan: ${response.error!.message}');
      }
    } catch (e) {
      print('Exception updating mode pengeringan: $e');
    }
  }

  // Method untuk mendapatkan status saat ini dari database
  static Future<Map<String, dynamic>?> getCurrentStatus() async {
    try {
      final response = await supabase
          .from('Pengeringan')
          .select('status_hujan, status_pemanas, status_kipas, mode')
          .eq('id_pengeringan', 1)
          .maybeSingle();

      if (response != null) {
        print('Current status retrieved: $response');
        return response;
      } else {
        print('No status data found');
        return null;
      }
    } catch (e) {
      print('Exception getting current status: $e');
      return null;
    }
  }

  static Future<SuhuModel> getDataSuhu({int userId = 1}) async {
    try {
      final response = await supabase
          .from("Suhu")
          .select("batasan_suhu, current_temperatur")
          .eq("id_user", userId)
          .order("id_suhu", ascending: false)
          .limit(1)
          .maybeSingle();

      print('Temperature data retrieved: $response');

      if (response != null) {
        return SuhuModel.fromJson(response);
      } else {
        print('No temperature data found for userId: $userId');
        return SuhuModel(
          id_suhu: 0,
          id_user: userId,
          batasan_suhu: 0,
          current_temperature: 0,
        );
      }
    } catch (e) {
      print('Exception getting temperature data: $e');
      return SuhuModel(
        id_suhu: 0,
        id_user: userId,
        batasan_suhu: 0,
        current_temperature: 0,
      );
    }
  }

  // Method untuk sync status dari database ke UI
  static Future<void> syncStatusFromDatabase() async {
    try {
      final status = await getCurrentStatus();
      if (status != null) {
        // Anda bisa menggunakan callback atau state management
        // untuk update UI berdasarkan data dari database
        print('Syncing status: $status');
      }
    } catch (e) {
      print('Exception syncing status: $e');
    }
  }

  // Method untuk reset semua status
  static Future<void> resetAllStatus() async {
    await updateAllStatus(
      statusHujan: false,
      statusPemanas: false,
      statusKipas: false,
    );
  }

  // Method untuk emergency stop
  static Future<void> emergencyStop() async {
    try {
      await resetAllStatus();
      print('Emergency stop executed - all systems disabled');
    } catch (e) {
      print('Exception during emergency stop: $e');
    }
  }

// Get fan status from database
  static Future<bool?> getFanStatus() async {
    try {
      final response = await supabase
          .from('Pengeringan')
          .select('status_kipas')
          .eq('id_pengeringan', 1)
          .single(); // Mengambil satu baris data

      if (response != null && response['status_kipas'] != null) {
        return response['status_kipas'] as bool;
      } else {
        print('Fan status not found or null');
        return null;
      }
    } catch (e) {
      print('Exception getting fan status: $e');
      return null;
    }
  }
  static Stream<SuhuModel> streamDataSuhu({int userId = 1}) {
  return supabase
      .from('Suhu')
      .stream(primaryKey: ['id_suhu']) // use your real primary key here
      .eq('id_user', userId)
      .order('id_suhu', ascending: false)
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
