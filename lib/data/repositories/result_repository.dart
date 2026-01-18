import 'package:get/get.dart';
import '../../core/services/api_service.dart';
import '../models/lottery_result.dart';

class ResultRepository {
  final ApiService _apiService = Get.find<ApiService>();

  /// Fetch latest result for a region
  Future<LotteryResult?> getLatestResult(String region) async {
    try {
      final response = await _apiService.get('/api/results/$region/latest');
      if (response != null) {
        return LotteryResult.fromJson(response);
      }
      return null;
    } catch (e) {
      print('Error fetching latest result: $e');
      return null;
    }
  }

  /// Fetch history for a region
  Future<List<LotteryResult>> getHistory(String region, {int page = 1, int limit = 30}) async {
    try {
      final response = await _apiService.get('/api/results/$region/history?page=$page&limit=$limit');
      if (response != null && response['data'] != null) {
        return (response['data'] as List)
            .map((e) => LotteryResult.fromJson(e))
            .toList();
      }
      return [];
    } catch (e) {
      print('Error fetching history: $e');
      return [];
    }
  }

  /// Fetch results by date
  Future<List<LotteryResult>> getByDate(String region, String date) async {
    try {
      final response = await _apiService.get('/api/results/$region/$date');
      if (response != null && response is List) {
        return response.map((e) => LotteryResult.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching by date: $e');
      return [];
    }
  }
}
