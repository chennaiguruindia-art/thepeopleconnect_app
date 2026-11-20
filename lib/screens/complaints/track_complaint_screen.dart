import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../config/api_config.dart';
import '../../utils/app_translations.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/app_header.dart';

// App colors matching the main theme
class TrackColors {
  static const navy = Color(0xFF0B1F3A);
  static const darkNavy = Color(0xFF071527);
  static const orange = Color(0xFFEA580C);
  static const saffron = Color(0xFFFF9933);
  static const tricolorGreen = Color(0xFF138808);
  static const green = Color(0xFF16A34A);
  static const blue = Color(0xFF2563EB);
  static const skyBlue = Color(0xFF0284C7);
  static const cyan = Color(0xFF0891B2);
  static const amber = Color(0xFFD97706);
  static const purple = Color(0xFF7C3AED);
  static const red = Color(0xFFDC2626);
  static const lightBg = Color(0xFFF8FAFC);
  static const grey = Color(0xFF64748B);
  static const textDark = Color(0xFF0F172A);
  static const borderLight = Color(0xFFE2E8F0);
}

// Model for Grievance Tracking Data
class ComplaintTrackData {
  final String complaintId;
  final String? citizenName;
  final String? citizenMobile;
  final String? citizenAddress;
  final String subject;
  final String description;
  final String categoryName;
  final String departmentName;
  final String districtName;
  final String talukName;
  final String villageName;
  final String wardNumber;
  final String? landmark;
  final double? liveLatitude;
  final double? liveLongitude;
  final String? liveAddress;
  final String priority;
  final String status;
  final String statusLabel;
  final String? referralStatus;
  final String? referralStatusLabel;
  final String? resolutionRemarks;
  final String createdAt;
  final String? resolvedAt;
  final Map<String, dynamic>? assignedOfficer;
  final List<dynamic> history;
  final List<dynamic> attachments;

  ComplaintTrackData({
    required this.complaintId,
    this.citizenName,
    this.citizenMobile,
    this.citizenAddress,
    required this.subject,
    required this.description,
    required this.categoryName,
    required this.departmentName,
    required this.districtName,
    required this.talukName,
    required this.villageName,
    required this.wardNumber,
    this.landmark,
    this.liveLatitude,
    this.liveLongitude,
    this.liveAddress,
    this.priority = 'medium',
    required this.status,
    required this.statusLabel,
    this.referralStatus,
    this.referralStatusLabel,
    this.resolutionRemarks,
    required this.createdAt,
    this.resolvedAt,
    this.assignedOfficer,
    required this.history,
    this.attachments = const [],
  });

