import 'package:flutter/material.dart';
import '../screens/contact_screen.dart';
import '../utils/app_translations.dart';

class AppHeaderColors {
  static const navy = Color(0xFF0B1F3A);
  static const orange = Color(0xFFEA580C);
  static const saffron = Color(0xFFFF9933);
  static const tricolorGreen = Color(0xFF138808);
  static const borderLight = Color(0xFFE2E8F0);
}

class AppHeader extends StatelessWidget {
  final bool showBackButton;
  final VoidCallback? onMenuPressed;

  const AppHeader({
    super.key,
    this.showBackButton = false,
    this.onMenuPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: appLanguage,
      builder: (context, currentLang, _) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 1. Indian Tricolor Line (Top 3.5px)
            SizedBox(
              height: 3.5,
              child: Row(
                children: [
                  Expanded(child: Container(color: AppHeaderColors.saffron)),
                  Expanded(child: Container(color: Colors.white)),
                  Expanded(child: Container(color: AppHeaderColors.tricolorGreen)),
                ],
              ),
            ),

            // 2. Top Utility & Civic Notice Bar
            Container(
              color: AppHeaderColors.navy,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7.5),
              child: Row(
                children: [
                  // Notice Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                    decoration: BoxDecoration(
                      color: AppHeaderColors.orange,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.campaign, color: Colors.white, size: 15),
                        const SizedBox(width: 4),
                        Text(
                          AppTranslations.tr('notice_badge'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Notice Ticker
                  Expanded(
                    child: Text(
                      AppTranslations.tr('notice_ticker'),
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  // Helpline Pill
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ContactScreen()),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.phone, color: AppHeaderColors.saffron, size: 13),
                          SizedBox(width: 4),
                          Text(
                            '9384995222',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),

                  // Language Switcher (Active & Dynamic)
                  PopupMenuButton<String>(
                    tooltip: 'Change Language / மொழி மாற்ற',
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.16),
                        border: Border.all(color: Colors.white38),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.language, color: Colors.white, size: 13),
                          const SizedBox(width: 4),
                          Text(
                            currentLang == 'ta' ? 'தமிழ்' : 'English',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Icon(Icons.arrow_drop_down, color: Colors.white, size: 14),
                        ],
                      ),
                    ),
                    onSelected: (val) {
                      AppTranslations.setLanguage(val);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            val == 'ta'
                                ? 'தமிழ் மொழி தேர்ந்தெடுக்கப்பட்டது'
                                : 'English Language Selected',
                          ),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: AppHeaderColors.navy,
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(
                        value: 'ta',
                        child: Row(
                          children: [
                            Text('🇮🇳 தமிழ் (Tamil)', style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'en',
                        child: Row(
                          children: [
                            Text('🇬🇧 English', style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 3. Main Branding Navbar (Enlarged Height & Prominent Logo)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    offset: const Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Back Button (If inner screen)
                  if (showBackButton) ...[
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: AppHeaderColors.navy, size: 24),
                      onPressed: () => Navigator.maybePop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 8),
                  ],

                  // Logo (Enlarged 80x60 container matching 1.5 aspect ratio for maximum clarity)
                  Container(
                    height: 60,
                    width: 80,
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppHeaderColors.orange.withValues(alpha: 0.4), width: 1.3),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(9),
                      child: Image.asset(
                        'assets/images/logo/logo.png',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset(
                            'assets/images/logo.png',
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.how_to_vote, color: AppHeaderColors.orange, size: 30);
                            },
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Vertical divider
                  Container(
                    height: 46,
                    width: 1.5,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(width: 10),

                  // Title & Subtitle (Bilingual, Larger & Prominent)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          AppTranslations.tr('platform_title'),
                          maxLines: 2,
                          overflow: TextOverflow.visible,
                          softWrap: true,
                          style: const TextStyle(
                            fontSize: 13.0,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.3,
                            height: 1.2,
                            color: AppHeaderColors.navy,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          AppTranslations.tr('voice_tagline'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: AppHeaderColors.orange,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Lotus Badge (Enlarged 44x44)
                  Container(
                    height: 44,
                    width: 44,
                    margin: const EdgeInsets.only(right: 6),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.shade300, width: 1.2),
                      color: Colors.white,
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/bjp/lotus.png',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset(
                            'assets/images/lotus.png',
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.eco, color: AppHeaderColors.orange, size: 22);
                            },
                          );
                        },
                      ),
                    ),
                  ),

                  // Hamburger Menu Button (Larger 34px icon)
                  Builder(
                    builder: (headerContext) {
                      return IconButton(
                        onPressed: () {
                          if (onMenuPressed != null) {
                            onMenuPressed!();
                          } else {
                            Scaffold.maybeOf(headerContext)?.openDrawer();
                          }
                        },
                        icon: const Icon(Icons.menu_rounded, color: AppHeaderColors.navy, size: 34),
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
