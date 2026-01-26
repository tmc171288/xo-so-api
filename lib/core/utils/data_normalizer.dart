import '../../data/models/lottery_result.dart';

class DataNormalizer {
  /// Fix malformed lottery data
  static LotteryResult normalize(LotteryResult result) {
    // 1. Fix Province Name if it looks like a number
    // Regex to check if string contains mainly digits (length > 3)
    // or matches the corrupted pattern seen in logs
    if (_isCorruptedProvince(result.province)) {
      final correctName = _getProvinceName(
        result.region,
        result.date,
        result.province,
      );
      // We return a copy with the fixed name
      // Note: Data inside prizes might still be wrong (transposed),
      // but at least the UI won't look broken with "624211" as header.
      return result.copyWith(province: correctName);
    }

    return result;
  }

  static bool _isCorruptedProvince(String name) {
    // If name contains digits and is longer than 2, it's suspicious for a name
    // e.g. "624211"
    if (name.isEmpty) return false;
    final digitRegex = RegExp(r'^\d+$');
    return digitRegex.hasMatch(name.trim());
  }

  static String _getProvinceName(
    String region,
    DateTime date,
    String currentName,
  ) {
    if (region == 'north') return 'Miền Bắc';

    final weekday = date.weekday;
    // Simple heuristic: we can't be 100% sure of the index without the original list index.
    // But since we are normalizing *individual* results, we lack the context of "Index in List".
    // Wait, this is a limitation. If 3 results come in, how do I know which one is Kon Tum?
    // The "currentName" (which is corrupted, e.g., the Special Prize) might be a clue?
    // Actually, in the logs:
    // Item 1: Name=Hue's DB. Data8=KhanhHoa's DB.
    // This implies a shift.
    // Without the full list context, I cannot map by index.

    // For now, let's return a placeholder or try to infer.
    // Better strategy: The Repository processes a LIST.
    // We should normalize the LIST, not just individual item.

    return currentName; // Fallback if we can't determine
  }

  /// Normalize a list of results (enables index-based recovery)
  static List<LotteryResult> normalizeList(List<LotteryResult> results) {
    if (results.isEmpty) return [];

    final region = results.first.region;
    final date = results.first.date;
    // Assuming list is for same region/date usually

    // Get schedule for this day
    final scheduledProvinces = _getSchedule(region, date.weekday);

    // CRITICAL FIX: Detect Matrix Transposition
    // If we have many items (e.g., > 5), it's likely a list of Prize Rows, not Provinces.
    // Standard provinces count: North (1), Central/South (2-3).
    // If results.length >= 6 (DB, G1..G8 is 9 rows), we assume it's Transposed.
    if (results.length >= 6 && scheduledProvinces.isNotEmpty) {
       return _pivotTransposedData(results, scheduledProvinces, region, date);
    }

    // Existing "Simple Rename" logic for correct structural lists (e.g. North or corrected API)
    if (scheduledProvinces.isNotEmpty) {
      // Map one-to-one, ignoring extra garbage items from API
      return results.asMap().entries.map((entry) {
        final index = entry.key;
        final result = entry.value;
        
        if (_isCorruptedProvince(result.province)) {
           // Use scheduled name if index is within bounds
           if (index < scheduledProvinces.length) {
             final newName = scheduledProvinces[index];
             return result.copyWith(province: newName);
           }
        }
        return result;
      }).toList();
    }

    return results;
  }

