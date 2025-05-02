import 'package:sensors_plus/sensors_plus.dart';
import 'dart:async';

class SensorService {
  List<double> accelData = [];
  List<double> gyroData = [];
  double baroPressure = 1013.25; // Placeholder for barometer

  StreamSubscription? _accelSub;
  StreamSubscription? _gyroSub;

  void start() {
    accelData.clear();
    gyroData.clear();

    _accelSub = accelerometerEvents.listen((event) {
      accelData.add(event.z.abs());
    });

    _gyroSub = gyroscopeEvents.listen((event) {
      gyroData.add(event.x.abs() + event.y.abs() + event.z.abs());
    });
  }

  Future<void> stop() async {
    await _accelSub?.cancel();
    await _gyroSub?.cancel();
  }
}
