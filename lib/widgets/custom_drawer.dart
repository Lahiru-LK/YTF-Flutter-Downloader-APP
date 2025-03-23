import 'package:flutter/material.dart';

class CustomDrawer extends StatelessWidget {
  final Animation<Color?> color1;
  final Animation<Color?> color2;
  final AnimationController gradientController;

  const CustomDrawer({
    super.key,
    required this.color1,
    required this.color2,
    required this.gradientController,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          AnimatedBuilder(
            animation: gradientController,
            builder: (context, child) {
              return DrawerHeader(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      color1.value ?? const Color(0xFF3B82F6),
                      color2.value ?? const Color(0xFF60A5FA),
                    ],
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: const [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.download_rounded,
                          color: Color(0xFF1E65FF), size: 30),
                    ),
                    SizedBox(width: 14),
                    Flexible(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "YTF Downloader",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              letterSpacing: 0.3,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Direct Terabox Video Downloader",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 4),
          _buildDrawerItem(context, Icons.home_rounded, "Home"),
          _buildDrawerItem(context, Icons.info_outline, "About us"),
          _buildDrawerItem(context, Icons.contact_mail_outlined, "Contact Us"),
          _buildDrawerItem(context, Icons.star_border, "Give Star"),
          _buildDrawerItem(context, Icons.share_outlined, "Share App"),
          _buildDrawerItem(context, Icons.apps_rounded, "More Apps"),
          const Divider(),
          _buildDrawerItem(context, Icons.privacy_tip_outlined, "Privacy Policy"),
          _buildDrawerItem(context, Icons.flag_outlined, "Terms and Conditions"),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: Colors.black87),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14.5,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$title tapped')),
        );
      },
    );
  }
}
