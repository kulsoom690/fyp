class WeightEstimator {
  static double calculate({
    required List<double> accelData,
    required List<double> gyroData,
    required double pressure,
  }) {
    double avgAccel =
        accelData.isNotEmpty
            ? accelData.reduce((a, b) => a + b) / accelData.length
            : 0.0;

    double avgGyro =
        gyroData.isNotEmpty
            ? gyroData.reduce((a, b) => a + b) / gyroData.length
            : 0.0;

    // Example: pseudo-physical formula
    double raw = (avgAccel + avgGyro + (pressure % 10)) * 2.5;
    return raw.clamp(50.0, 3000.0); // grams
  }
}
