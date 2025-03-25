import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const VideoDownloaderApp());
}

class VideoDownloaderApp extends StatelessWidget {
  const VideoDownloaderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Video Downloader',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        textSelectionTheme: const TextSelectionThemeData(
          selectionColor: Color(0xFFB3D4FF),
          selectionHandleColor: Color(0xFF1E65FF),
          cursorColor: Color(0xFF1E65FF),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
