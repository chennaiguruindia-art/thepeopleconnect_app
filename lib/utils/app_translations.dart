import 'package:flutter/material.dart';
import '../services/gemini_translation_service.dart';

// Global Language Notifier: 'ta' for Tamil, 'en' for English
final ValueNotifier<String> appLanguage = ValueNotifier<String>('ta');

class AppTranslations {
  static bool get isTamil => appLanguage.value == 'ta';

  static void setLanguage(String lang) {
    appLanguage.value = lang;
  }

  // Base Tamil content mapped to keys (No repetitive English lines in code)
  static final Map<String, String> _tamilTexts = {
    // Navigation & Common
    'site_name': 'தமிழ்நாடு மக்கள் குரல்',
    'platform_title': 'PEOPLE GRIEVANCE PLATFORM',
    'voice_tagline': 'குரலற்ற மக்களின் குரல்',
    'notice_badge': 'அறிவிப்பு',
    'notice_ticker': 'சுயாதீன மக்கள் குறைதீர்க்கும் தளம் • அரசு தளம் அல்ல',
    'helpline_label': 'உதவி எண்: +91 9384995222',
    'nav_home': 'முகப்பு',
    'nav_submit': 'புகார் பதிவு',
    'nav_track': 'புகார் நிலை',
    'nav_about': 'எங்களை பற்றி',
    'nav_district': 'மாவட்ட விவரங்கள்',
    'nav_news': 'செய்திகள் & நிகழ்வுகள்',
    'nav_schemes': 'அரசு நலத்திட்டங்கள்',
    'nav_contact': 'தொடர்புக்கு',
    'nav_privacy': 'தனியுரிமைக் கொள்கை',
    'nav_admin': 'அதிகாரி உள்நுழைவு',
    'nav_profile': 'சுயவிவரம்',

    // Hero Section
    'hero_badge': 'கடைக்கோடி மக்களின் நேரடி குறைதீர்ப்பு தளம்',
    'hero_with_people': 'மக்களோடு நாம்',
    'hero_line_1': 'உங்கள் குரல்.',
    'hero_line_2': 'உங்கள் பகுதி.',
    'hero_line_3': 'உங்கள் இணைப்பு.',
    'hero_quote': '"மக்களின் குறைகளை நேரடியாகக் கேட்டு, இடைத்தரகர்கள் இன்றி உடனடி தீர்வு காண்பதே நல்லாட்சியின் அடையாளம்."',
    'badge_transparent': '100% வெளிப்படையானது',
    'badge_tracking': 'நேரடி கண்காணிப்பு',
    'badge_districts': '38 மாவட்டங்கள்',
    'btn_register_grievance': 'புகாரைப் பதிவு செய்யுங்கள்',
    'btn_track_status': 'புகார் நிலையை அறியுங்கள்',

    // Stats Section
    'stats_tag': '🇮🇳 நல்லாட்சி & வெளிப்படைத்தன்மை',
    'stats_title': 'தமிழ்நாட்டின் 38 மாவட்டங்களிலும் நேரடி மக்கள் சேவை',
    'stats_subtitle': 'Real-Time District People Grievance Resolution Metrics',
    'stat_total': 'மொத்த\nகோரிக்கைகள்',
    'stat_resolved': 'தீர்வு\nகாணப்பட்டவை',
    'stat_in_progress': 'நடவடிக்கையில்\nஉள்ளவை',
    'stat_referred': 'துறைக்கு\nபரிந்துரைக்கப்பட்டவை',
    'stat_taluks': 'வருவாய் வட்டங்கள்\n(தாலுகாக்கள்)',
    'stat_villages': 'வருவாய்\nகிராமங்கள்',

    // Categories
    'category_title': 'எந்தப் பிரச்சினையைப் பதிவு செய்ய விரும்புகிறீர்கள்?',
    'category_sub': 'Choose your Grievance Category',
    'cat_road': 'சாலை வசதி',
    'cat_water': 'குடிநீர்',
    'cat_electricity': 'மின்சாரம்',
    'cat_sanitation': 'சுகாதாரம்',
    'cat_education': 'கல்வி',
    'cat_health': 'மருத்துவம்',

    // 4-Step Process
    'process_title': 'எளிய செயல்முறை',
    'process_sub': 'புகார் பதிவு முதல் நடவடிக்கை வரை',
    'step_1_title': '1. புகார் பதிவு',
    'step_1_desc': 'உங்கள் பிரச்சினையை எளிய முறையில் பதிவு செய்யுங்கள்',
    'step_2_title': '2. சரிபார்ப்பு',
    'step_2_desc': 'புகார் விவரங்கள் மற்றும் ஆவணங்கள் சரிபார்க்கப்படும்',
    'step_3_title': '3. அரசுத் துறைக்கு அனுப்புதல்',
    'step_3_desc': 'சம்பந்தப்பட்ட அரசு துறை மற்றும் அதிகாரிகளுக்கு அனுப்பப்படும்',
    'step_4_title': '4. நடவடிக்கை கண்காணிப்பு',
    'step_4_desc': 'புகாரின் உடனடி நடவடிக்கை நிலையை நீங்கள் அறியலாம்',

    // Track Bar & Screen
    'track_box_title': 'உங்கள் புகாரின் நிலையை அறியுங்கள்',
    'track_box_sub': 'Track Your Complaint Status',
    'track_box_hint': 'Complaint ID (e.g. VNK-20261101-0012)',
    'track_box_btn': 'பார்க்க',
    'track_screen_title': 'புகார் நிலை கண்காணிப்பு',
    'track_screen_sub': 'உங்கள் மனுவின் தற்போதைய நிலையை அறிய, புகார் எண் மற்றும் பதிவு செய்யப்பட்ட மொபைல் எண்ணை உள்ளிடுங்கள்.',
    'lbl_complaint_id': 'புகார் எண் (Complaint ID) *',
    'lbl_mobile': 'பதிவு செய்யப்பட்ட மொபைல் எண் *',
    'hint_mobile': '10 இலக்க மொபைல் எண்',
    'btn_fetch_track': 'நிலையைப் பார்க்கவும் (Track)',
    'btn_demo_track': 'மாதிரி மனு நிலையைச் சோதிக்க (Demo ID)',
    'security_text': 'உங்கள் தனிப்பட்ட தகவல்கள் உங்களுக்கும் அங்கீகரிக்கப்பட்ட நிர்வாகிகளுக்கும் மட்டுமே அணுகக்கூடியவை.',

    // About Us Screen
    'about_hero_badge': 'குரலற்ற மக்களின் குரல் — பொது மக்கள் குறைதீர்க்கும் தளம்',
    'about_title': 'மக்கள் குறைதீர்க்கும் தளம் — எங்களை பற்றி',
    'about_intro': 'மக்கள் குறைதீர்க்கும் தளம் (The People Connect) என்பது பொதுமக்களுக்கும் அரசு நிர்வாக அமைப்புகளுக்கும் இடையே வெளிப்படையான பாலமாகச் செயல்படும் ஒரு சுயாதீன மக்கள் சேவைத் தளமாகும்.',
    'about_who_we_are_title': 'நாங்கள் யார்? (Who We Are)',
    'about_mission_title': 'எமது நோக்கம் (Our Mission)',
    'about_mission_desc': 'ஒவ்வொரு குடிமகனின் குரலும் கேட்கப்பட வேண்டும். அடித்தட்டு மக்களின் அடிப்படை வாழ்க்கை பிரச்சனைகளைத் துல்லியமாக ஆவணப்படுத்தி, உரிய துறைகளுக்கு அனுப்பி, வெளிப்படைத்தன்மையுடன் தீர்வு காண்பதே எங்களின் முதன்மை நோக்கம்.',
    'about_vision_title': 'எமது தொலைநோக்கு (Our Vision)',
    'about_vision_desc': 'டிஜிட்டல் தொழில்நுட்பத்தின் மூலம் இடைத்தரகர்கள் இல்லாத, வெளிப்படையான, மக்களின் குறைகளுக்கு உடனுக்குடன் தீர்வு காணும் நல்லாட்சி மாதிரி அமைப்பை உருவாக்குதல்.',
    'about_principles_title': 'எங்கள் முதன்மைக் கொள்கைகள்',
    'about_principle_1_title': 'நடுநிலைமை & மக்கள் சேவை',
    'about_principle_1_desc': 'அனைத்து குடிமக்களுக்கும் சமமான முன்னுரிமை மற்றும் பாரபட்சமற்ற சேவை.',
    'about_principle_2_title': 'தரவு பாதுகாப்பு & தனியுரிமை',
    'about_principle_2_desc': 'பொதுமக்களின் தொலைபேசி மற்றும் இருப்பிடத் தகவல்கள் பாதுகாப்பாகப் பராமரிக்கப்படும்.',
    'about_principle_3_title': 'பொறுப்புடைமை & வேகம்',
    'about_principle_3_desc': 'ஒவ்வொரு மனுவிற்கும் தனி ஐடி வழங்கப்பட்டு தொடர் நடவடிக்கை கண்காணிக்கப்படுகிறது.',
    'about_disclaimer_title': 'சுயாதீன மக்கள் குறைதீர்ப்பு உதவி தளம்',
    'about_disclaimer_desc': 'தமிழ்நாடு மக்கள் குரல் என்பது ஒரு சுயாதீன, அரசு சாரா மக்கள் நல்வாழ்வு குறைதீர்க்கும் தளமாகும். இது அரசு நிர்வாகத்தின் நேரடி தளம் அல்ல.',
    'about_cta_title': 'உங்கள் பகுதியில் பொதுப் பிரச்சனை உள்ளதா?',
    'about_cta_desc': 'புகாரை உடனடியாக புகைப்படங்களுடன் பதிவு செய்யுங்கள் அல்லது உங்கள் புகாரின் நடவடிக்கை நிலையை ஆன்லைனில் தெரிந்து கொள்ளுங்கள்.',

    // Updates Screen
    'updates_live_badge': 'தமிழ்நாடு நேரடி செய்தி அலைவரிசை • LIVE UPDATES',
    'updates_title': 'தமிழ்நாடு மாநில & மாவட்ட செய்திகள் மற்றும் அறிவிப்புகள்',
    'updates_sub': '38 மாவட்டங்களின் தினசரி முக்கிய மக்கள் நல நிகழ்வுகள், அரசு திட்டங்கள், குடிநீர், சாலை மற்றும் உட்கட்டமைப்பு மேம்பாட்டு பணிகள்.',
    'updates_search_hint': 'செய்திகளைத் தேடுங்கள்...',
    'cat_all_news': 'அனைத்தும்',
    'cat_water_road': 'குடிநீர் & சாலை',
    'cat_schemes': 'நலத்திட்டங்கள்',
    'cat_power_sanitation': 'மின்சாரம் & சுகாதாரம்',

    // Contact Screen
    'contact_title': 'உதவி மையம் & தொடர்புக்கு',
    'contact_sub': 'மக்களின் குரல் உதவி மையம் - குறைதீர்ப்பு மனு மற்றும் தொழில்நுட்ப உதவிக்கு எங்களைத் தொடர்பு கொள்ளவும்.',
    'contact_helpline_title': 'தொலைபேசி உதவி மையம்',
    'contact_helpline_timing': 'திங்கள் - சனி (காலை 9:00 - மாலை 6:00)',
    'contact_email_title': 'மின்னஞ்சல் வசதி',
    'contact_email_sub': 'கோரிக்கை மற்றும் கேள்விகளுக்கு',
    'contact_social_title': 'இன்ஸ்டாகிராம் தளம்',
    'contact_social_sub': 'அதிகாரப்பூர்வ சமூக வலைத்தளம்',
    'emergency_directory_title': 'அவசர கால எண்கள் (District Emergency Directory)',
    'emergency_police': 'காவல் கட்டுப்பாட்டு அறை',
    'emergency_fire': 'தீயணைப்பு & மீட்புப் பணி',
    'emergency_ambulance': 'ஆம்புலன்ஸ் அவசர சேவை',
    'emergency_electricity': 'மின்சார வாரிய புகார் (TANGEDCO)',
  };

