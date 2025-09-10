import 'package:flutter/material.dart';
import 'package:xml_converter/config/app_config.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get available width and height for responsive sizing
    final Size screenSize = MediaQuery.of(context).size;

    // Calculate responsive sizes
    final double avatarSize = screenSize.width * 0.15; // 15% of screen width
    final double minAvatarSize = 120.0;
    final double maxAvatarSize = 220.0;
    final double responsiveAvatarSize =
        avatarSize.clamp(minAvatarSize, maxAvatarSize);

    // Calculate responsive font sizes
    final double headlineSize = (screenSize.width * 0.025).clamp(24.0, 36.0);
    final double subtitleSize = (screenSize.width * 0.012).clamp(14.0, 20.0);

    return Container(
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Responsive circle avatar
            Container(
              width: responsiveAvatarSize,
              height: responsiveAvatarSize,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(height: screenSize.height * 0.03), // Responsive spacing
            Text(
              AppConfig.welcomeText,
              style: TextStyle(
                fontSize: headlineSize,
                color: const Color(0xFF333333),
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: screenSize.height * 0.01), // Responsive spacing
            Text(
              AppConfig.teamText,
              style: TextStyle(
                fontSize: subtitleSize,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
