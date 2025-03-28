import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized(); // ✅ For future async setups (e.g. permissions, shared prefs)
  runApp(const VideoDownloaderApp());
}

class VideoDownloaderApp extends StatelessWidget {
  const VideoDownloaderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Video Downloader',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        scaffoldBackgroundColor: Colors.white,
        textSelectionTheme: const TextSelectionThemeData(
          selectionColor: Color(0xFFB3D4FF),
          selectionHandleColor: Color(0xFF1E65FF),
          cursorColor: Color(0xFF1E65FF),
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.black87,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
