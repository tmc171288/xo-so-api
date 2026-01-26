import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NextDrawWidget extends StatefulWidget {
  final String region;

  const NextDrawWidget({Key? key, required this.region}) : super(key: key);

  @override
  State<NextDrawWidget> createState() => _NextDrawWidgetState();
}

class _NextDrawWidgetState extends State<NextDrawWidget> {
  late Timer _timer;
  Duration _timeLeft = Duration.zero;
  DateTime? _targetTime;

  @override
  void initState() {
    super.initState();
    _calculateTargetTime();
    _startTimer();
  }

  @override
  void didUpdateWidget(NextDrawWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.region != widget.region) {
      _calculateTargetTime();
    }
  }

  void _calculateTargetTime() {
    final now = DateTime.now();
    // Default times: MN 16:15, MT 17:15, MB 18:15
    int hour = 18;
    int minute = 15;

    if (widget.region == 'south') {
      hour = 16;
      minute = 15;
    } else if (widget.region == 'central') {
      hour = 17;
      minute = 15;
    }

    DateTime target = DateTime(now.year, now.month, now.day, hour, minute);

    // If already passed today's time, target is tomorrow
    if (now.isAfter(target)) {
      target = target.add(const Duration(days: 1));
    }

    setState(() {
      _targetTime = target;
      _timeLeft = target.difference(now);
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_targetTime == null) return;
      final now = DateTime.now();
      final difference = _targetTime!.difference(now);

      if (difference.isNegative) {
        // Refresh target if passed
        _calculateTargetTime();
      } else {
        setState(() {
          _timeLeft = difference;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_targetTime == null) return const SizedBox.shrink();

    final hours = _timeLeft.inHours.toString().padLeft(2, '0');
    final minutes = (_timeLeft.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (_timeLeft.inSeconds % 60).toString().padLeft(2, '0');



    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.red.withOpacity(0.5),
          width: 2,
        ), // Red border frame like screenshot
      ),
      child: Column(
        children: [
          // Header: Line - Dot - Text - Dot - Line
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(child: Divider(color: Colors.grey[300])),
              const SizedBox(width: 8),
              const Text(
                'Kỳ Tiếp Theo',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(width: 8),
              Expanded(child: Divider(color: Colors.grey[300])),
            ],
          ),

          Text(
            _getVietnameseDate(_targetTime!),
            style: TextStyle(color: Colors.grey[600], fontSize: 13),
          ),

          const SizedBox(height: 12),

          // Countdown Boxes: H H : M M : S S
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTimeBox(hours[0]),
              const SizedBox(width: 4),
              _buildTimeBox(hours[1]),
              _buildColon(),
              _buildTimeBox(minutes[0]),
              const SizedBox(width: 4),
              _buildTimeBox(minutes[1]),
              _buildColon(),
              _buildTimeBox(seconds[0]),
              const SizedBox(width: 4),
              _buildTimeBox(seconds[1]),
            ],
          ),

          const SizedBox(height: 16),

          // Button
          ElevatedButton.icon(
            onPressed: () {
              // Mock notification enable
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã bật thông báo xổ số!')),
              );
            },
            icon: const Icon(Icons.notifications_active, size: 18),
            label: const Text('Bật Thông Báo'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(
                0xFFFFF3E0,
              ), // Light orange bg like screenshot
              foregroundColor: Colors.black87,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Bottom Divider with "Kết Quả Mới Nhất"
          Row(
            children: [
              Expanded(child: Divider(color: Colors.grey[300])),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  'Kết Quả Mới Nhất',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
              const Icon(Icons.circle, size: 6, color: Colors.grey),
              Expanded(child: Divider(color: Colors.grey[300])),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeBox(String digit) {
    return Container(
      width: 32,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black87),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        digit,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
      ),
    );
  }

  Widget _buildColon() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 6),
      child: Text(
        ':',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  String _getVietnameseDate(DateTime date) {
    // Simple fallback if intl locale not ready
    final weekDays = [
      'Thứ Hai',
      'Thứ Ba',
      'Thứ Tư',
      'Thứ Năm',
      'Thứ Sáu',
      'Thứ Bảy',
      'Chủ Nhật',
    ];
    final dayName = weekDays[date.weekday - 1];
    return '$dayName, ${DateFormat('dd/MM/yyyy').format(date)}';
  }
}
