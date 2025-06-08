import 'package:duri_care/core/services/zone_service.dart';
import 'package:duri_care/core/utils/helpers/dialog_helper.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HistoryController extends GetxController {
  final ZoneService _zoneService = Get.find<ZoneService>();
  final SupabaseClient _supabase = Supabase.instance.client;
  final isLoading = false.obs;
  final historyList = <Map<String, dynamic>>[].obs;
  final selectedZoneId = ''.obs;
  final selectedZoneName = ''.obs;
  final RxMap<String, String> userNameCache = <String, String>{}.obs;
  @override
  void onInit() {
    super.onInit();

    if (Get.arguments != null && Get.arguments['zoneId'] != null) {
      selectedZoneId.value = Get.arguments['zoneId'].toString();
      if (Get.arguments['zoneName'] != null) {
        selectedZoneName.value = Get.arguments['zoneName'].toString();
      }
      loadHistory();
    } else {
      loadZones().then((_) {
        loadHistory();
      });
    }
  }

  Future<void> loadZones() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        DialogHelper.showErrorDialog(
          title: 'Authentication Error',
          message: 'User not logged in. Please log in to view your zones.',
        );
        return;
      }

      final zoneModels = await _zoneService.loadZones(userId);
      if (zoneModels.isNotEmpty && selectedZoneId.isEmpty) {
        selectedZoneId.value = zoneModels.first.id.toString();
        selectedZoneName.value = zoneModels.first.name;
      }
    } catch (e) {
      DialogHelper.showErrorDialog(
        title: 'Failed to Load Zones',
        message: 'Error: ${e.toString()}',
      );
    }
  }

  Future<void> loadHistory() async {
    if (selectedZoneId.value.isEmpty) return;

    isLoading.value = true;
    historyList.clear();

    try {
      final histories = await _zoneService.loadAllIrrigationHistory(
        selectedZoneId.value,
      );

      for (var history in histories) {
        final executedBy = history.executedBy;
        String userName = "Unknown";

        if (userNameCache.containsKey(executedBy)) {
          userName = userNameCache[executedBy]!;
        } else {
          try {
            final userProfile =
                await _supabase
                    .from('users')
                    .select('fullname')
                    .eq('id', executedBy)
                    .maybeSingle();

            if (userProfile != null) {
              userName = userProfile['fullname'] ?? 'Unknown User';
              userNameCache[executedBy] = userName;
            }
          } catch (e) {
            userName = 'User $executedBy';
          }
        }

        historyList.add({
          'id': history.id,
          'zone_id': history.zoneId,
          'started_at': history.startedAt,
          'duration': history.duration,
          'type': history.type,
          'message': history.message,
          'executed_by': userName,
          'executed_by_id': history.executedBy,
          'created_at': history.createdAt,
        });
      }
    } catch (e) {
      DialogHelper.showErrorDialog(
        title: 'Gagal Memuat Riwayat',
        message: 'Gagal memuat riwayat irigasi: ${e.toString()}',
      );
    } finally {
      isLoading.value = false;
    }
  }

  void changeSelectedZone(String zoneId, String zoneName) {
    selectedZoneId.value = zoneId;
    selectedZoneName.value = zoneName;
    loadHistory();
  }

  String getZoneName() {
    return selectedZoneName.value.isNotEmpty
        ? selectedZoneName.value
        : 'Unknown Zone';
  }
}
