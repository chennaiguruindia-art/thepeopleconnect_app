import 'package:flutter/material.dart';
import '../utils/app_translations.dart';
import '../widgets/app_drawer.dart';
import '../widgets/app_header.dart';

class SchemeColors {
  static const navy = Color(0xFF0B1F3A);
  static const darkNavy = Color(0xFF071527);
  static const orange = Color(0xFFEA580C);
  static const saffron = Color(0xFFFF9933);
  static const green = Color(0xFF16A34A);
  static const emerald = Color(0xFF059669);
  static const blue = Color(0xFF2563EB);
  static const skyBlue = Color(0xFF0284C7);
  static const purple = Color(0xFF7C3AED);
  static const amber = Color(0xFFD97706);
  static const red = Color(0xFFDC2626);
  static const lightBg = Color(0xFFF8FAFC);
  static const grey = Color(0xFF64748B);
  static const textDark = Color(0xFF0F172A);
  static const borderLight = Color(0xFFE2E8F0);
}

class SchemeModel {
  final String id;
  final String govType; // 'central' or 'state'
  final String category; // 'farmers', 'women', 'health', 'housing', 'education', 'business', 'social'
  final String titleTa;
  final String titleEn;
  final String benefitBadgeTa;
  final String benefitBadgeEn;
  final String descTa;
  final String descEn;
  final String eligibilityTa;
  final String eligibilityEn;
  final List<String> benefitsListTa;
  final List<String> benefitsListEn;
  final List<String> docsTa;
  final List<String> docsEn;
  final String applyMethodTa;
  final String applyMethodEn;
  final String officialPortal;
  final String helpline;
  final IconData icon;
  final Color color;

  const SchemeModel({
    required this.id,
    required this.govType,
    required this.category,
    required this.titleTa,
    required this.titleEn,
    required this.benefitBadgeTa,
    required this.benefitBadgeEn,
    required this.descTa,
    required this.descEn,
    required this.eligibilityTa,
    required this.eligibilityEn,
    required this.benefitsListTa,
    required this.benefitsListEn,
    required this.docsTa,
    required this.docsEn,
    required this.applyMethodTa,
    required this.applyMethodEn,
    required this.officialPortal,
    required this.helpline,
    required this.icon,
    required this.color,
  });
}

class SchemesScreen extends StatefulWidget {
  const SchemesScreen({super.key});

  @override
  State<SchemesScreen> createState() => _SchemesScreenState();
}

