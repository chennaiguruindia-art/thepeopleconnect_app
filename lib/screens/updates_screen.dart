import 'package:flutter/material.dart';
import '../utils/app_translations.dart';
import '../widgets/app_drawer.dart';
import '../widgets/app_header.dart';

class UpdatesColors {
  static const navy = Color(0xFF0B1F3A);
  static const darkNavy = Color(0xFF071527);
  static const orange = Color(0xFFEA580C);
  static const green = Color(0xFF16A34A);
  static const blue = Color(0xFF2563EB);
  static const skyBlue = Color(0xFF0284C7);
  static const amber = Color(0xFFD97706);
  static const purple = Color(0xFF7C3AED);
  static const red = Color(0xFFDC2626);
  static const lightBg = Color(0xFFF8FAFC);
  static const grey = Color(0xFF64748B);
  static const textDark = Color(0xFF0F172A);
  static const borderLight = Color(0xFFE2E8F0);
}

class CivicNewsItem {
  final String titleTa;
  final String titleEn;
  final String descTa;
  final String descEn;
  final String categoryTa;
  final String categoryEn;
  final String timeTa;
  final String timeEn;
  final String source;
  final Color badgeColor;

  CivicNewsItem({
    required this.titleTa,
    required this.titleEn,
    required this.descTa,
    required this.descEn,
    required this.categoryTa,
    required this.categoryEn,
    required this.timeTa,
    required this.timeEn,
    required this.source,
    required this.badgeColor,
  });
}

class UpdatesScreen extends StatefulWidget {
  const UpdatesScreen({super.key});

  @override
  State<UpdatesScreen> createState() => _UpdatesScreenState();
}

