import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/lottery_result.dart';
import 'loto_table_widget.dart';

class LotteryResultWidget extends StatelessWidget {
  final LotteryResult result;

  const LotteryResultWidget({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _getRegionColor(result.region),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  result.province,
                  style: TextStyle(
                    color: result.region == 'south' ? Colors.black : Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  DateFormat('dd/MM/yyyy').format(result.date),
                  style: TextStyle(
                    color: result.region == 'south' ? Colors.black : Colors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          if (result.isLive)
            Container(
              width: double.infinity,
              color: AppColors.error.withOpacity(0.1),
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: const Text(
                'ĐANG QUAY TRỰC TIẾP',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.error,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),

          // Content
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Table(
              border: TableBorder(
                horizontalInside: BorderSide(color: Colors.grey.shade200),
                verticalInside: BorderSide(color: Colors.grey.shade200),
              ),
              columnWidths: const {
                0: FlexColumnWidth(1.5),
                1: FlexColumnWidth(4),
              },
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: [
                if (result.eighthPrize.isNotEmpty)
                  _buildRow('Giải Tám', result.eighthPrize, isRed: true),
                if (result.seventhPrize.isNotEmpty)
                  _buildRow(
                    'Giải Bảy',
                    result.seventhPrize,
                    isLarge: result.region == 'north',
                    isRed: result.region == 'north',
                  ),
                if (result.featuredPrize('sixth').isNotEmpty)
                  _buildRow('Giải Sáu', result.sixthPrize),
                if (result.featuredPrize('fifth').isNotEmpty)
                  _buildRow('Giải Năm', result.fifthPrize),
                if (result.featuredPrize('fourth').isNotEmpty)
                  _buildRow('Giải Tư', result.fourthPrize),
                if (result.featuredPrize('third').isNotEmpty)
                  _buildRow('Giải Ba', result.thirdPrize),
                if (result.featuredPrize('second').isNotEmpty)
                  _buildRow('Giải Nhì', result.secondPrize),
                if (result.featuredPrize('first').isNotEmpty)
                  _buildRow('Giải Nhất', result.firstPrize),
                _buildRow(
                  'Đặc Biệt',
                  result.specialPrize.isEmpty ? [] : [result.specialPrize],
                  isSpecial: true,
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Loto Table
          Padding(
            padding: const EdgeInsets.all(0.0),
            child: LotoTableWidget(result: result),
          ),
        ],
      ),
    );
  }

  TableRow _buildRow(
    String title,
    List<String> numbers, {
    bool isSpecial = false,
    bool isRed = false,
    bool isLarge = false,
  }) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.center,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: isSpecial
              ? Text(
                  numbers.firstOrNull ?? '...',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: AppColors.error,
                  ),
                  textAlign: TextAlign.center,
                )
              : Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 4,
                  children: numbers
                      .map(
                        (n) => Text(
                          n,
                          style: TextStyle(
                            fontWeight: isLarge ? FontWeight.bold : FontWeight.w500,
                            fontSize: isLarge ? 24 : 16,
                            color: isRed ? AppColors.error : Colors.black,
                          ),
                        ),
                      )
                      .toList(),
                ),
        ),
      ],
    );
  }

  Color _getRegionColor(String region) {
    switch (region) {
      case 'north':
        return AppColors.northColor;
      case 'central':
        return AppColors.centralColor;
      case 'south':
        return AppColors.southColor;
      default:
        return AppColors.primary;
    }
  }
}

extension LotteryResultExtension on LotteryResult {
  // Helper to safely get lists even if they don't exist in some versions
  List<String> featuredPrize(String key) {
    switch (key) {
      case 'first':
        return firstPrize;
      case 'second':
        return secondPrize;
      case 'third':
        return thirdPrize;
      case 'fourth':
        return fourthPrize;
      case 'fifth':
        return fifthPrize;
      case 'sixth':
        return sixthPrize;
      case 'seventh':
        return seventhPrize;
      case 'eighth':
        return eighthPrize;
      default:
        return [];
    }
  }
}
