import 'package:get/get.dart';
import '../../data/models/lottery_result.dart';
import '../../data/repositories/result_repository.dart';

/// Controller for History Screen
class HistoryController extends GetxController {
  final ResultRepository _resultRepository = Get.find<ResultRepository>();

  // Observable variables
  final RxString selectedRegion = 'north'.obs;
  final RxList<LotteryResult> historyResults = <LotteryResult>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool hasMore = true.obs;

  int _currentPage = 1;
  static const int _limit = 20;

  @override
  void onInit() {
    super.onInit();
    loadHistory();
  }

  /// Load initial history
  Future<void> loadHistory({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      hasMore.value = true;
      historyResults.clear();
    }

    if (!hasMore.value && !refresh) return;

    isLoading.value = true;

    try {
      final results = await _resultRepository.getHistory(
        selectedRegion.value,
        page: _currentPage,
        limit: _limit,
      );

      if (results.length < _limit) {
        hasMore.value = false;
      }

      historyResults.addAll(results);
      _currentPage++;
    } catch (e) {
      print('Error loading history: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Change region for history
  void changeRegion(String region) {
    if (selectedRegion.value == region) return;
    selectedRegion.value = region;
    loadHistory(refresh: true);
  }

  /// Group results by date for Table View
  Map<DateTime, List<LotteryResult>> get groupedResults {
    final Map<DateTime, List<LotteryResult>> groups = {};

    // Deduplication map to handle potential dirty DB data
    // Key: "Date_Province" -> Result
    final Map<String, LotteryResult> uniqueMap = {};

    for (var result in historyResults) {
      // Normalize date (ignore time)
      final dateOnly = DateTime(
        result.date.year,
        result.date.month,
        result.date.day,
      );
      final key = "${dateOnly.toIso8601String()}_${result.province}";

      // Keep only the latest/first unique entry per province per day
      if (!uniqueMap.containsKey(key)) {
        uniqueMap[key] = result;
      }
    }

    // Build the groups from unique results
    for (var result in uniqueMap.values) {
      final dateKey = DateTime(
        result.date.year,
        result.date.month,
        result.date.day,
      );
      if (!groups.containsKey(dateKey)) {
        groups[dateKey] = [];
      }
      groups[dateKey]!.add(result);
    }

    // Sort groups by date descending (optional, ListView index usually handles this via historyResults order but map is unordered)
    // Actually map insertion order is preserved in Dart, but let's be safe if needed.
    // Since historyResults is already sorted by backend, uniqueMap iteration should mostly preserve it.

    return groups;
  }
}
