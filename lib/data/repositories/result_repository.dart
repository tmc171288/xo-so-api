import 'package:get/get.dart';
import '../../core/services/api_service.dart';
import '../models/lottery_result.dart';
import 'scraper_repository.dart';

class ResultRepository {
  final ApiService _apiService = Get.find<ApiService>();
  final ScraperRepository _scraper = ScraperRepository();

  /// Fetch latest result (List because MT/MN has multiple provinces)
  Future<List<LotteryResult>> getLatestResult(String region) async {
    try {
      // Use Scraper
      final results = await _scraper.getLatestResults(region);

      // If scraper returns empty, maybe fallback or just return empty
      // Scraper returns ALL history tables found on the main page.
      // For "Latest", we just want the first day's results.
      // But Scraper logic already groups them by Table/Day?
      // Wait, _scraper.getLatestResults returns FLAT List<LotteryResult>.
      // We should filter for the Latest Date?
      // Or just return all and let controller pick?
      // Home Controller displays "Live Results".
      // If we return 30 items (7 days), Home might show 30 items?
      // We should filter for the most recent date.

      if (results.isNotEmpty) {
        // Find the most recent date
        final latestDate = results.first.date;
        // Filter only results matching this date
        return results.where((r) => isSameDay(r.date, latestDate)).toList();
      }
      return [];
    } catch (e) {
      print('Error getting latest result: $e');
      return [];
    }
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Fetch history for a region
  Future<List<LotteryResult>> getHistory(
    String region, {
    int page = 1,
    int limit = 30,
  }) async {
    try {
      // Scraper fetches the main page which usually contains ~7 days of history.
      // We return all of them. Pagination is not fully supported by this simple scraper layer yet
      // unless we implement crawling 'page 2', 'page 3' URLs.
      // For now, ignore page > 1 or return empty to stop infinite scroll.
      if (page > 1) return [];

      final results = await _scraper.getLatestResults(region);
      return results;
    } catch (e) {
      print('Error getting history: $e');
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
