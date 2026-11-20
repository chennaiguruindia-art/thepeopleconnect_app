import 'package:flutter/material.dart';
import '../utils/app_translations.dart';
import '../widgets/app_drawer.dart';
import '../widgets/app_header.dart';

class ContactColors {
  static const navy = Color(0xFF0B1F3A);
  static const darkNavy = Color(0xFF071527);
  static const orange = Color(0xFFEA580C);
  static const saffron = Color(0xFFFF9933);
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

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _messageController = TextEditingController();
  bool _isSending = false;

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _submitInquiry(bool isTa) {
    final name = _nameController.text.trim();
    final mobile = _mobileController.text.trim();
    final message = _messageController.text.trim();

    if (name.isEmpty || mobile.isEmpty || message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isTa ? 'தயவுசெய்து அனைத்து விவரங்களையும் உள்ளிடவும்' : 'Please fill all required fields',
          ),
          backgroundColor: ContactColors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isSending = true;
    });

    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        setState(() {
          _isSending = false;
          _nameController.clear();
          _mobileController.clear();
          _messageController.clear();
        });

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                const Icon(Icons.check_circle, color: ContactColors.green, size: 24),
                const SizedBox(width: 8),
                Text(isTa ? 'செய்தி பெறப்பட்டது' : 'Inquiry Submitted'),
              ],
            ),
            content: Text(
              isTa
                  ? 'உங்கள் செய்தி வெற்றிகரமாகப் பெறப்பட்டது. எங்கள் உதவி மைய ஒருங்கிணைப்பாளர் விரைவில் உங்களைத் தொடர்புகொள்வார்.'
                  : 'Your query has been successfully received. Our support coordinator will get in touch with you shortly.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(isTa ? 'சரி' : 'OK'),
              ),
            ],
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: appLanguage,
      builder: (context, currentLang, _) {
        final isTa = AppTranslations.isTamil;

        return Scaffold(
          key: _scaffoldKey,
          drawer: const AppDrawer(currentRoute: 'contact'),
          backgroundColor: ContactColors.lightBg,
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
                                    const Icon(Icons.home_outlined, size: 15, color: ContactColors.orange),
                                    const SizedBox(width: 4),
                                    Text(
                                      AppTranslations.tr('nav_home'),
                                      style: const TextStyle(fontSize: 12, color: ContactColors.orange, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right, size: 15, color: ContactColors.grey),
                              Text(
                                AppTranslations.tr('nav_contact'),
                                style: const TextStyle(fontSize: 12, color: ContactColors.grey, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 1, color: ContactColors.borderLight),

                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Page Title
                              Center(
                                child: Text(
                                  AppTranslations.tr('contact_title'),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                    color: ContactColors.navy,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Center(
                                child: Text(
                                  AppTranslations.tr('contact_sub'),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: ContactColors.grey,
                                    height: 1.45,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),

                              // 3 Contact Channels Cards
                              _buildContactChannelCard(
                                icon: Icons.phone_in_talk,
                                iconColor: ContactColors.blue,
                                title: AppTranslations.tr('contact_helpline_title'),
                                subtitle: AppTranslations.tr('contact_helpline_timing'),
                                value: '+91 9384995222',
                                buttonText: isTa ? 'நேரடி அழைப்பு (Call)' : 'Call Helpline',
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('அழைக்கப்படுகிறது: +91 9384995222'),
                                      behavior: SnackBarBehavior.floating,
                                      backgroundColor: ContactColors.navy,
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 12),

                              _buildContactChannelCard(
                                icon: Icons.email_outlined,
                                iconColor: ContactColors.green,
                                title: AppTranslations.tr('contact_email_title'),
                                subtitle: AppTranslations.tr('contact_email_sub'),
                                value: 'thepeopleconnectofficial@gmail.com',
                                buttonText: isTa ? 'மின்னஞ்சல் அனுப்புக' : 'Send Email',
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Email: thepeopleconnectofficial@gmail.com'),
                                      behavior: SnackBarBehavior.floating,
                                      backgroundColor: ContactColors.navy,
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 12),

                              _buildContactChannelCard(
                                icon: Icons.camera_alt_outlined,
                                iconColor: const Color(0xFFD6249F),
                                title: AppTranslations.tr('contact_social_title'),
                                subtitle: AppTranslations.tr('contact_social_sub'),
                                value: '@thepeopleconnectofficial',
                                buttonText: isTa ? 'பார்வையிடுக (Instagram)' : 'View Profile',
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Instagram: @thepeopleconnectofficial'),
                                      behavior: SnackBarBehavior.floating,
                                      backgroundColor: ContactColors.navy,
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 24),

                              // Emergency District Directory
                              _buildEmergencyDirectory(isTa),
                              const SizedBox(height: 24),

                              // Quick Inquiry Form Card
                              _buildInquiryForm(isTa),
                              const SizedBox(height: 24),
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

  Widget _buildContactChannelCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String value,
    required String buttonText,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ContactColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: iconColor.withOpacity(0.12),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: ContactColors.navy),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 11, color: ContactColors.grey),
          ),
          const SizedBox(height: 8),
          SelectableText(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: iconColor,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 38,
            child: ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: ContactColors.navy,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: Text(buttonText, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyDirectory(bool isTa) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: ContactColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.emergency_outlined, color: ContactColors.red, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  AppTranslations.tr('emergency_directory_title'),
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: ContactColors.navy),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.6,
            children: [
              _emergencyCard(AppTranslations.tr('emergency_police'), '100 / 04562-280100', ContactColors.red),
              _emergencyCard(AppTranslations.tr('emergency_fire'), '101 / 04562-243101', ContactColors.red),
              _emergencyCard(AppTranslations.tr('emergency_ambulance'), '108 / 102', ContactColors.red),
              _emergencyCard(AppTranslations.tr('emergency_electricity'), '1912', ContactColors.blue),
            ],
          ),
        ],
      ),
    );
  }

  Widget _emergencyCard(String title, String number, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: ContactColors.lightBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ContactColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 10.5, color: ContactColors.grey, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            number,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildInquiryForm(bool isTa) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: ContactColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.chat_outlined, color: ContactColors.orange, size: 20),
              const SizedBox(width: 8),
              Text(
                isTa ? 'விரைவு தகவல் கோரிக்கை' : 'Quick Inquiry Message',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: ContactColors.navy),
              ),
            ],
          ),
          const SizedBox(height: 14),

          Text(
            isTa ? 'பெயர் (Full Name) *' : 'Full Name *',
            style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: ContactColors.navy),
          ),
          const SizedBox(height: 4),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              hintText: isTa ? 'உங்கள் பெயர்' : 'Your Name',
              hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              filled: true,
              fillColor: ContactColors.lightBg,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: ContactColors.borderLight)),
            ),
          ),
          const SizedBox(height: 12),

          Text(
            isTa ? 'மொபைல் எண் (Mobile Number) *' : 'Mobile Number *',
            style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: ContactColors.navy),
          ),
          const SizedBox(height: 4),
          TextField(
            controller: _mobileController,
            keyboardType: TextInputType.phone,
            maxLength: 10,
            decoration: InputDecoration(
              counterText: '',
              hintText: isTa ? '10 இலக்க மொபைல் எண்' : '10-digit mobile',
              hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              filled: true,
              fillColor: ContactColors.lightBg,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: ContactColors.borderLight)),
            ),
          ),
          const SizedBox(height: 12),

          Text(
            isTa ? 'செய்தி அல்லது கேள்வி (Message) *' : 'Message or Query *',
            style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: ContactColors.navy),
          ),
          const SizedBox(height: 4),
          TextField(
            controller: _messageController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: isTa ? 'உங்கள் கேள்வியைப் பதிவு செய்யவும்...' : 'Enter your inquiry...',
              hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              filled: true,
              fillColor: ContactColors.lightBg,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: ContactColors.borderLight)),
            ),
          ),
          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton.icon(
              onPressed: _isSending ? null : () => _submitInquiry(isTa),
              icon: _isSending
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.send, size: 16),
              label: Text(
                _isSending
                    ? (isTa ? 'அனுப்பப்படுகிறது...' : 'Sending...')
                    : (isTa ? 'செய்தி அனுப்புக (Submit Query)' : 'Submit Query'),
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: ContactColors.orange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
