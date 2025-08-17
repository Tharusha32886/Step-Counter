import 'package:hive/hive.dart';
import 'models/settings.dart';
import 'models/step_day.dart';

late Box<Settings> settingsBox;
late Box<StepDay> daysBox;
late Box runtimeBox; // holds baseline/offset/last counters

Future<void> openHiveBoxes() async {
  settingsBox = await Hive.openBox<Settings>('settings');
  daysBox = await Hive.openBox<StepDay>('days');
  runtimeBox = await Hive.openBox('runtime');

  // Defaults
  if (settingsBox.isEmpty) {
    await settingsBox.put('settings', Settings(dailyGoal: 8000));
  }
}
