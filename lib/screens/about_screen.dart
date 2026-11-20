import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../utils/app_translations.dart';
import '../widgets/app_drawer.dart';
import '../widgets/app_header.dart';
import 'complaints/submit_complaint_screen.dart';
import 'complaints/track_complaint_screen.dart';

class AboutColors {
  static const navy = Color(0xFF0B1F3A);
  static const darkNavy = Color(0xFF071527);
  static const orange = Color(0xFFEA580C);
  static const orangeLight = Color(0xFFFFF7ED);
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

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Dynamic API Settings (with fallback defaults matching api/v1/meta/settings)
  String _portalName = 'Tamil Nadu Makkal Kural';
  String _sloganEn = 'Voice of the Voiceless';
  String _sloganTa = 'குரலற்ற மக்களின் குரல்';
  String _contactPhone = '+91 9384995222';
  String _contactEmail = 'thepeopleconnectofficial@gmail.com';
  String _officeAddress =
      'Civic Grievance Facilitation Center, Tirunelveli - 627001';
  String _operatingHours = 'Mon - Sat (9:00 AM - 6:00 PM)';
  bool _isLoadingSettings = false;

  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Accept': 'application/json'},
    ),
  );

  @override
  void initState() {
    super.initState();
    _fetchMetaSettings();
  }

  Future<void> _fetchMetaSettings() async {
    setState(() => _isLoadingSettings = true);
    try {
      final response = await _dio.get(ApiConfig.metaSettingsUrl);
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'] as Map<String, dynamic>?;
        if (data != null && mounted) {
          setState(() {
            _portalName = data['portal_name'] ?? _portalName;
            _sloganEn = data['slogan_en'] ?? _sloganEn;
            _sloganTa = data['slogan_ta'] ?? _sloganTa;
            _contactPhone = data['contact_phone'] ?? _contactPhone;
            _contactEmail = data['contact_email'] ?? _contactEmail;
            _officeAddress = data['office_address'] ?? _officeAddress;
            _operatingHours = data['operating_hours'] ?? _operatingHours;
          });
        }
      }
    } catch (e) {
      debugPrint('Notice: Meta settings API offline or slow, using fallback: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoadingSettings = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: appLanguage,
      builder: (context, currentLang, _) {
        final isTa = AppTranslations.isTamil;

        return Scaffold(
          key: _scaffoldKey,
          drawer: const AppDrawer(currentRoute: 'about'),
          backgroundColor: AboutColors.lightBg,
          body: SafeArea(
            child: Column(
              children: [
                // 1. REUSABLE TOP APP HEADER
                AppHeader(
                  showBackButton: true,
                  onMenuPressed: () {
                    _scaffoldKey.currentState?.openDrawer();
                  },
                ),

                // 2. Scrollable Body
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Breadcrumb Navigation
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          color: Colors.white,
                          child: Row(
                            children: [
                              InkWell(
                                onTap: () => Navigator.pop(context),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.home_outlined, size: 15, color: AboutColors.orange),
                                    const SizedBox(width: 4),
                                    Text(
                                      AppTranslations.tr('nav_home'),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AboutColors.orange,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right, size: 15, color: AboutColors.grey),
                              Flexible(
                                child: Text(
                                  AppTranslations.tr('nav_about'),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AboutColors.grey,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 1, color: AboutColors.borderLight),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 1. HERO HEADER: WHO WE ARE
                              _buildHeroSection(isTa),
                              const SizedBox(height: 16),

                              // 2. WHO WE ARE (OVERVIEW CARD WITH 3 HIGHLIGHTS)
                              _buildWhoWeAreCard(isTa),
                              const SizedBox(height: 16),

                              // 3. LEADERSHIP & CIVIC VISION (பாரதப் பிரதமர் & தலைமைத்துவ உத்வேகம்)
                              _buildLeadershipVisionCard(isTa),
                              const SizedBox(height: 16),

                              // 4. MISSION & VISION CARDS
                              _buildMissionVisionCards(isTa),
                              const SizedBox(height: 16),

                              // 5. 4-STEP CIVIC WORKFLOW
                              _buildWorkflowCard(context, isTa),
                              const SizedBox(height: 16),

                              // 6. 6 CIVIC CATEGORIES WE COVER
                              _buildCategoriesGrid(isTa),
                              const SizedBox(height: 16),

                              // 7. CORE OPERATING PRINCIPLES
                              _buildPrinciplesCard(isTa),
                              const SizedBox(height: 16),

                              // 8. OFFICIAL DISCLAIMER BANNER
                              _buildDisclaimerBanner(isTa),
                              const SizedBox(height: 16),

                              // 9. CTA & FACILITATION CENTER CONTACT CARD
                              _buildCtaAndContactCard(context, isTa),
                              const SizedBox(height: 28),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 1. HERO HEADER
  Widget _buildHeroSection(bool isTa) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF7ED), Colors.white],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFEDD5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          // Civic Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: const Color(0xFFFCD34D)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AboutColors.orange,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.campaign, color: AboutColors.orange, size: 16),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    isTa
                        ? 'குரலற்ற மக்களின் குரல் — பொது மக்கள் குறைதீர்க்கும் தளம்'
                        : 'VOICE OF THE VOICELESS — CITIZEN CIVIC PLATFORM',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AboutColors.navy,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Title
          Text(
            isTa
                ? 'மக்கள் குறைதீர்க்கும் தளம் — எங்களைப் பற்றி'
                : 'About People Grievance Management Platform',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: AboutColors.navy,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 6),

          // Tricolor Divider
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(width: 24, height: 3, decoration: BoxDecoration(color: AboutColors.orange, borderRadius: BorderRadius.circular(2))),
              const SizedBox(width: 4),
              Container(width: 24, height: 3, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
              const SizedBox(width: 4),
              Container(width: 24, height: 3, decoration: BoxDecoration(color: AboutColors.green, borderRadius: BorderRadius.circular(2))),
            ],
          ),
          const SizedBox(height: 12),

          // Intro Paragraph
          Text(
            isTa
                ? '$_portalName என்பது பொதுமக்களுக்கும் அரசு நிர்வாக அமைப்புகளுக்கும் இடையே வெளிப்படையான பாலமாகச் செயல்படும் ஒரு சுயாதீன மக்கள் சேவைத் தளமாகும். தமிழ்நாட்டு மக்கள் தங்கள் பகுதியில் உள்ள குடிநீர், சாலை, மின்சாரம், சுகாதாரம் உள்ளிட்ட அனைத்து அடிப்படைப் பொதுப் பிரச்சனைகளையும் இடைத்தரகர்கள் இன்றி நேரடியாகப் பதிவு செய்து துரித தீர்வு காண இத்தளம் உதவுகிறது.'
                : '$_portalName is an independent, citizen-first civic facilitation network established to bridge the gap between citizens and administrative bodies. We empower residents across Tamil Nadu to report, document, and resolve community problems transparently without middlemen or procedural delays.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: AboutColors.textDark,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 14),

          // 3 Core Highlights Full-Width Clean Trust Rows (Zero overflow guarantee)
          Column(
            children: [
              _heroTrustRow(
                Icons.shield_outlined,
                AboutColors.green,
                isTa ? 'இடைத்தரகர்கள் இல்லாத நேரடி தீர்வு' : '100% Direct Citizen Action',
              ),
              const SizedBox(height: 6),
              _heroTrustRow(
                Icons.location_on_outlined,
                AboutColors.blue,
                isTa ? 'மாவட்டம் & கிராமப்புற நேரடி இணைப்பு' : 'Grassroots District & Village Reach',
              ),
              const SizedBox(height: 6),
              _heroTrustRow(
                Icons.sensors,
                AboutColors.purple,
                isTa ? 'முழுமையான நேரடி கண்காணிப்பு' : 'End-to-End Live Tracking',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _heroTrustRow(IconData icon, Color color, String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 15),
          const SizedBox(width: 7),
          Flexible(
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // 2. WHO WE ARE (OVERVIEW CARD)
  Widget _buildWhoWeAreCard(bool isTa) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AboutColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tricolor Top Strip
          SizedBox(
            height: 4,
            child: Row(
              children: [
                Expanded(child: Container(color: AboutColors.orange)),
                Expanded(child: Container(color: Colors.white)),
                Expanded(child: Container(color: AboutColors.green)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AboutColors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    isTa ? 'நாம் யார்?' : 'WHO WE ARE',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AboutColors.blue,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                Text(
                  isTa
                      ? 'மக்களின் உரிமைகளுக்காக, மக்களின் குரலாக ஒலிக்கும் தளம்'
                      : 'Empowering Citizens, Elevating Civic Life',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AboutColors.navy,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 10),

                Text(
                  isTa
                      ? 'பல கிராமங்களிலும் நகர்ப்புறப் பகுதிகளிலும் சேதமடைந்த சாலைகள், குடிநீர் பற்றாக்குறை, தெருவிளக்கு எரியாமை, சாக்கடை அடைப்பு போன்ற அன்றாடப் பொதுப் பிரச்சனைகள் உரிய அதிகாரிகளைச் சென்றடைவதில் தாமதம் ஏற்படுகிறது. மனுக்களை யாரிடம் கொடுப்பது என்ற விழிப்புணர்வு இன்மை மற்றும் முறையான ஆவணப்படுத்துதல் இல்லாததே இதற்கு முக்கிய காரணமாகும்.'
                      : 'In many localities, genuine civic difficulties—from contaminated drinking water and broken roads to non-functioning streetlights—often go unheard due to complicated administrative workflows or lack of documentation.',
                  style: const TextStyle(fontSize: 12, color: AboutColors.grey, height: 1.55),
                ),
                const SizedBox(height: 8),

                Text(
                  isTa
                      ? 'இச்சிக்கலுக்கு முற்றுப்புள்ளி வைக்கும் வகையில், இத்தளம் எளிய மக்களுக்கும் தொழில்நுட்பத்தின் வலிமையைக் கொண்டு சேர்க்கிறது. பொதுமக்கள் தங்கள் ஸ்மார்ட்போன் வழியாகவே புகைப்படங்களுடன் புகார்களைப் பதிவு செய்யலாம். அப்புகார்கள் சரிபார்க்கப்பட்டு, சம்பந்தப்பட்ட அரசு மற்றும் உள்ளாட்சித் துறைகளின் கவனத்திற்குக் கொண்டு செல்லப்பட்டு தீர்வு காண வழிவகை செய்யப்படுகிறது.'
                      : 'Our platform provides every citizen an equal, straightforward digital channel to document grievances with photos and location details. Once recorded, petitions are organized, verified, and officially presented to the respective municipal and government departments for measurable, time-bound action.',
                  style: const TextStyle(fontSize: 12, color: AboutColors.grey, height: 1.55),
                ),
                const SizedBox(height: 16),

                // Sub-box: What Sets This Platform Apart?
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AboutColors.lightBg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AboutColors.borderLight),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.star, color: AboutColors.amber, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              isTa ? 'இத்தளத்தின் தனித்துவங்கள் என்ன?' : 'What Sets This Platform Apart?',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AboutColors.navy,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      _apartItem(
                        Icons.check_circle_outline,
                        AboutColors.blue,
                        isTa ? 'இடைத்தரகர்கள் இல்லாத நேரடி பதிவு' : 'Direct Registration without Middlemen',
                        isTa
                            ? 'பொதுமக்கள் யாரிடமும் கெஞ்சாமல், எந்தக் கட்டணமும் இன்றி தங்கள் புகார்களை நேரடியாகப் பதிவு செய்யலாம்.'
                            : 'Citizens register petitions directly without paying any fees or relying on intermediaries.',
                      ),
                      const SizedBox(height: 10),

                      _apartItem(
                        Icons.camera_alt_outlined,
                        AboutColors.green,
                        isTa ? 'உண்மையான புகைப்படச் சான்றுகள்' : 'Authentic Photo & Location Proof',
                        isTa
                            ? 'புகைப்படம் மற்றும் பகுதி விவரங்களுடன் பதிவு செய்யப்படுவதால் அதிகாரிகள் உடனடியாக கள ஆய்வு செய்ய முடிகிறது.'
                            : 'Every petition is accompanied by real visual evidence ensuring authentic administrative review.',
                      ),
                      const SizedBox(height: 10),

                      _apartItem(
                        Icons.qr_code_2_outlined,
                        AboutColors.orange,
                        isTa ? 'தனித்துவமான புகார் அடையாள எண்' : 'Unique Tracking ID',
                        isTa
                            ? 'ஒவ்வொரு புகாருக்கும் தனி எண் வழங்கப்பட்டு, அதன் நடவடிக்கை நிலை என்னவென்று வெளிப்படையாகத் தெரிந்து கொள்ளலாம்.'
                            : 'Instant complaint tracking ID enables citizens to follow petition progress at every stage.',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _apartItem(IconData icon, Color color, String title, String desc) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: AboutColors.navy),
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: const TextStyle(fontSize: 11, color: AboutColors.grey, height: 1.35),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 3. LEADERSHIP & CIVIC VISION (பாரதப் பிரதமர் & தலைமைத்துவ உத்வேகம்)
  Widget _buildLeadershipVisionCard(bool isTa) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AboutColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tricolor Top Strip
          SizedBox(
            height: 4,
            child: Row(
              children: [
                Expanded(child: Container(color: AboutColors.orange)),
                Expanded(child: Container(color: Colors.white)),
                Expanded(child: Container(color: AboutColors.green)),
              ],
            ),
          ),

          // Leadership Image Banner (Full width & natural height so no part is hidden)
          ClipRRect(
            child: Image.asset(
              'assets/images/bjp/images.jpg',
              width: double.infinity,
              fit: BoxFit.fitWidth,
              errorBuilder: (context, error, stackTrace) {
                return Image.network(
                  '${ApiConfig.baseUrl}/assets/images/bjp/images.jpg',
                  width: double.infinity,
                  fit: BoxFit.fitWidth,
                  errorBuilder: (ctx, err, stack) => Container(
                    height: 200,
                    width: double.infinity,
                    color: AboutColors.navy,
                    child: const Center(
                      child: Icon(Icons.account_balance, size: 50, color: Colors.white54),
                    ),
                  ),
                );
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Leadership Badges Row
                Row(
                  children: [
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFFCD34D)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.verified_user, color: AboutColors.orange, size: 14),
                            const SizedBox(width: 5),
                            Flexible(
                              child: Text(
                                isTa
                                    ? 'தலைமைத்துவ வழிகாட்டல் & மக்கள் சேவை'
                                    : 'Leadership Vision & Guidance',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AboutColors.navy,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                Row(
                  children: [
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AboutColors.lightBg,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AboutColors.borderLight),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star, color: AboutColors.amber, size: 13),
                            const SizedBox(width: 5),
                            Flexible(
                              child: Text(
                                isTa
                                    ? 'மக்கள் சேவை உத்வேகம் & நெறிமுறைகள்'
                                    : 'Inspiration & Governance Principles',
                                style: const TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.bold,
                                  color: AboutColors.navy,
                                  letterSpacing: 0.3,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                Text(
                  isTa
                      ? 'அந்தியோதயா தொலைநோக்கு & அர்ப்பணிப்புள்ள மக்கள் சேவை'
                      : 'Inspired by Antyodaya & Grassroots Public Service',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AboutColors.navy,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 10),

                // Antyodaya Quote Box (Clean uniform border & full flexible height)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFBEB),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFDE68A)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.format_quote, color: Color(0xFFD97706), size: 20),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          isTa
                              ? '"அனைவருடன் இணைந்து, அனைவரின் வளர்ச்சிக்காக" (Sabka Saath, Sabka Vikas, Sabka Vishwas) மற்றும் \'அந்தியோதயா\' (கடைக்கோடி ஏழை எளிய மனிதனுக்கும் அதிகாரம் அளித்தல்).'
                              : '"Sabka Saath, Sabka Vikas, Sabka Vishwas, Sabka Prayas" — Uplifting the last person in society (Antyodaya).',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF92400E),
                            height: 1.45,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                Text(
                  isTa
                      ? 'பாரதிய ஜனதா கட்சியின் அதிகாரப்பூர்வ மக்கள் சேவைக் கொள்கைகள் மற்றும் பாரதப் பிரதமர் நரேந்திர மோடி அவர்களின் உயரிய தொலைநோக்கின்படி, மக்கள் சேவையே அரசியலின் தலையாய கடமையாகும்.'
                      : 'According to the public service principles articulated by the Bharatiya Janata Party (BJP) and Prime Minister Narendra Modi’s core governance philosophy, the foremost priority of public engagement is dedicated, transparent service to every citizen.',
                  style: const TextStyle(fontSize: 12, color: AboutColors.grey, height: 1.55),
                ),
                const SizedBox(height: 8),

                Text(
                  isTa
                      ? 'இத்தலைமைத்துவ வழிகாட்டலின் அடிப்படையில், பொதுமக்கள் தங்கள் பகுதியில் சந்திக்கும் குடிநீர், சாலை, மின்சாரம், சுகாதாரம் மற்றும் அரசு நலத்திட்ட உதவிகள் போன்ற அன்றாடக் கோரிக்கைகளை வெளிப்படைத்தன்மையுடன் ஆவணப்படுத்தி, அரசு மற்றும் உள்ளாட்சித் துறைகள் மூலம் துரித தீர்வு காணும் மக்கள் சேவை பாலமாக இத்தளம் அர்ப்பணிப்புடன் இயங்குகிறது.'
                      : 'Guided by this proactive leadership vision, this grievance facilitation initiative works continuously on the ground to systematically record, follow up, and resolve essential community needs—including safe drinking water, reliable electricity, rural roads, public health, and welfare benefits—through seamless administrative coordination.',
                  style: const TextStyle(fontSize: 12, color: AboutColors.grey, height: 1.55),
                ),
                const SizedBox(height: 14),

                // 2 Civic Highlight Cards
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        decoration: BoxDecoration(
                          color: AboutColors.green.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AboutColors.green.withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle_outline, color: AboutColors.green, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                isTa ? 'கடைக்கோடி மக்களுக்கும் நேரடி சேவை' : 'Direct Last-Mile Reach',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AboutColors.navy,
                                  height: 1.25,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        decoration: BoxDecoration(
                          color: AboutColors.blue.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AboutColors.blue.withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.shield_outlined, color: AboutColors.blue, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                isTa ? 'நேர்மையான வெளிப்படையான செயல்பாடு' : 'Transparent Administration',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AboutColors.navy,
                                  height: 1.25,
                                ),
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
        ],
      ),
    );
  }

  // 4. MISSION & VISION
  Widget _buildMissionVisionCards(bool isTa) {
    return Column(
      children: [
        // Mission Card
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(height: 4, width: double.infinity, color: AboutColors.orange),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.track_changes, color: AboutColors.orange, size: 20),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            isTa ? 'எங்கள் நோக்கம் (Our Mission)' : 'Our Mission',
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AboutColors.navy),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      isTa
                          ? 'தமிழ்நாட்டின் ஒவ்வொரு குடிமகனும் தங்கள் பகுதிப் பொதுப் பிரச்சனைகளை எளிமையாகவும் வெளிப்படைத்தன்மையுடனும் பதிவு செய்யவும், அப்புகார்களை முறைப்படி ஆவணப்படுத்தி சம்பந்தப்பட்ட அரசு நிர்வாக அமைப்புகளுக்குக் கொண்டு சென்று மக்கள் நலனை உறுதி செய்வதே எங்களின் தலையாய நோக்கமாகும்.'
                          : 'To provide an accessible, transparent, and bilingual grievance redressal portal where every citizen\'s voice is heard, accurately documented, and coordinated with public authorities to achieve measurable civic solutions.',
                      style: const TextStyle(fontSize: 12, color: AboutColors.textDark, height: 1.55),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Vision Card
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(height: 4, width: double.infinity, color: AboutColors.green),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.visibility_outlined, color: AboutColors.green, size: 20),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            isTa ? 'எங்கள் தொலைநோக்கு (Our Vision)' : 'Our Vision',
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AboutColors.navy),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      isTa
                          ? 'சுத்தமான குடிநீர், பாதுகாப்பான சாலைகள், முறையான மின்சார வசதி மற்றும் தூய்மையான சுற்றுப்புறம் ஆகியவை ஒவ்வொரு குடிமகனுக்கும் தடையின்றி கிடைப்பதை உறுதி செய்து, மக்கள் குறைகள் உடனுக்குடன் தீர்க்கப்படும் ஒரு முன்மாதிரி டிஜிட்டல் சமூகத்தை உருவாக்குவதே எங்களின் தொலைநோக்காகும்.'
                          : 'To cultivate a modern, responsive civic ecosystem where community infrastructure needs—clean drinking water, proper drainage, safe roads, and reliable power—are addressed promptly with digital transparency and zero administrative apathy.',
                      style: const TextStyle(fontSize: 12, color: AboutColors.textDark, height: 1.55),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 5. 4-STEP WORKFLOW
  Widget _buildWorkflowCard(BuildContext context, bool isTa) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AboutColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AboutColors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                isTa ? 'செயல்முறை' : 'WORKFLOW',
                style: const TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.bold,
                  color: AboutColors.grey,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          Center(
            child: Text(
              isTa
                  ? 'புகார் பதிவு முதல் நடவடிக்கை வரை — எளிய செயல்முறை'
                  : 'How the Grievance Redressal Platform Works',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AboutColors.navy),
            ),
          ),
          const SizedBox(height: 4),

          Center(
            child: Text(
              isTa
                  ? 'உங்கள் புகார் உரிய அதிகாரிகளைச் சென்றடைய நாங்கள் பின்பற்றும் எளிய 4-படி நடைமுறை.'
                  : 'A systematic, step-by-step workflow designed to ensure every complaint is verified and addressed.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11.5, color: AboutColors.grey),
            ),
          ),
          const SizedBox(height: 16),

          _workflowStep(
            '1',
            isTa ? '1. புகார் பதிவு' : '1. Submit',
            isTa ? 'விவரங்கள் & புகைப்படங்களுடன் புகாரைப் பதிவு செய்யவும்' : 'Register details with photos and location',
            AboutColors.orange,
            Icons.edit_note,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SubmitComplaintScreen()),
              );
            },
          ),
          const SizedBox(height: 8),

          _workflowStep(
            '2',
            isTa ? '2. சரிபார்ப்பு' : '2. Verification',
            isTa ? 'புகார் விவரங்கள் எங்கள் குழுவால் சரிபார்க்கப்படும்' : 'Our civic team reviews authenticity',
            AboutColors.skyBlue,
            Icons.verified_outlined,
          ),
          const SizedBox(height: 8),

          _workflowStep(
            '3',
            isTa ? '3. அரசுத் துறைக்கு அனுப்புதல்' : '3. Official Escalation',
            isTa ? 'சம்பந்தப்பட்ட அரசு அல்லது உள்ளாட்சித் துறைக்கு அனுப்பப்படும்' : 'Forwarded to the concerned civic department',
            AboutColors.green,
            Icons.account_balance_outlined,
          ),
          const SizedBox(height: 8),

          _workflowStep(
            '4',
            isTa ? '4. தீர்வு & நேரடி கண்காணிப்பு' : '4. Tracking & Resolution',
            isTa ? 'புகாரின் நடவடிக்கை நிலையை ஆன்லைனில் அறியலாம்' : 'Follow resolution status live with Complaint ID',
            AboutColors.purple,
            Icons.manage_search,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TrackComplaintScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _workflowStep(
    String num,
    String title,
    String desc,
    Color color,
    IconData icon, [
    VoidCallback? onTap,
  ]) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AboutColors.lightBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  num,
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AboutColors.navy),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    desc,
                    style: const TextStyle(fontSize: 11, color: AboutColors.grey, height: 1.3),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(Icons.arrow_forward_ios, size: 12, color: color),
              ),
          ],
        ),
      ),
    );
  }

  // 6. CIVIC CATEGORIES WE COVER (6 categories from about.blade.php)
  Widget _buildCategoriesGrid(bool isTa) {
    final categories = [
      {
        'icon': Icons.signpost_outlined,
        'color': AboutColors.orange,
        'title': isTa ? 'சாலை வசதி' : 'Roads & Bridges',
        'desc': isTa ? 'சேதமடைந்த சாலைகள், பாலங்கள்' : 'Potholes & roads',
      },
      {
        'icon': Icons.water_drop_outlined,
        'color': AboutColors.skyBlue,
        'title': isTa ? 'குடிநீர் விநியோகம்' : 'Drinking Water',
        'desc': isTa ? 'குடிநீர் பற்றாக்குறை, குழாய் உடைப்பு' : 'Water scarcity & pipes',
      },
      {
        'icon': Icons.bolt_outlined,
        'color': AboutColors.amber,
        'title': isTa ? 'மின்சாரம் & விளக்கு' : 'Electricity & Light',
        'desc': isTa ? 'தெருவிளக்கு எரியாமை, மின்கம்ப பழுது' : 'Dark streetlights',
      },
      {
        'icon': Icons.delete_sweep_outlined,
        'color': AboutColors.green,
        'title': isTa ? 'சுகாதாரம் & துப்புரவு' : 'Sanitation & Hygiene',
        'desc': isTa ? 'சாக்கடை அடைப்பு, குப்பை அகற்றுதல்' : 'Drainage blockage',
      },
      {
        'icon': Icons.school_outlined,
        'color': AboutColors.cyan,
        'title': isTa ? 'கல்வி & பள்ளிகள்' : 'Education & Schools',
        'desc': isTa ? 'பள்ளி உள்கட்டமைப்பு, கல்வி உதவிகள்' : 'School infra',
      },
      {
        'icon': Icons.local_hospital_outlined,
        'color': Colors.redAccent,
        'title': isTa ? 'மருத்துவம் & நலம்' : 'Healthcare & Clinics',
        'desc': isTa ? 'ஆரம்ப சுகாதார நிலையங்கள்' : 'PHCs & clinics',
      },
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AboutColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AboutColors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                isTa ? 'சேவை வகைகள்' : 'SCOPE OF SERVICE',
                style: const TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.bold,
                  color: AboutColors.blue,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          Center(
            child: Text(
              isTa ? 'நாங்கள் தீர்வு காணும் பொதுப் பிரச்சனைகள்' : 'Civic Categories We Cover',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AboutColors.navy),
            ),
          ),
          const SizedBox(height: 14),

          // 2-Column Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: categories.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.25,
            ),
            itemBuilder: (context, index) {
              final cat = categories[index];
              final catColor = cat['color'] as Color;
              return Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AboutColors.lightBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: catColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(cat['icon'] as IconData, color: catColor, size: 22),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      cat['title'] as String,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AboutColors.navy,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      cat['desc'] as String,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 10.5,
                        color: AboutColors.grey,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // 7. CORE OPERATING PRINCIPLES
  Widget _buildPrinciplesCard(bool isTa) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AboutColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.shield_outlined, color: AboutColors.navy, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isTa ? 'எங்கள் முதன்மைக் கொள்கைகள்' : 'Our Core Operating Principles',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AboutColors.navy),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          _principleRow(
            Icons.lock_outline,
            AboutColors.orange,
            isTa ? 'தனியுரிமை & தகவல் பாதுகாப்பு' : 'Citizen Privacy & Security',
            isTa
                ? 'மனுதாரர்களின் தொலைபேசி எண் மற்றும் முகவரி போன்ற தனிப்பட்ட விவரங்கள் பொதுவெளியில் பகிரப்படாமல் முழுமையாகப் பாதுகாக்கப்படுகின்றன.'
                : 'Citizen phone numbers and private addresses are strictly protected and never disclosed publicly.',
          ),
          const Divider(height: 16),

          _principleRow(
            Icons.location_on_outlined,
            AboutColors.green,
            isTa ? 'துல்லியமான பகுதி விவரங்கள்' : 'Authentic Civic Mapping',
            isTa
                ? 'ஒவ்வொரு புகாரும் அதன் மாவட்டம், வட்டம், கிராமம் மற்றும் வார்டு வாரியாக துல்லியமாக ஆவணப்படுத்தப்படுகிறது.'
                : 'Every complaint is accurately mapped to its district, taluk, ward, or revenue village for direct administrative action.',
          ),
          const Divider(height: 16),

          _principleRow(
            Icons.history_toggle_off,
            AboutColors.blue,
            isTa ? 'வெளிப்படையான கண்காணிப்பு' : 'Full Transparency',
            isTa
                ? 'மனு பதிவு முதல் துறைக்கு பரிந்துரைப்பது மற்றும் களத் தீர்வு வரை ஒவ்வொரு கட்டமும் வெளிப்படையாக கண்காணிக்கப்படுகிறது.'
                : 'From registration to departmental referral and verified on-site completion, progress is tracked clearly.',
          ),
        ],
      ),
    );
  }

  Widget _principleRow(IconData icon, Color color, String title, String desc) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AboutColors.navy)),
              const SizedBox(height: 2),
              Text(desc, style: const TextStyle(fontSize: 11.5, color: AboutColors.grey, height: 1.35)),
            ],
          ),
        ),
      ],
    );
  }

  // 8. OFFICIAL DISCLAIMER BANNER
  Widget _buildDisclaimerBanner(bool isTa) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFED7AA)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: AboutColors.amber, size: 24),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isTa ? 'அதிகாரப்பூர்வ மக்கள் குறைதீர் தளம்' : 'People Grievance Redressal Platform',
                  style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: AboutColors.navy),
                ),
                const SizedBox(height: 4),
                Text(
                  isTa
                      ? 'தமிழ்நாடு மக்கள் குரல் என்பது ஒரு சுயாதீன, அரசு சாரா மக்கள் நல்வாழ்வு குறைதீர்க்கும் தளமாகும். இது அரசு நிர்வாகத்தின் நேரடி தளம் அல்ல. பொதுமக்களின் அடிப்படை கோரிக்கைகளை முறைப்படி ஆவணப்படுத்தி, உரிய அரசு அதிகாரிகளின் கவனத்திற்குக் கொண்டு சென்று தீர்வு காணும் பாலமாக மட்டுமே இத்தளம் செயல்படுகிறது.'
                      : 'Tamil Nadu Makkal Kural is an independent civic facilitation platform and is not an official government administrative portal. Our team facilitates petition documentation and coordination with respective public departments.',
                  style: const TextStyle(fontSize: 11, color: AboutColors.textDark, height: 1.45),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 9. CTA & FACILITATION CENTER CONTACT CARD
  Widget _buildCtaAndContactCard(BuildContext context, bool isTa) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AboutColors.navy, AboutColors.darkNavy],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Main CTA Section
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text(
                  isTa ? 'உங்கள் பகுதியில் பொதுப் பிரச்சனை உள்ளதா?' : 'Have a civic problem in your neighborhood?',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 6),
                Text(
                  isTa
                      ? 'புகாரை உடனடியாக புகைப்படங்களுடன் பதிவு செய்யுங்கள் அல்லது உங்கள் புகாரின் நடவடிக்கை நிலையை உடனே ஆன்லைனில் தெரிந்து கொள்ளுங்கள்.'
                      : 'Submit your complaint online with photos or check the live progress of an existing petition anytime.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12, color: Colors.white70, height: 1.45),
                ),
                const SizedBox(height: 18),

                // Action Buttons
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  alignment: WrapAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SubmitComplaintScreen()),
                        );
                      },
                      icon: const Icon(Icons.edit_note, size: 18),
                      label: Text(
                        isTa ? 'புகாரைப் பதிவு செய்க' : 'Submit Grievance',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AboutColors.orange,
                        foregroundColor: Colors.white,
                        elevation: 3,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const TrackComplaintScreen()),
                        );
                      },
                      icon: const Icon(Icons.search, size: 16),
                      label: Text(
                        isTa ? 'புகார் நிலை அறிய' : 'Track Grievance',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white70),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Divider inside CTA
          const Divider(height: 1, color: Colors.white24),

          // Facilitation Center Details (Dynamic from API)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.location_city, color: AboutColors.saffron, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        isTa ? 'மக்கள் குறைதீர்ப்பு உதவி மையம் (Head Office)' : 'Grievance Facilitation Office',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                    if (_isLoadingSettings)
                      const SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AboutColors.saffron),
                      ),
                  ],
                ),
                const SizedBox(height: 10),

                // Office Address
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.place_outlined, size: 15, color: Colors.white70),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _officeAddress,
                        style: const TextStyle(fontSize: 11.5, color: Colors.white70, height: 1.3),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Phone & Operating Hours
                Row(
                  children: [
                    const Icon(Icons.phone_outlined, size: 15, color: AboutColors.green),
                    const SizedBox(width: 8),
                    Text(
                      _contactPhone,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.access_time, size: 14, color: Colors.white70),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        _operatingHours,
                        style: const TextStyle(fontSize: 11, color: Colors.white70),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Email
                Row(
                  children: [
                    const Icon(Icons.email_outlined, size: 15, color: AboutColors.skyBlue),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _contactEmail,
                        style: const TextStyle(fontSize: 11.5, color: Colors.white70),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
