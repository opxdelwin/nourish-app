import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutUsView extends StatelessWidget {
  const AboutUsView({super.key});

  Future<void> _launchSocial(String urlString) async {
    final Uri url = Uri.parse(urlString);
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final paddingValue = screenWidth > 600 ? 32.0 : 24.0;
    final contentWidth = screenWidth > 600 ? 500.0 : double.infinity;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/profile');
        }
      },
      child: Scaffold(
        backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : Colors.black,
          ),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/profile');
            }
          },
        ),
        title: Text(
          'About GDG KIIT',
          style: TextStyle(
            fontFamily: 'Chivo',
            fontWeight: FontWeight.w400,
            fontSize: 24,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SizedBox(
            width: contentWidth,
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: paddingValue,
                vertical: 16.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),

                  Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDark ? Colors.grey[900] : Colors.white,
                      border: Border.all(
                        color: const Color(0xffFFC009),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                      image: const DecorationImage(
                        image: AssetImage('assets/images/gdg_logo.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: FaIcon(
                          FontAwesomeIcons.linkedin,
                          color: isDark ? Colors.white : Colors.black,
                          size: 26,
                        ),
                        onPressed: () => _launchSocial('https://www.linkedin.com/company/gdgkiit/'),
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        icon: FaIcon(
                          FontAwesomeIcons.instagram,
                          color: isDark ? Colors.white : Colors.black,
                          size: 26,
                        ),
                        onPressed: () => _launchSocial('https://www.instagram.com/_gdgkiit_/'),
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        icon: FaIcon(
                          FontAwesomeIcons.github,
                          color: isDark ? Colors.white : Colors.black,
                          size: 26,
                        ),
                        onPressed: () => _launchSocial('https://github.com/GDSC-KIIT'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Google Developer Groups KIIT is a technical club focused on building a community of student developers interested in solving real-world problems.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Chivo',
                      fontWeight: FontWeight.w300,
                      fontSize: 16,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'We host various workshops and hackathons. We also host flagship events from Google such as Android Study Jams, 30 days of Google Cloud, ExploreML etc.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Chivo',
                      fontWeight: FontWeight.w300,
                      fontSize: 16,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Our goal is to build an inclusive community of students who want to learn about tech and grow together.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Chivo',
                      fontWeight: FontWeight.w300,
                      fontSize: 16,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    ),);
  }
}
