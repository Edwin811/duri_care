import 'package:duri_care/features/history/history_binding.dart';
import 'package:duri_care/features/history/history_view.dart';
import 'package:get/get.dart';

final historyRoute = [
  GetPage(
    name: HistoryView.route,
    page: () => const HistoryView(),
    binding: HistoryBinding(),
    transition: Transition.rightToLeft,
    transitionDuration: const Duration(milliseconds: 200),
  ),
];
