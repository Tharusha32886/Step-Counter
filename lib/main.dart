import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app.dart';
import 'data/hive_boxes.dart';
import 'data/models/settings.dart';
import 'data/models/step_day.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  Hive.registerAdapter(SettingsAdapter());
  Hive.registerAdapter(StepDayAdapter());

  await openHiveBoxes();

  runApp(const StepCounterApp());
}
