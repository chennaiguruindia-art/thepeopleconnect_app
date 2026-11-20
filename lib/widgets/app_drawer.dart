import 'package:flutter/material.dart';
import '../utils/app_translations.dart';

class AppDrawerColors {
  static const navy = Color(0xFF0B1F3A);
  static const darkNavy = Color(0xFF071527);
  static const orange = Color(0xFFEA580C);
  static const saffron = Color(0xFFFF9933);
  static const green = Color(0xFF16A34A);
  static const skyBlue = Color(0xFF0284C7);
  static const purple = Color(0xFF7C3AED);
  static const lightBg = Color(0xFFF8FAFC);
  static const grey = Color(0xFF64748B);
  static const borderLight = Color(0xFFE2E8F0);
}

class AppDrawer extends StatelessWidget {
  final String currentRoute; // 'home', 'submit', 'track', 'about', 'updates', 'contact'

  const AppDrawer({
    super.key,
    this.currentRoute = 'home',
  });

  void _navigateToRoute(BuildContext context, String routeName, String routeKey) {
    Navigator.pop(context); // Close drawer first
    if (currentRoute == routeKey) {
      return; // Already on this screen
    }
    if (routeKey == 'home') {
      Navigator.popUntil(context, (route) => route.isFirst);
    } else {
      if (currentRoute == 'home') {
        Navigator.pushNamed(context, routeName);
      } else {
        Navigator.pushReplacementNamed(context, routeName);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTa = AppTranslations.isTamil;

    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            // 1. TRICOLOR TOP STRIP (Indian National Accent)
            SizedBox(
              height: 4,
              child: Row(
                children: [
                  Expanded(child: Container(color: AppDrawerColors.saffron)),
                  Expanded(child: Container(color: Colors.white)),
                  Expanded(child: Container(color: AppDrawerColors.green)),
                ],
              ),
            ),

            // 2. PREMIUM HEADER (Navy Gradient + Logo + Voice + Helpline + Language Switcher)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppDrawerColors.darkNavy, AppDrawerColors.navy],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row: Logo + App Titles + Close Button
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Logo Tile
                      Container(
                        height: 50,
                        width: 50,
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppDrawerColors.saffron.withValues(alpha: 0.5), width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.25),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            'assets/images/logo/logo.png',
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Image.asset(
                                'assets/images/logo.png',
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(Icons.how_to_vote, color: AppDrawerColors.orange, size: 28);
                                },
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Platform Name & Tagline
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'THE PEOPLE CONNECT',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 13.5,
                                letterSpacing: 0.4,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              AppTranslations.tr('voice_tagline'),
                              style: const TextStyle(
                                color: AppDrawerColors.saffron,
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.white24),
                              ),
                              child: Text(
                                isTa ? '🏛️ தமிழ்நாடு மக்கள் குறைதீர்ப்பு தளம்' : '🏛️ Tamil Nadu Citizen Grievance Portal',
                                style: const TextStyle(fontSize: 9.5, color: Colors.white70, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Close Drawer Button
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: Colors.white70, size: 20),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Quick Helpline & Language Switcher Bar
                  Row(
                    children: [
                      // Helpline Pill
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.white12),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.phone_in_talk_rounded, color: AppDrawerColors.saffron, size: 14),
                              SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  '9384995222',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Language Switcher Mini-Button
                      InkWell(
                        onTap: () {
                          final newLang = isTa ? 'en' : 'ta';
                          AppTranslations.setLanguage(newLang);
                        },
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppDrawerColors.saffron.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppDrawerColors.saffron.withValues(alpha: 0.5)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.language_rounded, color: AppDrawerColors.saffron, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                isTa ? 'English' : 'தமிழ்',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 3. STRUCTURED NAVIGATION LIST (Grouped with Modern Headers)
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                children: [
                  // SECTION A: CORE CITIZEN SERVICES
                  _sectionHeader(isTa ? 'மக்கள் சேவைகள்' : 'Grievance Services'),

                  _drawerItem(
                    icon: Icons.home_rounded,
                    iconColor: const Color(0xFF2563EB),
                    iconBgColor: const Color(0xFFEFF6FF),
                    title: AppTranslations.tr('nav_home'),
                    subtitle: isTa ? 'முகப்பு & உடனடி தகவல்கள்' : 'Dashboard & Overview',
                    isActive: currentRoute == 'home',
                    onTap: () => _navigateToRoute(context, '/', 'home'),
                  ),

                  _drawerItem(
                    icon: Icons.edit_note_rounded,
                    iconColor: const Color(0xFFEA580C),
                    iconBgColor: const Color(0xFFFFF7ED),
                    title: AppTranslations.tr('nav_submit'),
                    subtitle: isTa ? 'உங்கள் குறையை நேரடியாகப் பதிவு செய்க' : 'Register a new petition',
                    badge: isTa ? 'புதியது' : 'New',
                    isActive: currentRoute == 'submit',
                    onTap: () => _navigateToRoute(context, '/submit', 'submit'),
                  ),

                  _drawerItem(
                    icon: Icons.track_changes_rounded,
                    iconColor: const Color(0xFF0284C7),
                    iconBgColor: const Color(0xFFF0F9FF),
                    title: AppTranslations.tr('nav_track'),
                    subtitle: isTa ? 'மனு எண் மூலம் நிலவரம் அறிதல்' : 'Check real-time resolution status',
                    isActive: currentRoute == 'track',
                    onTap: () => _navigateToRoute(context, '/track', 'track'),
                  ),

                  const SizedBox(height: 8),
                  const Divider(height: 1, color: AppDrawerColors.borderLight),
                  const SizedBox(height: 8),

                  // SECTION B: MEDIA & INFORMATION
                  _sectionHeader(isTa ? 'தகவல்கள் & அறிவிப்புகள்' : 'Updates & Directory'),

                  _drawerItem(
                    icon: Icons.newspaper_rounded,
                    iconColor: const Color(0xFF7C3AED),
                    iconBgColor: const Color(0xFFF5F3FF),
                    title: AppTranslations.tr('nav_news'),
                    subtitle: isTa ? 'அரசு நலத்திட்டங்கள் & எச்சரிக்கைகள்' : 'Latest news & civic alerts',
                    isActive: currentRoute == 'updates',
                    onTap: () => _navigateToRoute(context, '/updates', 'updates'),
                  ),

                  _drawerItem(
                    icon: Icons.account_balance_rounded,
                    iconColor: const Color(0xFFEA580C),
                    iconBgColor: const Color(0xFFFFF7ED),
                    title: AppTranslations.tr('nav_schemes'),
                    subtitle: isTa ? 'மத்திய & மாநில அரசு நலத்திட்டங்கள்' : 'Central & State Government Schemes',
                    badge: isTa ? 'திட்டம்' : 'Schemes',
                    isActive: currentRoute == 'schemes',
                    onTap: () => _navigateToRoute(context, '/schemes', 'schemes'),
                  ),

                  _drawerItem(
                    icon: Icons.info_outline_rounded,
                    iconColor: const Color(0xFF0D9488),
                    iconBgColor: const Color(0xFFF0FDFA),
                    title: AppTranslations.tr('nav_about'),
                    subtitle: isTa ? 'தளத்தின் நோக்கம் & செயல்பாடுகள்' : 'Vision & platform objectives',
                    isActive: currentRoute == 'about',
                    onTap: () => _navigateToRoute(context, '/about', 'about'),
                  ),

                  const SizedBox(height: 8),
                  const Divider(height: 1, color: AppDrawerColors.borderLight),
                  const SizedBox(height: 8),

                  // SECTION C: SUPPORT
                  _sectionHeader(isTa ? 'உதவி மையம் & தொடர்பு' : 'Help & Support'),

                  _drawerItem(
                    icon: Icons.headset_mic_rounded,
                    iconColor: const Color(0xFF16A34A),
                    iconBgColor: const Color(0xFFF0FDF4),
                    title: AppTranslations.tr('nav_contact'),
                    subtitle: isTa ? 'அலுவலக தொடர்பு & வாட்ஸ்அப்' : 'Official contact & helpdesk',
                    isActive: currentRoute == 'contact',
                    onTap: () => _navigateToRoute(context, '/contact', 'contact'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Section Header Widget
  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: Color(0xFF94A3B8),
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  // Individual Drawer Navigation Tile
  Widget _drawerItem({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    String? subtitle,
    String? badge,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFFFF7ED) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive ? const Color(0xFFFDBA74) : Colors.transparent,
          width: 1.2,
        ),
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        leading: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              height: 38,
              width: 38,
              decoration: BoxDecoration(
                color: isActive ? AppDrawerColors.orange : iconBgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: isActive ? Colors.white : iconColor,
                size: 20,
              ),
            ),
          ],
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isActive ? FontWeight.w800 : FontWeight.w700,
                  color: isActive ? AppDrawerColors.orange : const Color(0xFF1E293B),
                ),
              ),
            ),
            if (badge != null)
              Container(
                margin: const EdgeInsets.only(left: 6),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFEA580C),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10.5,
                  color: isActive ? const Color(0xFFC2410C) : const Color(0xFF64748B),
                ),
              )
            : null,
        trailing: Icon(
          Icons.chevron_right_rounded,
          color: isActive ? AppDrawerColors.orange : const Color(0xFFCBD5E1),
          size: 18,
        ),
        dense: true,
        onTap: onTap,
      ),
    );
  }
}
