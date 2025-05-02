import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:vibration/vibration.dart';

class WeightMeasurementScreen extends StatefulWidget {
  const WeightMeasurementScreen({Key? key}) : super(key: key);

  @override
  State<WeightMeasurementScreen> createState() => _WeightMeasurementScreenState();
}

class _WeightMeasurementScreenState extends State<WeightMeasurementScreen> {
  bool _isProcessing = false;
  bool _isComplete = false;
  double _estimatedWeight = 0.0;

  List<double> _accelData = [];
  List<double> _gyroData = [];
  double _baroPressure = 1013.25; // Simulated constant pressure

  StreamSubscription? _accelSub;
  StreamSubscription? _gyroSub;

  void _startMeasurement() {
    setState(() {
      _isProcessing = true;
      _isComplete = false;
      _estimatedWeight = 0.0;
      _accelData.clear();
      _gyroData.clear();
    });

    _accelSub = accelerometerEvents.listen((AccelerometerEvent event) {
      _accelData.add(event.z.abs());
    });

    _gyroSub = gyroscopeEvents.listen((GyroscopeEvent event) {
      _gyroData.add(event.x.abs() + event.y.abs() + event.z.abs());
    });

    Future.delayed(const Duration(seconds: 5), () {
      _stopMeasurement();
      _processSensorData();
    });
  }

  void _stopMeasurement() {
    _accelSub?.cancel();
    _gyroSub?.cancel();
  }

  void _processSensorData() async {
    double avgAccel = _accelData.isNotEmpty
        ? _accelData.reduce((a, b) => a + b) / _accelData.length
        : 0.0;

    double avgGyro = _gyroData.isNotEmpty
        ? _gyroData.reduce((a, b) => a + b) / _gyroData.length
        : 0.0;

    double simulatedWeight = (avgAccel + avgGyro + (_baroPressure % 10)) * 2.5;
    simulatedWeight = simulatedWeight.clamp(50.0, 3000.0); // grams

    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 100);
    }

    setState(() {
      _isProcessing = false;
      _isComplete = true;
      _estimatedWeight = double.parse(simulatedWeight.toStringAsFixed(2));
    });
  }

  @override
  void dispose() {
    _stopMeasurement();
    super.dispose();
  }

  Widget _buildStatusText() {
    if (_isProcessing) {
      return const Text(
        'Analyzing... Please wait',
        style: TextStyle(fontSize: 20, color: Colors.black87),
        textAlign: TextAlign.center,
      );
    } else if (_isComplete) {
      return const Text(
        'Estimated Weight',
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.teal),
        textAlign: TextAlign.center,
      );
    } else {
      return const Text(
        'Place object gently on screen and tap Start',
        style: TextStyle(fontSize: 18, color: Colors.black54),
        textAlign: TextAlign.center,
      );
    }
  }

  Widget _buildWeightDisplay() {
    if (_isComplete) {
      return Text(
        '$_estimatedWeight grams',
        style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.teal),
      );
    } else if (_isProcessing) {
      return const Text(
        'Processing...',
        style: TextStyle(fontSize: 28, color: Colors.grey),
      );
    } else {
      return const Text(
        '--.-- grams',
        style: TextStyle(fontSize: 32, color: Colors.grey),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Smart Weight Estimator'),
        centerTitle: true,
        backgroundColor: Colors.teal[700],
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.scale_outlined, size: 100, color: Colors.teal[700]),
              const SizedBox(height: 30),
              _buildStatusText(),
              const SizedBox(height: 30),
              _buildWeightDisplay(),
              const SizedBox(height: 40),
              if (_isProcessing)
                const CircularProgressIndicator()
              else if (!_isComplete)
                ElevatedButton.icon(
                  onPressed: _startMeasurement,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text("Start Measurement"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    textStyle: const TextStyle(fontSize: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              if (_isComplete)
                Column(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _isComplete = false;
                          _estimatedWeight = 0.0;
                        });
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text("Measure Again"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        textStyle: const TextStyle(fontSize: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Back to Home'),
                    )
                  ],
                )
            ],
          ),
        ),
      ),
    );
  }
}
