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
}