  // Instant fast-cache for quick UI words so user gets 0ms speed without API lag
  static final Map<String, String> _quickEnglish = {
    'nav_home': 'Home',
    'nav_submit': 'Submit Grievance',
    'nav_track': 'Track Grievance',
    'nav_about': 'About Us',
    'nav_district': 'District Info',
    'nav_news': 'News & Updates',
    'nav_schemes': 'Govt Schemes',
    'nav_contact': 'Contact Us',
    'nav_privacy': 'Privacy Policy',
    'nav_admin': 'Admin Portal',
    'nav_profile': 'Profile',
    'notice_badge': 'NOTICE',
    'notice_ticker': 'Independent Civic Grievance Portal • Non-Governmental',
    'voice_tagline': 'VOICE OF THE VOICELESS',
    'platform_title': 'PEOPLE GRIEVANCE PLATFORM',
    'hero_with_people': 'With The People',
    'hero_line_1': 'Your Voice.',
    'hero_line_2': 'Your Area.',
    'hero_line_3': 'Your Connection.',
    'btn_register_grievance': 'Register Grievance',
    'btn_track_status': 'Track Grievance Status',
    'track_box_btn': 'Track',
    'btn_fetch_track': 'Fetch Grievance Details',
    'btn_demo_track': 'Test with Demo ID',
  };

  /// Dynamic Translator:
  /// - If Tamil: returns Tamil text instantly.
  /// - If English: returns fast cache or calls Laravel Backend Gemini API dynamically.
  static String tr(String key, [String? fallback]) {
    final lang = appLanguage.value;
    final tamilText = _tamilTexts[key] ?? key;

    // 1. If Tamil mode, return Tamil text directly
    if (lang == 'ta') {
      return tamilText;
    }

    // 2. If English mode, check instant cache first
    if (_quickEnglish.containsKey(key)) {
      return _quickEnglish[key]!;
    }

    // 3. Check Gemini Cache
    final cached = GeminiTranslationService.getCached(tamilText, target: 'en', source: 'ta');
    if (cached != null) {
      return cached;
    }

    // 4. Trigger Dynamic Gemini Translation via your Laravel backend
    GeminiTranslationService().translate(tamilText, target: 'en', source: 'ta');

    return fallback ?? tamilText;
  }

  /// Direct method to translate any custom dynamic text via Backend Gemini API
  static Future<String> translateWithGemini(String text, {String target = 'en', String source = 'ta'}) {
    return GeminiTranslationService().translate(text, target: target, source: source);
  }
}
