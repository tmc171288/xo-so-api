// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lottery_result.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LotteryResultAdapter extends TypeAdapter<LotteryResult> {
  @override
  final int typeId = 0;

  @override
  LotteryResult read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LotteryResult(
      id: fields[0] as String,
      region: fields[1] as String,
      date: fields[2] as DateTime,
      province: fields[3] as String,
      specialPrize: fields[4] as String,
      firstPrize: (fields[5] as List).cast<String>(),
      secondPrize: (fields[6] as List).cast<String>(),
      thirdPrize: (fields[7] as List).cast<String>(),
      fourthPrize: (fields[8] as List).cast<String>(),
      fifthPrize: (fields[9] as List).cast<String>(),
      sixthPrize: (fields[10] as List).cast<String>(),
      seventhPrize: (fields[11] as List).cast<String>(),
      eighthPrize: (fields[12] as List).cast<String>(),
      isLive: fields[13] as bool,
      updatedAt: fields[14] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, LotteryResult obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.region)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.province)
      ..writeByte(4)
      ..write(obj.specialPrize)
      ..writeByte(5)
      ..write(obj.firstPrize)
      ..writeByte(6)
      ..write(obj.secondPrize)
      ..writeByte(7)
      ..write(obj.thirdPrize)
      ..writeByte(8)
      ..write(obj.fourthPrize)
      ..writeByte(9)
      ..write(obj.fifthPrize)
      ..writeByte(10)
      ..write(obj.sixthPrize)
      ..writeByte(11)
      ..write(obj.seventhPrize)
      ..writeByte(12)
      ..write(obj.eighthPrize)
      ..writeByte(13)
      ..write(obj.isLive)
      ..writeByte(14)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LotteryResultAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
