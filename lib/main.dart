import 'package:flutter/material.dart';
import 'screens/about_screen.dart';
import 'screens/complaints/submit_complaint_screen.dart';
import 'screens/complaints/track_complaint_screen.dart';
import 'screens/contact_screen.dart';
import 'screens/schemes_screen.dart';
import 'screens/updates_screen.dart';
import 'utils/app_translations.dart';
import 'widgets/app_drawer.dart';
import 'widgets/app_header.dart';

void main() {
  runApp(const PeopleConnectApp());
}

// -------------------------------------------------------------
// APP COLORS & THEME (MATCHING LARAVEL PROJECT PALETTE)
// -------------------------------------------------------------
class AppColors {
  static const navy = Color(0xFF0B1F3A);
  static const darkNavy = Color(0xFF071527);
  static const orange = Color(0xFFEA580C);
  static const lightOrange = Color(0xFFFFF0DF);
  static const saffron = Color(0xFFFF9933);
  static const tricolorGreen = Color(0xFF138808);
  static const green = Color(0xFF16A34A);
  static const blue = Color(0xFF2563EB);
  static const skyBlue = Color(0xFF0284C7);
  static const cyan = Color(0xFF0891B2);
  static const amber = Color(0xFFD97706);
  static const purple = Color(0xFF7C3AED);
  static const lightBg = Color(0xFFF8FAFC);
  static const grey = Color(0xFF64748B);
  static const textDark = Color(0xFF0F172A);
  static const borderLight = Color(0xFFE2E8F0);
}

// -------------------------------------------------------------
// ROOT APPLICATION
// -------------------------------------------------------------
class PeopleConnectApp extends StatelessWidget {
  const PeopleConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: appLanguage,
      builder: (context, lang, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'The People Connect - குரலற்ற மக்களின் குரல்',
          theme: ThemeData(
            useMaterial3: true,
            scaffoldBackgroundColor: Colors.white,
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.orange,
              primary: AppColors.navy,
              secondary: AppColors.orange,
              primaryContainer: Colors.white,
              secondaryContainer: Colors.white,
              tertiaryContainer: Colors.white,
              surface: Colors.white,
              onPrimaryContainer: AppColors.navy,
              onSecondaryContainer: AppColors.orange,
            ),
            fontFamily: 'Roboto',
            // Disable any stray Material3 color bleed
            cardColor: Colors.white,
            dialogTheme: const DialogThemeData(backgroundColor: Colors.white),
          ),
          initialRoute: '/',
          routes: {
            '/': (context) => const CitizenHomeScreen(),
            '/submit': (context) => const SubmitComplaintScreen(),
            '/track': (context) => const TrackComplaintScreen(),
            '/about': (context) => const AboutScreen(),
            '/schemes': (context) => const SchemesScreen(),
            '/updates': (context) => const UpdatesScreen(),
            '/contact': (context) => const ContactScreen(),
          },
        );
      },
    );
  }
}

// -------------------------------------------------------------
// CITIZEN HOME SCREEN
// -------------------------------------------------------------
class CitizenHomeScreen extends StatefulWidget {
  const CitizenHomeScreen({super.key});

  @override
  State<CitizenHomeScreen> createState() => _CitizenHomeScreenState();
}

