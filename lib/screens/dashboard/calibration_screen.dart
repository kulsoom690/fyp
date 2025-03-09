import 'package:flutter/material.dart';

class CalibrationScreen extends StatefulWidget {
  const CalibrationScreen({super.key});

  @override
  State<CalibrationScreen> createState() => _CalibrationScreenState();
}

class _CalibrationScreenState extends State<CalibrationScreen> {
  final double _referenceWeight = 100; // Grams
  final List<double> _sensorReadings = [];
  bool _isCalibrating = false;

  void _startCalibration() async {
    setState(() => _isCalibrating = true);
    _sensorReadings.clear();

    // Simulate sensor readings for calibration
    for (int i = 0; i < 30; i++) {
      if (!_isCalibrating) break;
      setState(() => _sensorReadings.add(100 + i.toDouble())); // Dummy data
      await Future.delayed(const Duration(milliseconds: 100));
    }

    setState(() => _isCalibrating = false);

    final averageReading =
        _sensorReadings.isEmpty
            ? 0
            : _sensorReadings.reduce((a, b) => a + b) / _sensorReadings.length;

    final calibrationFactor = averageReading / _referenceWeight;

    // Save calibration factor (Example Placeholder)
    debugPrint('Calibration Factor: $calibrationFactor');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calibration'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Calibration Guide',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            const Text(
              '1. Place a known weight (e.g., 100g object)\n'
              '2. Ensure phone is on a flat surface\n'
              '3. Keep still during calibration',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 40),
            LinearProgressIndicator(
              value:
                  _isCalibrating
                      ? null
                      : _sensorReadings.isNotEmpty
                      ? 1
                      : 0,
              backgroundColor: Colors.grey.shade800,
              color: Colors.blueAccent,
            ),
            const SizedBox(height: 20),
            Text(
              'Readings: ${_sensorReadings.length}',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70),
            ),
            const Spacer(),
            ElevatedButton.icon(
              icon:
                  _isCalibrating
                      ? const CircularProgressIndicator()
                      : const Icon(Icons.adjust),
              label: Text(
                _isCalibrating ? 'Calibrating...' : 'Start Calibration',
              ),
              onPressed: _isCalibrating ? null : _startCalibration,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
