import 'package:duri_care/core/resources/resources.dart';
import 'package:duri_care/core/themes/app_themes.dart';
import 'package:duri_care/core/utils/widgets/back_button.dart';
import 'package:duri_care/features/history/history_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class HistoryView extends GetView<HistoryController> {
  const HistoryView({super.key});
  static const String route = '/history';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColor.greenPrimary,
        leading: AppBackButton(iconColor: AppColor.white),
        title: Text(
          'Riwayat Irigasi',
          style: AppThemes.textTheme(context, ColorScheme.dark()).titleLarge,
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(
              () =>
                  controller.isLoading.value
                      ? const Center(child: CircularProgressIndicator())
                      : _buildHistoryList(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList(BuildContext context) {
    if (controller.historyList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.history_rounded, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'Belum ada riwayat irigasi',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Riwayat irigasi akan muncul di sini',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: Colors.grey),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: () => controller.loadHistory(),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: controller.historyList.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final history = controller.historyList[index];
          return _buildHistoryCard(context, history);
        },
      ),
    );
  }

  Widget _buildHistoryCard(BuildContext context, Map<String, dynamic> history) {
    final startedAt = history['started_at'] as DateTime;
    final formattedDate = DateFormat('dd MMM yyyy, HH:mm').format(startedAt);
    final duration = history['duration'] as int;
    final type = history['type'] as String;
    final message = history['message'] as String;
    final executedBy = history['executed_by'] as String;

    IconData historyIcon = Icons.water_drop;
    Color iconColor = AppColor.greenPrimary;

    if (type.toLowerCase().contains('manual')) {
      historyIcon = Icons.touch_app;
      iconColor = Colors.blue;
    } else if (type.toLowerCase().contains('jadwal') ||
        type.toLowerCase().contains('schedule')) {
      historyIcon = Icons.schedule;
      iconColor = Colors.purple;
    } else if (type.toLowerCase().contains('otomatis') ||
        type.toLowerCase().contains('auto')) {
      historyIcon = Icons.auto_awesome;
      iconColor = Colors.orange;
    }

    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.withAlpha(150)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: iconColor.withAlpha(80),
              child: Icon(historyIcon, color: iconColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Durasi: $duration menit',
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Dilakukan oleh: $executedBy',
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formattedDate,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