  factory ComplaintTrackData.fromJson(Map<String, dynamic> json) {
    final isTa = AppTranslations.isTamil;

    // Category & Department extraction
    String catName = '-';
    String deptName = '-';
    if (json['category'] is Map) {
      final cat = json['category'] as Map;
      catName = isTa
          ? (cat['name_ta'] ?? cat['name_en'] ?? '-')
          : (cat['name_en'] ?? cat['name_ta'] ?? '-');
      deptName = cat['department_name'] ?? catName;
    } else if (json['category_name'] != null) {
      catName = json['category_name'].toString();
      deptName = json['department_name'] ?? catName;
    }

    // District extraction
    String distName = '-';
    if (json['district'] is Map) {
      final d = json['district'] as Map;
      distName = isTa
          ? (d['name_ta'] ?? d['name_en'] ?? '-')
          : (d['name_en'] ?? d['name_ta'] ?? '-');
    } else if (json['district_name'] != null) {
      distName = json['district_name'].toString();
    }

    // Taluk extraction
    String tlkName = '-';
    if (json['taluk'] is Map) {
      final t = json['taluk'] as Map;
      tlkName = isTa
          ? (t['name_ta'] ?? t['name_en'] ?? '-')
          : (t['name_en'] ?? t['name_ta'] ?? '-');
    } else if (json['taluk_name'] != null) {
      tlkName = json['taluk_name'].toString();
    }

    // Village name
    String vlgName = '-';
    if (json['village_name'] != null && json['village_name'].toString().isNotEmpty && json['village_name'].toString() != '-') {
      vlgName = json['village_name'].toString();
    } else if (json['revenue_village'] is Map) {
      final rv = json['revenue_village'] as Map;
      vlgName = isTa ? (rv['name_ta'] ?? rv['name_en'] ?? '-') : (rv['name_en'] ?? rv['name_ta'] ?? '-');
    } else if (json['custom_village_name'] != null && json['custom_village_name'].toString().isNotEmpty) {
      vlgName = json['custom_village_name'].toString();
    }

    // Status label mapping
    final rawStatus = (json['status'] ?? 'submitted').toString().toLowerCase();
    String sLabel = json['status_label']?.toString() ?? '';
    if (sLabel.isEmpty) {
      switch (rawStatus) {
        case 'submitted':
          sLabel = isTa ? 'சமர்ப்பிக்கப்பட்டது' : 'Submitted';
          break;
        case 'under_review':
        case 'in_progress':
          sLabel = isTa ? 'ஆய்வில் உள்ளது' : 'In Progress / Under Review';
          break;
        case 'action_taken':
          sLabel = isTa ? 'நடவடிக்கை எடுக்கப்பட்டது' : 'Action Taken';
          break;
        case 'resolved':
          sLabel = isTa ? 'தீர்வு காணப்பட்டது' : 'Resolved';
          break;
        case 'closed':
          sLabel = isTa ? 'முடிக்கப்பட்டது' : 'Closed';
          break;
        case 'rejected':
          sLabel = isTa ? 'நிராகரிக்கப்பட்டது' : 'Rejected';
          break;
        default:
          sLabel = rawStatus;
      }
    }

    // Referral status label mapping
    final rawReferral = json['referral_status']?.toString();
    String? refLabel = json['referral_status_label'];
    if (refLabel == null && rawReferral != null && rawReferral != 'not_referred') {
      switch (rawReferral.toLowerCase()) {
        case 'referred':
          refLabel = isTa ? 'துறைக்கு பரிந்துரைக்கப்பட்டது' : 'Referred to Dept';
          break;
        case 'accepted':
          refLabel = isTa ? 'துறை ஏற்றுக்கொண்டது' : 'Accepted by Dept';
          break;
        default:
          refLabel = rawReferral;
      }
    }

    return ComplaintTrackData(
      complaintId: json['complaint_id'] ?? '-',
      citizenName: json['citizen_name']?.toString(),
      citizenMobile: (json['masked_mobile'] ?? json['citizen_mobile'])?.toString(),
      citizenAddress: json['citizen_address']?.toString(),
      subject: json['subject'] ?? (isTa ? 'பொதுக் கோரிக்கை' : 'Grievance'),
      description: json['description'] ?? '',
      categoryName: catName,
      departmentName: deptName,
      districtName: distName,
      talukName: tlkName,
      villageName: vlgName,
      wardNumber: json['ward_number'] != null ? json['ward_number'].toString() : '-',
      landmark: json['landmark']?.toString(),
      liveLatitude: json['live_latitude'] != null ? double.tryParse(json['live_latitude'].toString()) : null,
      liveLongitude: json['live_longitude'] != null ? double.tryParse(json['live_longitude'].toString()) : null,
      liveAddress: json['live_address']?.toString(),
      priority: json['priority'] ?? 'medium',
      status: rawStatus,
      statusLabel: sLabel,
      referralStatus: rawReferral,
      referralStatusLabel: refLabel,
      resolutionRemarks: json['resolution_remarks']?.toString(),
      createdAt: json['created_at_formatted'] ?? json['created_at'] ?? (isTa ? 'இன்று' : 'Today'),
      resolvedAt: json['resolved_at_formatted'] ?? json['resolved_at'],
      assignedOfficer: json['assigned_officer'] as Map<String, dynamic>?,
      history: json['history'] as List<dynamic>? ?? [],
      attachments: json['attachments'] as List<dynamic>? ?? [],
    );
  }
}

