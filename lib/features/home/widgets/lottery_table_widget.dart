import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/lottery_result.dart';

class LotteryTableWidget extends StatelessWidget {
  final DateTime date;
  final List<LotteryResult> results; // Results for the same day (multiple provinces)

  const LotteryTableWidget({
    super.key,
    required this.date,
    required this.results,
  });

  @override
  Widget build(BuildContext context) {
    if (results.isEmpty) return const SizedBox();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Date Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFFFFF9C4), // Light yellow background like reference
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Center(
              child: Text(
                'Chủ Nhật, ${date.day}/${date.month}/${date.year}', // Todo: Proper formatting
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
          
          // The Table
          Table(
            border: TableBorder(
              horizontalInside: BorderSide(color: Colors.grey[200]!, width: 1),
              verticalInside: BorderSide(color: Colors.grey[200]!, width: 1),
            ),
            columnWidths: _buildColumnWidths(results.length),
            children: [
              // Province Header Row
              TableRow(
                decoration: const BoxDecoration(color: Color(0xFFFAFBFB)), // Light grey
                children: [
                  const SizedBox(), // Prize Name column
                  ...results.map((r) => Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      r.province,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  )),
                ],
              ),
              
              // Prize Rows
              _buildRow('Giải Tám', 'eighth', Colors.red),
              _buildRow('Giải Bảy', 'seventh'),
              _buildRow('Giải Sáu', 'sixth'),
              _buildRow('Giải Năm', 'fifth'),
              _buildRow('Giải Tư', 'fourth'),
              _buildRow('Giải Ba', 'third'),
              _buildRow('Giải Nhì', 'second'),
              _buildRow('Giải Nhất', 'first'),
              _buildRow('Đặc Biệt', 'special', Colors.red, isSpecial: true),
            ],
          ),
        ],
      ),
    );
  }

  Map<int, TableColumnWidth> _buildColumnWidths(int provinceCount) {
    // Column 0 is Prize Name (Fixed width), others Flex
    final Map<int, TableColumnWidth> widths = {
      0: const FixedColumnWidth(80),
    };
    for (int i = 1; i <= provinceCount; i++) {
      widths[i] = const FlexColumnWidth();
    }
    return widths;
  }

  TableRow _buildRow(String label, String key, [Color? color, bool isSpecial = false]) {
    // Check if this prize exists in any result (optimization: skip if empty?)
    // But for table alignment we usually keep all rows.

    return TableRow(
      children: [
        // Label Cell
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13, 
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        
        // Data Cells
        ...results.map((r) {
          final data = r.prizes[key];
          // Determine content
          String text = '...';
          bool isDataEmpty = true;
          
          if (key == 'special') {
             // Special is String in my parsing logic but model might use List? 
             // Checking model: Map<String, dynamic> prizes.
             // Usually specialized parsers set it as string, standard schema might vary.
             // My recent crawler sets it as String in 'special' prop.
             // But my Flutter model expects List<String>? 
             // Let's check model. Model: Map<String, List<String>> prizes.
             // Crawler: results[provIndex].prizes.special = text (String).
             // API Service probably converts or Mongoose model handles it.
             // Backend Model: special: String.
             // Flutter Model: fromJson: prizes['special'] -> if String wrap in List.
             
             if (data != null && data.isNotEmpty) {
               text = data is List ? data.join('\n') : data.toString();
               isDataEmpty = false;
             }
          } else {
             if (data != null && (data as List).isNotEmpty) {
               text = (data as List).join('\n'); // Stack numbers vertically like reference
               // For G4, G6 there are multiple numbers.
               // Reference image uses spacing.
               text = (data as List).join('   '); 
               // Wait, reference (Image 4) shows G8 1 num, G7 1 num.
               // Standard: G6 has 3 nums.
               // Let's formatting:
               // Join with spacing if short, newlines if many?
               // Let's try newline for cleaner look if count > 2?
               // Reference Image 4: G8 one row. DB one row.
               // Image 4 is confusing, it shows G8-G7-??-DB.
               
               if ((data as List).length > 2) {
                 // Format: 2 per line?
                 // Simple join for now using newlines looks standard for printed tickets.
                 // Reference app seems to use Grid or Wrap?
                 // Let's use spaces.
                 text = (data as List).join('\n');
               } else {
                 text = (data as List).join(' - ');
               }
               isDataEmpty = false;
             }
          }

          return Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(8),
            child: Text(
              isDataEmpty ? '...' : text,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isSpecial ? Colors.red : (color ?? Colors.black87),
                fontWeight: isSpecial || color != null ? FontWeight.bold : FontWeight.normal,
                fontSize: isSpecial ? 16 : 14,
              ),
            ),
          );
        }),
      ],
    );
  }
}
