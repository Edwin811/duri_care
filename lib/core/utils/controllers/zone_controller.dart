import 'dart:async';
import 'package:get/get.dart';

class ZoneController extends GetxController {
  final timer = '00:00:00'.obs;
  final isActive = false.obs;
  Timer? _countdownTimer;

  void powerButton() {
    isActive.value = !isActive.value;
    if (isActive.value) {
      startTimer();
    } else {
      stopTimer();
    }
  }

  void startTimer() {
    const oneSecond = Duration(seconds: 1);
    int totalSeconds = 30;

    _countdownTimer = Timer.periodic(oneSecond, (timer) {
      if (totalSeconds > 0) {
        totalSeconds--;
        final hours = (totalSeconds ~/ 3600).toString().padLeft(2, '0');
        final minutes = ((totalSeconds % 3600) ~/ 60).toString().padLeft(
          2,
          '0',
        );
        final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
        this.timer.value = '$hours:$minutes:$seconds';
      } else {
        stopTimer();
        isActive.value = false;
      }
    });
  }

  void stopTimer() {
    _countdownTimer?.cancel();
    timer.value = '00:00:00';
  }

  @override
  void onClose() {
    _countdownTimer?.cancel();
    super.onClose();
  }
}
