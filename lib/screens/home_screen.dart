// home_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../widgets/custom_drawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  String selectedPlatform = 'YouTube';
  final TextEditingController linkController = TextEditingController();

  final List<Map<String, String>> platforms = [
    {'name': 'YouTube', 'icon': 'assets/images/youtube.png'},
    {'name': 'Facebook', 'icon': 'assets/images/facebook.png'},
    {'name': 'TikTok', 'icon': 'assets/images/tiktolk.png'},
  ];

  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  late AnimationController _gradientController;
  late Animation<Color?> _color1;
  late Animation<Color?> _color2;

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

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    );
    _scaleController.forward();

    _gradientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _setupGradientAnimation();
    Timer.periodic(const Duration(seconds: 3), (_) => _changeGradient());
    _gradientController.forward();
  }

  void _setupGradientAnimation() {
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
    _setupGradientAnimation();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _gradientController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Builder(
          builder: (context) {
            return AnimatedBuilder(
              animation: _gradientController,
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        _color1.value ?? _colorSets[0][0],
                        _color2.value ?? _colorSets[0][1],
                      ],
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: SafeArea(child: child ?? const SizedBox.shrink()),
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.video_library_rounded, color: Colors.white),
                      SizedBox(width: 10),
                      Text(
                        'YTF Downloader',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Scaffold.of(context).openDrawer();
                        },
                        child: const Icon(Icons.settings, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.workspace_premium_outlined, color: Colors.amber),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),

      drawer: CustomDrawer(
        color1: _color1,
        color2: _color2,
        gradientController: _gradientController,
      ),

      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 122,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: platforms.length,
                separatorBuilder: (_, __) => const SizedBox(width: 16),
                itemBuilder: (_, index) {
                  final platform = platforms[index];
                  final isSelected = platform['name'] == selectedPlatform;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedPlatform = platform['name']!;
                        _scaleController.reset();
                        _scaleController.forward();
                      });
                    },
                    child: ScaleTransition(
                      scale: isSelected
                          ? _scaleAnimation
                          : const AlwaysStoppedAnimation(1.0),
                      child: Column(
                        children: [
                          Container(
                            width: 88,
                            height: 88,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: isSelected
                                  ? const LinearGradient(
                                colors: [
                                  Color(0xFF3BE4F6),
                                  Color(0xFF6A75FF)
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                                  : const LinearGradient(
                                colors: [
                                  Color(0xFFF4F4F4),
                                  Color(0xFFCDCDCD)
                                ],
                              ),
                              boxShadow: [
                                if (isSelected)
                                  const BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 6,
                                    offset: Offset(0, 3),
                                  )
                              ],
                            ),
                            padding: const EdgeInsets.all(10),
                            child: CircleAvatar(
                              backgroundColor: Colors.white,
                              backgroundImage: AssetImage(platform['icon']!),
                              radius: 28,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            platform['name']!,
                            style: TextStyle(
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isSelected ? Colors.blueAccent : Colors.grey,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 35),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 6),
                ],
              ),
              child: Column(
                children: [
                  TextField(
                    controller: linkController,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Paste link to download',
                      hintStyle: TextStyle(color: Colors.black54),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            linkController.text = 'https://example.com';
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade200,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 20),
                          ),
                          child: const Text('Paste Link',
                              style: TextStyle(color: Colors.blueGrey)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // Download logic here
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1FBF95),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 20),
                          ),
                          child: const Text('Download',
                              style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: const Color(0xFF1FBF95),
        unselectedItemColor: Colors.grey,
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.ondemand_video), label: 'Watch'),
          BottomNavigationBarItem(icon: Icon(Icons.download_done), label: 'Saved'),
        ],
      ),
    );
  }
}