class _CitizenHomeScreenState extends State<CitizenHomeScreen> {
  int _selectedIndex = 0;
  final TextEditingController _trackController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void dispose() {
    _trackController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.navy,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: appLanguage,
      builder: (context, currentLang, _) {
        final isTa = AppTranslations.isTamil;
        return Scaffold(
          key: _scaffoldKey,
          drawer: const AppDrawer(currentRoute: 'home'),
          body: SafeArea(
            child: Column(
              children: [
                // 1. REUSABLE APP HEADER (Tricolor + Notice + Language Switcher + Navbar)
                AppHeader(
                  showBackButton: false,
                  onMenuPressed: () {
                    _scaffoldKey.currentState?.openDrawer();
                  },
                ),

                // 2. Scrollable Main Content
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Section 1: Hero Banner (Main Voice, Headline & 2 CTAs)
                        _buildHeroSection(),

                        // Section 2: Quick Track Complaint Banner (Placed immediately below Hero for instant citizen tracking)
                        _buildTrackComplaintBar(),

                        // Section 3: Grievance Categories (6 Clean Core Civic Categories)
                        _buildCategoriesSection(),

                        // Section 4: 4-Step Transparent Grievance Process
                        _buildProcessStepsSection(),

                        // Section 5: Real-Time District Impact Metrics
                        _buildDistrictMetricsSection(),

                        // Section 6: Latest Civic News & Alerts
                        _buildCivicNewsSection(),

                        // Section 7: Security & Official Helpline
                        _buildSecurityBanner(),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Modern Civic Bottom Navigation Bar (White, Elevated, Non-wrapping labels)
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: const Border(
                top: BorderSide(color: Color(0xFFE2E8F0), width: 1.2),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 10,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: SizedBox(
                height: 60,
                child: Row(
                  children: [
                    _buildNavItem(0, Icons.home_rounded, isTa ? 'முகப்பு' : 'Home'),
                    _buildNavItem(1, Icons.edit_note_rounded, isTa ? 'மனு பதிவு' : 'Register'),
                    _buildNavItem(2, Icons.search_rounded, isTa ? 'கண்காணிப்பு' : 'Track'),
                    _buildNavItem(3, Icons.info_outline_rounded, isTa ? 'அறிமுகம்' : 'About'),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _selectedIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () {
          if (index == 0) {
            setState(() => _selectedIndex = 0);
            return;
          }
          setState(() => _selectedIndex = index);

          Widget targetScreen;
          if (index == 1) {
            targetScreen = const SubmitComplaintScreen();
          } else if (index == 2) {
            targetScreen = const TrackComplaintScreen();
          } else {
            targetScreen = const AboutScreen();
          }

          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => targetScreen),
          ).then((_) {
            // When popping back to Home, always reset selection to Home (index 0)
            if (mounted) {
              setState(() => _selectedIndex = 0);
            }
          });
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFFFF0DF) : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                size: 22,
                color: isSelected ? AppColors.orange : AppColors.grey,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? AppColors.orange : AppColors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -----------------------------------------------------------
  // A. HERO BANNER SECTION (Laravel Mobile Hero with Banner Image)
  // -----------------------------------------------------------
  Widget _buildHeroSection() {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner photo container with floating badge
          Stack(
            children: [
              Container(
                width: double.infinity,
                height: 215,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                ),
                child: Image.asset(
                  'assets/images/banner.jpg',
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      'assets/images/banner/banner.jpg',
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          'assets/images/banner/banner1.png',
                          fit: BoxFit.cover,
                          alignment: Alignment.center,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: AppColors.navy,
                              child: const Center(
                                child: Icon(Icons.people_alt, color: Colors.white54, size: 60),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),

              // Bottom Curved Wave Effect
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 18,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(22),
                      topRight: Radius.circular(22),
                    ),
                  ),
                ),
              ),

              // Floating Badge: "மக்களோடு நாம்"
              Positioned(
                bottom: 24,
                right: 14,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.75),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.circle, color: AppColors.green, size: 8),
                      const SizedBox(width: 6),
                      Text(
                        AppTranslations.tr('hero_with_people'),
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

          // Hero Content Below Image
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hook badge pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFFCD34D)),
                  ),
                  child: Text(
                    AppTranslations.tr('hero_badge'),
                    style: const TextStyle(
                      color: AppColors.navy,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Main Heading + Logo Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left: Main Heading Text
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 27,
                            fontWeight: FontWeight.w900,
                            height: 1.25,
                            fontFamily: 'Roboto',
                          ),
                          children: [
                            TextSpan(
                              text: '${AppTranslations.tr('hero_line_1')}\n${AppTranslations.tr('hero_line_2')}\n',
                              style: const TextStyle(color: AppColors.navy),
                            ),
                            TextSpan(
                              text: AppTranslations.tr('hero_line_3'),
                              style: const TextStyle(color: AppColors.orange),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Right: Logo Image (rose mark spot)
                    Container(
                      width: 100,
                      height: 110,
                      margin: const EdgeInsets.only(left: 10, top: 2),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.orange.withValues(alpha: 0.4),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset(
                          'assets/images/logo/logo.png',
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.asset(
                              'assets/images/logo.png',
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.how_to_vote,
                                  color: AppColors.orange,
                                  size: 48,
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Quote bar with left border
                Container(
                  padding: const EdgeInsets.only(left: 12, top: 4, bottom: 4),
                  decoration: const BoxDecoration(
                    border: Border(
                      left: BorderSide(color: AppColors.saffron, width: 4),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppTranslations.tr('hero_quote'),
                        style: const TextStyle(
                          color: AppColors.textDark,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Trust Highlights
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          Text('✓ ${AppTranslations.tr('badge_transparent')}', style: const TextStyle(fontSize: 11, color: AppColors.grey)),
                          const Text('•', style: TextStyle(fontSize: 11, color: AppColors.grey)),
                          Text('✓ ${AppTranslations.tr('badge_tracking')}', style: const TextStyle(fontSize: 11, color: AppColors.grey)),
                          const Text('•', style: TextStyle(fontSize: 11, color: AppColors.grey)),
                          Text('✓ ${AppTranslations.tr('badge_districts')}', style: const TextStyle(fontSize: 11, color: AppColors.grey)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // 2 Big Call-to-action buttons
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SubmitComplaintScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.edit_note, size: 20),
                    label: Text(
                      AppTranslations.tr('btn_register_grievance'),
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.orange,
                      foregroundColor: Colors.white,
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TrackComplaintScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.search, size: 18),
                    label: Text(
                      AppTranslations.tr('btn_track_status'),
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.navy,
                      side: const BorderSide(color: AppColors.navy, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // -----------------------------------------------------------
  // B. REAL-TIME DISTRICT GRIEVANCE METRICS (6 Stat Cards)
  // -----------------------------------------------------------
  Widget _buildDistrictMetricsSection() {
    return Container(
      color: AppColors.lightBg,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 26),
      child: Column(
        children: [
          Text(
            AppTranslations.tr('stats_tag'),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppColors.blue,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 6),

          Text(
            AppTranslations.tr('stats_title'),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: AppColors.navy,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 4),

          Text(
            AppTranslations.tr('stats_subtitle'),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, color: AppColors.grey),
          ),
          const SizedBox(height: 18),

          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.45,
            children: [
              _metricCard('0', AppTranslations.tr('stat_total'), AppColors.orange),
              _metricCard('0', AppTranslations.tr('stat_resolved'), AppColors.green),
              _metricCard('0', AppTranslations.tr('stat_in_progress'), AppColors.blue),
              _metricCard('0', AppTranslations.tr('stat_referred'), AppColors.cyan),
              _metricCard('0', AppTranslations.tr('stat_taluks'), AppColors.amber),
              _metricCard('0', AppTranslations.tr('stat_villages'), AppColors.purple),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metricCard(String number, String label, Color topBorderColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 3,
            width: 32,
            decoration: BoxDecoration(
              color: topBorderColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Spacer(),
          Text(
            number,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: topBorderColor,
              height: 1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.grey,
              height: 1.25,
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  // -----------------------------------------------------------
  // C. GRIEVANCE CATEGORIES ("எந்தப் பிரச்சினையைப் பதிவு செய்ய விரும்புகிறீர்கள்?")
  // -----------------------------------------------------------
  Widget _buildCategoriesSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 26),
      child: Column(
        children: [
          Text(
            AppTranslations.tr('category_title'),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.navy,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            AppTranslations.tr('category_sub'),
            style: const TextStyle(fontSize: 12, color: AppColors.grey),
          ),
          const SizedBox(height: 18),

          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.95,
            children: [
              _categoryCard(AppTranslations.tr('cat_road'), Icons.alt_route, const Color(0xFFF1F5F9), const Color(0xFF334155)),
              _categoryCard(AppTranslations.tr('cat_water'), Icons.water_drop_rounded, const Color(0xFFEFF6FF), const Color(0xFF2563EB)),
              _categoryCard(AppTranslations.tr('cat_electricity'), Icons.bolt_rounded, const Color(0xFFFEFCE8), const Color(0xFFCA8A04)),
              _categoryCard(AppTranslations.tr('cat_sanitation'), Icons.delete_outline, const Color(0xFFF0FDF4), const Color(0xFF16A34A)),
              _categoryCard(AppTranslations.tr('cat_education'), Icons.school_rounded, const Color(0xFFFAF5FF), const Color(0xFF8B5CF6)),
              _categoryCard(AppTranslations.tr('cat_health'), Icons.local_hospital_rounded, const Color(0xFFFFF1F2), const Color(0xFFE11D48)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _categoryCard(String title, IconData icon, Color bgColor, Color iconColor) {
    return InkWell(
      onTap: () => _showMessage(
        AppTranslations.isTamil
            ? '$title பிரிவில் புகார் பதிவு'
            : 'Register grievance for $title',
      ),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: iconColor.withValues(alpha: 0.12)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 42,
              width: 42,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -----------------------------------------------------------
  // D. 4-STEP GRIEVANCE PROCESS
  // -----------------------------------------------------------
  Widget _buildProcessStepsSection() {
    return Container(
      color: AppColors.lightBg,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 26),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: Divider(color: AppColors.saffron.withValues(alpha: 0.6), thickness: 1.5)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  AppTranslations.tr('process_title'),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.navy,
                  ),
                ),
              ),
              Expanded(child: Divider(color: AppColors.saffron.withValues(alpha: 0.6), thickness: 1.5)),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            AppTranslations.tr('process_sub'),
            style: const TextStyle(fontSize: 12, color: AppColors.grey),
          ),
          const SizedBox(height: 20),

          // 4 Step Cards
          _stepCard('1', AppTranslations.tr('step_1_title'), AppTranslations.tr('step_1_desc'), Icons.edit_note_rounded, AppColors.orange, () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SubmitComplaintScreen(),
              ),
            );
          }),
          const SizedBox(height: 10),
          _stepCard('2', AppTranslations.tr('step_2_title'), AppTranslations.tr('step_2_desc'), Icons.search_rounded, AppColors.skyBlue, () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const TrackComplaintScreen()));
          }),
          const SizedBox(height: 10),
          _stepCard('3', AppTranslations.tr('step_3_title'), AppTranslations.tr('step_3_desc'), Icons.account_balance_rounded, AppColors.green),
          const SizedBox(height: 10),
          _stepCard('4', AppTranslations.tr('step_4_title'), AppTranslations.tr('step_4_desc'), Icons.task_alt_rounded, AppColors.purple, () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const TrackComplaintScreen()));
          }),
        ],
      ),
    );
  }

  Widget _stepCard(String number, String title, String subtitle, IconData icon, Color color, [VoidCallback? onTap]) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(
              height: 44,
              width: 44,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.navy,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.grey,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.grey),
          ],
        ),
      ),
    );
  }

  // -----------------------------------------------------------
  // E. LATEST CIVIC NEWS & ALERTS
  // -----------------------------------------------------------
  Widget _buildCivicNewsSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'CIVIC NEWS & ALERTS',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.blue,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      AppTranslations.tr('nav_news'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.navy,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const UpdatesScreen(),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(6),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        AppTranslations.isTamil ? 'மேலும் பார்க்க' : 'View All',
                        style: const TextStyle(
                          color: AppColors.orange,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 3),
                      const Icon(Icons.arrow_forward_rounded, size: 14, color: AppColors.orange),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.lightBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        AppTranslations.isTamil ? 'மக்கள் நலம் / திட்டங்கள்' : 'Public Welfare / Schemes',
                        style: const TextStyle(
                          color: AppColors.blue,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Text(
                      '17 Nov 2026',
                      style: TextStyle(fontSize: 11, color: AppColors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  AppTranslations.isTamil
                      ? 'திருநெல்வேலி & தமிழ்நாடு முழுவதும் பொது மக்கள் குறைதீர்க்கும் தளம் துவக்கம்'
                      : 'Public Grievance Facilitation Network Active in Tirunelveli',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.navy,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  AppTranslations.isTamil
                      ? 'குடிநீர், சாலை, மின்சாரம் உள்ளிட்ட அடிப்படைத் தேவைகளுக்கான கோரிக்கைகளை பொதுமக்கள் நேரடியாகப் பதிவு செய்யலாம்.'
                      : 'Citizens can report issues regarding drinking water, roads, electricity, and sanitation with direct tracking.',
                  style: const TextStyle(fontSize: 11, color: AppColors.grey, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // -----------------------------------------------------------
  // F. QUICK TRACK COMPLAINT BAR
  // -----------------------------------------------------------
  Widget _buildTrackComplaintBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.search, color: AppColors.saffron, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppTranslations.tr('track_box_title'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      AppTranslations.tr('track_box_sub'),
                      style: const TextStyle(color: Colors.white54, fontSize: 10),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Input & Search Button
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _trackController,
                    decoration: InputDecoration(
                      hintText: AppTranslations.tr('track_box_hint'),
                      hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: ElevatedButton(
                    onPressed: () {
                      final id = _trackController.text.trim();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TrackComplaintScreen(
                            initialComplaintId: id.isNotEmpty ? id : null,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.orange,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(AppTranslations.tr('track_box_btn'), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 4),
                        const Icon(Icons.arrow_forward, size: 14),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // -----------------------------------------------------------
  // G. SECURITY & TRUST BANNER
  // -----------------------------------------------------------
  Widget _buildSecurityBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F9FF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFBAE6FD)),
      ),
      child: Row(
        children: [
          const Icon(Icons.shield_outlined, color: AppColors.skyBlue, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              AppTranslations.tr('security_text'),
              style: const TextStyle(
                color: AppColors.skyBlue,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