class _SchemesScreenState extends State<SchemesScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();

  String _selectedGovFilter = 'central'; // 'all', 'central'
  String _selectedCategory = 'all'; // 'all', 'farmers', 'women', 'health', 'education', 'business', 'housing'
  String _searchQuery = '';

  late final List<SchemeModel> _allSchemes;

  @override
  void initState() {
    super.initState();
    _allSchemes = _initializeSchemes();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<SchemeModel> get _filteredSchemes {
    return _allSchemes.where((scheme) {
      // Government Type Filter
      if (_selectedGovFilter != 'all' && scheme.govType != _selectedGovFilter) {
        return false;
      }
      // Category Filter
      if (_selectedCategory != 'all' && scheme.category != _selectedCategory) {
        return false;
      }
      // Search Query
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchTitle = scheme.titleTa.toLowerCase().contains(query) ||
            scheme.titleEn.toLowerCase().contains(query);
        final matchDesc = scheme.descTa.toLowerCase().contains(query) ||
            scheme.descEn.toLowerCase().contains(query);
        final matchBenefit = scheme.benefitBadgeTa.toLowerCase().contains(query) ||
            scheme.benefitBadgeEn.toLowerCase().contains(query);
        return matchTitle || matchDesc || matchBenefit;
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: appLanguage,
      builder: (context, currentLang, _) {
        final isTa = AppTranslations.isTamil;
        final schemesList = _filteredSchemes;

        return Scaffold(
          key: _scaffoldKey,
          drawer: const AppDrawer(currentRoute: 'schemes'),
          backgroundColor: SchemeColors.lightBg,
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

                // 2. BREADCRUMB
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
                            const Icon(Icons.home_outlined, size: 15, color: SchemeColors.orange),
                            const SizedBox(width: 4),
                            Text(
                              AppTranslations.tr('nav_home'),
                              style: const TextStyle(
                                fontSize: 12,
                                color: SchemeColors.orange,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, size: 15, color: SchemeColors.grey),
                      Flexible(
                        child: Text(
                          isTa ? 'மத்திய அரசு நலத்திட்டங்கள்' : 'Central Govt Welfare Schemes',
                          style: const TextStyle(
                            fontSize: 12,
                            color: SchemeColors.grey,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: SchemeColors.borderLight),

                // 3. MAIN SCROLLABLE BODY
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top Civic Banner & Search
                        _buildHeroBanner(isTa),

                        // Segmented Gov Type Tabs (Central / State / All)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                          child: _buildGovTypeTabs(isTa),
                        ),

                        // Category Chips (Horizontal Scroll)
                        _buildCategoryFilterBar(isTa),

                        // Results Counter Row
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Text(
                                  isTa
                                      ? 'மொத்த நலத்திட்டங்கள்: ${schemesList.length}'
                                      : 'Available Schemes: ${schemesList.length}',
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.bold,
                                    color: SchemeColors.navy,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (_selectedGovFilter != 'all' || _selectedCategory != 'all' || _searchQuery.isNotEmpty)
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      _selectedGovFilter = 'all';
                                      _selectedCategory = 'all';
                                      _searchQuery = '';
                                      _searchController.clear();
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: Colors.red.shade50,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.red.shade200),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.close, size: 12, color: Colors.red.shade700),
                                        const SizedBox(width: 3),
                                        Text(
                                          isTa ? 'அழி' : 'Clear',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.red.shade700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),

                        // Schemes List Cards
                        if (schemesList.isEmpty)
                          _buildEmptyState(isTa)
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: schemesList.length,
                            itemBuilder: (context, index) {
                              return _buildSchemeCard(schemesList[index], isTa);
                            },
                          ),

                        const SizedBox(height: 24),

                        // Official Disclaimer & Help Center Notice
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: _buildFooterDisclaimer(isTa),
                        ),

                        const SizedBox(height: 30),
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

  // HERO BANNER & SEARCH BAR
  Widget _buildHeroBanner(bool isTa) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFFF7ED), Colors.white],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        border: Border(bottom: BorderSide(color: Color(0xFFFFEDD5))),
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tricolor Top Accent Line
          Row(
            children: [
              Container(width: 24, height: 3, decoration: BoxDecoration(color: SchemeColors.orange, borderRadius: BorderRadius.circular(2))),
              const SizedBox(width: 4),
              Container(width: 24, height: 3, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
              const SizedBox(width: 4),
              Container(width: 24, height: 3, decoration: BoxDecoration(color: SchemeColors.green, borderRadius: BorderRadius.circular(2))),
            ],
          ),
          const SizedBox(height: 10),

          // Header Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFFCD34D)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.verified, color: SchemeColors.orange, size: 14),
                const SizedBox(width: 5),
                Flexible(
                  child: Text(
                    isTa
                        ? 'அரசு நலத்திட்டங்கள் — வழிகாட்டி & தகுதிகள்'
                        : 'Citizen Welfare Schemes Directory',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: SchemeColors.navy,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          Text(
            isTa
                ? 'மத்திய அரசு நலத்திட்டங்கள்'
                : 'Central Government Schemes',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: SchemeColors.navy,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isTa
                ? 'விவசாயிகள், பெண்கள், மாணவர்கள், தொழிலாளர்கள் மற்றும் ஏழை எளிய மக்களுக்கான மத்திய அரசு உதவிகள், தகுதிகள் மற்றும் விண்ணப்பிக்கும் முழு விவரங்கள்.'
                : 'Explore PM schemes — financial aid, housing, pensions, health insurance, and business loans available for all citizens.',
            style: const TextStyle(
              fontSize: 12,
              color: SchemeColors.grey,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 14),

          // Search Bar
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade300),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: isTa
                    ? 'திட்டத்தின் பெயர் அல்லது பலனைத் தேடுங்கள்...'
                    : 'Search schemes by name or keyword...',
                hintStyle: const TextStyle(fontSize: 12.5, color: SchemeColors.grey),
                prefixIcon: const Icon(Icons.search, color: SchemeColors.orange, size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18, color: SchemeColors.grey),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGovTypeTabs(bool isTa) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: _govTabItem(
              label: isTa ? 'அனைத்தும்' : 'All',
              count: _allSchemes.length,
              isSelected: _selectedGovFilter == 'all',
              onTap: () => setState(() => _selectedGovFilter = 'all'),
            ),
          ),
          Expanded(
            child: _govTabItem(
              label: isTa ? 'மத்திய அரசு' : 'Central Govt',
              icon: Icons.flag,
              isSelected: _selectedGovFilter == 'central',
              onTap: () => setState(() => _selectedGovFilter = 'central'),
              accentColor: SchemeColors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _govTabItem({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    IconData? icon,
    int? count,
    Color? accentColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 13,
                color: isSelected ? (accentColor ?? SchemeColors.navy) : SchemeColors.grey,
              ),
              const SizedBox(width: 4),
            ],
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  color: isSelected ? SchemeColors.navy : SchemeColors.grey,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // CATEGORY FILTER BAR
  Widget _buildCategoryFilterBar(bool isTa) {
    final categories = [
      {'key': 'all', 'label': isTa ? 'அனைத்தும்' : 'All', 'icon': Icons.apps},
      {'key': 'farmers', 'label': isTa ? '🌾 விவசாயிகள்' : '🌾 Farmers', 'icon': Icons.agriculture},
      {'key': 'women', 'label': isTa ? '👩 பெண்கள்' : '👩 Women', 'icon': Icons.family_restroom},
      {'key': 'health', 'label': isTa ? '🏥 மருத்துவம்' : '🏥 Health', 'icon': Icons.medical_services},
      {'key': 'education', 'label': isTa ? '🎓 கல்வி' : '🎓 Education', 'icon': Icons.school},
      {'key': 'housing', 'label': isTa ? '🏠 வீடுகள்' : '🏠 Housing', 'icon': Icons.home},
      {'key': 'business', 'label': isTa ? '💼 வணிகம்' : '💼 Business', 'icon': Icons.business_center},
      {'key': 'social', 'label': isTa ? '🛡️ ஓய்வூதியம்' : '🛡️ Pension', 'icon': Icons.shield},
    ];

    return SizedBox(
      height: 42,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = _selectedCategory == cat['key'];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedCategory = cat['key'] as String;
                });
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? SchemeColors.navy : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? SchemeColors.navy : Colors.grey.shade300,
                  ),
                ),
                child: Center(
                  child: Text(
                    cat['label'] as String,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                      color: isSelected ? Colors.white : SchemeColors.navy,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // SCHEME CARD
  Widget _buildSchemeCard(SchemeModel scheme, bool isTa) {
    final isCentral = scheme.govType == 'central';
    final govBadgeColor = isCentral ? SchemeColors.orange : SchemeColors.green;
    final govBadgeText = isCentral
        ? (isTa ? 'மத்திய அரசு திட்டம்' : 'Central Govt Scheme')
        : (isTa ? 'தமிழ்நாடு அரசு திட்டம்' : 'Tamil Nadu State Scheme');

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
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
          // Top Colored Accent Stripe
          Container(
            height: 3.5,
            width: double.infinity,
            color: govBadgeColor,
          ),

          Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Badges Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Govt Type Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: govBadgeColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isCentral ? Icons.flag_rounded : Icons.account_balance_rounded,
                            size: 12,
                            color: govBadgeColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            govBadgeText,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: govBadgeColor,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Scheme Icon Squircle
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: scheme.color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(scheme.icon, size: 18, color: scheme.color),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Scheme Title
                Text(
                  isTa ? scheme.titleTa : scheme.titleEn,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: SchemeColors.navy,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 6),

                // Headline Benefit Pill (Highlight)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF86EFAC)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.stars_rounded, size: 14, color: Color(0xFF15803D)),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          isTa ? scheme.benefitBadgeTa : scheme.benefitBadgeEn,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF15803D),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // Short Description
                Text(
                  isTa ? scheme.descTa : scheme.descEn,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: SchemeColors.grey,
                    height: 1.45,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),

                // Divider
                const Divider(height: 1, color: SchemeColors.borderLight),
                const SizedBox(height: 10),

                // Action Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Eligibility Preview Snippet
                    Flexible(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.people_outline, size: 14, color: SchemeColors.grey),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              isTa ? 'தகுதி: ' : 'Eligibility: ',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: SchemeColors.navy),
                            ),
                          ),
                          Flexible(
                            child: Text(
                              isTa ? scheme.eligibilityTa : scheme.eligibilityEn,
                              style: const TextStyle(fontSize: 11, color: SchemeColors.grey),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // "View Details" Pill Button
                    InkWell(
                      onTap: () => _openSchemeDetailsModal(scheme, isTa),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: SchemeColors.navy,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              isTa ? 'விவரம்' : 'Details',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.arrow_forward, size: 12, color: Colors.white),
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

  // BOTTOM SHEET DETAILS MODAL
  void _openSchemeDetailsModal(SchemeModel scheme, bool isTa) {
    final isCentral = scheme.govType == 'central';
    final govBadgeColor = isCentral ? SchemeColors.orange : SchemeColors.green;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.88,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Drag Handle
              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 6),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Modal Header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: scheme.color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(scheme.icon, color: scheme.color, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: govBadgeColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              isCentral
                                  ? (isTa ? 'மத்திய அரசு திட்டம்' : 'Central Scheme')
                                  : (isTa ? 'தமிழ்நாடு அரசு திட்டம்' : 'Tamil Nadu State Scheme'),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: govBadgeColor,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isTa ? scheme.titleTa : scheme.titleEn,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: SchemeColors.navy,
                              height: 1.25,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 22, color: SchemeColors.grey),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: SchemeColors.borderLight),

              // Scrollable Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Highlight Benefit Box
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF86EFAC)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.stars_rounded, color: Color(0xFF15803D), size: 22),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                isTa ? scheme.benefitBadgeTa : scheme.benefitBadgeEn,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF15803D),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Section 1: Overview
                      _modalSectionHeader(
                        icon: Icons.info_outline,
                        color: SchemeColors.blue,
                        title: isTa ? 'திட்டத்தின் நோக்கம்' : 'Scheme Overview',
                      ),
                      const SizedBox(height: 6),
                      Text(
                        isTa ? scheme.descTa : scheme.descEn,
                        style: const TextStyle(fontSize: 12.5, color: SchemeColors.textDark, height: 1.55),
                      ),
                      const SizedBox(height: 18),

                      // Section 2: Key Benefits
                      _modalSectionHeader(
                        icon: Icons.card_giftcard,
                        color: SchemeColors.green,
                        title: isTa ? 'கிடைக்கும் பயன்கள்' : 'Key Benefits & Assistance',
                      ),
                      const SizedBox(height: 8),
                      ...((isTa ? scheme.benefitsListTa : scheme.benefitsListEn).map(
                        (b) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.check_circle, size: 16, color: SchemeColors.green),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  b,
                                  style: const TextStyle(fontSize: 12, color: SchemeColors.textDark, height: 1.4),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )),
                      const SizedBox(height: 16),

                      // Section 3: Eligibility
                      _modalSectionHeader(
                        icon: Icons.how_to_reg,
                        color: SchemeColors.purple,
                        title: isTa ? 'யார் யாருக்குத் தகுதி?' : 'Eligibility Criteria',
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: SchemeColors.lightBg,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: SchemeColors.borderLight),
                        ),
                        child: Text(
                          isTa ? scheme.eligibilityTa : scheme.eligibilityEn,
                          style: const TextStyle(fontSize: 12, color: SchemeColors.textDark, height: 1.5),
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Section 4: Required Documents
                      _modalSectionHeader(
                        icon: Icons.folder_shared_outlined,
                        color: SchemeColors.orange,
                        title: isTa ? 'தேவையான ஆவணங்கள்' : 'Required Documents',
                      ),
                      const SizedBox(height: 8),
                      ...((isTa ? scheme.docsTa : scheme.docsEn).map(
                        (doc) => Padding(
                          padding: const EdgeInsets.only(bottom: 5),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.task_alt, size: 15, color: SchemeColors.orange),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  doc,
                                  style: const TextStyle(fontSize: 12, color: SchemeColors.textDark),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )),
                      const SizedBox(height: 18),

                      // Section 5: How to Apply
                      _modalSectionHeader(
                        icon: Icons.touch_app_outlined,
                        color: SchemeColors.amber,
                        title: isTa ? 'விண்ணப்பிக்கும் முறை' : 'How to Apply',
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFBEB),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFFDE68A)),
                        ),
                        child: Text(
                          isTa ? scheme.applyMethodTa : scheme.applyMethodEn,
                          style: const TextStyle(fontSize: 12, color: Color(0xFF92400E), height: 1.5),
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Section 6: Official Portal & Helpline
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: SchemeColors.navy,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isTa ? 'அதிகாரப்பூர்வ உதவித் தகவல்' : 'Official Portal & Helpline',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.language, size: 15, color: SchemeColors.saffron),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    scheme.officialPortal,
                                    style: const TextStyle(fontSize: 11.5, color: Colors.white70),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.phone_in_talk, size: 15, color: SchemeColors.green),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    scheme.helpline,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
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
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _modalSectionHeader({
    required IconData icon,
    required Color color,
    required String title,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: SchemeColors.navy),
        ),
      ],
    );
  }

  // EMPTY SEARCH STATE
  Widget _buildEmptyState(bool isTa) {
    return Container(
      margin: const EdgeInsets.all(32),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          const Icon(Icons.search_off_rounded, size: 48, color: SchemeColors.grey),
          const SizedBox(height: 12),
          Text(
            isTa ? 'திட்டங்கள் எதுவும் கிடைக்கவில்லை' : 'No Schemes Found',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: SchemeColors.navy),
          ),
          const SizedBox(height: 6),
          Text(
            isTa
                ? 'உங்கள் தேடல் சொல்லிற்கு ஏற்ற திட்டம் இல்லை. வேறு சொல்லைப் பயன்படுத்தி தேடவும்.'
                : 'Try searching with different keywords or clear filters.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: SchemeColors.grey),
          ),
          const SizedBox(height: 14),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _selectedGovFilter = 'all';
                _selectedCategory = 'all';
                _searchQuery = '';
                _searchController.clear();
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: SchemeColors.navy,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: Text(isTa ? 'அனைத்து திட்டங்களையும் காண்க' : 'View All Schemes'),
          ),
        ],
      ),
    );
  }

  // FOOTER DISCLAIMER
  Widget _buildFooterDisclaimer(bool isTa) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFED7AA)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: SchemeColors.amber, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              isTa
                  ? 'குறிப்பு: இத்தளத்தில் உள்ள அரசு நலத்திட்ட விவரங்கள் பொதுமக்களின் விழிப்புணர்விற்காக மட்டுமே வழங்கப்பட்டுள்ளன. திட்டங்களுக்கான விதிமுறைகள் மற்றும் மானியத் தொகைகள் அரசு அறிவிப்புகளுக்கு ஏற்ப மாறுபடலாம். விண்ணப்பங்களை அதிகாரப்பூர்வ அரசு இ-சேவை மையங்கள் அல்லது இணையதளம் மூலம் சமர்ப்பிக்கவும்.'
                  : 'Disclaimer: The scheme details presented here are compiled for citizen civic facilitation and awareness. Official guidelines, eligibility, and grant amounts are subject to change as per official government gazette notifications.',
              style: const TextStyle(fontSize: 11, color: SchemeColors.textDark, height: 1.45),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // ALL COMPREHENSIVE SCHEMES DATA REPOSITORY (CENTRAL & TN STATE)
  // -------------------------------------------------------------
  List<SchemeModel> _initializeSchemes() {
    return const [
      // -----------------------------------------------------------
      // 1. CENTRAL GOVERNMENT SCHEMES (12 SCHEMES)
      // -----------------------------------------------------------
      SchemeModel(
        id: 'pm_kisan',
        govType: 'central',
        category: 'farmers',
        titleTa: 'பிரதம மந்திரி கிசான் சம்மான் நிதி (PM-KISAN)',
        titleEn: 'Pradhan Mantri Kisan Samman Nidhi (PM-KISAN)',
        benefitBadgeTa: 'ஆண்டுக்கு ₹6,000 நேரடி வங்கி வரவு',
        benefitBadgeEn: '₹6,000/year Direct Bank Credit',
        descTa: 'விவசாய குடும்பங்களுக்கு விவசாய இடுபொருட்கள் வாங்குவதற்கும் அன்றாடத் தேவைகளுக்கும் நிதி ஆதரவு வழங்கும் மத்திய அரசின் முதன்மைத் திட்டம்.',
        descEn: 'Income support scheme for all landholding farmers families across India providing guaranteed financial assistance.',
        eligibilityTa: 'சொந்தமாக சாகுபடி நிலம் வைத்துள்ள அனைத்து சிறு, குறு மற்றும் நடுத்தர விவசாய குடும்பங்கள்.',
        eligibilityEn: 'All landholding farmer families having cultivable landholding in their names.',
        benefitsListTa: [
          'ஆண்டுக்கு ₹6,000 மூன்று சம தவணைகளாக (தலா ₹2,000) நேரடியாக வங்கிக் கணக்கில் வரவு வைக்கப்படுகிறது.',
          'இடைத்தரகர்கள் இன்றி ஆதார் இணைக்கப்பட்ட வங்கிக் கணக்கிற்கு நேரடிப் பணப் பரிமாற்றம் (DBT).',
          'உரங்கள், விதைகள் மற்றும் விவசாய உபகரணங்கள் வாங்க பயனுள்ளதாக அமைகிறது.',
        ],
        benefitsListEn: [
          'Financial benefit of ₹6,000 per year per family payable in three equal four-monthly installments of ₹2,000.',
          'Direct Benefit Transfer (DBT) into Aadhaar-seeded bank accounts with zero leakage.',
          'Ensures timely liquidity for crop inputs, seeds, and fertilizers.',
        ],
        docsTa: ['ஆதார் அட்டை (Aadhaar Card)', 'பட்டா / சிட்டா நில உரிமை ஆவணங்கள்', 'வங்கி கணக்குப் புத்தகம் (Aadhaar Linked)', 'குடும்ப அட்டை (Ration Card)'],
        docsEn: ['Aadhaar Card', 'Land ownership records (Patta / Chitta)', 'Bank Passbook with Aadhaar seeding', 'Ration Card'],
        applyMethodTa: 'PM-KISAN போர்டல் (pmkisan.gov.in) அல்லது உங்கள் கிராம பொது சேவை மையம் (CSC) அல்லது வேளாண்மைத் துறை அலுவலகம் வழியாக பதிவு செய்யலாம்.',
        applyMethodEn: 'Apply online at pmkisan.gov.in or visit your nearest Common Service Centre (CSC) / Agriculture Extension Office.',
        officialPortal: 'https://pmkisan.gov.in',
        helpline: '155261 / 1800-115-526',
        icon: Icons.agriculture_rounded,
        color: SchemeColors.green,
      ),

      SchemeModel(
        id: 'pmay',
        govType: 'central',
        category: 'housing',
        titleTa: 'பிரதான் மந்திரி ஆவாஸ் யோஜனா (PMAY - வீட்டு வசதி திட்டம்)',
        titleEn: 'Pradhan Mantri Awas Yojana (PMAY Housing)',
        benefitBadgeTa: 'வீடு கட்ட ₹1.2L முதல் ₹2.5L வரை அரசு மானியம்',
        benefitBadgeEn: '₹1.2 Lakh to ₹2.5 Lakh Housing Subsidy',
        descTa: 'வீடற்ற ஏழை எளிய மற்றும் நடுத்தரக் குடும்பங்கள் சொந்தமாகக் கான்கிரீட் பக்கா வீடு கட்டிக்கொள்ள அரசு மானியம் வழங்கும் திட்டம்.',
        descEn: 'Credit-linked subsidy and direct financial grant scheme ensuring a pucca concrete house for all homeless and rural families.',
        eligibilityTa: 'சொந்தமாக பக்கா வீடு இல்லாத பொருளாதாரத்தில் நலிவடைந்த பிரிவினர் (EWS) மற்றும் குறைந்த வருவாய் பிரிவினர் (LIG).',
        eligibilityEn: 'Families who do not own a pucca house anywhere in India with annual household income up to ₹3-6 Lakhs.',
        benefitsListTa: [
          'கிராமப்புறங்களில் வீடு கட்ட ₹1.20 லட்சம் முதல் ₹1.30 லட்சம் வரை நேரடி மானியம்.',
          'நகர்ப்புறங்களில் வீட்டுக் கடனுக்கான வட்டி மானியமாக ₹2.50 லட்சம் வரை சலுகை.',
          'கழிப்பறை வசதி மற்றும் 90 நாள் ஊரக வேலைவாய்ப்புத் திட்டக் கூலி கூடுதல் பலனாகக் கிடைக்கிறது.',
        ],
        benefitsListEn: [
          'Direct grant of ₹1.20 Lakh to ₹1.30 Lakh for rural beneficiaries.',
          'Interest subsidy up to ₹2.50 Lakh on home loans for urban beneficiaries.',
          'Additional toilet grant of ₹12,000 under Swachh Bharat and 90 days MGNREGA wages.',
        ],
        docsTa: ['ஆதார் அட்டை', 'வருமானச் சான்றிதழ்', 'நில உரிமைப் பத்திரம் / மனைப் பட்டா', 'வங்கி கணக்குப் புத்தகம்'],
        docsEn: ['Aadhaar Card', 'Income Certificate', 'Land ownership deed / House site Patta', 'Bank Passbook'],
        applyMethodTa: 'கிராம ஊராட்சி அலுவலகம் அல்லது நகராட்சி அலுவலகம் அல்லது pmaymis.gov.in இணையதளம் மூலம் விண்ணப்பிக்கலாம்.',
        applyMethodEn: 'Apply through your Village Panchayat, Municipal Corporation, or online at pmaymis.gov.in.',
        officialPortal: 'https://pmaymis.gov.in',
        helpline: '011-23063285 / 1800-11-6163',
        icon: Icons.home_work_rounded,
        color: SchemeColors.blue,
      ),

      SchemeModel(
        id: 'pmjay',
        govType: 'central',
        category: 'health',
        titleTa: 'ஆயுஷ்மான் பாரத் - பிரதம மந்திரி ஜன் ஆரோக்கிய யோஜனா (PM-JAY)',
        titleEn: 'Ayushman Bharat - PM-JAY Health Insurance',
        benefitBadgeTa: 'குடும்பத்திற்கு ₹5 லட்சம் இலவச மருத்துவக் காப்பீடு',
        benefitBadgeEn: '₹5 Lakh Free Cashless Health Cover',
        descTa: 'உலகின் மிகப்பெரிய அரசு மருத்துவக் காப்பீட்டுத் திட்டம். ஏழைக் குடும்பங்களுக்கு அரசு மற்றும் தனியார் மருத்துவமனைகளில் இலவச சிகிச்சை வழங்குகிறது.',
        descEn: 'Worlds largest government-funded healthcare scheme providing secondary and tertiary hospitalization cover.',
        eligibilityTa: 'SECC பொருளாதாரக் கணக்கெடுப்பின்படி தகுதி பெற்ற நலிவடைந்த குடும்பங்கள் மற்றும் 70 வயது நிரம்பிய அனைத்து மூத்த குடிமக்கள்.',
        eligibilityEn: 'Identified poor and vulnerable families under SECC 2011 and all senior citizens aged 70+ irrespective of income.',
        benefitsListTa: [
          'குடும்பத்தில் உள்ள அனைவருக்கும் சேர்த்து ஆண்டுக்கு ₹5,00,000 வரை கட்டணமில்லா பணமில்லா (Cashless) சிகிச்சை.',
          '1,900-க்கும் மேற்பட்ட அறுவை சிகிச்சைகள், மருத்துவப் பரிசோதனைகள் மற்றும் தீவிர சிகிச்சைகள் உள்ளடக்கம்.',
          'அரசு மற்றும் அங்கீகரிக்கப்பட்ட முன்னணி தனியார் மருத்துவமனைகளில் நாடு முழுவதும் செல்லுபடியாகும்.',
        ],
        benefitsListEn: [
          'Cashless and paperless access to healthcare services up to ₹5 Lakh per family per year.',
          'Covers over 1,900 medical procedures including oncology, cardiology, neurosurgery.',
          'Portable across all empaneled public and private hospitals across India.',
        ],
        docsTa: ['ஆதார் அட்டை', 'ரேஷன் அட்டை (Ration Card)', 'ஆயுஷ்மான் பாரத் கோல்டன் கார்டு (PM-JAY Card)'],
        docsEn: ['Aadhaar Card', 'Ration Card', 'Ayushman Golden Card'],
        applyMethodTa: 'அருகிலுள்ள அரசு பொது மருத்துவமனை, இ-சேவை மையம் அல்லது beneficiary.nha.gov.in தளம் மூலம் உடனடியாக கோல்டன் கார்டு பெறலாம்.',
        applyMethodEn: 'Get your Ayushman Card at any empaneled hospital, CSC centre, or via beneficiary.nha.gov.in.',
        officialPortal: 'https://beneficiary.nha.gov.in',
        helpline: '14555 / 1800-111-565',
        icon: Icons.health_and_safety_rounded,
        color: SchemeColors.red,
      ),

      SchemeModel(
        id: 'pmuy',
        govType: 'central',
        category: 'women',
        titleTa: 'பிரதம மந்திரி உஜ்வாலா யோஜனா (PMUY - இலவச கேஸ் திட்டம்)',
        titleEn: 'Pradhan Mantri Ujjwala Yojana (PMUY)',
        benefitBadgeTa: 'இலவச எல்.பி.ஜி சிலிண்டர் இணைப்பு + ₹300 மானியம்',
        benefitBadgeEn: 'Free LPG Connection + ₹300 Subsidy',
        descTa: 'கிராமப்புற மற்றும் ஏழைக் குடும்பப் பெண்களுக்குப் புகையற்ற சமையல் சூழலை உறுதி செய்ய இலவச எரிவாயு இணைப்பு வழங்கும் திட்டம்.',
        descEn: 'Safeguards the health of women by providing them with clean cooking fuel (LPG) free of security deposit.',
        eligibilityTa: '18 வயது நிரம்பிய வறுமைக் கோட்டிற்கு கீழ் உள்ள (BPL) குடும்பத்தின் பெண் உறுப்பினர்.',
        eligibilityEn: 'Adult woman belonging to an underprivileged household without an active LPG connection.',
        benefitsListTa: [
          'இலவச எல்.பி.ஜி கேஸ் இணைப்பு (வைப்புத் தொகை இல்லை).',
          'முதல் சிலிண்டர் ரீஃபில் மற்றும் அடுப்பு இலவசமாக வழங்கப்படுகிறது.',
          'ஒவ்வொரு சிலிண்டருக்கும் ₹300 வரை நேரடி வங்கி மானியம் வழங்கப்படுகிறது.',
        ],
        benefitsListEn: [
          'Free LPG connection with zero security deposit.',
          'First LPG refill and cooking stove provided completely free of charge.',
          'Targeted direct subsidy of ₹300 per 14.2 kg cylinder credited to bank account.',
        ],
        docsTa: ['குடும்பத் தலைவியின் ஆதார் அட்டை', 'குடும்ப அட்டை (Ration Card)', 'வங்கி கணக்குப் புத்தகம்'],
        docsEn: ['Aadhaar Card of woman applicant', 'Ration Card', 'Bank Passbook'],
        applyMethodTa: 'அருகிலுள்ள எல்.பி.ஜி கேஸ் ஏஜென்சியில் (Indane / Bharat Gas / HP Gas) அல்லது pmuy.gov.in வழியாக விண்ணப்பிக்கலாம்.',
        applyMethodEn: 'Apply directly at your nearest LPG distributorship or online via pmuy.gov.in.',
        officialPortal: 'https://www.pmuy.gov.in',
        helpline: '1906 / 1800-266-6696',
        icon: Icons.local_fire_department_rounded,
        color: SchemeColors.orange,
      ),

      SchemeModel(
        id: 'pmmy',
        govType: 'central',
        category: 'business',
        titleTa: 'பிரதான் மந்திரி முத்ரா கடன் திட்டம் (PMMY)',
        titleEn: 'Pradhan Mantri Mudra Yojana (PMMY)',
        benefitBadgeTa: 'பிணையில்லா தொழில் கடன் ₹50,000 முதல் ₹20 லட்சம் வரை',
        benefitBadgeEn: 'Collateral-free Business Loan up to ₹20L',
        descTa: 'சிறு மற்றும் குறு தொழில் முனைவோர், வியாபாரிகளுக்கு சொத்து பிணையின்றி வங்கிகள் மூலம் குறைந்த வட்டியில் கடன் வழங்கும் திட்டம்.',
        descEn: 'Collateral-free institutional micro-credit to small and micro enterprises across manufacturing, trading, and services.',
        eligibilityTa: 'புதிய தொழில் தொடங்க விரும்புவோர் மற்றும் இருக்கும் தொழிலை விரிவாக்கம் செய்ய விரும்பும் சிறு தொழில் முனைவோர்.',
        eligibilityEn: 'Any Indian citizen who has a business plan for non-farm income-generating activity.',
        benefitsListTa: [
          'சிசு கடன் (Shishu): ₹50,000 வரை புதிய தொழிலுக்கு.',
          'கிஷோர் கடன் (Kishore): ₹50,000 முதல் ₹5 லட்சம் வரை.',
          'தருண் கடன் (Tarun): ₹5 லட்சம் முதல் ₹20 லட்சம் வரை பிணையமின்றி கடன்.',
        ],
        benefitsListEn: [
          'Shishu: Loans up to ₹50,000 for starting new enterprises.',
          'Kishore: Loans from ₹50,000 up to ₹5,00,000 for purchasing equipment.',
          'Tarun: Loans from ₹5,00,000 up to ₹20,00,000 with zero collateral required.',
        ],
        docsTa: ['ஆதார் அட்டை', 'பான் கார்டு (PAN Card)', 'தொழில் திட்ட விவர அறிக்கை (Business Plan)', 'வங்கி பரிவர்த்தனை ஆவணம்'],
        docsEn: ['Aadhaar Card', 'PAN Card', 'Business proposal / Project report', '6 months Bank statement'],
        applyMethodTa: 'அனைத்து தேசியமயமாக்கப்பட்ட வங்கிகள், கிராமப்புற வங்கிகள் அல்லது udyamimitra.in போர்டல் வழியாக விண்ணப்பிக்கலாம்.',
        applyMethodEn: 'Apply at any commercial bank, regional rural bank, or online at udyamimitra.in.',
        officialPortal: 'https://www.mudra.org.in',
        helpline: '1800-180-1111 / 1800-11-0001',
        icon: Icons.payments_rounded,
        color: SchemeColors.emerald,
      ),

      SchemeModel(
        id: 'pm_vishwakarma',
        govType: 'central',
        category: 'business',
        titleTa: 'பிரதம மந்திரி விஸ்வகர்மா திட்டம் (PM Vishwakarma)',
        titleEn: 'PM Vishwakarma Scheme for Traditional Artisans',
        benefitBadgeTa: '₹3L குறைந்த வட்டிக் கடன் + ₹15,000 டூல் கிட் உதவி',
        benefitBadgeEn: '₹3L Soft Loan at 5% + ₹15,000 Toolkit Grant',
        descTa: 'பாரம்பரியக் கைவினைஞர்கள், தச்சர்கள், கொல்லர்கள், தையல்காரர்கள் உள்ளிட்ட 18 வகை கைவினைத் தொழிலாளர்களுக்கு நிதி மற்றும் திறன் ஆதரவு.',
        descEn: 'End-to-end holistic support for traditional artisans and craftspeople with training, certification, and capital.',
        eligibilityTa: 'பாரம்பரிய கைவினைத் தொழில்களில் ஈடுபடும் குடும்பத்தைச் சேர்ந்த 18 வயது நிரம்பிய கைவினைஞர்.',
        eligibilityEn: 'Artisans and craftspeople engaged in any of the 18 recognized traditional trades.',
        benefitsListTa: [
          'ரூ.15,000 மதிப்பிலான நவீன உபகரணங்கள் வாங்க இலவச இ-வவுச்சர்.',
          'முதல் தவணையில் ₹1 லட்சம், இரண்டாம் தவணையில் ₹2 லட்சம் என 5% சலுகை வட்டியில் கடன்.',
          'தினசரி ₹500 உதவித்தொகையுடன் கூடிய இலவச நவீன திறன் மேம்பாட்டுப் பயிற்சி.',
        ],
        benefitsListEn: [
          'Financial grant of ₹15,000 for purchasing modern toolkits.',
          'Collateral-free credit support up to ₹3 Lakh (₹1L in 1st tranche, ₹2L in 2nd tranche) at only 5% interest.',
          'Skill training with a daily stipend of ₹500 and PM Vishwakarma Certificate.',
        ],
        docsTa: ['ஆதார் அட்டை', 'குடும்ப அட்டை (Ration Card)', 'தொழில் சான்று', 'வங்கி கணக்குப் புத்தகம்'],
        docsEn: ['Aadhaar Card', 'Ration Card', 'Trade proof / Self declaration', 'Bank details'],
        applyMethodTa: 'கிராமப் பொது சேவை மையங்கள் (CSC) வழியாக pmvishwakarma.gov.in தளத்தில் பயோமெட்ரிக் சரிபார்ப்புடன் பதிவு செய்யவும்.',
        applyMethodEn: 'Register via Common Service Centre (CSC) with Aadhaar biometric authentication at pmvishwakarma.gov.in.',
        officialPortal: 'https://pmvishwakarma.gov.in',
        helpline: '1800-267-7777 / 011-23061500',
        icon: Icons.handyman_rounded,
        color: SchemeColors.amber,
      ),

      SchemeModel(
        id: 'pm_svanidhi',
        govType: 'central',
        category: 'business',
        titleTa: 'பி.எம். ஸ்வநிதி திட்டம் (PM SVANidhi - தெருவோர வியாபாரிகள் கடன்)',
        titleEn: 'PM SVANidhi Micro-Credit Scheme',
        benefitBadgeTa: 'தெருவோர வியாபாரிகளுக்கு ₹10,000 முதல் ₹50,000 கடன்',
        benefitBadgeEn: 'Working Capital up to ₹50,000 for Vendors',
        descTa: 'தெருவோரக் கடைக்காரர்கள் மற்றும் நடைபாதை வியாபாரிகளுக்கு குறைந்த வட்டியில் மூலதனக் கடன் வழங்கி வாழ்வாதாரத்தை உயர்த்தும் திட்டம்.',
        descEn: 'Special micro-credit facility empowering street vendors with affordable working capital loans.',
        eligibilityTa: 'நகர்ப்புறங்கள் மற்றும் கிராமப்புறங்களில் நடைபாதை, தள்ளுவண்டி வியாபாரம் செய்யும் தெருவோர வியாபாரிகள்.',
        eligibilityEn: 'Street vendors in urban and peri-urban areas holding a vending certificate or recommendation letter.',
        benefitsListTa: [
          'முதற்கட்டமாக ₹10,000 பிணையில்லா கடன் (1 வருடத்தில் திரும்ப செலுத்தினால் அடுத்தகட்ட கடன்).',
          'இரண்டாம் தவணையில் ₹20,000 மற்றும் மூன்றாம் தவணையில் ₹50,000 வரை கடன் உயர்வு.',
          'சரியான நேரத்தில் திரும்ப செலுத்தினால் 7% வட்டி மானியம் மற்றும் டிஜிட்டல் பரிவர்த்தனைகளுக்கு கேஷ்பேக்.',
        ],
        benefitsListEn: [
          'Initial working capital loan up to ₹10,000 repayable in monthly installments over 1 year.',
          'Enhanced loan of ₹20,000 on timely repayment, and up to ₹50,000 in the 3rd tranche.',
          '7% interest subsidy credited directly to bank account + digital cashback up to ₹1,200/year.',
        ],
        docsTa: ['ஆதார் அட்டை', 'வியாபார அடையாள அட்டை (Vendor ID / LoR)', 'வங்கி கணக்குப் புத்தகம்'],
        docsEn: ['Aadhaar Card', 'Vending Identity Card or Letter of Recommendation', 'Bank Passbook'],
        applyMethodTa: 'நகராட்சி அலுவலகம், இ-சேவை மையம் அல்லது pmsvanidhi.mohua.gov.in தளம் மூலம் விண்ணப்பிக்கலாம்.',
        applyMethodEn: 'Apply online through pmsvanidhi.mohua.gov.in or visit your local Municipal Corporation office.',
        officialPortal: 'https://pmsvanidhi.mohua.gov.in',
        helpline: '1800-111-979',
        icon: Icons.storefront_rounded,
        color: SchemeColors.skyBlue,
      ),

      SchemeModel(
        id: 'pmsby',
        govType: 'central',
        category: 'health',
        titleTa: 'பிரதம மந்திரி சுரக்ஷா பீமா யோஜனா (PMSBY - விபத்து காப்பீடு)',
        titleEn: 'Pradhan Mantri Suraksha Bima Yojana (PMSBY)',
        benefitBadgeTa: 'ஆண்டுக்கு வெறும் ₹20-ல் ₹2 லட்சம் விபத்து காப்பீடு',
        benefitBadgeEn: '₹2 Lakh Accident Insurance at ₹20/year',
        descTa: 'அனைத்து மக்களும் எளிதில் பெறக்கூடிய மலிவு விலை விபத்து காப்பீட்டுத் திட்டம். விபத்தினால் ஏற்படும் இறப்பு அல்லது ஊனத்திற்கு இழப்பீடு வழங்குகிறது.',
        descEn: 'Most affordable government accidental death and permanent disability insurance scheme.',
        eligibilityTa: '18 முதல் 70 வயதுக்குட்பட்ட வங்கிக் கணக்கு வைத்துள்ள அனைத்து இந்தியக் குடிமக்கள்.',
        eligibilityEn: 'All savings bank account holders aged between 18 and 70 years.',
        benefitsListTa: [
          'விபத்து காரணமாக உயிரிழப்பு ஏற்பட்டால் நாமினிக்கு ₹2,00,000 முழு இழப்பீடு.',
          'விபத்தினால் நிரந்தர முழு ஊனம் ஏற்பட்டால் ₹2,00,000 மற்றும் பகுதி ஊனத்திற்கு ₹1,00,000.',
          'ஆண்டு பிரீமியம் வெறும் ₹20 மட்டுமே (வங்கிக் கணக்கிலிருந்து தானாகப் பிடித்தம் செய்யப்படும்).',
        ],
        benefitsListEn: [
          'Accidental death coverage of ₹2 Lakh to nominee.',
          'Coverage of ₹2 Lakh for permanent total disability and ₹1 Lakh for partial disability.',
          'Extremely nominal annual premium of just ₹20 auto-debited once a year.',
        ],
        docsTa: ['ஆதார் அட்டை', 'சேமிப்பு வங்கிக் கணக்குப் புத்தகம்'],
        docsEn: ['Aadhaar Card', 'Savings Bank Account Passbook'],
        applyMethodTa: 'உங்கள் சேமிப்புக் கணக்கு உள்ள வங்கிக் கிளையில் படிவம் வழங்கி அல்லது நெட் பேங்கிங் மூலம் உடனடியாகச் செயல்படுத்தலாம்.',
        applyMethodEn: 'Enroll at your bank branch or activate through Net Banking / Mobile Banking app.',
        officialPortal: 'https://www.jansuraksha.gov.in',
        helpline: '1800-180-1111',
        icon: Icons.car_crash_rounded,
        color: SchemeColors.blue,
      ),

      SchemeModel(
        id: 'pmjjby',
        govType: 'central',
        category: 'health',
        titleTa: 'பிரதம மந்திரி ஜீவன் ஜோதி பீமா யோஜனா (PMJJBY - ஆயுள் காப்பீடு)',
        titleEn: 'Pradhan Mantri Jeevan Jyoti Bima Yojana (PMJJBY)',
        benefitBadgeTa: 'ஆண்டுக்கு ₹436-ல் ₹2 லட்சம் ஆயுள் காப்பீடு',
        benefitBadgeEn: '₹2 Lakh Life Cover at ₹436/year',
        descTa: 'எந்தக் காரணத்தினாலும் உயிரிழப்பு ஏற்பட்டால் குடும்பத்தின் பொருளாதாரப் பாதுகாப்பிற்கு ₹2 லட்சம் வழங்கும் மத்திய அரசின் ஆயுள் காப்பீட்டுத் திட்டம்.',
        descEn: 'One-year renewable life insurance scheme offering ₹2 Lakh cover for death due to any reason.',
        eligibilityTa: '18 முதல் 50 வயதுக்குட்பட்ட வங்கிக் கணக்கு வைத்துள்ள இந்தியக் குடிமக்கள்.',
        eligibilityEn: 'Any individual aged 18 to 50 years with an active savings bank account.',
        benefitsListTa: [
          'எந்தக் காரணத்தினாலும் உயிரிழப்பு ஏற்பட்டால் நாமினிக்கு ₹2,00,000 உடனடி காப்பீட்டு நிதி.',
          'மருத்துவப் பரிசோதனை ஏதும் தேவையின்றி எளிய முறையில் காப்பீடு வழங்கப்படுகிறது.',
          'ஆண்டு பிரீமியம் ₹436 மட்டுமே (ஆண்டுதோறும் மே மாதத்தில் தானாகப் பிடித்தம்).',
        ],
        benefitsListEn: [
          'Risk coverage of ₹2 Lakh in case of death of the insured due to any reason.',
          'No medical examination required for policy enrollment.',
          'Affordable annual premium of ₹436 automatically debited from savings account.',
        ],
        docsTa: ['ஆதார் அட்டை', 'சேமிப்பு வங்கிக் கணக்கு'],
        docsEn: ['Aadhaar Card', 'Savings Bank Account'],
        applyMethodTa: 'உங்கள் சேமிப்புக் கணக்கு உள்ள வங்கிக் கிளையில் அல்லது வங்கி மொபைல் ஆப் வழியாக செயல்படுத்தலாம்.',
        applyMethodEn: 'Enroll directly via your bank branch, NetBanking, or mobile banking portal.',
        officialPortal: 'https://www.jansuraksha.gov.in',
        helpline: '1800-180-1111',
        icon: Icons.security_rounded,
        color: SchemeColors.navy,
      ),

      SchemeModel(
        id: 'apy',
        govType: 'central',
        category: 'social',
        titleTa: 'அடல் ஓய்வூதியத் திட்டம் (Atal Pension Yojana - APY)',
        titleEn: 'Atal Pension Yojana (APY Pension)',
        benefitBadgeTa: 'மாதம் ₹1,000 முதல் ₹5,000 வரை உத்தரவாத ஓய்வூதியம்',
        benefitBadgeEn: 'Guaranteed Pension up to ₹5,000/month',
        descTa: 'அமைப்புசாரா தொழிலாளர்கள் மற்றும் சாதாரண மக்கள் தங்கள் முதியோர் காலத்தில் மாதாந்திர ஓய்வூதியம் பெறுவதை உறுதி செய்யும் சேமிப்புத் திட்டம்.',
        descEn: 'Guaranteed monthly pension scheme administered by PFRDA for all citizens in the unorganized sector.',
        eligibilityTa: '18 முதல் 40 வயதுக்குட்பட்ட வருமான வரி செலுத்தாத இந்தியக் குடிமக்கள்.',
        eligibilityEn: 'All Indian citizens aged 18 to 40 years who are non-income tax payers.',
        benefitsListTa: [
          '60 வயது பூர்த்தியடைந்தவுடன் வாழ்நாள் முழுவதும் மாதம் ₹1,000, ₹2,000, ₹3,000, ₹4,000 அல்லது ₹5,000 உத்தரவாத ஓய்வூதியம்.',
          'சந்தாதாரரின் மறைவிற்குப் பின் அதே ஓய்வூதியம் அவரது வாழ்க்கைத் துணைக்கு (மனைவி/கணவர்) தொடர்ந்து வழங்கப்படும்.',
          'இருவரின் மறைவிற்குப் பின் மொத்தக் கூட்டுத் தொகை நாமினிக்குத் திருப்பிக் கொடுக்கப்படும்.',
        ],
        benefitsListEn: [
          'Guaranteed monthly pension of ₹1,000 to ₹5,000 from age 60 till lifetime.',
          'After demise of subscriber, same pension is paid to spouse for lifetime.',
          'On demise of both, entire accumulated pension corpus returned to nominee.',
        ],
        docsTa: ['ஆதார் அட்டை', 'சேமிப்பு வங்கிக் கணக்கு', 'நாமினி விவரங்கள்'],
        docsEn: ['Aadhaar Card', 'Savings Bank Account', 'Nominee Details'],
        applyMethodTa: 'வங்கிகள், தபால் நிலையங்கள் அல்லது npscra.nsdl.co.in இணையதளம் மூலம் உடனடியாகத் தொடங்கலாம்.',
        applyMethodEn: 'Subscribe through any commercial bank, post office, or online at npscra.nsdl.co.in.',
        officialPortal: 'https://www.npscra.nsdl.co.in',
        helpline: '1800-110-069',
        icon: Icons.elderly_rounded,
        color: SchemeColors.purple,
      ),

      SchemeModel(
        id: 'ssy',
        govType: 'central',
        category: 'women',
        titleTa: 'செல்வமகள் சேமிப்புத் திட்டம் (Sukanya Samriddhi Yojana)',
        titleEn: 'Sukanya Samriddhi Yojana (SSY Girl Child)',
        benefitBadgeTa: '8.2% அதிக வட்டியுடன் பெண் குழந்தை சேமிப்பு',
        benefitBadgeEn: '8.2% High Interest + Tax Exemption',
        descTa: 'பெண் குழந்தைகளின் உயர்கல்வி மற்றும் திருமணச் செலவுகளுக்கு அதிக வட்டியுடன் கூடிய பாதுகாப்பான மத்திய அரசின் சேமிப்புத் திட்டம்.',
        descEn: 'Government-backed savings scheme for girl child offering high sovereign interest rates and full tax exemption.',
        eligibilityTa: '10 வயதுக்குட்பட்ட பெண் குழந்தைகளின் பெயரில் பெற்றோர் அல்லது பாதுகாவலர் கணக்குத் தொடங்கலாம்.',
        eligibilityEn: 'Parents/guardians of girl child from birth up to age 10 years (maximum 2 girls per family).',
        benefitsListTa: [
          'அரசு சேமிப்புத் திட்டங்களிலேயே மிக அதிகபட்ச வட்டி விகிதம் (தற்போது 8.2% ஆண்டு வட்டி).',
          'ஆண்டுக்கு குறைந்தபட்சம் ₹250 முதல் அதிகபட்சம் ₹1.5 லட்சம் வரை சேமிக்கலாம்.',
          'முதலீடு, வட்டி மற்றும் முதிர்வுத் தொகை என அனைத்திற்கும் பிரிவு 80C கீழ் 100% வருமான வரிவிலக்கு (EEE).',
        ],
        benefitsListEn: [
          'Highest sovereign interest rate among all small savings schemes (currently 8.2% p.a.).',
          'Flexible deposit from minimum ₹250 up to ₹1.5 Lakh per financial year.',
          'Triple Tax Exemption (EEE) under Section 80C on deposit, interest, and maturity amount.',
        ],
        docsTa: ['பெண் குழந்தையின் பிறப்புச் சான்றிதழ் (Birth Certificate)', 'பெற்றோரின் ஆதார் அட்டை', 'புகைப்படம்'],
        docsEn: ['Birth certificate of girl child', 'Parents Aadhaar Card & PAN Card', 'Photographs'],
        applyMethodTa: 'அனைத்து அஞ்சலகங்கள் (Post Office) அல்லது தேசியமயமாக்கப்பட்ட வங்கிகளில் கணக்குத் தொடங்கலாம்.',
        applyMethodEn: 'Open an account at any Indian Post Office or authorized commercial bank branch.',
        officialPortal: 'https://www.indiapost.gov.in',
        helpline: '1800-266-6868',
        icon: Icons.savings_rounded,
        color: SchemeColors.orange,
      ),

      SchemeModel(
        id: 'jjm',
        govType: 'central',
        category: 'social',
        titleTa: 'ஜல் ஜீவன் மிஷன் - குடிநீர் திட்டம் (JJM)',
        titleEn: 'Jal Jeevan Mission (Har Ghar Jal)',
        benefitBadgeTa: 'ஒவ்வொரு ஊரக வீட்டிற்கும் குழாய் குடிநீர் இணைப்பு',
        benefitBadgeEn: 'Piped Tap Water to Every Rural Home',
        descTa: 'கிராமப்புறங்களில் உள்ள ஒவ்வொரு வீட்டிற்கும் பாதுகாப்பான மற்றும் போதிய அளவு குடிநீரை வீட்டின் குழாய் வழியாகவே வழங்கும் திட்டம்.',
        descEn: 'Flagship mission to provide functional household tap water connection (FHTC) to every rural household.',
        eligibilityTa: 'குடிநீர் இணைப்பு இல்லாத அனைத்து கிராமப்புற குடியிருப்புப் பகுதிகள்.',
        eligibilityEn: 'All rural households without individual functional tap water connections.',
        benefitsListTa: [
          'ஒரு நபருக்கு ஒரு நாளைக்கு 55 லிட்டர் தரமான பாதுகாக்கப்பட்ட குடிநீர் வழங்கல்.',
          'பெண்கள் தொலைதூரம் சென்று தண்ணீர் சுமந்து வரும் சிரமத்திற்கு முற்றுப்புள்ளி.',
          'பள்ளிகள், அங்கன்வாடி மையங்கள் மற்றும் ஆரம்ப சுகாதார நிலையங்களுக்கும் இணைப்பு வழங்கப்படுகிறது.',
        ],
        benefitsListEn: [
          'Assures 55 litres per capita per day (lpcd) of safe and potable drinking water.',
          'Eliminates the hardship of rural women walking miles to fetch water.',
          'Covers all village schools, Anganwadis, and community health centers.',
        ],
        docsTa: ['ஆதார் அட்டை', 'வீட்டு முகவரிச் சான்று / மின்கட்டண ரசீது'],
        docsEn: ['Aadhaar Card', 'House address proof'],
        applyMethodTa: 'கிராம ஊராட்சி மன்ற அலுவலகம் மற்றும் ஊராட்சி குடிநீர் மற்றும் சுகாதாரக் குழுவை அணுகலாம்.',
        applyMethodEn: 'Contact your Village Panchayat President or Village Water and Sanitation Committee (VWSC).',
        officialPortal: 'https://jaljeevanmission.gov.in',
        helpline: '1800-180-1551',
        icon: Icons.water_drop_rounded,
        color: SchemeColors.skyBlue,
      ),

      // Tamil Nadu State schemes removed — Central Govt schemes only
      /*SchemeModel(
        id: 'kmut',
        govType: 'state',
        category: 'women',
        titleTa: 'கலைஞர் மகளிர் உரிமைத் திட்டம் (KMUT)',
        titleEn: 'Kalaignar Magalir Urimai Thittam (KMUT)',
        benefitBadgeTa: 'குடும்பத் தலைவிகளுக்கு மாதம் ₹1,000 உரிமைத் தொகை',
        benefitBadgeEn: '₹1,000/month Direct Financial Aid to Women',
        descTa: 'குடும்பத்திற்காக உழைக்கும் தாய்மார்களின் உழைப்பை அங்கீகரித்து, பொருளாதார சுதந்திரம் அளிக்க மாதம் ₹1,000 வழங்கும் தமிழ்நாடு அரசின் வரலாற்றுத் திட்டம்.',
        descEn: 'Historic basic income guarantee scheme providing monthly financial grant of ₹1,000 directly to eligible women heads of households.',
        eligibilityTa: '21 வயது நிரம்பிய, குடும்ப ஆண்டு வருமானம் ₹2.5 லட்சத்திற்குள் உள்ள குடும்பத் தலைவிகள்.',
        eligibilityEn: 'Women heads of families aged 21+, annual family income below ₹2.5 Lakh, possessing smart ration card.',
        benefitsListTa: [
          'ஒவ்வொரு மாதமும் ₹1,000 பயனாளியின் வங்கிக் கணக்கில் நேரடியாக (DBT) வரவு வைக்கப்படுகிறது.',
          'சுமார் 1.15 கோடிக்கும் அதிகமான தமிழ்நாட்டுப் பெண்கள் இத்திட்டத்தால் பயன்பெற்று வருகின்றனர்.',
          'குடும்பத்தின் அன்றாடச் செலவுகள், குழந்தைகள் கல்வி மற்றும் மருத்துவத் தேவைகளுக்கு உறுதுணையாக அமைகிறது.',
        ],
        benefitsListEn: [
          'Direct bank transfer of ₹1,000 every single month directly into women bank accounts.',
          'Benefits over 1.15 Crore eligible women across Tamil Nadu.',
          'Strengthens economic independence and supports household nutrition and education expenses.',
        ],
        docsTa: ['ஸ்மார்ட் குடும்ப அட்டை (Smart Ration Card)', 'ஆதார் அட்டை', 'வங்கி கணக்குப் புத்தகம்', 'மின்கட்டண ரசீது (EB Bill)'],
        docsEn: ['Smart Ration Card', 'Aadhaar Card', 'Aadhaar-seeded Bank Passbook', 'EB Consumer Number'],
        applyMethodTa: 'உங்கள் பகுதிக்கான இ-சேவை முகாம்கள் அல்லது வருவாய்த் துறை அலுவலகங்கள் மூலம் விண்ணப்பிக்கலாம்.',
        applyMethodEn: 'Apply during e-Sevai field camps or register via your Taluk Supply Office / kmut.tn.gov.in.',
        officialPortal: 'https://kmut.tn.gov.in',
        helpline: '044-25619208 / 1100',
        icon: Icons.woman_rounded,
        color: SchemeColors.green,
      ),

      SchemeModel(
        id: 'cmchis',
        govType: 'state',
        category: 'health',
        titleTa: 'முதலமைச்சரின் விரிவான மருத்துவக் காப்பீட்டுத் திட்டம் (CMCHIS)',
        titleEn: 'Chief Ministers Comprehensive Health Insurance (CMCHIS)',
        benefitBadgeTa: 'குடும்பத்திற்கு ₹5 லட்சம் கட்டணமில்லா மருத்துவ சிகிச்சை',
        benefitBadgeEn: '₹5 Lakh Free Cashless Hospitalization Cover',
        descTa: 'தமிழ்நாட்டின் ஏழை குடும்பங்கள் பணமின்மையால் மருத்துவ சிகிச்சை பெறாமல் அவதிப்படுவதைத் தடுக்க அரசு மற்றும் தனியார் மருத்துவமனைகளில் இலவச சிகிச்சை வழங்கும் திட்டம்.',
        descEn: 'State government health coverage ensuring cashless treatment up to ₹5 Lakh per family per year.',
        eligibilityTa: 'தமிழ்நாடு ஸ்மார்ட் ரேஷன் அட்டை வைத்துள்ள, ஆண்டு வருமானம் ₹1,20,000-க்குள் உள்ள குடும்பங்கள்.',
        eligibilityEn: 'Resident families in Tamil Nadu holding Smart Ration Card with annual income up to ₹1,20,000.',
        benefitsListTa: [
          'குடும்பத்திற்கு ஆண்டுக்கு ₹5,00,000 வரை பணமில்லா உயர் மருத்துவ சிகிச்சைகள்.',
          '1,090-க்கும் மேற்பட்ட அறுவை சிகிச்சைகள், புற்றுநோய், இதய அறுவை சிகிச்சை, சிறுநீரக மாற்று அறுவை சிகிச்சைகள் உள்ளடக்கம்.',
          'தமிழ்நாடு முழுவதும் உள்ள 1,200-க்கும் மேற்பட்ட அரசு மற்றும் தனியார் மருத்துவமனைகளில் சிகிச்சை பெறலாம்.',
        ],
        benefitsListEn: [
          'Cashless coverage up to ₹5,00,000 per family per annum.',
          'Covers 1,090 specialized procedures, diagnostic tests, and critical surgeries.',
          'Network of over 1,200 empaneled private and government hospitals across Tamil Nadu.',
        ],
        docsTa: ['முதலமைச்சர் காப்பீட்டு அட்டை (CMCHIS Card)', 'ரேஷன் அட்டை (Ration Card)', 'ஆதார் அட்டை', 'வருமானச் சான்றிதழ்'],
        docsEn: ['CMCHIS Smart Card', 'Ration Card', 'Aadhaar Card', 'Income Certificate'],
        applyMethodTa: 'மாவட்ட ஆட்சியர் அலுவலகத்தில் உள்ள CMCHIS மையத்தில் ரேஷன் அட்டை மற்றும் வருமானச் சான்று காட்டி உடனடி கார்டு பெறலாம்.',
        applyMethodEn: 'Visit the CMCHIS kiosk at your District Collectorate with Ration card and income certificate.',
        officialPortal: 'https://www.cmchistn.com',
        helpline: '1800-425-3993',
        icon: Icons.local_hospital_rounded,
        color: SchemeColors.red,
      ),

      SchemeModel(
        id: 'pudhumai_penn',
        govType: 'state',
        category: 'education',
        titleTa: 'புதுமைப் பெண் திட்டம் (Pudhumai Penn Scheme)',
        titleEn: 'Pudhumai Penn Scheme for Higher Education',
        benefitBadgeTa: 'கல்லூரி மாணவிகளுக்கு மாதம் ₹1,000 உதவித்தொகை',
        benefitBadgeEn: '₹1,000/month Higher Education Aid for Girls',
        descTa: 'அரசுப் பள்ளிகளில் படித்த மாணவிகள் இடைநிற்றல் இன்றி பட்டப்படிப்பு, டிப்ளமோ பயில மாதம் ₹1,000 வங்கி கணக்கில் வரவு வைக்கும் திட்டம்.',
        descEn: 'Monthly financial assistance to encourage female students from government schools to pursue higher education.',
        eligibilityTa: '6 முதல் 12 ஆம் வகுப்பு வரை அரசுப் பள்ளிகளில் படித்து கல்லூரி, பாலிடெக்னிக் அல்லது தொழிற்கல்வி பயிலும் மாணவிகள்.',
        eligibilityEn: 'Girl students who studied classes 6 to 12 in Tamil Nadu government schools and enrolled in undergraduate degrees/diplomas.',
        benefitsListTa: [
          'படிப்பு முடியும் வரை மாதந்தோறும் ₹1,000 நேரடியாக மாணவியின் வங்கிக் கணக்கில் வரவு வைக்கப்படுகிறது.',
          'பெண் குழந்தைகளின் உயர்கல்வி சேர்க்கை விகிதத்தை பெருமளவில் உயர்த்தியுள்ளது.',
          'புத்தகங்கள், கல்விக் கட்டணம் மற்றும் பயணச் செலவுகளுக்குப் பெரிதும் உதவுகிறது.',
        ],
        benefitsListEn: [
          'Monthly financial grant of ₹1,000 credited directly into the student bank account.',
          'Applicable till graduation (UG degree, diploma, engineering, medicine, arts & science).',
          'Significantly reduced female student dropouts after class 12.',
        ],
        docsTa: ['10 & 12 ஆம் வகுப்பு மதிப்பெண் சான்றிதழ்', 'அரசுப் பள்ளி பயின்ற சான்றிதழ் (Bonafide)', 'ஆதார் அட்டை', 'கல்லூரி அடையாள அட்டை', 'வங்கி கணக்குப் புத்தகம்'],
        docsEn: ['Class 10 & 12 mark sheets', 'School bonafide certificate', 'Aadhaar Card', 'College ID', 'Bank Passbook'],
        applyMethodTa: 'நீங்கள் பயிலும் கல்லூரி மூலமாகவே பெண் கல்வி போர்டலில் (pudhumaipenn.tn.gov.in) எளிதாகப் பதிவு செய்யலாம்.',
        applyMethodEn: 'Apply through your respective college nodal officer on pudhumaipenn.tn.gov.in portal.',
        officialPortal: 'https://pudhumaipenn.tn.gov.in',
        helpline: '044-25619208 / 1800-425-1600',
        icon: Icons.school_rounded,
        color: SchemeColors.purple,
      ),

      SchemeModel(
        id: 'tamil_pudhalvan',
        govType: 'state',
        category: 'education',
        titleTa: 'தமிழ்ப் புதல்வன் திட்டம் (Tamil Pudhalvan Scheme)',
        titleEn: 'Tamil Pudhalvan Higher Education Scheme',
        benefitBadgeTa: 'கல்லூரி மாணவர்களுக்கு மாதம் ₹1,000 உதவித்தொகை',
        benefitBadgeEn: '₹1,000/month Education Support for Boys',
        descTa: 'அரசுப் பள்ளிகளில் பயின்று உயர்கல்வி தொடரும் ஏழை எளிய மாணவர்களுக்கு மாதம் ₹1,000 நிதி உதவி வழங்கும் தமிழ்நாடு அரசின் புதிய திட்டம்.',
        descEn: 'Monthly financial grant of ₹1,000 to boys who studied in government schools and enrolled in higher education.',
        eligibilityTa: '6 முதல் 12 ஆம் வகுப்பு வரை அரசுப் பள்ளிகளில் படித்து, உயர்கல்வி (கலை, அறிவியல், பொறியியல், மருத்துவம், ஐடிஐ) பயிலும் மாணவர்கள்.',
        eligibilityEn: 'Boy students who completed schooling from classes 6 to 12 in Tamil Nadu government schools.',
        benefitsListTa: [
          'கல்லூரிப் படிப்பு முடியும் வரை மாதந்தோறும் ₹1,000 வங்கிக் கணக்கில் நேரடி வரவு.',
          'ஏழை எளிய குடும்பங்களைச் சேர்ந்த மாணவர்களின் உயர்கல்வி கனவை நனவாக்குகிறது.',
          'பாடப் புத்தகங்கள், தேர்வுக் கட்டணம் மற்றும் கல்விச் செலவுகளுக்கு ஆதரவு.',
        ],
        benefitsListEn: [
          'Direct bank transfer of ₹1,000 every month throughout undergraduate course tenure.',
          'Assists students from rural and underprivileged backgrounds in pursuing higher education.',
          'Helps cover college fees, technical books, and competitive exam materials.',
        ],
        docsTa: ['பள்ளி மாற்றுச் சான்றிதழ் (TC) & Bonafide', 'ஆதார் அட்டை', 'கல்லூரி சேர்க்கை ஆவணம்', 'வங்கி கணக்குப் புத்தகம்'],
        docsEn: ['School TC & Bonafide certificate', 'Aadhaar Card', 'College admission receipt', 'Bank details'],
        applyMethodTa: 'மாணவர்கள் பயிலும் கல்லூரி அலுவலகம் மற்றும் உயர்கல்வித் துறை வழிகாட்டுதல் மூலம் பதிவு செய்யலாம்.',
        applyMethodEn: 'Enroll directly through the designated nodal desk at your college or university.',
        officialPortal: 'https://tamilpudhalvan.tn.gov.in',
        helpline: '1800-425-1600',
        icon: Icons.cast_for_education_rounded,
        color: SchemeColors.blue,
      ),

      SchemeModel(
        id: 'vidiyal_payanam',
        govType: 'state',
        category: 'women',
        titleTa: 'விடியல் பயணம் திட்டம் (Vidiyal Payanam - இலவச பேருந்து பயணம்)',
        titleEn: 'Vidiyal Payanam Zero-Fare Bus Travel',
        benefitBadgeTa: 'அரசுப் பேருந்துகளில் பெண்களுக்கு 100% இலவசப் பயணம்',
        benefitBadgeEn: 'Zero-Fare Bus Travel for Women & Transpersons',
        descTa: 'தமிழ்நாடு அரசுப் போக்குவரத்துக் கழக சாதாரண கட்டண நகரப் பேருந்துகளில் பெண்கள், திருநங்கைகள் மற்றும் மாற்றுத்திறனாளிகள் இலவசமாகப் பயணிக்கும் திட்டம்.',
        descEn: 'Revolutionary social mobility initiative providing zero-ticket fare bus travel for women, transpersons, and differently-abled individuals.',
        eligibilityTa: 'தமிழ்நாட்டில் பயணிக்கும் அனைத்துப் பெண்கள், பெண் குழந்தைகள், திருநங்கைகள் மற்றும் மாற்றுத்திறனாளிகள்.',
        eligibilityEn: 'All women, transpersons, and differently-abled citizens travelling in city and town ordinary fare government buses.',
        benefitsListTa: [
          'தமிழ்நாடு முழுவதும் சாதாரண கட்டண அரசுப் பேருந்துகளில் கட்டணமில்லா பயணம்.',
          'பணிக்குச் செல்லும் பெண்களுக்கு மாதம் சுமார் ₹800 முதல் ₹1,500 வரை பயணச் செலவு மிச்சமாகிறது.',
          'பெண்களின் வேலைவாய்ப்பு மற்றும் சுதந்திரமான நடமாட்டத்தை அதிகரிக்கச் செய்துள்ளது.',
        ],
        benefitsListEn: [
          '100% free bus travel in all ordinary white-board city and town state transport buses.',
          'Saves working women between ₹800 to ₹1,500 every month on travel expenditure.',
          'Dramatically improves female workforce participation and financial savings.',
        ],
        docsTa: ['எந்தவித ஆவணமும் தேவையில்லை (கட்டணமில்லா பயணச் சீட்டு உடனடியாகப் பேருந்திலேயே வழங்கப்படும்)'],
        docsEn: ['No documentation required (Zero-fare ticket issued on-board by bus conductor)'],
        applyMethodTa: 'விண்ணப்பிக்கத் தேவையில்லை. சாதாரண கட்டண அரசுப் பேருந்தில் ஏறி இலவச பயணச்சீட்டு பெற்றுக் கொள்ளலாம்.',
        applyMethodEn: 'No prior registration required. Simply board any ordinary town bus displaying the Vidiyal logo.',
        officialPortal: 'https://www.tn.gov.in',
        helpline: '1800-599-1500',
        icon: Icons.directions_bus_rounded,
        color: SchemeColors.emerald,
      ),

      SchemeModel(
        id: 'breakfast_scheme',
        govType: 'state',
        category: 'education',
        titleTa: 'முதலமைச்சரின் காலை உணவுத் திட்டம் (CM Breakfast Scheme)',
        titleEn: 'Chief Ministers Nutritious Breakfast Scheme',
        benefitBadgeTa: '1 முதல் 5 வரை அரசுப் பள்ளி மாணவர்களுக்கு காலை உணவு',
        benefitBadgeEn: 'Free Hot Breakfast in All Govt Primary Schools',
        descTa: 'பசியின்றி குழந்தைகள் பாடம் கற்க வேண்டும் என்ற உயரிய நோக்கில், அரசுத் தொடக்கப் பள்ளி மாணவர்களுக்கு சூடான, சத்தான காலை உணவு வழங்கும் திட்டம்.',
        descEn: 'Pioneering nutrition scheme ensuring hot, nutritious breakfast daily for primary school children in government schools.',
        eligibilityTa: 'தமிழ்நாடு அரசு மற்றும் அரசு உதவிபெறும் தொடக்கப் பள்ளிகளில் 1 முதல் 5 ஆம் வகுப்பு வரை பயிலும் அனைத்துக் குழந்தைகள்.',
        eligibilityEn: 'All students enrolled in classes 1 to 5 in Tamil Nadu government primary schools.',
        benefitsListTa: [
          'பள்ளி நாட்களில் காலையிலேயே ரவா உப்புமா, சேமியா கிச்சடி, பொங்கல் மற்றும் சாம்பார் உள்ளிட்ட சத்தான உணவு.',
          'மாணவர்களின் ஊட்டச்சத்து குறைபாட்டை நீக்கி, நினைவாற்றல் மற்றும் கற்றல் திறனை மேம்படுத்துகிறது.',
          'பள்ளிக்கு வரும் மாணவர்களின் வருகைப் பதிவை பெருமளவில் அதிகரித்துள்ளது.',
        ],
        benefitsListEn: [
          'Nutritious cooked meals served every school morning before classes begin.',
          'Addresses classroom hunger, improves student attentiveness and cognitive health.',
          'Boosts primary school attendance and retention rates across all districts.',
        ],
        docsTa: ['பள்ளி மாணவர் சேர்க்கை பதிவேடு (School Admission Enrollment)'],
        docsEn: ['School enrollment record'],
        applyMethodTa: 'அரசுப் பள்ளியில் சேர்ந்தவுடனே தானாகவே இத்திட்டத்தின் பலன் மாணவர்களுக்குக் கிடைக்கும்.',
        applyMethodEn: 'Automatic coverage upon enrollment in any Tamil Nadu government primary school.',
        officialPortal: 'https://www.tn.gov.in',
        helpline: '14417',
        icon: Icons.restaurant_rounded,
        color: SchemeColors.amber,
      ),

      SchemeModel(
        id: 'kanavu_illam',
        govType: 'state',
        category: 'housing',
        titleTa: 'கலைஞரின் கனவு இல்லம் திட்டம் (Kalaignarin Kanavu Illam)',
        titleEn: 'Kalaignarin Kanavu Illam Housing Scheme',
        benefitBadgeTa: 'குடிசைகளை மாற்றி கான்கிரீட் வீடு கட்ட ₹3.50L நிதி',
        benefitBadgeEn: '₹3.50 Lakh Grant for Concrete Homes',
        descTa: 'தமிழ்நாட்டின் ஊரகப் பகுதிகளில் குடிசைகளே இல்லாத நிலையை உருவாக்கி, ஏழை எளிய குடும்பங்களுக்குப் பாதுகாப்பான கான்கிரீட் வீடுகள் கட்டித் தரும் திட்டம்.',
        descEn: 'Rural housing initiative aimed at transforming thatched huts into robust concrete homes across Tamil Nadu villages.',
        eligibilityTa: 'ஊரகப் பகுதிகளில் குடிசை வீடுகளில் வசிக்கும் ஏழை மற்றும் பட்டியல்/பழங்குடியின எளிய குடும்பங்கள்.',
        eligibilityEn: 'Rural families living in thatched or dilapidated huts owning land plot.',
        benefitsListTa: [
          'ஒவ்வொரு வீட்டிற்கும் அரசு மானியமாக ₹3,50,000 வரை நிதி உதவி.',
          '360 சதுர அடி பரப்பளவில் பக்கா கான்கிரீட் கூரை, சமையலறை மற்றும் கழிப்பறையுடன் கூடிய வீடு.',
          '2030-க்குள் தமிழ்நாட்டை குடிசைகள் இல்லா மாநிலமாக மாற்றுவதை இலக்காகக் கொண்டது.',
        ],
        benefitsListEn: [
          'Financial grant of ₹3.50 Lakh per house provided in staged construction phases.',
          'Constructs a 360 sq.ft durable concrete house with kitchen and sanitary toilet.',
          'Aims to create a hut-free rural Tamil Nadu by 2030.',
        ],
        docsTa: ['மனைப் பட்டா (Plot Patta)', 'ஆதார் அட்டை', 'ரேஷன் அட்டை', 'வங்கி கணக்குப் புத்தகம்'],
        docsEn: ['House site Patta', 'Aadhaar Card', 'Ration Card', 'Bank Passbook'],
        applyMethodTa: 'கிராம ஊராட்சி மன்ற அலுவலகம் மற்றும் வட்டார வளர்ச்சி அலுவலகம் (BDO) வழியாகப் பயனாளிகள் தேர்வு செய்யப்படுகின்றனர்.',
        applyMethodEn: 'Selection through Village Panchayat survey and Block Development Office (BDO).',
        officialPortal: 'https://rdpb.tn.gov.in',
        helpline: '044-25671754',
        icon: Icons.cottage_rounded,
        color: SchemeColors.blue,
      ),

      SchemeModel(
        id: 'makkalai_thedi_maruthuvam',
        govType: 'state',
        category: 'health',
        titleTa: 'மக்களைத் தேடி மருத்துவம் (Makkalai Thedi Maruthuvam)',
        titleEn: 'Makkalai Thedi Maruthuvam (Doorstep Healthcare)',
        benefitBadgeTa: 'வீட்டிற்கே வந்து இலவச மருத்துவப் பரிசோதனை & மருந்துகள்',
        benefitBadgeEn: 'Free Doorstep Chronic Disease Care & Medicine',
        descTa: 'முதியவர்கள் மற்றும் நோயாளிகள் மருத்துவமனைக்கு அலையாமல், மருத்துவக் குழுவினர் நேரடியாக வீடுகளுக்கே சென்று பரிசோதனை செய்து மருந்துகள் வழங்கும் திட்டம்.',
        descEn: 'Pioneering doorstep healthcare delivery scheme providing screening, diagnostics, and free medicines at citizens doorsteps.',
        eligibilityTa: 'உயர் ரத்த அழுத்தம், சர்க்கரை நோய், முடக்குவாதம் உள்ளவர்கள் மற்றும் மருத்துவமனைக்கு வர முடியாத முதியோர்கள்.',
        eligibilityEn: 'Citizens aged 45+ or patients suffering from non-communicable diseases (hypertension, diabetes, palliative care).',
        benefitsListTa: [
          'செவிலியர்கள் மற்றும் சுகாதாரப் பணியாளர்கள் வீடுகளுக்கே வந்து ரத்த அழுத்தம் மற்றும் சர்க்கரை அளவு பரிசோதனை.',
          'பரிந்துரைக்கப்பட்ட அத்தியாவசிய மருந்துகள் மாதந்தோறும் வீட்டிற்கே நேரடியாக இலவசமாக வழங்கப்படுகிறது.',
          'இயன்முறை சிகிச்சை (Physiotherapy) மற்றும் நோய்த்தடுப்புச் சிகிச்சைகள் வீட்டிலேயே அளிக்கப்படுகின்றன.',
        ],
        benefitsListEn: [
          'Doorstep screening for hypertension, diabetes, kidney disease, and cervical/oral cancer.',
          'Free supply of monthly chronic disease maintenance medicines directly to patients homes.',
          'Home-based physiotherapy and palliative care services for bedridden individuals.',
        ],
        docsTa: ['ரேஷன் அட்டை (Ration Card)', 'ஆதார் அட்டை', 'முந்தைய மருத்துவச் சீட்டு'],
        docsEn: ['Ration Card', 'Aadhaar Card', 'Previous medical prescription'],
        applyMethodTa: 'உங்கள் பகுதி கிராம சுகாதார செவிலியர் (VHN) அல்லது ஆரம்ப சுகாதார நிலையத்தை (PHC) தொடர்பு கொள்ளவும்.',
        applyMethodEn: 'Contact your local Village Health Nurse (VHN), ASHA worker, or nearest Primary Health Centre.',
        officialPortal: 'https://mtm.tn.gov.in',
        helpline: '104 (Health Helpline)',
        icon: Icons.medication_rounded,
        color: SchemeColors.emerald,
      ),

      SchemeModel(
        id: 'naan_mudhalvan',
        govType: 'state',
        category: 'business',
        titleTa: 'நான் முதல்வன் திட்டம் (Naan Mudhalvan Skill Scheme)',
        titleEn: 'Naan Mudhalvan Youth Skill Development',
        benefitBadgeTa: 'மாணவர்களுக்கு நவீன தொழில் & வேலைவாய்ப்பு பயிற்சி',
        benefitBadgeEn: 'Free Industry 4.0 & AI Job Readiness Training',
        descTa: 'தமிழ்நாடு இளைஞர்கள் மற்றும் கல்லூரி மாணவர்களுக்கு நவீன தொழில்நுட்பப் பயிற்சிகள் வழங்கி உலகத்தரம் வாய்ந்த வேலைவாய்ப்பைப் பெற்றுத்தரும் திட்டம்.',
        descEn: 'Dynamic youth skilling platform empowering college students with cutting-edge industry courses and job placements.',
        eligibilityTa: 'தமிழ்நாடு அரசு, அரசு உதவிபெறும் மற்றும் தனியார் கல்லூரிகளில் பயிலும் மாணவர்கள் மற்றும் பட்டதாரிகள்.',
        eligibilityEn: 'Students and graduates from arts, science, engineering, and polytechnic colleges across Tamil Nadu.',
        benefitsListTa: [
          'செயற்கை நுண்ணறிவு (AI), சைபர் செக்யூரிட்டி, கிளவுட் கம்ப்யூட்டிங், டேட்டா சயின்ஸ் உள்ளிட்ட உயர் தொழில்நுட்பப் பயிற்சிகள்.',
          'சர்வதேச முன்னணி தொழில்நுட்ப நிறுவனங்களின் (Google, Microsoft, IBM) சான்றிதழ்.',
          'நேரடி வளாக வேலைவாய்ப்பு முகாம்கள் மூலம் பெருநிறுவனங்களில் உடனடி வேலைவாய்ப்பு.',
        ],
        benefitsListEn: [
          'Free access to industry-curated courses in AI, Machine Learning, Data Analytics, and Robotics.',
          'Global industry certification from top tech giants (Microsoft, IBM, Cambridge).',
          'Direct campus placement drives and career counseling support.',
        ],
        docsTa: ['கல்லூரி அடையாள அட்டை', 'ஆதார் அட்டை', 'மின்னஞ்சல் & செல்போன் எண்'],
        docsEn: ['College Student ID', 'Aadhaar Card', 'Email ID & Mobile number'],
        applyMethodTa: 'கல்லூரி வாயிலாக அல்லது naanmudhalvan.tn.gov.in இணையதளம் வழியாக இலவசமாகப் பதிவு செய்யலாம்.',
        applyMethodEn: 'Register online at naanmudhalvan.tn.gov.in through your institutional student login.',
        officialPortal: 'https://naanmudhalvan.tn.gov.in',
        helpline: '044-22253001',
        icon: Icons.trending_up_rounded,
        color: SchemeColors.blue,
      ),

      SchemeModel(
        id: 'aatg',
        govType: 'state',
        category: 'business',
        titleTa: 'அண்ணல் அம்பேத்கர் தொழில் முன்னோடிகள் திட்டம் (AATG)',
        titleEn: 'Annal Ambedkar Business Champions Scheme (AATG)',
        benefitBadgeTa: 'SC/ST தொழில் முனைவோருக்கு 35% மூலதன மானியம்',
        benefitBadgeEn: '35% Capital Subsidy + 6% Interest Subsidy',
        descTa: 'பட்டியலின மற்றும் பழங்குடியின (SC/ST) இளைஞர்கள் வெற்றிகரமான தொழில் முனைவோர்களாக மாற நிதி உதவி மற்றும் மானியம் வழங்கும் திட்டம்.',
        descEn: 'Flagship affirmative entrepreneurship scheme providing capital grant and subsidized loans to SC/ST entrepreneurs.',
        eligibilityTa: '18 முதல் 55 வயதுக்குட்பட்ட பட்டியல் மற்றும் பழங்குடியின (SC/ST) தொழில்முனைவோர்.',
        eligibilityEn: 'SC/ST entrepreneurs starting manufacturing, trading, or service sector projects in Tamil Nadu.',
        benefitsListTa: [
          'தொழில் திட்ட மதிப்பீட்டில் 35% நேரடி மூலதன மானியம் (அதிகபட்சம் ₹1.5 கோடி வரை).',
          'வங்கிக் கடனுக்கு 6% வட்டி மானியம் முழு கடன் காலத்திற்கும் வழங்கப்படுகிறது.',
          'தொழில் தொடங்குவதற்கான இலவச மேலாண்மை மற்றும் தொழில் வழிகாட்டல் பயிற்சி.',
        ],
        benefitsListEn: [
          '35% direct capital subsidy on total project cost up to a maximum of ₹1.5 Crore.',
          '6% interest subsidy on bank term loans for the entire loan repayment tenure.',
          'Free EDP entrepreneurship training and technical handholding by EDII-TN.',
        ],
        docsTa: ['சாதிச் சான்றிதழ் (Community Certificate)', 'ஆதார் அட்டை', 'விரிவான தொழில் திட்ட அறிக்கை (Project DPR)', 'வங்கி ஆவணங்கள்'],
        docsEn: ['Community Certificate', 'Aadhaar Card', 'Detailed Project Report (DPR)', 'Land/lease deed'],
        applyMethodTa: 'மாவட்ட தொழில் மையம் (DIC) அல்லது msmeonline.tn.gov.in இணையதளம் மூலம் விண்ணப்பிக்கலாம்.',
        applyMethodEn: 'Apply online at msmeonline.tn.gov.in or contact General Manager, District Industries Centre (DIC).',
        officialPortal: 'https://msmeonline.tn.gov.in',
        helpline: '044-22501494',
        icon: Icons.rocket_launch_rounded,
        color: SchemeColors.purple,
      ),

      SchemeModel(
        id: 'uzhavar_pathukappu',
        govType: 'state',
        category: 'farmers',
        titleTa: 'முதலமைச்சரின் உழவர் பாதுகாப்புத் திட்டம்',
        titleEn: 'Chief Ministers Uzhavar Pathukappu Scheme',
        benefitBadgeTa: 'விவசாயிகளுக்கு கல்வி, திருமணம் & விபத்து நல உதவிகள்',
        benefitBadgeEn: 'Comprehensive Welfare & Social Security for Farmers',
        descTa: 'விவசாயிகள், விவசாயக் கூலித் தொழிலாளர்கள் மற்றும் அவர்களது குடும்பத்தினருக்கு கல்வி, திருமணம், மகப்பேறு, விபத்து மற்றும் முதியோர் நல உதவிகளை வழங்கும் திட்டம்.',
        descEn: 'Dedicated social security net protecting farmers and agricultural laborers with multifaceted welfare assistance.',
        eligibilityTa: 'சொந்தமாக 2.5 ஏக்கர் நன்செய் அல்லது 5 ஏக்கர் புன்செய் நிலம் வைத்துள்ள விவசாயிகள் மற்றும் விவசாயத் தொழிலாளர்கள் (18-65 வயது).',
        eligibilityEn: 'Small and marginal farmers owning up to 2.5 acres of wet land or 5 acres of dry land, and landless agri laborers.',
        benefitsListTa: [
          'விவசாயிகள் விபத்து மரணத்திற்கு ₹1,00,000 இழப்பீட்டு உதவித்தொகை.',
          'உழவர் குடும்பக் குழந்தைகளின் பள்ளி மற்றும் கல்லூரிப் படிப்பிற்கு ஆண்டுதோறும் கல்வி உதவித்தொகை.',
          'உழவர் குடும்பத் திருமணங்களுக்கு ₹10,000 முதல் ₹20,000 வரை உதவி மற்றும் மூத்த விவசாயிகளுக்கு மாதம் ₹1,000 முதியோர் ஓய்வூதியம்.',
        ],
        benefitsListEn: [
          'Accidental death compensation of ₹1,00,000 to family of registered farmer.',
          'Educational grants from school level up to postgraduate and professional degrees.',
          'Marriage assistance grant of ₹10,000 to ₹20,000 and old age pension of ₹1,000/month for senior farmers.',
        ],
        docsTa: ['உழவர் பாதுகாப்பு அட்டை (Uzhavar Card)', 'ஆதார் அட்டை', 'சிட்டா / அடங்கல்', 'ரேஷன் அட்டை', 'வங்கி கணக்குப் புத்தகம்'],
        docsEn: ['Uzhavar Pathukappu Card', 'Aadhaar Card', 'Chitta / Adangal land extract', 'Ration Card', 'Bank details'],
        applyMethodTa: 'வட்டாட்சியர் அலுவலகம் (Taluk Office - உழவர் பாதுகாப்பு பிரிவு) அல்லது கிராம நிர்வாக அலுவலரை (VAO) அணுகவும்.',
        applyMethodEn: 'Contact Special Tahsildar (Uzhavar Pathukappu Thittam) at your Taluk Office or Village Administrative Officer.',
        officialPortal: 'https://www.tn.gov.in',
        helpline: '1800-425-1550',
        icon: Icons.nature_people_rounded,
        color: SchemeColors.green,
      ),

      SchemeModel(
        id: 'illam_thedi_kalvi',
        govType: 'state',
        category: 'education',
        titleTa: 'இல்லம் தேடிக் கல்வி திட்டம் (Illam Thedi Kalvi)',
        titleEn: 'Illam Thedi Kalvi (Education at Doorstep)',
        benefitBadgeTa: 'தொடக்க & நடுநிலைப் பள்ளி மாணவர்களுக்கு இலவச மாலைக் கல்வி',
        benefitBadgeEn: 'Free Evening Supplementary Community Education',
        descTa: 'கொரோனா பெருந்தொற்றினால் மாணவர்களிடம் ஏற்பட்ட கற்றல் இடைவெளியை நீக்க, குடியிருப்புப் பகுதிகளிலேயே தன்னார்வலர்கள் மூலம் மாலை நேரத்தில் இலவசமாகக் கற்பிக்கும் திட்டம்.',
        descEn: 'Community-led supplementary education initiative bridging learning gaps for children in grades 1 to 8.',
        eligibilityTa: 'அரசு மற்றும் அரசு உதவிபெறும் பள்ளிகளில் 1 முதல் 8 ஆம் வகுப்பு வரை பயிலும் அனைத்துக் கிராமப்புற மாணவர்கள்.',
        eligibilityEn: 'All government school students in classes 1 to 8 in rural and urban neighborhood centers.',
        benefitsListTa: [
          'தினசரி மாலை வேளையில் 1 மணி முதல் 1.5 மணி நேரம் விளையாட்டு முறை கற்றல்.',
          'மாணவர்களின் தமிழ், ஆங்கில வாசிப்பு மற்றும் அடிப்படைக் கணிதத் திறன் கணிசமாக மேம்படுகிறது.',
          'பள்ளிகளுக்கு அருகிலேயே வசிக்கும் பயிற்சி பெற்ற மகளிர் தன்னார்வலர்களால் அன்புடன் பாடம் கற்பிக்கப்படுகிறது.',
        ],
        benefitsListEn: [
          '1 to 1.5 hours of joyful activity-based supplementary learning after school hours.',
          'Improves foundational literacy, mother tongue reading fluency, and numeracy.',
          'Conducted right in the neighborhood by trained local community women volunteers.',
        ],
        docsTa: ['எந்த ஆவணமும் தேவையில்லை (கிராம மையத்திற்கு நேரடியாகச் செல்லலாம்)'],
        docsEn: ['No documentation required'],
        applyMethodTa: 'உங்கள் தெரு அல்லது கிராமத்தில் உள்ள இல்லம் தேடிக் கல்வி மையத் தன்னார்வலரை அணுகி குழந்தைகளை இணைக்கலாம்.',
        applyMethodEn: 'Parents can enroll their children at any local neighborhood Illam Thedi Kalvi volunteer center.',
        officialPortal: 'https://illamthedikalvi.tnschools.gov.in',
        helpline: '14417 (School Education Helpline)',
        icon: Icons.menu_book_rounded,
        color: SchemeColors.purple,
      ),*/
    ];
  }
}
