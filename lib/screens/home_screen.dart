// home_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../widgets/custom_drawer.dart';
import '../widgets/download_quality_modal.dart';
import 'package:flutter/services.dart';
import '../services/video_download_service.dart';





class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

// 🆕 Add at the top inside _HomeScreenState
bool hasFetched = false;
String videoTitle = '';
String videoSize = '';
String thumbnailUrl = '';
bool isLoading = false;
bool _isDisposed = false;
bool isDownloading = false;




class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  String selectedPlatform = 'YouTube';
  final TextEditingController linkController = TextEditingController();
  final FocusNode _linkFocusNode = FocusNode();

  BottomNavigationBarItem _buildNavBarItem(String iconPath, String label, int index) {
    return BottomNavigationBarItem(
      icon: TweenAnimationBuilder<double>(
        tween: Tween<double>(
          begin: 1.0,
          end: _currentIndex == index ? 1.2 : 1.0,
        ),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutBack,
        builder: (context, scale, child) {
          return Column(
            children: [
              Transform.scale(
                scale: scale,
                child: Image.asset(
                  iconPath,
                  width: 28,
                  height: 28,
                  color: _currentIndex == index
                      ? const Color(0xFF1E65FF)
                      : Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 4,
                width: _currentIndex == index ? 20 : 0,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E65FF),
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
            ],
          );
        },
      ),
      label: label,
    );
  }


  String extractYouTubeVideoId(String url) {
    try {
      Uri uri = Uri.parse(url);

      // https://youtu.be/<id>?si=...
      if (uri.host.contains("youtu.be") && uri.pathSegments.isNotEmpty) {
        return uri.pathSegments.first;
      }

      // https://www.youtube.com/watch?v=<id>&ab_channel=...
      if (uri.queryParameters.containsKey("v")) {
        return uri.queryParameters["v"]!;
      }
    } catch (e) {
      print("Error parsing URL: $e");
    }

    return "";
  }




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

  LinearGradient _getPlatformGradient(String platform) {
    switch (platform) {
      case 'YouTube':
        return const LinearGradient(
          colors: [Color(0xFFFF5252), Color(0xFFD32F2F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'Facebook':
        return const LinearGradient(
          colors: [Color(0xFF1877F2), Color(0xFF0D47A1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'TikTok':
        return const LinearGradient(
          colors: [Color(0xFF25F4EE), Color(0xFFFE2C55)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      default:
        return const LinearGradient(
          colors: [Color(0xFFF4F4F4), Color(0xFFCDCDCD)],
        );
    }
  }


  String detectPlatform(String url) {
    url = url.toLowerCase();
    if (url.contains('youtube.com') || url.contains('youtu.be')) {
      return 'YouTube';
    } else if (url.contains('facebook.com') || url.contains('fb.watch')) {
      return 'Facebook';
    } else if (url.contains('tiktok.com')) {
      return 'TikTok';
    } else {
      return 'Unknown';
    }
  }




  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = 0;

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
  }

  void _changeGradient() {
    if (!_isDisposed) {
      _setupGradientAnimation();
    }
  }


  @override
  void dispose() {
    _isDisposed = true; // mark disposed
    _gradientController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      drawerEnableOpenDragGesture: false,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(200),
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
                      bottomLeft: Radius.circular(34),
                      bottomRight: Radius.circular(34),
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.only(top: 40, left: 18, right: 18, bottom: 18),
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
                          Scaffold.of(context).openDrawer(); // 👈 Already correct
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

      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 30, left: 18, right: 18, bottom: 18),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.only(top: 10, left: 18, right: 18, bottom: 18),
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
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeInOut,
                              width: 74,
                              height: 74,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: (hasFetched && isSelected)
                                    ? _getPlatformGradient(platform['name']!)
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
                    focusNode: _linkFocusNode, // Assign the focus node
                    keyboardType: TextInputType.url,
                    enableSuggestions: false,
                    autocorrect: false,
                    style: const TextStyle(
                      color: Color(0xFF0032A1), // 💙 Text typed color
                      fontWeight: FontWeight.bold,
                    ),


                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 25),
                      hintText: 'Paste Terabox URL',
                      hintStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: const Color(0xFFF2F8FF),
                      prefixIcon: const Icon(Icons.link, color: Colors.blue),
                      suffixIcon: IconButton(
                          icon: const Icon(Icons.paste, color: Colors.blue),


                          onPressed: () async {
                            final data = await Clipboard.getData('text/plain');
                            final pastedText = data?.text?.trim() ?? "";

                            if (pastedText.isNotEmpty) {
                              setState(() {
                                linkController.text = pastedText;
                                selectedPlatform = detectPlatform(pastedText);
                                _scaleController
                                  ..reset()
                                  ..forward();
                              });


                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Clipboard is empty.")),
                              );
                            }
                          }
                      ),


                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(17),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) {
                      final detected = detectPlatform(value);
                      if (detected != selectedPlatform && detected != 'Unknown') {
                        setState(() {
                          selectedPlatform = detected;
                          _scaleController
                            ..reset()
                            ..forward();
                        });
                      }
                    },
                  ),


                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        if (isLoading) return; // ✅ prevent multiple taps manually

                        String link = linkController.text.trim();
                        if (!link.startsWith("http")) {
                          link = "https://$link";
                        }

                        setState(() {
                          isLoading = true;
                        });

                        String videoId = extractYouTubeVideoId(link);
                        if (videoId.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Invalid YouTube link.")),
                          );
                          setState(() => isLoading = false);
                          return;
                        }

                        String finalUrl = "https://www.youtube.com/watch?v=$videoId";
                        print("🔗 Fetching for: $finalUrl");

                        try {
                          final details = await VideoDownloadService.fetchYouTubeDetails(finalUrl);
                          setState(() {
                            hasFetched = true;
                            videoTitle = details['title'] ?? "Unknown Title";
                            videoSize = details['size'] ?? "Unknown Size";
                            thumbnailUrl = details['thumbnail'] ?? "";
                          });
                        } catch (e) {
                          print("❌ Error: $e");
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Failed to fetch video details.")),
                          );
                        }

                        setState(() => isLoading = false);
                      },
                      icon: isLoading
                          ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                          : const Icon(Icons.search_rounded, color: Colors.white),
                      label: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Text(
                          isLoading ? "Fetching..." : "Analyze Video",
                          key: ValueKey(isLoading),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E65FF),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                  ),




                  const SizedBox(height: 20),

                  //  Result Preview Box
                  if (hasFetched)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F9FF),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFF1E65FF)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              thumbnailUrl,
                              width: double.infinity,
                              height: 180, // full width, better aspect ratio
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 180,
                                  color: Colors.grey.shade200,
                                  child: const Icon(Icons.broken_image, color: Colors.grey),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            videoTitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Size: $videoSize",
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),



                  const SizedBox(height: 16),
                  Row(
                    children: [
                      // ▶️ Play Button
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // TODO: Play logic
                          },
                          icon: const Icon(Icons.play_arrow, color: Colors.white),
                          label: const Text(
                            "Play",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.resolveWith<Color>(
                                  (states) {
                                if (states.contains(MaterialState.pressed)) {
                                  return const Color(0xFF1539AA); // Darker blue when pressed
                                }
                                return const Color(0xFF1E65FF); // Default
                              },
                            ),
                            overlayColor: MaterialStateProperty.all(Colors.white24),
                            padding: MaterialStateProperty.resolveWith<EdgeInsets>(
                                  (states) {
                                return states.contains(MaterialState.pressed)
                                    ? const EdgeInsets.symmetric(vertical: 12)
                                    : const EdgeInsets.symmetric(vertical: 14);
                              },
                            ),
                            elevation: MaterialStateProperty.resolveWith<double>(
                                  (states) => states.contains(MaterialState.pressed) ? 2 : 6,
                            ),
                            shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                            ),
                          ),
                        ),
                      ),


                      const SizedBox(width: 10),
                      // ⬇ Download Button
                      // ⬇ Download Button
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            String link = linkController.text.trim();
                            if (!link.startsWith("http")) {
                              link = "https://$link";
                            }

                            setState(() {
                              isDownloading = true;
                            });

                            final videoId = extractYouTubeVideoId(link);
                            if (videoId.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Invalid YouTube link.")),
                              );
                              setState(() {
                                isDownloading = false;
                              });
                              return;
                            }

                            final finalUrl = "https://www.youtube.com/watch?v=$videoId";

                            try {
                              final qualities = await VideoDownloadService.getAvailableQualities(finalUrl);

                              if (qualities.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("No downloadable qualities found.")),
                                );
                                setState(() {
                                  isDownloading = false;
                                });
                                return;
                              }

                              setState(() {
                                isDownloading = false;
                              });

                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                                ),
                                builder: (context) => DownloadQualityModal(
                                  qualities: qualities,
                                  onQualitySelected: (selected) async {
                                    final selectedUrl = selected['url']!;
                                    final label = selected['label']!;
                                    final size = selected['size']!;

                                    Navigator.pop(context);

                                    print("⬇ Downloading $label ($size)");
                                    print("▶️ URL: $selectedUrl");

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text("Download started: $label")),
                                    );
                                  },
                                ),
                              );
                            } catch (e) {
                              print("❌ Error fetching qualities: $e");
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Failed to fetch video qualities.")),
                              );
                              setState(() {
                                isDownloading = false;
                              });
                            }
                          },
                          icon: isDownloading
                              ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                              : const Icon(Icons.download_rounded, color: Colors.white),
                          label: isDownloading
                              ? const Text(
                            "Loading...",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          )
                              : const Text(
                            "Download",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.resolveWith<Color>(
                                  (states) => states.contains(MaterialState.pressed)
                                  ? const Color(0xFF1539AA)
                                  : const Color(0xFF1E65FF),
                            ),
                            overlayColor: MaterialStateProperty.all(Colors.white24),
                            padding: MaterialStateProperty.all(
                              const EdgeInsets.symmetric(vertical: 14),
                            ),
                            elevation: MaterialStateProperty.resolveWith<double>(
                                  (states) => states.contains(MaterialState.pressed) ? 2 : 6,
                            ),
                            shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                            ),
                          ),
                        ),
                      ),



                      const SizedBox(width: 10),

                      // 📋 Copy Button (unchanged)
                      ElevatedButton(
                        onPressed: () {
                          // TODO: Copy to clipboard logic
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E65FF),
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(12),
                        ),
                        child: const Icon(Icons.copy, color: Colors.white),
                      ),
                    ],
                  ),




                ],
              ),
            ),

          ],
        ),
      ),


      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(22),
            topRight: Radius.circular(22),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(22),
            topRight: Radius.circular(22),
          ),
          child: BottomNavigationBar(
            selectedItemColor: const Color(0xFF1E65FF),
            unselectedItemColor: Colors.grey,
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            type: BottomNavigationBarType.fixed,
            items: [
              _buildNavBarItem('assets/images/home.png', 'Home', 0),
              _buildNavBarItem('assets/images/play-circle.png', 'Watch', 1),
              _buildNavBarItem('assets/images/cloud-download-alt.png', 'Saved', 2),
            ],
          ),
        ),
      ),




    );
  }
}
