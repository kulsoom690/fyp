import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Cyberpunk Color Scheme
const _cyberBlue = Color(0xFF00F3FF);
const _neonPink = Color(0xFFFF00C7);
const _matrixGreen = Color(0xFF00FF9D);
const _hudText = Color(0xFFE0E0E0);
const _cyberBlack = Color(0xFF0A0A0F);
const _cyberGradient = LinearGradient(
  colors: [_cyberBlack, Color(0xFF1A1A2E)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

enum CalibrationState {
  initial,
  measuringBase,
  addWeight,
  measuringWeight,
  complete,
}

class CalibrationScreen extends StatefulWidget {
  const CalibrationScreen({super.key});

  @override
  State<CalibrationScreen> createState() => _CalibrationScreenState();
}

class _CalibrationScreenState extends State<CalibrationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  List<double> _baseReadings = [];
  List<double> _weightReadings = [];
  CalibrationState _state = CalibrationState.initial;
  double _calibrationFactor = 1.0;
  final double _knownWeight = 100.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  Future<void> _startCalibration() async {
    setState(() => _state = CalibrationState.measuringBase);
    _baseReadings = await _collectSensorData();

    setState(() => _state = CalibrationState.addWeight);
    await Future.delayed(const Duration(seconds: 2));

    setState(() => _state = CalibrationState.measuringWeight);
    _weightReadings = await _collectSensorData();

    _calculateCalibration();
    await _saveCalibration();
    setState(() => _state = CalibrationState.complete);
  }

  Future<List<double>> _collectSensorData() async {
    final List<double> readings = [];
    final stream = accelerometerEvents
        .map((event) => event.x.abs() + event.y.abs() + event.z.abs())
        .take(100);

    await for (final value in stream) {
      readings.add(value);
    }
    return readings;
  }

  void _calculateCalibration() {
    final baseAvg =
        _baseReadings.reduce((a, b) => a + b) / _baseReadings.length;
    final weightAvg =
        _weightReadings.reduce((a, b) => a + b) / _weightReadings.length;
    _calibrationFactor = (weightAvg - baseAvg) / _knownWeight;
  }

  Future<void> _saveCalibration() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('calibration_factor', _calibrationFactor);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Calibration',
          style: TextStyle(
            color: const Color.fromARGB(255, 61, 11, 11),
            fontSize: 22,
            fontWeight: FontWeight.w700,
            shadows: [
              Shadow(color: _cyberBlue.withOpacity(0.4), blurRadius: 10),
            ],
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: _hudText),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(gradient: _cyberGradient),
        child: Stack(
          children: [
            // Add a background grid or visual effect if needed
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildVisualFeedback(),
                  _buildInstructions(),
                  _buildControls(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVisualFeedback() {
    return SizedBox(
      height: 200,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        child:
            _state == CalibrationState.complete
                ? _buildSuccessAnimation()
                : _buildSensorAnimation(),
      ),
    );
  }

  Widget _buildSensorAnimation() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Center(
          child: CircularProgressIndicator(
            color:
                _state == CalibrationState.measuringBase ||
                        _state == CalibrationState.measuringWeight
                    ? _neonPink
                    : _cyberBlue,
          ),
        );
      },
    );
  }

  Widget _buildSuccessAnimation() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            'assets/Animation - 1742578000459.json',
            width: 100,
            repeat: false,
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _matrixGreen.withOpacity(0.2)),
            ),
            child: Text(
              'Calibration factor: ${_calibrationFactor.toStringAsFixed(2)}',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _matrixGreen,
                fontSize: 20,
                fontWeight: FontWeight.w600,
                shadows: [
                  Shadow(color: _matrixGreen.withOpacity(0.3), blurRadius: 10),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cyberBlue.withOpacity(0.3)),
        gradient: LinearGradient(
          colors: [
            Colors.black.withOpacity(0.3),
            Colors.black.withOpacity(0.1),
          ],
        ),
      ),
      child: Column(
        children: [
          Text(
            _getInstructionText(),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _hudText,
              fontSize: 16,
              height: 1.4,
              fontWeight: FontWeight.w500,
              shadows: [
                Shadow(color: _cyberBlue.withOpacity(0.3), blurRadius: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getInstructionText() {
    switch (_state) {
      case CalibrationState.initial:
        return 'Place device on flat surface\nRemove all objects';
      case CalibrationState.measuringBase:
        return 'Measuring baseline...\nMaintain stillness';
      case CalibrationState.addWeight:
        return 'Apply known weight (${_knownWeight}g)\nTo device surface';
      case CalibrationState.measuringWeight:
        return 'Measuring load...\nDo not disturb';
      case CalibrationState.complete:
        return 'Calibration complete!\nFactor: ${_calibrationFactor.toStringAsFixed(2)}';
    }
  }

  Widget _buildControls() {
    return Column(
      children: [
        if (_state == CalibrationState.complete)
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: _matrixGreen, width: 2),
              ),
            ),
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Done',
              style: TextStyle(
                color: _matrixGreen,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          )
        else
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            icon:
                _state == CalibrationState.initial
                    ? Icon(Icons.tune, color: _hudText)
                    : SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: _hudText),
                    ),
            label: Text(
              _state == CalibrationState.initial
                  ? 'Initiate Calibration'
                  : 'Calibrating...',
              style: TextStyle(
                color: _hudText,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            onPressed:
                _state == CalibrationState.initial ? _startCalibration : null,
          ),
      ],
    );
  }
}
