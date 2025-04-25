import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

void main() {
  runApp(MaterialApp(home: SimulatedWeightScreen()));
}

class SimulatedWeightScreen extends StatefulWidget {
  @override
  _SimulatedWeightScreenState createState() => _SimulatedWeightScreenState();
}

class _SimulatedWeightScreenState extends State<SimulatedWeightScreen> {
  bool _isMeasuring = false;
  double _estimatedWeight = 0.0;

  StreamSubscription? _accelSub;
  List<double> _accelHistory = [];

  final double _gravity = 9.8;
  final double _calibrationFactor = 3.0;

  void _startMeasurement() {
    setState(() {
      _isMeasuring = true;
      _estimatedWeight = 0.0;
      _accelHistory.clear();
    });

    _accelSub = userAccelerometerEvents.listen((event) {
      double accMagnitude = (event.x.abs() + event.y.abs() + event.z.abs());
      _accelHistory.add(accMagnitude);

      if (_accelHistory.length > 10) _accelHistory.removeAt(0);

      double avgAcc =
          _accelHistory.reduce((a, b) => a + b) / _accelHistory.length;
      double diff = avgAcc - _gravity;

      if (diff > 0.2) {
        // Estimate weight based on difference (simulated)
        double estimated = diff * _calibrationFactor * 10;

        setState(() {
          _estimatedWeight = double.parse(estimated.toStringAsFixed(2));
        });
      }
    });
  }

  void _stopMeasurement() {
    _accelSub?.cancel();
    setState(() {
      _isMeasuring = false;
      _estimatedWeight = 0.0;
      _accelHistory.clear();
    });
  }

  @override
  void dispose() {
    _accelSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Simulated Weight Estimator"),
        backgroundColor: Colors.teal,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.monitor_weight, size: 80, color: Colors.teal),
              SizedBox(height: 20),
              Text(
                _isMeasuring
                    ? 'Object detected... estimating weight'
                    : 'Tap Start, then gently place object or tap screen',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 30),
              Text(
                '${_estimatedWeight.toStringAsFixed(2)} grams',
                style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 40),
              _isMeasuring
                  ? ElevatedButton(
                    onPressed: _stopMeasurement,
                    child: Text("Stop"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                    ),
                  )
                  : ElevatedButton(
                    onPressed: _startMeasurement,
                    child: Text("Start"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
  

double _weightEstimate = 0.0;

@override
void initState() {
  super.initState();
  accelerometerEvents.listen((AccelerometerEvent event) {
    setState(() {
      // This is a dummy formula for demo — you need to calibrate with vibration/hardware
      _weightEstimate = (event.z.abs() * 10).clamp(0, 100);
    });
  });
}

}
