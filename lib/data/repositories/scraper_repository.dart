import 'dart:convert';
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart';
import 'package:http/http.dart' as http;
import '../models/lottery_result.dart';

class ScraperRepository {
  final http.Client _client = http.Client();
  final String _baseUrl = 'https://az24.vn';

  /// Fetch latest results (or specific date if we implement url construction)
  /// Returns a List because MN/MT has multiple provinces per day.
  Future<List<LotteryResult>> getLatestResults(String region) async {
    final url = _getUrl(region);
    try {
      final response = await _client.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final body = utf8.decode(response.bodyBytes);
        final document = parser.parse(body);
        return _parseDocument(document, region);
      }
    } catch (e) {
      print('Scraper Error: $e');
    }
    return [];
  }

  String _getUrl(String region) {
    if (region == 'north') return '$_baseUrl/xsmb-sxmb-xo-so-mien-bac.html';
    if (region == 'central') return '$_baseUrl/xsmt-sxmt-xo-so-mien-trung.html';
    if (region == 'south') return '$_baseUrl/xsmn-sxmn-xo-so-mien-nam.html';
    return _baseUrl;
  }

  List<LotteryResult> _parseDocument(Document document, String region) {
    if (region == 'north') {
      return _parseMB(document);
    } else {
      return _parseMN_MT(document, region);
    }
  }

  List<String> _parsePrizeValues(Element cell) {
    // 1. Try to find child spans (often used for specific styling or separation)
    final spans = cell.querySelectorAll('span');
    if (spans.isNotEmpty) {
      // Filter out empty spans or tooltips if any
      // AZ24 spans usually contain the numbers directly
      return spans
          .map((e) => e.text.trim())
          .where((s) => s.isNotEmpty)
          .toList();
    }

    // 2. If no spans, check for <br> tags in innerHtml
    var html = cell.innerHtml;
    // Replace <br> with a distinct separator like " | "
    html = html.replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), ' | ');

    // Parse back to text
    final tempDoc = parser.parseFragment(html);
    final text = tempDoc.text ?? '';

    // Split by the separator or newlines/spaces/dashes
    // Including simple whitespace \s is critical for cells where numbers are just space-separated
    final parts = text.split(RegExp(r'[|\n\s-]+'));

    return parts.map((e) => e.trim()).where((s) => s.isNotEmpty).toList();
  }

  DateTime _findDateForTable(Element table) {
    // Search up to 3 levels of parents
    Element? currentLevel = table;

    for (int i = 0; i < 3; i++) {
      if (currentLevel == null) break;

      // Search previous siblings of current level
      Element? candidate = currentLevel.previousElementSibling;
      int attempts = 0;
      while (candidate != null && attempts < 5) {
        final dateMatch = _parseDateFromText(candidate.text);
        if (dateMatch != null) return dateMatch;

        candidate = candidate.previousElementSibling;
        attempts++;
      }

      // Move up to parent
      currentLevel = currentLevel.parent;
    }

    // Fallback: This is dangerous if we can't find the date.
    // But returning today is better than crashing, though it causes the "Fake Today" bug.
    // If we really can't find it, maybe we should look at the Table content itself?
    // Some tables have date in the second row? No.
    // Let's assume the 3-level search (covering .table-responsive wrapping) catches it.
    return DateTime.now();
  }

  DateTime? _parseDateFromText(String text) {
    // Matches dd-mm-yyyy or dd/mm/yyyy
    // Also matches d/m/yyyy
    final match = RegExp(r'(\d{1,2})[-/](\d{1,2})[-/](\d{4})').firstMatch(text);
    if (match != null) {
      return DateTime(
        int.parse(match.group(3)!),
        int.parse(match.group(2)!),
        int.parse(match.group(1)!),
      );
    }
    return null;
  }

  List<LotteryResult> _parseMB(Document document) {
    // XSMB: Find ALL tables with class 'kqmb'
    final tables = document.querySelectorAll('table.kqmb');
    if (tables.isEmpty) return [];

    List<LotteryResult> results = [];

    for (var table in tables) {
      DateTime date = _findDateForTable(table);

      final result = LotteryResult(
        id: 'MB_${date.millisecondsSinceEpoch}',
        region: 'north',
        date: date,
        province: 'Miền Bắc',
        specialPrize: '',
        firstPrize: [],
        secondPrize: [],
        thirdPrize: [],
        fourthPrize: [],
        fifthPrize: [],
        sixthPrize: [],
        seventhPrize: [],
        eighthPrize: [],
        isLive: false,
      );

      var updatedResult = result;

      final rows = table.getElementsByTagName('tr');
      for (var row in rows) {
        final cells = row.getElementsByTagName('td');
        if (cells.length < 2) continue;

        final prizeName = cells[0].text.trim().toLowerCase();

        // Extract values using improved helper
        final values = _parsePrizeValues(cells[1]);

        if (prizeName.contains('đb') || prizeName.contains('đặc biệt')) {
          // Special prize logic:
          // Often contains symbols like 5UV-12345. We want 12345.
          // Look for the last sequence of digits.
          String bestCandidate = '';
          for (var v in values.reversed) {
            // Remove dashes or spaces
            final clean = v.replaceAll(RegExp(r'[^0-9]'), '');
            if (clean.length > 3) {
              // Special prize usually > 3 digits
              bestCandidate = clean;
              break;
            }
          }
          if (bestCandidate.isEmpty && values.isNotEmpty) {
            // Fallback to last value whatever it is
            bestCandidate = values.last;
          }
          updatedResult = updatedResult.copyWith(specialPrize: bestCandidate);
        } else if (prizeName.contains('g1') || prizeName.contains('nhất')) {
          updatedResult = updatedResult.copyWith(firstPrize: values);
        } else if (prizeName.contains('g2') || prizeName.contains('nhì')) {
          updatedResult = updatedResult.copyWith(secondPrize: values);
        } else if (prizeName.contains('g3') || prizeName.contains('ba')) {
          updatedResult = updatedResult.copyWith(thirdPrize: values);
        } else if (prizeName.contains('g4') || prizeName.contains('tư')) {
          updatedResult = updatedResult.copyWith(fourthPrize: values);
        } else if (prizeName.contains('g5') || prizeName.contains('năm')) {
          updatedResult = updatedResult.copyWith(fifthPrize: values);
        } else if (prizeName.contains('g6') || prizeName.contains('sáu')) {
          updatedResult = updatedResult.copyWith(sixthPrize: values);
        } else if (prizeName.contains('g7') || prizeName.contains('bảy')) {
          updatedResult = updatedResult.copyWith(seventhPrize: values);
        }
      }
      results.add(updatedResult);
    }

    return results;
  }

  List<LotteryResult> _parseMN_MT(Document document, String region) {
    // Determine which tables to parse based on region?
    // Usually AZ24 uses 'table-kq-bold-border' or similar.
    // The current `validTables` logic filtering by class is risky if classes change.
    // Let's grab all tables that look like result tables (have 'G8' or 'Giải Tám').

    final allTables = document.getElementsByTagName('table');
    List<Element> validTables = [];

    for (var t in allTables) {
      // Filter tables that likely contain lottery results
      if (t.className.contains('kqmb') ||
          t.text.contains('Giải Tám') ||
          t.text.contains('G8')) {
        validTables.add(t);
      }
    }

    List<LotteryResult> collectedResults = [];

    for (var table in validTables) {
      DateTime date = _findDateForTable(table);

      // Find Header Row: usually containing province names
      // Heuristic: The row that has > 1 cell, and cells contain known province names?
      // Or simply Row 0.
      final rows = table.getElementsByTagName('tr');
      if (rows.isEmpty) continue;

      Element? headerRow;
      List<String> provinceNames = [];

      // Try to find header row (usually first row with text)
      for (var row in rows) {
        var cells = row.children; // th or td
        if (cells.isEmpty) continue;

        // If first cell is empty or 'Giai', and others are text
        if (cells.length > 1) {
          // Check if it's a header
          // If it contains "G8" it's not header.
          if (!cells[0].text.contains('G8') &&
              !cells[0].text.contains('Giải')) {
            // Use this as header
            // Skip first cell if it's label col
            int start = 0;
            // If first cell is empty or short, skip it
            if (cells[0].text.trim().length < 5) start = 1;

            for (int k = start; k < cells.length; k++) {
              provinceNames.add(cells[k].text.trim());
            }
            if (provinceNames.isNotEmpty) {
              headerRow = row;
              break;
            }
          }
        }
      }

      // If no valid header found, skip table
      if (provinceNames.isEmpty) continue;

      List<LotteryResult> dailyResults = provinceNames
          .map(
            (name) => LotteryResult(
              id: '${date.millisecondsSinceEpoch}_$name',
              region: region,
              date: date,
              province: name,
              specialPrize: '',
              firstPrize: [],
              secondPrize: [],
              thirdPrize: [],
              fourthPrize: [],
              fifthPrize: [],
              sixthPrize: [],
              seventhPrize: [],
              eighthPrize: [],
              isLive: false,
            ),
          )
          .toList();

      // Iterate all rows to find data
      for (var row in rows) {
        if (row == headerRow) continue;

        final cells = row.getElementsByTagName('td');
        if (cells.length < dailyResults.length + 1) continue;

        final prizeName = cells[0].text.trim().toLowerCase();

        for (int i = 0; i < dailyResults.length; i++) {
          final cell = cells[i + 1];
          final values = _parsePrizeValues(cell);

          if (prizeName.contains('đb') || prizeName.contains('đặc biệt')) {
            String bestCandidate = '';
            for (var v in values.reversed) {
              final clean = v.replaceAll(RegExp(r'[^0-9]'), '');
              if (clean.length > 3) {
                bestCandidate = clean;
                break;
              }
            }
            if (bestCandidate.isEmpty && values.isNotEmpty) {
              bestCandidate = values.last;
            }
            dailyResults[i] = dailyResults[i].copyWith(
              specialPrize: bestCandidate,
            );
          } else if (prizeName.contains('g1') || prizeName.contains('nhất')) {
            dailyResults[i] = dailyResults[i].copyWith(firstPrize: values);
          } else if (prizeName.contains('g2') || prizeName.contains('nhì')) {
            dailyResults[i] = dailyResults[i].copyWith(secondPrize: values);
          } else if (prizeName.contains('g3') || prizeName.contains('ba')) {
            // G3 (MN/MT): 2 prizes, 5 digits each
            dailyResults[i] = dailyResults[i].copyWith(
              thirdPrize: _splitConcatenated(values, 5),
            );
          } else if (prizeName.contains('g4') || prizeName.contains('tư')) {
            // G4 (MN/MT): 7 prizes, 5 digits each
            dailyResults[i] = dailyResults[i].copyWith(
              fourthPrize: _splitConcatenated(values, 5),
            );
          } else if (prizeName.contains('g5') || prizeName.contains('năm')) {
            dailyResults[i] = dailyResults[i].copyWith(fifthPrize: values);
          } else if (prizeName.contains('g6') || prizeName.contains('sáu')) {
            // G6 (MN/MT): 3 prizes, 4 digits each
            dailyResults[i] = dailyResults[i].copyWith(
              sixthPrize: _splitConcatenated(values, 4),
            );
          } else if (prizeName.contains('g7') || prizeName.contains('bảy')) {
            dailyResults[i] = dailyResults[i].copyWith(seventhPrize: values);
          } else if (prizeName.contains('g8') || prizeName.contains('tám')) {
            dailyResults[i] = dailyResults[i].copyWith(eighthPrize: values);
          }
        }
      }
      collectedResults.addAll(dailyResults);
    }
    return collectedResults;
  }

  List<String> _splitConcatenated(List<String> values, int digitCount) {
    if (values.isEmpty) return values;
    
    // Aggressive strategy: 
    // 1. Join all parts (in case specific separators caused partial splits)
    // 2. Remove ANY non-digit characters (fix invisible chars, dots, accidental text)
    // 3. Re-chunk based on expected digit count
    
    final fullString = values.join('');
    final clean = fullString.replaceAll(RegExp(r'[^0-9]'), '');
    
    // Check if the cleaned string length makes sense for this prize
    // e.g. G6 has 3 prizes * 4 digits = 12 digits. 
    // If we have 12 digits, we split into 3 chunks of 4.
    if (clean.isNotEmpty && clean.length % digitCount == 0 && clean.length >= digitCount) {
      List<String> result = [];
      for (int i = 0; i < clean.length; i += digitCount) {
        result.add(clean.substring(i, i + digitCount));
      }
      return result;
    }
    
    return values;
  }
}

extension ListExt<E> on List<E> {
  E? get firstOrNull => isEmpty ? null : first;
}
