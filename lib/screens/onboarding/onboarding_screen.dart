import 'package:flutter/material.dart';
import 'package:smartscalex/screens/auth/login._screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  late AnimationController _imageAnimController;
  late Animation<Offset> _imageOffset;
  late Animation<double> _imageFade;

  final List<Map<String, String>> _slides = [
    {
      'image': 'assets/image2.png',
      'title': 'Precision Measurement',
      'desc': 'Sensor calibration for accurate\nweight tracking.',
    },
    {
      'image': 'assets/image.png',
      'title': 'AI Calorie Estimation',
      'desc': 'AI-powered food analysis\nand calorie prediction.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _imageAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _imageOffset = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _imageAnimController,
      curve: Curves.easeOut,
    ));

    _imageFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _imageAnimController,
        curve: Curves.easeOut,
      ),
    );

    _imageAnimController.forward();
  }

  @override
  void dispose() {
    _imageAnimController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _goToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  void _onPageChanged(int index) {
    setState(() => _currentPage = index);
    _imageAnimController.reset();
    _imageAnimController.forward();
  }

  Widget _buildIndicator(int index) {
    bool isActive = index == _currentPage;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 6),
      height: 8,
      width: isActive ? 30 : 10,
      decoration: BoxDecoration(
        color: isActive ? Colors.cyanAccent : Colors.white30,
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1A237E), Color(0xFF8E24AA)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: _slides.length,
              onPageChanged: _onPageChanged,
              itemBuilder: (context, index) {
                final slide = _slides[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: SlideTransition(
                          position: _imageOffset,
                          child: FadeTransition(
                            opacity: _imageFade,
                            child: Image.asset(
                              slide['image']!,
                              height: 280,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 500),
                        child: Text(
                          slide['title']!,
                          key: ValueKey(slide['title']),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                blurRadius: 10,
                                color: Colors.black45,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 500),
                        child: Text(
                          slide['desc']!,
                          key: ValueKey(slide['desc']),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            height: 1.6,
                            color: Color(0xFFCBD5E1),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            // Bottom Buttons & Indicators
            Positioned(
              bottom: 40,
              left: 24,
              right: 24,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _slides.length,
                      (i) => _buildIndicator(i),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_currentPage < _slides.length - 1) {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                          );
                        } else {
                          _goToLogin();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.cyanAccent,
                        elevation: 12,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        _currentPage == _slides.length - 1
                            ? 'Get Started'
                            : 'Continue',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  if (_currentPage != _slides.length - 1)
                    TextButton(
                      onPressed: _goToLogin,
                      child: const Text(
                        'Skip',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
