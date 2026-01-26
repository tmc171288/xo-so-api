import 'package:get/get.dart';
import '../../core/services/socket_service.dart';
import '../../data/models/lottery_result.dart';
import '../../data/repositories/result_repository.dart';

/// Controller for Home Screen
class HomeController extends GetxController {
  final SocketService _socketService = Get.find<SocketService>();
  final ResultRepository _resultRepository = Get.put(ResultRepository());

  // Observable variables
  final RxString selectedRegion = 'north'.obs;
  final RxList<LotteryResult> liveResults = <LotteryResult>[].obs;
  final RxBool isLoading = false.obs;
  final RxInt selectedIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _setupSocketListeners();
    _loadLiveResults();
  }

  /// Setup socket listeners for real-time updates
  void _setupSocketListeners() {
    // Join channel for current region
    _socketService.emit('subscribe', selectedRegion.value);

    _socketService.on('lottery_update', (data) {
      print('Received lottery update: $data');
      // Parse and update results
      if (data != null) {
        final result = LotteryResult.fromJson(data);
        _updateResult(result);
      }
    });

    _socketService.on('lottery_complete', (data) {
      print('Lottery draw completed: $data');
      if (data != null) {
        final result = LotteryResult.fromJson(data);
        _updateResult(result);
      }
    });
  }

  /// Load live results
  Future<void> _loadLiveResults() async {
    isLoading.value = true;
    liveResults.clear();

    try {
      // 1. Fetch latest data from Scraper (returns List)
      final results = await _resultRepository.getLatestResult(
        selectedRegion.value,
      );
      if (results.isNotEmpty) {
        liveResults.assignAll(results);
      } else {
        liveResults.clear();
      }

      // 2. Socket logic (likely disabled or redundant if we use scraper)
      // Keep it but maybe it won't work nicely with scraper data structure.
      // If socket sends single update, we need to merge it.

      // _socketService.emit('get_live_results', {
      //   'region': selectedRegion.value,
      // });
    } catch (e) {
      print('Error loading live results: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Update result in the list
  void _updateResult(LotteryResult result) {
    // For single view (latest), we might just want to replace or update
    // If list is empty, add it
    if (liveResults.isEmpty) {
      liveResults.add(result);
      return;
    }

    // Check if same date/id to update
    final index = liveResults.indexWhere(
      (r) => r.region == result.region && r.date.day == result.date.day,
    );
    if (index >= 0) {
      liveResults[index] = result;
    } else {
      // If newer date, add to top? Or replace if we only show latest?
      // For now, let's keep only 1 latest item for Home
      liveResults[0] = result;
    }
  }

  /// Change selected region
  void changeRegion(String region) {
    if (selectedRegion.value == region) return;

    // Unsubscribe old
    // _socketService.emit('unsubscribe', selectedRegion.value); // If supported

    selectedRegion.value = region;

    // Subscribe new
    _socketService.emit('subscribe', region);

    _loadLiveResults();
  }

  /// Refresh results
  Future<void> refresh() async {
    await _loadLiveResults();
  }

  /// Change bottom nav index
  void changeIndex(int index) {
    selectedIndex.value = index;
  }

  @override
  void onClose() {
    _socketService.off('lottery_update');
    _socketService.off('lottery_complete');
    super.onClose();
  }
}
