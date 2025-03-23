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
                      const Icon(Icons.workspace_premium_outlined, color: Colors.white),
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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFDCE8FF),
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: platforms.map((platform) {
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
                        scale: isSelected ? _scaleAnimation : const AlwaysStoppedAnimation(1.0),
                        child: Column(
                          children: [
                            Container(
                              width: 74,
                              height: 74,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: isSelected
                                    ? const LinearGradient(
                                  colors: [Color(0xFF3BE4F6), Color(0xFF1E65FF)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                                    : const LinearGradient(
                                  colors: [Color(0xFFF4F4F4), Color(0xFFCDCDCD)],
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
                              padding: const EdgeInsets.all(8),
                              child: CircleAvatar(
                                backgroundColor: Colors.white,
                                backgroundImage: AssetImage(platform['icon']!),
                                radius: 26,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              platform['name']!,
                              style: TextStyle(
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                color: isSelected ? Colors.blueAccent : Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),


            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
              decoration: BoxDecoration(
                color: Color(0xFFDCE8FF),
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
                ],
              ),



              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: linkController,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 25),
                      hintText: 'Paste Terabox URL',
                      hintStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: const Color(0xFFF2F8FF),
                      prefixIcon: const Icon(Icons.link, color: Colors.blue),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.paste, color: Colors.blue),
                        onPressed: () {
                          // TODO: Implement paste logic
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(17),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: Fetch Details
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E65FF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 19),
                      ),
                      child: const Text(
                        "Fetch Details",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white, // 🟢 This makes text white
                        ),
                      ),                    ),
                  ),
                  const SizedBox(height: 20),

                  // 📦 Result Preview Box
                  Container(
                    height: 230, // <-- 🆕 Set the height you want
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FF),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFF1E65FF)),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            '',
                            height: 64,
                            width: 64,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Mission Impossible 7 - Dead Reckoning Part One",
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "Size: 1.24 GB",
                                style: TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.play_arrow,
                            color: Colors.white,
                          ),
                          label: const Text(
                            "Play",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),



                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E65FF),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.download_rounded,
                            color: Colors.white,
                          ),
                          label: const Text(
                            "Download",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E65FF),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {
                          // Copy to clipboard logic
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEBF3FF),
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(12),
                        ),
                        child: const Icon(Icons.copy, color: Colors.black87),
                      ),
                    ],
                  ),
                ],
              ),
            ),

          ],
        ),
      ),

        bottomNavigationBar: BottomNavigationBar(
          selectedItemColor: const Color(0xFF1E65FF),
          unselectedItemColor: Colors.grey,
          currentIndex: _currentIndex.clamp(0, 2), // 🛡️ clamp ensures index is valid
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: [
            BottomNavigationBarItem(
              icon: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: _currentIndex == 0
                      ? [
                    BoxShadow(
                      color: Colors.blueAccent.withOpacity(0.4),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ]
                      : [],
                ),
                child: const Icon(Icons.home),
              ),
              label: 'Home',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.ondemand_video),
              label: 'Watch',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.download_done),
              label: 'Saved',
            ),
          ],
        )



    );
  }
}
