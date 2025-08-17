import 'package:hive/hive.dart';

// part 'step_day.g.dart'; // removed: not used (manual adapter)

@HiveType(typeId: 1)
class StepDay extends HiveObject {
  @HiveField(0)
  DateTime date;

  @HiveField(1)
  int steps;

  @HiveField(2)
  double distanceKm;

  @HiveField(3)
  double calories;

  @HiveField(4)
  int goal;

  StepDay({
    required this.date,
    required this.steps,
    required this.distanceKm,
    required this.calories,
    required this.goal,
  });
}

// Manual adapter (so we don't need build_runner)
class StepDayAdapter extends TypeAdapter<StepDay> {
  @override
  final int typeId = 1;

  @override
  StepDay read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StepDay(
      date: fields[0] as DateTime,
      steps: fields[1] as int,
      distanceKm: fields[2] as double,
      calories: fields[3] as double,
      goal: fields[4] as int,
    );
  }

  @override
  void write(BinaryWriter writer, StepDay obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.steps)
      ..writeByte(2)
      ..write(obj.distanceKm)
      ..writeByte(3)
      ..write(obj.calories)
      ..writeByte(4)
      ..write(obj.goal);
  }
}