class TrackComplaintScreen extends StatefulWidget {
  final String? initialComplaintId;
  final String? initialMobile;

  const TrackComplaintScreen({
    super.key,
    this.initialComplaintId,
    this.initialMobile,
  });

  @override
  State<TrackComplaintScreen> createState() => _TrackComplaintScreenState();
}

class _TrackComplaintScreenState extends State<TrackComplaintScreen> {
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late final TextEditingController _complaintIdController;
  late final TextEditingController _mobileController;

  bool _isLoading = false;
  String? _errorMessage;
  ComplaintTrackData? _trackResult;

  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Accept': 'application/json',
      },
    ),
  );

  @override
  void initState() {
    super.initState();
    _complaintIdController = TextEditingController(text: widget.initialComplaintId ?? '');
    _mobileController = TextEditingController(text: widget.initialMobile ?? '');

    if (widget.initialComplaintId != null &&
        widget.initialComplaintId!.isNotEmpty &&
        widget.initialMobile != null &&
        widget.initialMobile!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _performTrack();
      });
    }
  }

  @override
  void dispose() {
    _complaintIdController.dispose();
    _mobileController.dispose();
    super.dispose();
  }

  Future<void> _performTrack() async {
    final isTa = AppTranslations.isTamil;
    final complaintId = _complaintIdController.text.trim().toUpperCase();
    final mobile = _mobileController.text.trim();

    if (complaintId.isEmpty) {
      setState(() {
        _errorMessage = isTa
            ? 'தயவுசெய்து புகார் எண் (Complaint ID) உள்ளிடவும்.'
            : 'Please enter your Grievance / Complaint ID.';
      });
      return;
    }

    if (mobile.isEmpty || mobile.length < 10) {
      setState(() {
        _errorMessage = isTa
            ? 'தயவுசெய்து 10 இலக்க பதிவு செய்யப்பட்ட மொபைல் எண்ணை உள்ளிடவும்.'
            : 'Please enter your 10-digit registered mobile number.';
      });
      return;
    }

    // Demo bypass only when explicit DEMO is requested
    if (complaintId == 'DEMO' || complaintId == 'DEMO-123') {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
        _trackResult = null;
      });
      await Future.delayed(const Duration(milliseconds: 300));
      setState(() {
        _trackResult = _generateDemoTrackData(complaintId, mobile);
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _trackResult = null;
    });

    try {
      final response = await _dio.post(
        ApiConfig.trackComplaintUrl,
        data: {
          'complaint_id': complaintId,
          'citizen_mobile': mobile,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data is Map && data['success'] == true && data['data'] != null) {
          setState(() {
            _trackResult = ComplaintTrackData.fromJson(data['data'] as Map<String, dynamic>);
            _isLoading = false;
            _errorMessage = null;
          });
          return;
        }
      }

      setState(() {
        _isLoading = false;
        _errorMessage = isTa
            ? 'மனு எண் ($complaintId) மற்றும் மொபைல் எண் ($mobile) பொருந்தவில்லை.'
            : 'No grievance found matching ID ($complaintId) and mobile ($mobile).';
      });
    } on DioException catch (dioErr) {
      debugPrint('Track DioException: ${dioErr.response?.data}');
      String msg = isTa
          ? 'மனு எண் ($complaintId) மற்றும் மொபைல் எண் ($mobile) பொருந்தவில்லை.\nதயவுசெய்து சரியான விவரங்களை உள்ளிடவும்.'
          : 'No grievance found matching ID ($complaintId) and mobile ($mobile). Please verify and retry.';

      if (dioErr.response?.data != null && dioErr.response!.data is Map) {
        final errData = dioErr.response!.data as Map;
        if (errData['message'] != null) {
          if (dioErr.response?.statusCode == 404) {
            msg = isTa
                ? 'மனு எண் ($complaintId) மற்றும் மொபைல் எண் ($mobile) கொண்ட கோரிக்கை தரவுத்தளத்தில் காணப்படவில்லை.\nதயவுசெய்து பதிவு செய்த சரியான மொபைல் எண்ணை உள்ளிடவும்.'
                : 'No grievance record found for ID ($complaintId) and mobile ($mobile).';
          } else {
            msg = errData['message'].toString();
          }
        }
      } else if (dioErr.type == DioExceptionType.connectionTimeout ||
          dioErr.type == DioExceptionType.receiveTimeout) {
        msg = isTa
            ? 'இணைய இணைப்பு மெதுவாக உள்ளது. மீண்டும் முயற்சிக்கவும்.'
            : 'Connection timeout. Please check your internet connection.';
      }

      setState(() {
        _isLoading = false;
        _errorMessage = msg;
        _trackResult = null;
      });
    } catch (e) {
      debugPrint('Track API error: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = isTa
            ? 'சர்வர் தொடர்பு பிழை. தயவுசெய்து சிறிது நேரம் கழித்து மீண்டும் முயற்சிக்கவும்.'
            : 'Server communication error. Please try again later.';
        _trackResult = null;
      });
    }
  }

  ComplaintTrackData _generateDemoTrackData(String id, String mobile) {
    final isTa = AppTranslations.isTamil;
    return ComplaintTrackData(
      complaintId: id.toUpperCase(),
      subject: isTa
          ? 'குடிநீர் விநியோகம் மற்றும் பைப்லைன் பழுதுநீக்கம் கோருதல்'
          : 'Request for Drinking Water Pipeline Repair & Restoration',
      description: isTa
          ? 'எங்கள் பகுதியில் கடந்த 4 நாட்களாக பிரதான குடிநீர் குழாய் உடைந்ததால் பொதுமக்களுக்கு குடிநீர் தட்டுப்பாடு ஏற்பட்டுள்ளது. உடனடியாக பழுதுநீக்க வேண்டுகிறோம்.'
          : 'Major drinking water pipeline broken for the past 4 days, causing acute shortage. Urgent repair requested for ward residents.',
      categoryName: isTa ? 'குடிநீர் வசதி' : 'Drinking Water Supply',
      departmentName: isTa ? 'தமிழ்நாடு குடிநீர் வடிகால் வாரியம் (TWAD)' : 'TWAD Board',
      districtName: isTa ? 'விருதுநகர்' : 'Virudhunagar',
      talukName: isTa ? 'விருதுநகர் வட்டம்' : 'Virudhunagar Taluk',
      villageName: isTa ? 'ஆமத்தூர்' : 'Amathur',
      wardNumber: '4',
      status: 'in_progress',
      statusLabel: isTa ? 'நடவடிக்கையில் உள்ளது' : 'In Progress / Action Taken',
      referralStatus: 'referred_twad',
      referralStatusLabel: isTa ? 'குடிநீர் வாரியத்திற்கு பரிந்துரைக்கப்பட்டது' : 'Referred to TWAD Dept',
      resolutionRemarks: isTa
          ? 'களப்பணியாளர்கள் நேரில் சென்று ஆய்வு செய்துள்ளனர். மாற்று குழாய் அமைக்கும் பணி துவங்கியுள்ளது.'
          : 'Field engineers inspected the location. Pipeline replacement work has commenced.',
      createdAt: '15 Nov 2026, 10:30 AM',
      assignedOfficer: {
        'name': isTa ? 'திரு. K. முருகேசன்' : 'Mr. K. Murugesan',
        'designation': isTa ? 'உதவி பொறியாளர்' : 'Assistant Engineer',
        'department': isTa ? 'குடிநீர் வழங்கல் துறை' : 'Water Supply Wing',
      },
      history: [
        {
          'action': isTa ? 'கள ஆய்வு பணி துவக்கம்' : 'Field Inspection Commenced',
          'new_status_label': isTa ? 'நடவடிக்கையில் உள்ளது' : 'In Progress',
          'remarks': isTa
              ? 'பொறியாளர் ஆய்வை நிறைவு செய்து பழுதுநீக்கும் பணியை தொடங்கியுள்ளார்.'
              : 'Engineer completed on-site assessment and initiated pipeline works.',
          'created_at_formatted': '17 Nov 2026, 09:15 AM',
        },
        {
          'action': isTa ? 'துறைக்கு பரிந்துரைக்கப்பட்டது' : 'Referred to Department',
          'new_status_label': isTa ? 'பரிந்துரைக்கப்பட்டது' : 'Referred',
          'remarks': isTa ? 'குடிநீர் வடிகால் வாரிய உதவி பொறியாளருக்கு மனு மாற்றப்பட்டது.' : 'Forwarded to TWAD Assistant Engineer.',
          'created_at_formatted': '16 Nov 2026, 02:45 PM',
        },
        {
          'action': isTa ? 'ஆவணங்கள் சரிபார்ப்பு' : 'Verification Completed',
          'new_status_label': isTa ? 'சரிபார்க்கப்பட்டது' : 'Verified',
          'remarks': isTa ? 'மனுதாரர் விவரங்கள் மற்றும் பகுதி இருப்பிடம் சரிபார்க்கப்பட்டது.' : 'Citizen contact & location confirmed.',
          'created_at_formatted': '15 Nov 2026, 04:20 PM',
        },
        {
          'action': isTa ? 'புகார் பதிவு செய்யப்பட்டது' : 'Grievance Registered',
          'new_status_label': isTa ? 'சமர்ப்பிக்கப்பட்டது' : 'Submitted',
          'remarks': isTa ? 'பொதுமக்கள் குறைதீர்ப்பு தளத்தில் மனு பதிவானது.' : 'Successfully registered on The People Connect.',
          'created_at_formatted': '15 Nov 2026, 10:30 AM',
        },
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'resolved':
        return TrackColors.green;
      case 'in_progress':
        return TrackColors.blue;
      case 'under_review':
        return TrackColors.amber;
      case 'referred':
        return TrackColors.cyan;
      case 'rejected':
        return TrackColors.red;
      case 'submitted':
      default:
        return TrackColors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: appLanguage,
      builder: (context, currentLang, _) {
        return Scaffold(
          key: _scaffoldKey,
          drawer: const AppDrawer(currentRoute: 'track'),
          backgroundColor: TrackColors.lightBg,
          body: SafeArea(
            child: Column(
              children: [
                // 1. REUSABLE TOP APP HEADER (Branded Header with Back Button & Language Switcher)
                AppHeader(
                  showBackButton: true,
                  onMenuPressed: () {
                    _scaffoldKey.currentState?.openDrawer();
                  },
                ),

                // 2. Scrollable Body Content
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
                                    const Icon(Icons.home_outlined, size: 15, color: TrackColors.orange),
                                    const SizedBox(width: 4),
                                    Text(
                                      AppTranslations.tr('nav_home'),
                                      style: const TextStyle(fontSize: 12, color: TrackColors.orange, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right, size: 15, color: TrackColors.grey),
                              Text(
                                AppTranslations.tr('nav_track'),
                                style: const TextStyle(fontSize: 12, color: TrackColors.grey, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 1, color: TrackColors.borderLight),

                        // Search Input Card
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: _buildSearchCard(),
                        ),

                        // Error Alert
                        if (_errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF2F2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFFECACA)),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.error_outline, color: TrackColors.red, size: 22),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      _errorMessage!,
                                      style: const TextStyle(
                                        color: Color(0xFF991B1B),
                                        fontSize: 12,
                                        height: 1.4,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        // Tracking Result
                        if (_trackResult != null)
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: _buildTrackingResultCard(_trackResult!),
                          ),

                        const SizedBox(height: 24),
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

  // Search Form Card
  Widget _buildSearchCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: TrackColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.search, color: TrackColors.orange, size: 22),
                const SizedBox(width: 8),
                Text(
                  AppTranslations.tr('track_screen_title'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: TrackColors.navy,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              AppTranslations.tr('track_screen_sub'),
              style: const TextStyle(fontSize: 12, color: TrackColors.grey, height: 1.4),
            ),
            const SizedBox(height: 18),

            // Field 1: Complaint ID
            Text(
              AppTranslations.tr('lbl_complaint_id'),
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: TrackColors.navy),
            ),
            const SizedBox(height: 6),
            Container(
              decoration: BoxDecoration(
                color: TrackColors.lightBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: TrackColors.borderLight),
              ),
              child: TextFormField(
                controller: _complaintIdController,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.confirmation_number_outlined, color: TrackColors.grey, size: 20),
                  hintText: 'e.g. VNK-20261101-0012',
                  hintStyle: TextStyle(fontSize: 13, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Field 2: Registered Mobile
            Text(
              AppTranslations.tr('lbl_mobile'),
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: TrackColors.navy),
            ),
            const SizedBox(height: 6),
            Container(
              decoration: BoxDecoration(
                color: TrackColors.lightBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: TrackColors.borderLight),
              ),
              child: TextFormField(
                controller: _mobileController,
                keyboardType: TextInputType.phone,
                maxLength: 10,
                decoration: InputDecoration(
                  counterText: '',
                  prefixIcon: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    child: Text(
                      '+91',
                      style: TextStyle(fontWeight: FontWeight.bold, color: TrackColors.navy, fontSize: 13),
                    ),
                  ),
                  prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                  hintText: AppTranslations.tr('hint_mobile'),
                  hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Track Submit Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _performTrack,
                icon: _isLoading
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.search, size: 20),
                label: Text(
                  _isLoading
                      ? (AppTranslations.isTamil ? 'கண்காணிக்கப்படுகிறது...' : 'Fetching Details...')
                      : AppTranslations.tr('btn_fetch_track'),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: TrackColors.orange,
                  foregroundColor: Colors.white,
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            // Demo Quick Fill Link
            const SizedBox(height: 10),
            Center(
              child: TextButton.icon(
                onPressed: () {
                  setState(() {
                    _complaintIdController.text = 'VNK-20261101-0012';
                    _mobileController.text = '9876543210';
                  });
                  _performTrack();
                },
                icon: const Icon(Icons.play_circle_outline, size: 16, color: TrackColors.blue),
                label: Text(
                  AppTranslations.tr('btn_demo_track'),
                  style: const TextStyle(fontSize: 11, color: TrackColors.blue, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Dynamic Tracking Result Card
  Widget _buildTrackingResultCard(ComplaintTrackData data) {
    final statusColor = _getStatusColor(data.status);
    final isTa = AppTranslations.isTamil;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: TrackColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Dark Navy with Complaint ID and Status Badge
          Container(
            color: TrackColors.navy,
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Grievance Record',
                          style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        data.complaintId,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),

                // Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.circle, color: Colors.white, size: 8),
                      const SizedBox(width: 5),
                      Text(
                        data.statusLabel,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Body Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Subject
                Text(
                  data.subject,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: TrackColors.navy,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 8),

                // Location Pin
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.location_on, color: TrackColors.red, size: 16),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${data.districtName}, ${data.talukName}, ${data.villageName} (${isTa ? 'வார்டு' : 'Ward'}: ${data.wardNumber})',
                        style: const TextStyle(fontSize: 12, color: TrackColors.grey),
                      ),
                    ),
                  ],
                ),
                if (data.citizenName != null && data.citizenName!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.person_pin_rounded, color: TrackColors.blue, size: 16),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${isTa ? 'மனுதாரர்' : 'Citizen'}: ${data.citizenName} • ${data.citizenMobile ?? ''}',
                          style: const TextStyle(fontSize: 12, color: TrackColors.navy, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ],
                if (data.liveLatitude != null && data.liveLongitude != null) ...[
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.verified_rounded, color: TrackColors.green, size: 16),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${isTa ? 'கள இருப்பிடம்' : 'Field Location'}: ${isTa ? 'உறுதி செய்யப்பட்டு இணைக்கப்பட்டுள்ளது' : 'Verified & Linked'}${data.liveAddress != null && data.liveAddress!.isNotEmpty ? ' (${data.liveAddress})' : ''}',
                          style: const TextStyle(fontSize: 11, color: Color(0xFF15803D), fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 12),

                // Badges Row
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _infoBadge(Icons.category_outlined, data.categoryName, TrackColors.orange),
                    _infoBadge(Icons.account_balance_outlined, data.departmentName, TrackColors.skyBlue),
                  ],
                ),
                const SizedBox(height: 14),

                // Description Box
                if (data.description.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: TrackColors.lightBg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Text(
                      data.description,
                      style: const TextStyle(fontSize: 12, color: TrackColors.textDark, height: 1.4),
                    ),
                  ),
                const SizedBox(height: 14),

                // Date Submitted & Resolved
                Row(
                  children: [
                    Expanded(
                      child: _dateBox(isTa ? 'பதிவு செய்யப்பட்ட நாள்' : 'Registered On', data.createdAt),
                    ),
                    if (data.resolvedAt != null) ...[
                      const SizedBox(width: 10),
                      Expanded(
                        child: _dateBox(isTa ? 'தீர்வு காணப்பட்ட நாள்' : 'Resolved Date', data.resolvedAt!),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 14),

                // Assigned Officer
                if (data.assignedOfficer != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFBFDBFE)),
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 18,
                          backgroundColor: TrackColors.blue,
                          child: Icon(Icons.person, color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isTa ? 'ஒதுக்கப்பட்ட அதிகாரி:' : 'Assigned Officer / Cell:',
                                style: const TextStyle(fontSize: 10, color: TrackColors.grey, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                data.assignedOfficer!['name'] ?? 'Nodal Officer',
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: TrackColors.navy),
                              ),
                              Text(
                                '${data.assignedOfficer!['designation'] ?? ''} • ${data.assignedOfficer!['department'] ?? ''}',
                                style: const TextStyle(fontSize: 11, color: TrackColors.grey),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                // Resolution Remarks
                if (data.resolutionRemarks != null && data.resolutionRemarks!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFBBF7D0)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.check_circle, color: TrackColors.green, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isTa ? 'நடவடிக்கை குறிப்பு:' : 'Resolution Remarks:',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: TrackColors.green),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                data.resolutionRemarks!,
                                style: const TextStyle(fontSize: 12, color: TrackColors.textDark, height: 1.35),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 10),

                // Timeline Section
                Row(
                  children: [
                    const Icon(Icons.history_rounded, color: TrackColors.navy, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      isTa ? 'நடவடிக்கை வரலாறு (Timeline)' : 'Action History & Timeline',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: TrackColors.navy,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: data.history.length,
                  itemBuilder: (context, index) {
                    final item = data.history[index];
                    final isLast = index == data.history.length - 1;
                    return _buildTimelineItem(item, isLast, index == 0);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoBadge(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }

  Widget _dateBox(String label, String date) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: TrackColors.lightBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: TrackColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: TrackColors.grey)),
          const SizedBox(height: 2),
          Text(
            date,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: TrackColors.navy),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(dynamic item, bool isLast, bool isLatest) {
    final title = item['action'] ?? item['new_status_label'] ?? '-';
    final remarks = item['remarks'] ?? '';
    final time = item['created_at_formatted'] ?? '';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              height: 16,
              width: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isLatest ? TrackColors.orange : Colors.grey.shade400,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 48,
                color: Colors.grey.shade300,
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isLatest ? TrackColors.orange : TrackColors.navy,
                      ),
                    ),
                  ),
                  Text(
                    time,
                    style: const TextStyle(fontSize: 10, color: TrackColors.grey),
                  ),
                ],
              ),
              if (remarks.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  remarks,
                  style: const TextStyle(fontSize: 11, color: TrackColors.grey, height: 1.3),
                ),
              ],
              const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }
}
