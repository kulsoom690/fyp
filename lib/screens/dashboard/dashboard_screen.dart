
import 'package:flutter/material.dart';
import 'package:smartscalex/screens/profile_screen.dart';
import 'package:smartscalex/screens/dashboard/calibration_screen.dart';
import 'package:smartscalex/screens/dashboard/measurement_screen.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

// Color Scheme
const _gradientStart = Color(0xFF1A237E); // Colors.indigo.shade800
const _gradientEnd = Color(0xFF8E24AA);   // Colors.purple.shade600
const _containerColor = Color(0xF2FFFFFF); // White with 95% opacity
const _inputFieldColor = Color(0xFFF5F5F5); // Light grey for input
const _accentIndigo = Color(0xFF5C6BC0); // Colors.indigo.shade400
const _accentTeal = Color(0xFF009688);   // Colors.teal.shade600
const _errorRed = Color(0xFFD32F2F);     // Colors.red.shade700
const _textPrimary = Colors.black87;
const _textLight = Colors.white;

class MainDashboard extends StatefulWidget {
  const MainDashboard({super.key});

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> with SingleTickerProviderStateMixin {
  late AnimationController _sensorAnimationController;
  final List<ChartData> _chartData = [];

  @override
  void initState() {
    super.initState();
    _sensorAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _chartData.addAll([
      ChartData('Mon', 68.2),
      ChartData('Tue', 67.8),
      ChartData('Wed', 68.1),
      ChartData('Thu', 67.9),
      ChartData('Fri', 68.0),
      ChartData('Sat', 67.7),
      ChartData('Sun', 67.5),
    ]);
  }

  @override
  void dispose() {
    _sensorAnimationController.dispose();
    super.dispose();
  }

  Widget _buildActionCard(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: _containerColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: _accentIndigo),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: _textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, String unit, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              )),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: TextStyle(
                    color: _textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: ' $unit',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: _containerColor.withOpacity(0.85),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: _accentTeal,
        unselectedItemColor: Colors.grey,
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Analytics'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _gradientStart,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [_gradientStart, _gradientEnd],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Header AppBar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'SmartScaleX',
                      style: TextStyle(
                        color: _textLight,
                        fontSize: 26,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ProfileScreen()),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: _accentTeal, width: 2),
                        ),
                        child: const CircleAvatar(
                          backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=3'),
                          radius: 20,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Action Buttons
                SizedBox(
                  height: 120,
                  child: GridView.count(
                    crossAxisCount: 3,
                    childAspectRatio: 1.2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildActionCard(Icons.tune, 'Calibrate', () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const CalibrationScreen()),
                        );
                      }),
                      _buildActionCard(Icons.scale, 'Measure', () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => WeightMeasurementScreen()),
                        );
                      }),
                      _buildActionCard(Icons.history, 'History', () {}),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Metrics
                Row(
                  children: [
                    Expanded(child: _buildMetricCard('Weight', '68.2', 'kg', _accentTeal)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildMetricCard('BMI', '22.5', 'kg/m²', _accentIndigo)),
                  ],
                ),
                const SizedBox(height: 20),

                // Chart
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: _containerColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(16),
                    child: SfCartesianChart(
                      plotAreaBorderWidth: 0,
                      primaryXAxis: CategoryAxis(),
                      primaryYAxis: NumericAxis(),
                      series: <LineSeries<ChartData, String>>[
                        LineSeries<ChartData, String>(
                          dataSource: _chartData,
                          xValueMapper: (ChartData data, _) => data.x,
                          yValueMapper: (ChartData data, _) => data.y,
                          color: _accentTeal,
                          width: 3,
                          markerSettings: MarkerSettings(
                            isVisible: true,
                            color: _accentTeal,
                            borderColor: Colors.white,
                            borderWidth: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }
}

class ChartData {
  final String x;
  final double y;

  ChartData(this.x, this.y);
}