class _UpdatesScreenState extends State<UpdatesScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();
  int _selectedCategoryIndex = 0;

  final List<CivicNewsItem> _allNews = [
    CivicNewsItem(
      titleTa: 'திருநெல்வேலி & தமிழ்நாடு முழுவதும் மக்கள் குறைதீர்க்கும் தளம் துவக்கம்',
      titleEn: 'Districtwide Grievance Redressal Network Launched in Tirunelveli',
      descTa: 'குடிநீர், சாலை, மின்சாரம், சுகாதாரம் உள்ளிட்ட அனைத்து அடிப்படைப் பொதுப் பிரச்சனைகளையும் இடைத்தரகர்கள் இன்றி பொதுமக்கள் நேரடியாகப் பதிவு செய்யலாம்.',
      descEn: 'Citizens can now report civic grievances directly regarding drinking water, roads, electricity, and sanitation with transparent online tracking.',
      categoryTa: 'நலத்திட்டங்கள்',
      categoryEn: 'Welfare Schemes',
      timeTa: '10 நிமிடங்களுக்கு முன்',
      timeEn: '10 mins ago',
      source: 'செய்தி வெளியீடு (Civic Bulletin)',
      badgeColor: UpdatesColors.orange,
    ),
    CivicNewsItem(
      titleTa: 'திருநெல்வேலி மாநகராட்சி பகுதியில் புதிய குடிநீர் குழாய் பதிக்கும் பணி தீவிரம்',
      titleEn: 'Intensive Pipeline Replacement Project Initiated Across Tirunelveli Corporation',
      descTa: 'பொதுமக்களின் கோரிக்கையை ஏற்று தச்சநல்லூர் மற்றும் சுற்றுவட்டார பகுதிகளில் பிரதான குழாய் சீரமைக்கும் பணிகள் முழுவீச்சில் நடைபெற்று வருகின்றன.',
      descEn: 'Responding to public petitions, major water main pipeline maintenance works have been fast-tracked in Thatchanallur and adjacent wards.',
      categoryTa: 'குடிநீர் & சாலை',
      categoryEn: 'Water & Roads',
      timeTa: '1 மணி நேரத்திற்கு முன்',
      timeEn: '1 hour ago',
      source: 'குடிநீர் வாரியம் (TWAD)',
      badgeColor: UpdatesColors.skyBlue,
    ),
    CivicNewsItem(
      titleTa: 'கிராமப்புற சாலை மேம்பாட்டு திட்டத்தின் கீழ் 14 தாலுகா சாலைகள் சீரமைப்பு',
      titleEn: '14 Rural Taluk Road Stretches Cleared for Upgradation & Asphalt Paving',
      descTa: 'மழைக்கால பாதிப்புகளை தவிர்க்கும் பொருட்டு தாலுகா அளவிலான சேதமடைந்த சாலைகளை உடனடியாக புனரமைக்க நிதி ஒதுக்கீடு செய்யப்பட்டுள்ளது.',
      descEn: 'Budget allocations sanctioned for immediate restoration and widening of rain-damaged rural access roads across the district.',
      categoryTa: 'குடிநீர் & சாலை',
      categoryEn: 'Water & Roads',
      timeTa: '3 மணி நேரத்திற்கு முன்',
      timeEn: '3 hours ago',
      source: 'நெடுஞ்சாலைத் துறை',
      badgeColor: UpdatesColors.skyBlue,
    ),
    CivicNewsItem(
      titleTa: 'மின்வாரிய அவசர உதவி: புதிய 1912 கட்டணமில்லா உதவி எண் அறிவிப்பு',
      titleEn: 'TANGEDCO Toll-Free 1912 Helpline Active for Power Outages & Fuse Calls',
      descTa: 'இரவு நேர மின்தடை மற்றும் மின் கம்பி பழுது குறித்து பொதுமக்கள் உடனடியாக 1912 எண்ணிற்கு அழைத்து புகார் அளிக்கலாம்.',
      descEn: 'Residents can dial 1912 24x7 to register urgent complaints on power tripping, transformer repairs, and street light issues.',
      categoryTa: 'மின்சாரம் & சுகாதாரம்',
      categoryEn: 'Power & Sanitation',
      timeTa: '5 மணி நேரத்திற்கு முன்',
      timeEn: '5 hours ago',
      source: 'மின்சார வாரியம் (TANGEDCO)',
      badgeColor: UpdatesColors.amber,
    ),
    CivicNewsItem(
      titleTa: 'அரசு ஆரம்ப சுகாதார நிலையங்களில் பொது மருத்துவ பரிசோதனை முகாம்',
      titleEn: 'Free Health Screening Camps Conducted Across Primary Healthcare Centers',
      descTa: 'பொதுமக்கள் பயன்பெறும் வகையில் அனைத்து வட்டார ஆரம்ப சுகாதார நிலையங்களிலும் இலவச இரத்த பரிசோதனை மற்றும் ஆலோசனைகள் வழங்கப்படுகின்றன.',
      descEn: 'Comprehensive diagnostic screenings, blood tests, and doctor consultations provided free of cost at regional health sub-centers.',
      categoryTa: 'கல்வி & மருத்துவம்',
      categoryEn: 'Education & Health',
      timeTa: 'நேற்று',
      timeEn: 'Yesterday',
      source: 'சுகாதாரத் துறை',
      badgeColor: UpdatesColors.green,
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showNewsDetailModal(BuildContext context, CivicNewsItem item, bool isTa) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  height: 4,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: item.badgeColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isTa ? item.categoryTa : item.categoryEn,
                      style: TextStyle(
                        color: item.badgeColor,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    isTa ? item.timeTa : item.timeEn,
                    style: const TextStyle(fontSize: 11, color: UpdatesColors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              Text(
                isTa ? item.titleTa : item.titleEn,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: UpdatesColors.navy,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 10),

              Text(
                isTa ? item.descTa : item.descEn,
                style: const TextStyle(
                  fontSize: 13,
                  color: UpdatesColors.textDark,
                  height: 1.55,
                ),
              ),
              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: UpdatesColors.lightBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: UpdatesColors.borderLight),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.newspaper, color: UpdatesColors.orange, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      '${isTa ? 'செய்தி மூலம்' : 'Source'}: ${item.source}',
                      style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: UpdatesColors.navy),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: UpdatesColors.navy,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: Text(isTa ? 'மூடுக' : 'Close'),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: appLanguage,
      builder: (context, currentLang, _) {
        final isTa = AppTranslations.isTamil;

        final categories = [
          isTa ? 'அனைத்தும்' : 'All News',
          isTa ? 'குடிநீர் & சாலை' : 'Water & Roads',
          isTa ? 'நலத்திட்டங்கள்' : 'Welfare Schemes',
          isTa ? 'மின்சாரம் & சுகாதாரம்' : 'Power & Sanitation',
          isTa ? 'கல்வி & மருத்துவம்' : 'Education & Health',
        ];

        // Filter by category and search
        final query = _searchController.text.trim().toLowerCase();
        final filteredNews = _allNews.where((item) {
          final matchesCategory = _selectedCategoryIndex == 0 ||
              (_selectedCategoryIndex == 1 && item.categoryEn == 'Water & Roads') ||
              (_selectedCategoryIndex == 2 && item.categoryEn == 'Welfare Schemes') ||
              (_selectedCategoryIndex == 3 && item.categoryEn == 'Power & Sanitation') ||
              (_selectedCategoryIndex == 4 && item.categoryEn == 'Education & Health');

          final title = isTa ? item.titleTa : item.titleEn;
          final desc = isTa ? item.descTa : item.descEn;
          final matchesSearch = query.isEmpty ||
              title.toLowerCase().contains(query) ||
              desc.toLowerCase().contains(query);

          return matchesCategory && matchesSearch;
        }).toList();

        return Scaffold(
          key: _scaffoldKey,
          drawer: const AppDrawer(currentRoute: 'updates'),
          backgroundColor: UpdatesColors.lightBg,
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
                                    const Icon(Icons.home_outlined, size: 15, color: UpdatesColors.orange),
                                    const SizedBox(width: 4),
                                    Text(
                                      AppTranslations.tr('nav_home'),
                                      style: const TextStyle(fontSize: 12, color: UpdatesColors.orange, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right, size: 15, color: UpdatesColors.grey),
                              Text(
                                AppTranslations.tr('nav_news'),
                                style: const TextStyle(fontSize: 12, color: UpdatesColors.grey, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 1, color: UpdatesColors.borderLight),

                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Live Pulse Badge
                              Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFEE2E2),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: const Color(0xFFFECACA)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        height: 8,
                                        width: 8,
                                        decoration: const BoxDecoration(
                                          color: UpdatesColors.red,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Flexible(
                                        child: Text(
                                          isTa ? 'தமிழ்நாடு நேரடி செய்திகள் • Live' : 'Tamil Nadu Live Civic News',
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: UpdatesColors.red,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),

                              Center(
                                child: Text(
                                  AppTranslations.tr('updates_title'),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: UpdatesColors.navy,
                                    height: 1.3,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),

                              Center(
                                child: Text(
                                  AppTranslations.tr('updates_sub'),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: UpdatesColors.grey,
                                    height: 1.45,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 18),

                              // Search Bar
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(25),
                                  border: Border.all(color: UpdatesColors.borderLight),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.03),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: TextField(
                                  controller: _searchController,
                                  onChanged: (_) {
                                    setState(() {});
                                  },
                                  decoration: InputDecoration(
                                    hintText: AppTranslations.tr('updates_search_hint'),
                                    hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                                    prefixIcon: const Icon(Icons.search, color: UpdatesColors.grey, size: 20),
                                    suffixIcon: _searchController.text.isNotEmpty
                                        ? IconButton(
                                            icon: const Icon(Icons.clear, size: 18),
                                            onPressed: () {
                                              setState(() {
                                                _searchController.clear();
                                              });
                                            },
                                          )
                                        : null,
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 14),

                              // Category Filter Chips
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: List.generate(categories.length, (index) {
                                    final isSelected = _selectedCategoryIndex == index;
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: ChoiceChip(
                                        label: Text(categories[index]),
                                        selected: isSelected,
                                        selectedColor: UpdatesColors.navy,
                                        labelStyle: TextStyle(
                                          color: isSelected ? Colors.white : UpdatesColors.textDark,
                                          fontSize: 12,
                                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                        ),
                                        backgroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20),
                                          side: BorderSide(
                                            color: isSelected ? UpdatesColors.navy : Colors.grey.shade300,
                                          ),
                                        ),
                                        onSelected: (val) {
                                          setState(() {
                                            _selectedCategoryIndex = index;
                                          });
                                        },
                                      ),
                                    );
                                  }),
                                ),
                              ),
                              const SizedBox(height: 16),

                              // News List
                              if (filteredNews.isEmpty)
                                Container(
                                  padding: const EdgeInsets.all(32),
                                  alignment: Alignment.center,
                                  child: Column(
                                    children: [
                                      const Icon(Icons.newspaper, size: 48, color: Colors.grey),
                                      const SizedBox(height: 10),
                                      Text(
                                        isTa ? 'செய்திகள் எதுவும் கிடைக்கவில்லை' : 'No news found',
                                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: UpdatesColors.navy),
                                      ),
                                    ],
                                  ),
                                )
                              else
                                ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: filteredNews.length,
                                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                                  itemBuilder: (context, index) {
                                    final item = filteredNews[index];
                                    return Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(color: UpdatesColors.borderLight),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.03),
                                            blurRadius: 6,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
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
                                                  color: item.badgeColor.withValues(alpha: 0.1),
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: Text(
                                                  isTa ? item.categoryTa : item.categoryEn,
                                                  style: TextStyle(
                                                    color: item.badgeColor,
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              Text(
                                                isTa ? item.timeTa : item.timeEn,
                                                style: const TextStyle(fontSize: 11, color: UpdatesColors.grey),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 10),

                                          Text(
                                            isTa ? item.titleTa : item.titleEn,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: UpdatesColors.navy,
                                              height: 1.3,
                                            ),
                                          ),
                                          const SizedBox(height: 6),

                                          Text(
                                            isTa ? item.descTa : item.descEn,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: UpdatesColors.grey,
                                              height: 1.45,
                                            ),
                                          ),
                                          const SizedBox(height: 12),

                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                item.source,
                                                style: const TextStyle(fontSize: 11, color: UpdatesColors.grey, fontWeight: FontWeight.w600),
                                              ),
                                              InkWell(
                                                onTap: () => _showNewsDetailModal(context, item, isTa),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Text(
                                                      isTa ? 'முழு விவரம்' : 'Full Story',
                                                      style: const TextStyle(
                                                        fontSize: 11.5,
                                                        fontWeight: FontWeight.bold,
                                                        color: UpdatesColors.orange,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 4),
                                                    const Icon(Icons.arrow_forward, size: 12, color: UpdatesColors.orange),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    );
                                  },
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
          ),
        );
      },
    );
  }
}