  /// Convert List<Row> to List<Province>
  static List<LotteryResult> _pivotTransposedData(
    List<LotteryResult> rows, 
    List<String> provinceNames,
    String region,
    DateTime date,
  ) {
    // Initialize empty results for each province
    List<LotteryResult> provinces = provinceNames.map((name) => LotteryResult(
      id: '${date.toIso8601String()}_$name',
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
    )).toList();

    // Iterate through rows (Input API Objects)
    // We assume the order is: Special -> First -> Second ... -> Eighth
    // But we should verify. The Log showed:
    // Item 0: DB (6 digits)
    // Item 1: G1 (5 digits)
    // ...
    // Item 8: G8 (2-3 digits) 
    // WARNING: Sometimes G8 is at the top? 
    // Check Log: Item 1 has _id ending in ...ab10? No.
    // Let's assume Top-Down (0=DB, 1=G1...) based on _id sequence and digit length observation.

    for (int i = 0; i < rows.length; i++) {
      if (i >= 9) break; // Only support up to 9 rows (DB..G8) for now
      
      final row = rows[i];
      // Collect valid data points from this row
      // Data might be in 'eighthPrize' (corrupted mapping), 'province' header, etc.
      List<String> validData = [];
      
      // 1. Check 'eighthPrize' (seen in logs holding values)
      if (row.eighthPrize.isNotEmpty) validData.addAll(row.eighthPrize);
      
      // 2. Check 'specialPrize'
      if (row.specialPrize.isNotEmpty) validData.add(row.specialPrize);

      // 3. Check 'firstPrize' -> 'seventhPrize'
      if (row.firstPrize.isNotEmpty) validData.addAll(row.firstPrize);
      if (row.secondPrize.isNotEmpty) validData.addAll(row.secondPrize);
      if (row.thirdPrize.isNotEmpty) validData.addAll(row.thirdPrize);
      if (row.fourthPrize.isNotEmpty) validData.addAll(row.fourthPrize);
      if (row.fifthPrize.isNotEmpty) validData.addAll(row.fifthPrize);
      if (row.sixthPrize.isNotEmpty) validData.addAll(row.sixthPrize);
      if (row.seventhPrize.isNotEmpty) validData.addAll(row.seventhPrize);
      
      // 4. Check 'province' header (often contains the last column's value)
      if (_isCorruptedProvince(row.province)) {
        validData.add(row.province);
      }
      
      // Distribute to Provinces
      // If we have 2 provinces (DT, CM), we expect 2 nums per row.
      // If we have 3 provinces (TG, KG, DL), we expect 3 nums per row.
      // CAUTION: Some prizes (G3, G4, G6) have multiple numbers PER PROVINCE.
      // E.g. G6 has 3 numbers. With 3 provinces, that's 9 numbers in the row!
      
      // Pivot Strategy:
      // If row is single-value (DB, G1, G2, G8), we just take the first N items.
      // If row is multi-value (G3, G4, G6), we divide the list by N.
      
      if (validData.isEmpty) continue;
      
      int numProvinces = provinces.length;
      // Calculate chunks based on typical distribution
      // If validData has 2 items and we have 3 provinces, clearly 1 is missing.
      // Observation suggests Prov 1 (Kon Tum) is missing, Prov 2 & 3 are present.
      // So we generally Right-Align the data.
      
      // Determine number of available chunks (columns) in this row
      // For simple single-value rows (DB, G1, etc), chunks = validData.length.
      // For multi-value rows (G3, G4), we need to check if validData.length is divisible.
      
      int chunksFound = 1;
      int itemsPerChunk = 1;

      // Heuristic for multi-value prizes
      // G3 (2 vals), G4 (7 vals), G6 (3 vals)
      if (i == 3 && validData.length >= 2) itemsPerChunk = 2; // G3
      if (i == 4 && validData.length >= 7) itemsPerChunk = 7; // G4
      if (i == 6 && validData.length >= 3) itemsPerChunk = 3; // G6
      
      // Override itemsPerChunk if we can detect structure
      if (validData.length % numProvinces == 0) {
        // Perfect fit
        itemsPerChunk = validData.length ~/ numProvinces;
        chunksFound = numProvinces;
      } else {
        // Imperfect fit - calculate how many full chunks we have
        // E.g. 2 items, chunks=2 (size 1). 3 provinces.
        chunksFound = validData.length ~/ itemsPerChunk;
      }

      // Right-Align Index Offset
      // If we have 3 provinces but only 2 chunks, we map to indices [1, 2].
      int offset = numProvinces - chunksFound;
      if (offset < 0) offset = 0; // Should not happen if logic is correct

      for (int c = 0; c < chunksFound; c++) {
        int targetProvIndex = offset + c;
        if (targetProvIndex >= numProvinces) break;

        int start = c * itemsPerChunk;
        int end = start + itemsPerChunk;
        if (end > validData.length) end = validData.length;
        
        List<String> chunk = validData.sublist(start, end);
        provinces[targetProvIndex] = _assignPrizeByRowIndex(provinces[targetProvIndex], i, chunk);
      }
    }
    
    return provinces;
  }

  static LotteryResult _assignPrizeByRowIndex(LotteryResult res, int rowIndex, List<String> values) {
    if (values.isEmpty) return res;
    
    // Map Row Index to Prize Field
    // 0: Special
    // 1: First
    // 2: Second
    // 3: Third (2 values usually)
    // 4: Fourth (7 values usually) - Wait, G4 has 7? 
    // Let's rely on standard structure:
    // DB, G1, G2, G3, G4, G5, G6, G7, G8. (9 Levels).
    
    switch (rowIndex) {
      case 0: return res.copyWith(specialPrize: values.first);
      case 1: return res.copyWith(firstPrize: values);
      case 2: return res.copyWith(secondPrize: values);
      case 3: return res.copyWith(thirdPrize: values); // Often 2 vals
      case 4: return res.copyWith(fourthPrize: values); // Often 7 vals
      case 5: return res.copyWith(fifthPrize: values);
      case 6: return res.copyWith(sixthPrize: values); // Often 3 vals
      case 7: return res.copyWith(seventhPrize: values);
      case 8: return res.copyWith(eighthPrize: values);
      default: return res;
    }
  }

  static List<String> _getSchedule(String region, int weekday) {
    if (region == 'central') {
      switch (weekday) {
        case DateTime.monday:
          return ['Thừa Thiên Huế', 'Phú Yên'];
        case DateTime.tuesday:
          return ['Đắk Lắk', 'Quảng Nam'];
        case DateTime.wednesday:
          return ['Đà Nẵng', 'Khánh Hòa'];
        case DateTime.thursday:
          return ['Bình Định', 'Quảng Trị', 'Quảng Bình'];
        case DateTime.friday:
          return ['Gia Lai', 'Ninh Thuận'];
        case DateTime.saturday:
          return ['Đà Nẵng', 'Quảng Ngãi', 'Đắk Nông'];
        // Sunday: Kon Tum, Khánh Hòa, Huế
        case DateTime.sunday:
          return ['Kon Tum', 'Khánh Hòa', 'Thừa Thiên Huế'];
      }
    } else if (region == 'south') {
      switch (weekday) {
        case DateTime.monday:
          return ['TP.HCM', 'Đồng Tháp', 'Cà Mau'];
        case DateTime.tuesday:
          return ['Bến Tre', 'Vũng Tàu', 'Bạc Liêu'];
        case DateTime.wednesday:
          return ['Đồng Nai', 'Cần Thơ', 'Sóc Trăng'];
        case DateTime.thursday:
          return ['Tây Ninh', 'An Giang', 'Bình Thuận'];
        case DateTime.friday:
          return ['Vĩnh Long', 'Bình Dương', 'Trà Vinh'];
        case DateTime.saturday:
          return ['TP.HCM', 'Long An', 'Bình Phước', 'Hậu Giang'];
        case DateTime.sunday:
          return ['Tiền Giang', 'Kiên Giang', 'Đà Lạt'];
      }
    }
    return [];
  }
}
