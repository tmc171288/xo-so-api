import 'package:flutter/material.dart';
import '../../../data/models/lottery_result.dart';

class LotteryTableWidget extends StatelessWidget {
  final DateTime date;
  final List<LotteryResult> results;

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
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 5,
            offset: Offset(0, 2),
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
              color: Color(0xFFFFF9C4), // Light yellow background
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Center(
              child: Text(
                '${_getDayOfWeek(date.weekday)}, ${date.day}/${date.month}/${date.year}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ),
          ),

          // The Table with LayoutBuilder for responsiveness
          LayoutBuilder(
            builder: (context, constraints) {
              const double labelWidth = 45.0;
              const double minProvinceWidth = 110.0;
              // Calculate if we need scrolling
              // Available width for data columns = totalWidth - labelWidth
              // If (minProvinceWidth * provinceCount) > availableWidth -> Scroll

              final double requiredWidth =
                  labelWidth + (results.length * minProvinceWidth);
              final bool needsScroll = requiredWidth > constraints.maxWidth;

              Widget table = Table(
                border: TableBorder(
                  horizontalInside: BorderSide(
                    color: Colors.grey[200]!,
                    width: 1,
                  ),
                  verticalInside: BorderSide(
                    color: Colors.grey[200]!,
                    width: 1,
                  ),
                ),
                columnWidths: _buildColumnWidths(
                  results.length,
                  needsScroll,
                  labelWidth,
                  minProvinceWidth,
                ),
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                children: [
                  // Province Header Row
                  TableRow(
                    decoration: const BoxDecoration(color: Color(0xFFFAFBFB)),
                    children: [
                      // Label Header: "G"
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          'G',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black54,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      ...results.map(
                        (r) => Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12.0,
                            horizontal: 4.0,
                          ),
                          child: Text(
                            r.province,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Only show Grade 8 if NOT North
                  if (results.isNotEmpty && results.first.region != 'north')
                    _buildRow('8', 'eighth', color: Colors.blueAccent),
                  _buildRow('7', 'seventh'),
                  _buildRow('6', 'sixth'),
                  _buildRow('5', 'fifth'),
                  _buildRow('4', 'fourth'),
                  _buildRow('3', 'third'),
                  _buildRow('2', 'second'),
                  _buildRow('1', 'first'),
                  _buildRow(
                    'ĐB',
                    'special',
                    color: Colors.red,
                    isSpecial: true,
                  ),
                ],
              );

              if (needsScroll) {
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: requiredWidth),
                    child: table,
                  ),
                );
              } else {
                return table;
              }
            },
          ),
        ],
      ),
    );
  }

  String _getDayOfWeek(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Thứ Hai';
      case DateTime.tuesday:
        return 'Thứ Ba';
      case DateTime.wednesday:
        return 'Thứ Tư';
      case DateTime.thursday:
        return 'Thứ Năm';
      case DateTime.friday:
        return 'Thứ Sáu';
      case DateTime.saturday:
        return 'Thứ Bảy';
      case DateTime.sunday:
        return 'Chủ Nhật';
      default:
        return '';
    }
  }

  Map<int, TableColumnWidth> _buildColumnWidths(
    int provinceCount,
    bool needsScroll,
    double labelWidth,
    double minProvinceWidth,
  ) {
    final Map<int, TableColumnWidth> widths = {0: FixedColumnWidth(labelWidth)};

    if (needsScroll) {
      // Use Fixed widths for all to force scroll
      for (int i = 1; i <= provinceCount; i++) {
        widths[i] = FixedColumnWidth(minProvinceWidth);
      }
    } else {
      // Use Flex to fill screen
      for (int i = 1; i <= provinceCount; i++) {
        widths[i] = const FlexColumnWidth();
      }
    }
    return widths;
  }

  TableRow _buildRow(
    String label,
    String key, {
    Color? color,
    bool isSpecial = false,
  }) {
    return TableRow(
      children: [
        // Label Cell
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        // Data Cells
        ...results.map((r) {
          dynamic data;
          switch (key) {
            case 'special':
              data = r.specialPrize;
              break;
            case 'first':
              data = r.firstPrize;
              break;
            case 'second':
              data = r.secondPrize;
              break;
            case 'third':
              data = r.thirdPrize;
              break;
            case 'fourth':
              data = r.fourthPrize;
              break;
            case 'fifth':
              data = r.fifthPrize;
              break;
            case 'sixth':
              data = r.sixthPrize;
              break;
            case 'seventh':
              data = r.seventhPrize;
              break;
            case 'eighth':
              data = r.eighthPrize;
              break;
            default:
              data = [];
          }

          if (key == 'special') {
            // Special Prize Logic
            String text = '';
            if (data != null && data.toString().isNotEmpty) {
              text = data.toString();
            }
            return Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            );
          } else {
            // List Prizes (1-8)
            List<String> list = [];
            if (data != null && (data as List).isNotEmpty) {
              list = (data as List).map((e) => e.toString()).toList();
            }

            if (list.isEmpty) return const SizedBox();

            return Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 4,
                children: list
                    .map(
                      (val) => Text(
                        val,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: (key == 'eighth')
                              ? Colors.red
                              : Colors.black87,
                        ),
                      ),
                    )
                    .toList(),
              ),
            );
          }
        }),
      ],
    );
  }
}
