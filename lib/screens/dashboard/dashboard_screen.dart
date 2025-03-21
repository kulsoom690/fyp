import 'dart:math';
import 'package:flutter/material.dart';
import 'package:smartscalex/screens/dashboard/calibration_screen.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

// Color Constants
const _primaryColor = Color(0xFF0A0E21);
const _secondaryColor = Color(0xFF1A2E35);
const _accentColor = Color(0xFF4ECDC4);
const _textColor = Color(0xFFE0F2F1);
const _mainGradient = LinearGradient(
  colors: [_primaryColor, _secondaryColor],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

class MainDashboard extends StatefulWidget {
  const MainDashboard({super.key});

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> 
    with SingleTickerProviderStateMixin {
  late AnimationController _sensorAnimationController;
  final List<double> _sensorData = List.generate(20, (i) => i + Random().nextDouble());
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
          gradient: LinearGradient(
            colors: [
              _secondaryColor.withOpacity(0.3),
              _accentColor.withOpacity(0.1)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _accentColor.withOpacity(0.2)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: _accentColor),
            const SizedBox(height: 8),
            Text(label, 
              style: TextStyle(
                color: _textColor.withOpacity(0.9),
                fontSize: 12,
                fontWeight: FontWeight.w500
              )
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: _mainGradient),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              AppBar(
                title: Text('SmartScaleX Dashboard',
                  style: TextStyle(
                    color: _textColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 18
                  )
                ),
                backgroundColor: Colors.transparent,
                elevation: 0,
                actions: [
                  IconButton(
                    icon: Icon(Icons.notifications, 
                      color: _textColor.withOpacity(0.8)),
                    onPressed: () {},
                  ),
                ],
              ),
              SizedBox(
                height: 120,
                child: GridView.count(
                  crossAxisCount: 3,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  children: [
                    _buildActionCard(Icons.scale, 'Calibrate', () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => CalibrationScreen()),
                      );
                    }),
                    _buildActionCard(Icons.speed, 'Measure', () {}),
                    _buildActionCard(Icons.fastfood, 'Food Scan', () {}),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _secondaryColor.withOpacity(0.6),
                      _secondaryColor.withOpacity(0.3)
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _accentColor.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Sensor Activity',
                      style: TextStyle(
                        color: _textColor.withOpacity(0.9),
                        fontSize: 16,
                        fontWeight: FontWeight.w600
                      )
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 100,
                      child: CustomPaint(
                        painter: _SensorWavePainter(
                          data: _sensorData,
                          animation: _sensorAnimationController,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      title: 'Last Weight',
                      value: '68.2 kg',
                      icon: Icons.monitor_weight,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      title: 'Calories Today',
                      value: '2,340 kcal',
                      icon: Icons.local_fire_department,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _secondaryColor.withOpacity(0.6),
                        _secondaryColor.withOpacity(0.3)
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _accentColor.withOpacity(0.2)),
                  ),
                  child: SfCartesianChart(
                    primaryXAxis: CategoryAxis(
                      labelStyle: TextStyle(color: _textColor.withOpacity(0.7)),
                    ),
                    primaryYAxis: NumericAxis(
                      labelStyle: TextStyle(color: _textColor.withOpacity(0.7)),
                    ),
                    series: <LineSeries<ChartData, String>>[
                      LineSeries(
                        dataSource: _chartData,
                        xValueMapper: (ChartData data, _) => data.x,
                        yValueMapper: (ChartData data, _) => data.y,
                        color: _accentColor,
                        markerSettings: const MarkerSettings(isVisible: true),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildStatCard({required String title, required String value, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _secondaryColor.withOpacity(0.4),
            _accentColor.withOpacity(0.1)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _accentColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: _accentColor, size: 28),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                style: TextStyle(
                  color: _textColor.withOpacity(0.7),
                  fontSize: 12,
                )
              ),
              Text(value,
                style: TextStyle(
                  color: _textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                )
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _primaryColor.withOpacity(0.9),
            _secondaryColor.withOpacity(0.9)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: _accentColor,
        unselectedItemColor: _textColor.withOpacity(0.5),
        currentIndex: 0,
        items: [
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _accentColor.withOpacity(0.2),
                    _accentColor.withOpacity(0.05)
                  ],
                ),
                borderRadius: BorderRadius.circular(12)),
              child: Icon(Icons.home)),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

class ChartData {
  final String x;
  final double y;

  ChartData(this.x, this.y);
}

class _SensorWavePainter extends CustomPainter {
  final List<double> data;
  final Animation<double> animation;

  _SensorWavePainter({required this.data, required this.animation}) 
    : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..shader = LinearGradient(
        colors: [_accentColor, _accentColor.withOpacity(0.3)]
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    final xStep = size.width / (data.length - 1);
    final yScale = size.height / 2;

    path.moveTo(0, yScale + data[0] * yScale);
    for (int i = 1; i < data.length; i++) {
      path.lineTo(
        i * xStep,
        yScale + data[i] * yScale * animation.value,
      );
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}