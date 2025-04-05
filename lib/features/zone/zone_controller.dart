import 'package:duri_care/core/utils/helpers/dialog_helper.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:get_storage/get_storage.dart';

class ZoneController extends GetxController {
  final supabase = Supabase.instance.client;
  final zones = <Map<String, dynamic>>[].obs;
  final selectedZone = <String, dynamic>{}.obs;
  final isActive = false.obs;
  final storage = GetStorage();

  @override
  void onInit() {
    super.onInit();
    isActive.value = storage.read('isActive') ?? false;
  }

  Future<void> createZone(String zoneName) async {
    try {
      final response = await supabase.from('zones').insert({
        'name': zoneName,
        'owner_id': supabase.auth.currentUser?.id,
        'device_count': 0,
        'status': 'inactive',
        'created_at': DateTime.now().toIso8601String(),
      });
      if (response.error == null) {
        zones.add(response.data[0]);
        DialogHelper.showSuccessDialog(
          title: 'Zona Berhasil Dibuat',
          'Zona $zoneName berhasil dibuat.',
        );
      } else {
        DialogHelper.showErrorDialog(
          title: 'Gagal Membuat Zona',
          response.error!.message,
        );
      }
    } catch (e) {
      DialogHelper.showErrorDialog(title: 'Error', e.toString());
    }
  }

  void deleteZone(String zoneId) async {
    try {
      final response = await supabase.from('zones').delete().eq('id', zoneId);
      if (response.error == null) {
        zones.removeWhere((zone) => zone['id'] == zoneId);
        DialogHelper.showSuccessDialog(
          title: 'Zona Dihapus',
          'Zona berhasil dihapus.',
        );
      } else {
        DialogHelper.showErrorDialog(
          title: 'Gagal Menghapus Zona',
          response.error!.message,
        );
      }
    } catch (e) {
      DialogHelper.showErrorDialog(title: 'Error', e.toString());
    }
  }

  void updateZone(String zoneId, String newZoneName) {}

  void toggleActive() {
    isActive.value = !isActive.value;
    storage.write('isActive', isActive.value);
  }
}
