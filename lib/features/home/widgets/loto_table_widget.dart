import 'package:flutter/material.dart';
import '../../../data/models/lottery_result.dart';

class LotoTableWidget extends StatelessWidget {
  final LotteryResult result;

  const LotoTableWidget({super.key, required this.result});

  Map<int, List<int>> _calculateLoto() {
    final Map<int, List<int>> loto = {
      0: [],
      1: [],
      2: [],
      3: [],
      4: [],
      5: [],
      6: [],
      7: [],
      8: [],
      9: [],
    };

    void processNumber(String number) {
      if (number.length < 2) return;
      // Remove any non-digit chars just in case
      final clean = number.replaceAll(RegExp(r'[^0-9]'), '');
      if (clean.length < 2) return;

      final lastTwo = clean.substring(clean.length - 2);
      final head = int.tryParse(lastTwo[0]);
      final tail = int.tryParse(lastTwo[1]);

      if (head != null && tail != null) {
        loto[head]?.add(tail);
      }
    }

    // Process all prizes
    processNumber(result.specialPrize);
    for (var n in result.firstPrize) processNumber(n);
    for (var n in result.secondPrize) processNumber(n);
    for (var n in result.thirdPrize) processNumber(n);
    for (var n in result.fourthPrize) processNumber(n);
    for (var n in result.fifthPrize) processNumber(n);
    for (var n in result.sixthPrize) processNumber(n);
    for (var n in result.seventhPrize) processNumber(n);
    for (var n in result.eighthPrize) processNumber(n);

    // Sort tails
    loto.forEach((key, value) {
      value.sort();
    });

    return loto;
  }

  @override
  Widget build(BuildContext context) {
    final lotoData = _calculateLoto();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          color: Colors.grey[100],
          child: const Text(
            'Thống Kê Đầu Đuôi',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ),
        Table(
          border: TableBorder(
            horizontalInside: BorderSide(color: Colors.grey.shade200),
            verticalInside: BorderSide(color: Colors.grey.shade200),
          ),
          columnWidths: const {
            0: FlexColumnWidth(1), // Head
            1: FlexColumnWidth(4), // Tail
          },
          children: [
            _buildHeaderRow(),
            ...List.generate(
              10,
              (index) => _buildLotoRow(index, lotoData[index] ?? []),
            ),
          ],
        ),
      ],
    );
  }

  TableRow _buildHeaderRow() {
    return TableRow(
      decoration: BoxDecoration(color: Colors.grey[50]),
      children: const [
        Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            'Đầu',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            'Đuôi',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  TableRow _buildLotoRow(int head, List<int> tails) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            '$head',
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            tails.isEmpty ? '-' : tails.join(', '), // Comma separated for Loto
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
          ),
        ),
      ],
    );
  }
}
