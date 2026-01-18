import 'package:get/get.dart';
import '../../core/services/socket_service.dart';
import '../../data/models/lottery_result.dart';

/// Controller for Home Screen
class HomeController extends GetxController {
  final SocketService _socketService = Get.find<SocketService>();
  
  // Observable variables
  final RxString selectedRegion = 'north'.obs;
  final RxList<LotteryResult> liveResults = <LotteryResult>[].obs;
  final RxBool isLoading = false.obs;
  
  @override
  void onInit() {
    super.onInit();
    _setupSocketListeners();
    _loadLiveResults();
  }
  
  /// Setup socket listeners for real-time updates
  void _setupSocketListeners() {
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
    
    try {
      // Request live results from server
      _socketService.emit('get_live_results', {
        'region': selectedRegion.value,
      });
      
      // TODO: Load from API or local cache
      await Future.delayed(const Duration(seconds: 1));
      
    } catch (e) {
      print('Error loading live results: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  /// Update result in the list
  void _updateResult(LotteryResult result) {
    final index = liveResults.indexWhere((r) => r.id == result.id);
    if (index >= 0) {
      liveResults[index] = result;
    } else {
      liveResults.add(result);
    }
  }
  
  /// Change selected region
  void changeRegion(String region) {
    selectedRegion.value = region;
    _loadLiveResults();
  }
  
  /// Refresh results
  Future<void> refresh() async {
    await _loadLiveResults();
  }
  
  @override
  void onClose() {
    _socketService.off('lottery_update');
    _socketService.off('lottery_complete');
    super.onClose();
  }
}
