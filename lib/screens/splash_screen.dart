import 'dart:async';
import 'package:flutter/material.dart';
import 'home_screen.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});


  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E65FF), // Background color
      body: Center(
        child: Image.asset(
          'assets/images/mainLogo.png',
          width: 150,
          height: 150,
        ),
      ),
    );
  }

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _gradientController;
  late Animation<Color?> _color1;
  late Animation<Color?> _color2;

  late AnimationController _iconController;
  late Animation<Offset> _iconAnimation;

  bool isLoading = false;


  final List<List<Color>> _colorSets = [

    [Color(0xFF0038FF), Color(0xFFF01EFF)],
    [Color(0xFF2EB4FD), Color(0xFF0038FF)],
    [Color(0xFFF01EFF), Color(0xFF0022FF)],
    [Color(0xFF0022FF), Color(0xFF2EB4FD)],


  ];



  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();

    // Icon animation controller
    _iconController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _iconAnimation = Tween<Offset>(
      begin: const Offset(0, -0.03),
      end: const Offset(0, 0.03),
    ).animate(CurvedAnimation(
      parent: _iconController,
      curve: Curves.easeInOut,
    ));

    // Gradient animation
    _gradientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    _setupAnimation();

    Timer.periodic(const Duration(seconds: 4), (_) {
      _changeGradient();
    });

    _gradientController.forward();
  }

  void _setupAnimation() {
    final nextIndex = (_currentIndex + 1) % _colorSets.length;

    _color1 = ColorTween(
      begin: _colorSets[_currentIndex][0],
      end: _colorSets[nextIndex][0],
    ).animate(_gradientController);

    _color2 = ColorTween(
      begin: _colorSets[_currentIndex][1],
      end: _colorSets[nextIndex][1],
    ).animate(_gradientController);

    _gradientController.reset();
    _gradientController.forward();

    _currentIndex = nextIndex;
  }

  void _changeGradient() {
    _setupAnimation();
  }

  @override
  void dispose() {
    _iconController.dispose();
    _gradientController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _gradientController,
      builder: (context, child) {
        return Scaffold(
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _color1.value ?? _colorSets[0][0],
                  _color2.value ?? _colorSets[0][1],
                ],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Animated Icon
                    SlideTransition(
                      position: _iconAnimation,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.download_rounded,
                          size: 130,
                          color: Color(0xFF1E65FF),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),
                    const Text(
                      'Welcome to Youtube TikTok Facebook Video Saver',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'A convenient tool to save videos from your Youtube TikTok Facebook feed with ease.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                        fontFamily: 'Poppins',
                      ),
                    ),

                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          setState(() => isLoading = true);
                          await Future.delayed(const Duration(milliseconds: 500));
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const HomeScreen()),
                          );
                          setState(() => isLoading = false);
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.resolveWith<Color>(
                                (states) => states.contains(MaterialState.pressed)
                                ? const Color(0xFFE0E8FF)
                                : Colors.white,
                          ),
                          foregroundColor: MaterialStateProperty.all(const Color(0xFF1E65FF)),
                          overlayColor: MaterialStateProperty.all(
                            const Color(0xFF1E65FF).withOpacity(0.06),
                          ),
                          elevation: MaterialStateProperty.resolveWith<double>(
                                (states) => states.contains(MaterialState.pressed) ? 2 : 6,
                          ),
                          padding: MaterialStateProperty.resolveWith<EdgeInsets>(
                                (states) => states.contains(MaterialState.pressed)
                                ? const EdgeInsets.symmetric(vertical: 18)
                                : const EdgeInsets.symmetric(vertical: 20),
                          ),
                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                        child: isLoading
                            ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Color(0xFF1E65FF),
                            strokeWidth: 2.5,
                          ),
                        )
                            : const Text(
                          'Continue',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),



                    const SizedBox(height: 12),
                    const Text(
                      'By tapping "Continue" you confirm that you agree with our privacy policy',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.white60,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );


  }



}
