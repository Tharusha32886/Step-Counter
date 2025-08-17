import 'dart:async';
import 'package:permission_handler/permission_handler.dart';
import 'package:pedometer/pedometer.dart';
import 'step_repository.dart';

class PedometerService {
  StreamSubscription<StepCount>? _sub;

  Future<void> start(StepRepository repo) async {
    // Request runtime permission on Android 10+
    final status = await Permission.activityRecognition.request();
    if (!status.isGranted) {
      // App will still run, but steps won't come in
      return;
    }

    _sub?.cancel();
    _sub = Pedometer.stepCountStream.listen(
      (event) {
        repo.onCumulativeSteps(event.steps);
      },
      onError: (e) {
        // Ignore or log
      },
      cancelOnError: false,
    );
  }

  Future<void> stop() async {
    await _sub?.cancel();
    _sub = null;
  }
}
