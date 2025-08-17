import 'package:hive/hive.dart';


@HiveType(typeId: 2)
class Settings extends HiveObject {
  @HiveField(0)
  int dailyGoal;

  @HiveField(1)
  double? heightCm; // optional, to improve distance estimate

  @HiveField(2)
  double? weightKg; // optional, not strictly needed

  Settings({
    required this.dailyGoal,
    this.heightCm,
    this.weightKg,
  });
}

class SettingsAdapter extends TypeAdapter<Settings> {
  @override
  final int typeId = 2;

  @override
  Settings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Settings(
      dailyGoal: fields[0] as int,
      heightCm: fields[1] as double?,
      weightKg: fields[2] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, Settings obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.dailyGoal)
      ..writeByte(1)
      ..write(obj.heightCm)
      ..writeByte(2)
      ..write(obj.weightKg);
  }
}
