import 'package:hive/hive.dart';

part 'lottery_result.g.dart';

/// Model for lottery result data
@HiveType(typeId: 0)
class LotteryResult {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String region; // 'north', 'central', 'south'

  @HiveField(2)
  final DateTime date;

  @HiveField(3)
  final String province; // e.g., 'Hà Nội', 'Đà Nẵng', 'TP.HCM'

  @HiveField(4)
  final String specialPrize; // Giải Đặc Biệt

  @HiveField(5)
  final List<String> firstPrize; // Giải Nhất

  @HiveField(6)
  final List<String> secondPrize; // Giải Nhì

  @HiveField(7)
  final List<String> thirdPrize; // Giải Ba

  @HiveField(8)
  final List<String> fourthPrize; // Giải Tư

  @HiveField(9)
  final List<String> fifthPrize; // Giải Năm

  @HiveField(10)
  final List<String> sixthPrize; // Giải Sáu

  @HiveField(11)
  final List<String> seventhPrize; // Giải Bảy

  @HiveField(12)
  final List<String> eighthPrize; // Giải Tám (if applicable)

  @HiveField(13)
  final bool isLive; // Đang quay hay đã kết thúc

  @HiveField(14)
  final DateTime? updatedAt;

  LotteryResult({
    required this.id,
    required this.region,
    required this.date,
    required this.province,
    required this.specialPrize,
    required this.firstPrize,
    required this.secondPrize,
    required this.thirdPrize,
    required this.fourthPrize,
    required this.fifthPrize,
    required this.sixthPrize,
    required this.seventhPrize,
    this.eighthPrize = const [],
    this.isLive = false,
    this.updatedAt,
  });

  /// Create from JSON
  factory LotteryResult.fromJson(Map<String, dynamic> json) {
    return LotteryResult(
      id: json['id'] ?? '',
      region: json['region'] ?? '',
      date: DateTime.parse(json['date']),
      province: json['province'] ?? '',
      specialPrize: json['specialPrize'] ?? '',
      firstPrize: List<String>.from(json['firstPrize'] ?? []),
      secondPrize: List<String>.from(json['secondPrize'] ?? []),
      thirdPrize: List<String>.from(json['thirdPrize'] ?? []),
      fourthPrize: List<String>.from(json['fourthPrize'] ?? []),
      fifthPrize: List<String>.from(json['fifthPrize'] ?? []),
      sixthPrize: List<String>.from(json['sixthPrize'] ?? []),
      seventhPrize: List<String>.from(json['seventhPrize'] ?? []),
      eighthPrize: List<String>.from(json['eighthPrize'] ?? []),
      isLive: json['isLive'] ?? false,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'region': region,
      'date': date.toIso8601String(),
      'province': province,
      'specialPrize': specialPrize,
      'firstPrize': firstPrize,
      'secondPrize': secondPrize,
      'thirdPrize': thirdPrize,
      'fourthPrize': fourthPrize,
      'fifthPrize': fifthPrize,
      'sixthPrize': sixthPrize,
      'seventhPrize': seventhPrize,
      'eighthPrize': eighthPrize,
      'isLive': isLive,
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Get all numbers from all prizes
  List<String> getAllNumbers() {
    return [
      specialPrize,
      ...firstPrize,
      ...secondPrize,
      ...thirdPrize,
      ...fourthPrize,
      ...fifthPrize,
      ...sixthPrize,
      ...seventhPrize,
      ...eighthPrize,
    ].where((n) => n.isNotEmpty).toList();
  }

  /// Copy with method for immutability
  LotteryResult copyWith({
    String? id,
    String? region,
    DateTime? date,
    String? province,
    String? specialPrize,
    List<String>? firstPrize,
    List<String>? secondPrize,
    List<String>? thirdPrize,
    List<String>? fourthPrize,
    List<String>? fifthPrize,
    List<String>? sixthPrize,
    List<String>? seventhPrize,
    List<String>? eighthPrize,
    bool? isLive,
    DateTime? updatedAt,
  }) {
    return LotteryResult(
      id: id ?? this.id,
      region: region ?? this.region,
      date: date ?? this.date,
      province: province ?? this.province,
      specialPrize: specialPrize ?? this.specialPrize,
      firstPrize: firstPrize ?? this.firstPrize,
      secondPrize: secondPrize ?? this.secondPrize,
      thirdPrize: thirdPrize ?? this.thirdPrize,
      fourthPrize: fourthPrize ?? this.fourthPrize,
      fifthPrize: fifthPrize ?? this.fifthPrize,
      sixthPrize: sixthPrize ?? this.sixthPrize,
      seventhPrize: seventhPrize ?? this.seventhPrize,
      eighthPrize: eighthPrize ?? this.eighthPrize,
      isLive: isLive ?? this.isLive,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
