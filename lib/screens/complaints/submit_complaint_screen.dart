import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import '../../config/api_config.dart';
import '../../utils/app_translations.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/app_header.dart';
import 'track_complaint_screen.dart';
import '../../data/tn_locations_data.dart';

class SubmitColors {
  static const navy = Color(0xFF0B1F3A);
  static const darkNavy = Color(0xFF071527);
  static const saffron = Color(0xFFFF7A00);
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

class SubmitComplaintScreen extends StatefulWidget {
  const SubmitComplaintScreen({super.key});

  @override
  State<SubmitComplaintScreen> createState() => _SubmitComplaintScreenState();
}

class _SubmitComplaintScreenState extends State<SubmitComplaintScreen> {
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Citizen Info Controllers
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();

  // Location Controllers & State (Cascading for Districts)
  int? _selectedDistrictId = 30; // Default: Tirunelveli
  int? _selectedDivisionId = 73; // Default: Tirunelveli Division
  int? _selectedTalukId = 235; // Default: Tirunelveli Taluk
  int? _selectedVillageId;
  bool _isManualVillage = false;

  List<Map<String, dynamic>> _districts = [];
  List<Map<String, dynamic>> _divisions = [];
  List<Map<String, dynamic>> _taluks = [];
  List<Map<String, dynamic>> _villages = [];

  bool _isLoadingVillages = false;

  final _villageController = TextEditingController();
  final _wardController = TextEditingController();
  final _landmarkController = TextEditingController();

  // Live GPS Geolocation
  double? _liveLatitude;
  double? _liveLongitude;
  String? _liveAddress;
  bool _isCapturingLocation = false;

  // Grievance Controllers
  int _selectedCategoryId = 1; // 1: Drinking Water
  String _selectedPriority = 'medium';
  final _subjectController = TextEditingController();
  final _descController = TextEditingController();

  // Consent & Attachment
  bool _privacyConsent = true;
  XFile? _selectedPhoto;
  final ImagePicker _picker = ImagePicker();

  bool _isSubmitting = false;
  String? _errorMessage;
  String? _registeredComplaintId;

  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
      headers: {
        'Accept': 'application/json',
      },
    ),
  );

  @override
  void initState() {
    super.initState();
    _districts = List<Map<String, dynamic>>.from(TnLocationsData.districts);
    _selectedDistrictId = 30; // Default: Tirunelveli
    _divisions = TnLocationsData.divisions.where((d) => d['district_id'] == _selectedDistrictId).toList();
    _selectedDivisionId = _divisions.isNotEmpty ? _divisions.first['id'] as int : 73;
    _taluks = TnLocationsData.taluks.where((t) => t['revenue_division_id'] == _selectedDivisionId).toList();
    _selectedTalukId = _taluks.isNotEmpty ? _taluks.first['id'] as int : 235;

    if (_selectedTalukId != null) {
      _loadVillages(_selectedTalukId!);
    }

    _loadActiveDistricts();

    // Attempt to prompt/capture live GPS location for complaint
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestAndCaptureLocation(silent: true);
    });
  }

  Future<void> _loadActiveDistricts() async {
    try {
      final res = await _dio.get(ApiConfig.metaDistrictsUrl);
      if (res.statusCode == 200 && res.data != null && res.data['success'] == true) {
        final list = (res.data['data'] as List).cast<Map<String, dynamic>>();
        if (list.isNotEmpty && mounted) {
          setState(() {
            _districts = list;
            // If current selected district is not in active list, or there is only 1 active district
            if (!_districts.any((d) => d['id'] == _selectedDistrictId) || _districts.length == 1) {
              _selectDistrict(_districts.first['id'] as int);
            }
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading active districts: $e');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _villageController.dispose();
    _wardController.dispose();
    _landmarkController.dispose();
    _subjectController.dispose();
    _descController.dispose();
    super.dispose();
  }

  String get _selectedDistrictName {
    if (_selectedDistrictId == null) return '';
    final d = _districts.firstWhere((x) => x['id'] == _selectedDistrictId, orElse: () => {});
    if (d.isEmpty) return '';
    final nameTa = d['name_ta'] ?? d['name_en'] ?? '';
    final nameEn = d['name_en'] ?? '';
    return (nameEn.isNotEmpty && nameEn != nameTa) ? '$nameTa ($nameEn)' : nameTa;
  }

  String get _selectedDivisionName {
    if (_selectedDivisionId == null) return '';
    final d = _divisions.firstWhere((x) => x['id'] == _selectedDivisionId, orElse: () => {});
    if (d.isEmpty) return '';
    final nameTa = d['name_ta'] ?? d['name_en'] ?? '';
    final nameEn = d['name_en'] ?? '';
    return (nameEn.isNotEmpty && nameEn != nameTa) ? '$nameTa ($nameEn)' : nameTa;
  }

  String get _selectedTalukName {
    if (_selectedTalukId == null) return '';
    final t = _taluks.firstWhere((x) => x['id'] == _selectedTalukId, orElse: () => {});
    if (t.isEmpty) return '';
    final nameTa = t['name_ta'] ?? t['name_en'] ?? '';
    final nameEn = t['name_en'] ?? '';
    return (nameEn.isNotEmpty && nameEn != nameTa) ? '$nameTa ($nameEn)' : nameTa;
  }

  void _selectDistrict(int districtId) {
    setState(() {
      _selectedDistrictId = districtId;
      _divisions = TnLocationsData.divisions.where((d) => d['district_id'] == districtId).toList();
      _selectedDivisionId = _divisions.isNotEmpty ? _divisions.first['id'] as int : null;
      if (_selectedDivisionId != null) {
        _taluks = TnLocationsData.taluks.where((t) => t['revenue_division_id'] == _selectedDivisionId).toList();
        _selectedTalukId = _taluks.isNotEmpty ? _taluks.first['id'] as int : null;
      } else {
        _taluks = [];
        _selectedTalukId = null;
      }
      _villages = [];
      _selectedVillageId = null;
      _isManualVillage = false;
      _villageController.clear();
    });

    if (_selectedTalukId != null) {
      _loadVillages(_selectedTalukId!);
    }
  }

  void _selectDivision(int divisionId) {
    setState(() {
      _selectedDivisionId = divisionId;
      _taluks = TnLocationsData.taluks.where((t) => t['revenue_division_id'] == divisionId).toList();
      _selectedTalukId = _taluks.isNotEmpty ? _taluks.first['id'] as int : null;
      _villages = [];
      _selectedVillageId = null;
      _isManualVillage = false;
      _villageController.clear();
    });

    if (_selectedTalukId != null) {
      _loadVillages(_selectedTalukId!);
    }
  }

  void _selectTaluk(int talukId) {
    setState(() {
      _selectedTalukId = talukId;
      _villages = [];
      _selectedVillageId = null;
      _isManualVillage = false;
      _villageController.clear();
    });

    _loadVillages(talukId);
  }

  Future<void> _loadVillages(int talukId) async {
    setState(() {
      _isLoadingVillages = true;
      _villages = [];
      _selectedVillageId = null;
    });

    try {
      final res = await _dio.get('${ApiConfig.metaVillagesUrl}?taluk_id=$talukId');
      if (res.statusCode == 200 && res.data != null && res.data['data'] != null) {
        final list = List<Map<String, dynamic>>.from(res.data['data']);
        if (mounted) {
          setState(() {
            _villages = list;
            _isLoadingVillages = false;
            if (_villages.isNotEmpty) {
              _selectedVillageId = _villages.first['id'] as int;
              final found = _villages.first;
              final nameTa = found['name_ta'] ?? found['name_en'] ?? '';
              final nameEn = found['name_en'] ?? '';
              _villageController.text = (nameEn.isNotEmpty && nameEn != nameTa) ? '$nameTa ($nameEn)' : nameTa;
              _isManualVillage = false;
            } else {
              _isManualVillage = true;
            }
          });
          return;
        }
      }
    } catch (e) {
      debugPrint('Error loading villages from API: $e');
    }

    if (mounted) {
      setState(() {
        _isLoadingVillages = false;
        if (_villages.isEmpty) {
          _isManualVillage = true;
        }
      });
    }
  }

  // Modern Searchable Bottom Sheet Picker (Select2 equivalent for Mobile)
  void _openLocationPicker({
    required String title,
    required String searchHint,
    required List<Map<String, dynamic>> items,
    required int? selectedId,
    required Function(Map<String, dynamic>) onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        String query = '';
        return StatefulBuilder(
          builder: (context, setModalState) {
            final isTa = AppTranslations.isTamil;
            final filtered = items.where((item) {
              if (query.trim().isEmpty) return true;
              final q = query.toLowerCase().trim();
              final nameTa = (item['name_ta'] ?? '').toString().toLowerCase();
              final nameEn = (item['name_en'] ?? '').toString().toLowerCase();
              return nameTa.contains(q) || nameEn.contains(q);
            }).toList();

            return Container(
              height: MediaQuery.of(context).size.height * 0.78,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
              ),
              child: Column(
                children: [
                  // Drag handle
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 10, bottom: 6),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  // Title bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.search_rounded, color: SubmitColors.blue, size: 20),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: SubmitColors.navy,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, color: SubmitColors.grey),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  // Search box
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: TextField(
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: searchHint,
                        hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                        prefixIcon: const Icon(Icons.search, color: SubmitColors.blue, size: 20),
                        suffixIcon: query.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () => setModalState(() => query = ''),
                              )
                            : null,
                        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                        filled: true,
                        fillColor: const Color(0xFFF1F5F9),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (val) => setModalState(() => query = val),
                    ),
                  ),
                  const Divider(height: 12),
                  // Count summary
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 2),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isTa ? 'மொத்தம்: ${filtered.length}' : 'Total: ${filtered.length}',
                          style: const TextStyle(fontSize: 11, color: SubmitColors.grey, fontWeight: FontWeight.w600),
                        ),
                        Text(
                          isTa ? 'தேர்வு செய்ய தட்டவும்' : 'Tap to select',
                          style: const TextStyle(fontSize: 11, color: SubmitColors.grey),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 10),
                  // List
                  Expanded(
                    child: filtered.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Text(
                                isTa ? 'பொருந்தும் தகவல்கள் இல்லை' : 'No items match your search',
                                style: const TextStyle(color: SubmitColors.grey, fontSize: 13),
                              ),
                            ),
                          )
                        : ListView.separated(
                            itemCount: filtered.length,
                            separatorBuilder: (_, _) => const Divider(height: 1, indent: 16, endIndent: 16),
                            itemBuilder: (context, idx) {
                              final item = filtered[idx];
                              final isSelected = item['id'] == selectedId;
                              final nameTa = item['name_ta'] ?? item['name_en'] ?? '';
                              final nameEn = item['name_en'] ?? '';
                              final display = (nameEn.isNotEmpty && nameEn != nameTa) ? '$nameTa ($nameEn)' : nameTa;

                              return ListTile(
                                dense: true,
                                title: Text(
                                  display,
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                    color: isSelected ? SubmitColors.blue : const Color(0xFF1E293B),
                                  ),
                                ),
                                trailing: isSelected
                                    ? const Icon(Icons.check_circle_rounded, color: SubmitColors.blue, size: 20)
                                    : null,
                                onTap: () {
                                  Navigator.pop(context);
                                  onSelected(item);
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _openVillagePicker(bool isTa) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        String searchQuery = '';
        return StatefulBuilder(
          builder: (context, setModalState) {
            final filtered = _villages.where((v) {
              if (searchQuery.trim().isEmpty) return true;
              final q = searchQuery.toLowerCase().trim();
              final nameTa = (v['name_ta'] ?? '').toString().toLowerCase();
              final nameEn = (v['name_en'] ?? '').toString().toLowerCase();
              return nameTa.contains(q) || nameEn.contains(q);
            }).toList();

            return Container(
              height: MediaQuery.of(context).size.height * 0.78,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
              ),
              child: Column(
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 10, bottom: 6),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF7ED),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.location_city_rounded, color: SubmitColors.orange, size: 20),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            isTa ? 'வருவாய் கிராமம் / நகரம்' : 'Revenue Village / Town',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: SubmitColors.navy,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, color: SubmitColors.grey),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  // Search Box
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: TextField(
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: isTa ? 'கிராமப் பெயர் உள்ளிட்டு தேடுக...' : 'Search village name...',
                        hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                        prefixIcon: const Icon(Icons.search, color: SubmitColors.blue, size: 20),
                        suffixIcon: searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () => setModalState(() => searchQuery = ''),
                              )
                            : null,
                        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                        filled: true,
                        fillColor: const Color(0xFFF1F5F9),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (val) {
                        setModalState(() {
                          searchQuery = val;
                        });
                      },
                    ),
                  ),
                  const Divider(height: 12),
                  // Special option: [+] பிற கிராமம் / நகர் (Type Manually)
                  ListTile(
                    leading: const Icon(Icons.edit_note, color: SubmitColors.orange),
                    title: Text(
                      isTa ? '[+] பிற கிராமம் / நகர் (நேரடியாக தட்டச்சு செய்ய)' : '[+] Other Village / Town (Type Manually)',
                      style: const TextStyle(color: SubmitColors.orange, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      setState(() {
                        _isManualVillage = true;
                      });
                    },
                  ),
                  const Divider(height: 1),
                  // Village List
                  Expanded(
                    child: filtered.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Text(
                                isTa
                                    ? 'கிராமம் கிடைக்கவில்லை.\nமேலே உள்ள "நேரடியாக தட்டச்சு செய்ய" என்பதை தேர்வு செய்யவும்.'
                                    : 'No villages match.\nUse "Type Manually" above.',
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: SubmitColors.grey, fontSize: 13),
                              ),
                            ),
                          )
                        : ListView.separated(
                            itemCount: filtered.length,
                            separatorBuilder: (_, _) => const Divider(height: 1, indent: 16, endIndent: 16),
                            itemBuilder: (context, index) {
                              final item = filtered[index];
                              final isSelected = item['id'] == _selectedVillageId;
                              final nameTa = item['name_ta'] ?? item['name_en'] ?? '';
                              final nameEn = item['name_en'] ?? '';
                              final display = (nameEn.isNotEmpty && nameEn != nameTa) ? '$nameTa ($nameEn)' : nameTa;

                              return ListTile(
                                dense: true,
                                title: Text(
                                  display,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    color: isSelected ? SubmitColors.blue : const Color(0xFF1E293B),
                                  ),
                                ),
                                trailing: isSelected ? const Icon(Icons.check, color: SubmitColors.blue, size: 18) : null,
                                onTap: () {
                                  Navigator.pop(context);
                                  setState(() {
                                    _selectedVillageId = item['id'] as int;
                                    _villageController.text = display;
                                    _isManualVillage = false;
                                  });
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // 10 Categories matching Laravel Database
  final List<Map<String, dynamic>> _categories = const [
    {'id': 1, 'name_ta': 'குடிநீர் வழங்கல்', 'name_en': 'Drinking Water Supply'},
    {'id': 2, 'name_ta': 'சாக்கடை மற்றும் சுகாதாரம்', 'name_en': 'Drainage and Sanitation'},
    {'id': 3, 'name_ta': 'சாலை மற்றும் தெரு பராமரிப்பு', 'name_en': 'Roads and Street Maintenance'},
    {'id': 4, 'name_ta': 'தெருவிளக்கு பராமரிப்பு', 'name_en': 'Street Lighting'},
    {'id': 5, 'name_ta': 'மின்சாரம் மற்றும் மின்கட்டமைப்பு', 'name_en': 'Electricity & Power Supply'},
    {'id': 6, 'name_ta': 'குப்பை மேலாண்மை & அகற்றுதல்', 'name_en': 'Solid Waste & Garbage Clearance'},
    {'id': 7, 'name_ta': 'பொது சுகாதாரம் & கொசு ஒழிப்பு', 'name_en': 'Public Health & Mosquito Control'},
    {'id': 8, 'name_ta': 'வருவாய் மற்றும் நில நிர்வாகம்', 'name_en': 'Revenue & Land Matters'},
    {'id': 9, 'name_ta': 'ரேஷன் கடை மற்றும் உணவுப்பொருள்', 'name_en': 'Fair Price Shops / Ration (PDS)'},
    {'id': 10, 'name_ta': 'ஆக்கிரமிப்பு அகற்றுதல்', 'name_en': 'Encroachment Removal'},
  ];

  Future<void> _pickPhoto() async {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        final isTa = AppTranslations.isTamil;
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: SubmitColors.orange),
                title: Text(isTa ? 'கேமரா மூலம் புகைப்படம் எடுக்க' : 'Take Photo with Camera'),
                onTap: () async {
                  Navigator.pop(context);
                  final photo = await _picker.pickImage(source: ImageSource.camera, imageQuality: 75);
                  if (photo != null) {
                    setState(() {
                      _selectedPhoto = photo;
                    });
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: SubmitColors.blue),
                title: Text(isTa ? 'கேலரியில் இருந்து தேர்ந்தெடுக்க' : 'Choose from Gallery'),
                onTap: () async {
                  Navigator.pop(context);
                  final photo = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 75);
                  if (photo != null) {
                    setState(() {
                      _selectedPhoto = photo;
                    });
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<bool> _requestAndCaptureLocation({bool silent = false}) async {
    if (_isCapturingLocation) return false;
    setState(() {
      _isCapturingLocation = true;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (!silent && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppTranslations.isTamil
                    ? 'உங்கள் போனில் GPS / Location சேவையை On செய்யவும்.'
                    : 'Please turn on Location/GPS service on your phone.',
              ),
              backgroundColor: SubmitColors.amber,
            ),
          );
        }
        if (mounted) {
          setState(() {
            _isCapturingLocation = false;
          });
        }
        return false;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            setState(() {
              _isCapturingLocation = false;
            });
          }
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          setState(() {
            _isCapturingLocation = false;
          });
          if (!silent) {
            _showPermissionSettingsDialog();
          }
        }
        return false;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 12),
        ),
      );

      if (mounted) {
        setState(() {
          _liveLatitude = position.latitude;
          _liveLongitude = position.longitude;
          _isCapturingLocation = false;
        });
      }
      return true;
    } catch (e) {
      debugPrint('Live location capture error: $e');
      if (mounted) {
        setState(() {
          _isCapturingLocation = false;
        });
      }
      return false;
    }
  }

  void _showPermissionSettingsDialog() {
    final isTa = AppTranslations.isTamil;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.location_off_rounded, color: SubmitColors.orange, size: 22),
            const SizedBox(width: 8),
            Text(
              isTa ? 'இருப்பிட அனுமதி தேவை' : 'Location Permission Needed',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
        content: Text(
          isTa
              ? 'புகார் செய்யப்படும் இடத்தின் சரியான GPS ஆயங்களை ஆவணப்படுத்த, உங்கள் போன் Settings-ல் அனுமதி வழங்கவும்.'
              : 'To record accurate GPS coordinates for verification, please enable Location permission in app settings.',
          style: const TextStyle(fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(isTa ? 'ரத்து' : 'Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Geolocator.openAppSettings();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: SubmitColors.blue,
              foregroundColor: Colors.white,
            ),
            child: Text(isTa ? 'Settings திறக்க' : 'Open Settings'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitGrievance() async {
    final isTa = AppTranslations.isTamil;

    if (!_formKey.currentState!.validate()) {
      setState(() {
        _errorMessage = isTa
            ? 'தயவுசெய்து அனைத்து கட்டாய விவரங்களையும் சரியாக நிரப்பவும்.'
            : 'Please complete all required fields correctly.';
      });
      return;
    }

    if (!_privacyConsent) {
      setState(() {
        _errorMessage = isTa
            ? 'மனுவைச் சமர்ப்பிக்க உறுதிமொழி நிபந்தனையை ஏற்க வேண்டும்.'
            : 'You must accept the truthfulness and privacy declaration.';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      // Prompt/capture live GPS coordinates if not already present
      if (_liveLatitude == null && !_isCapturingLocation) {
        await _requestAndCaptureLocation(silent: true);
      }

      final payload = <String, dynamic>{
        'citizen_name': _nameController.text.trim(),
        'citizen_mobile': _mobileController.text.trim(),
        'citizen_email': _emailController.text.trim(),
        'citizen_address': _addressController.text.trim(),
        'district_id': _selectedDistrictId,
        'revenue_division_id': _selectedDivisionId,
        'taluk_id': _selectedTalukId,
        'category_id': _selectedCategoryId,
        'priority': _selectedPriority,
        'subject': _subjectController.text.trim(),
        'description': _descController.text.trim(),
        'privacy_consent': _privacyConsent ? 1 : 0,
      };

      if (_liveLatitude != null) {
        payload['live_latitude'] = _liveLatitude;
      }
      if (_liveLongitude != null) {
        payload['live_longitude'] = _liveLongitude;
      }
      if (_liveAddress != null && _liveAddress!.trim().isNotEmpty) {
        payload['live_address'] = _liveAddress!.trim();
      }

      if (_wardController.text.trim().isNotEmpty) {
        payload['ward_number'] = _wardController.text.trim();
      }
      if (_landmarkController.text.trim().isNotEmpty) {
        payload['landmark'] = _landmarkController.text.trim();
      }

      if (_isManualVillage || _selectedVillageId == null) {
        payload['custom_village_name'] = _villageController.text.trim();
      } else {
        payload['revenue_village_id'] = _selectedVillageId;
      }

      if (_selectedPhoto != null) {
        final bytes = await _selectedPhoto!.readAsBytes();
        payload['photo'] = MultipartFile.fromBytes(
          bytes,
          filename: _selectedPhoto!.name,
        );
      }

      final formData = FormData.fromMap(payload);

      final response = await _dio.post(
        ApiConfig.apiSubmitComplaintUrl,
        data: formData,
      );

      if ((response.statusCode == 200 || response.statusCode == 201) && response.data != null) {
        final resData = response.data;
        if (resData is Map && resData['success'] == true) {
          final complaintId = resData['data']?['complaint_id'] ?? resData['complaint_id'];
          if (complaintId != null) {
            setState(() {
              _isSubmitting = false;
              _registeredComplaintId = complaintId.toString();
              _errorMessage = null;
            });
            return;
          }
        }
      }

      throw Exception('Server returned incomplete response');
    } catch (e) {
      debugPrint('Submission error: $e');
      String errorMsg = isTa
          ? 'மனுவைச் சமர்ப்பிக்க முடியவில்லை. தயவுசெய்து விவரங்களைச் சரிபார்த்து மீண்டும் முயற்சிக்கவும்.'
          : 'Failed to submit grievance. Please verify details and try again.';

      if (e is DioException) {
        if (e.response?.data != null) {
          final errData = e.response!.data;
          if (errData is Map) {
            if (errData['errors'] != null && errData['errors'] is Map) {
              final errMap = errData['errors'] as Map;
              final firstErr = errMap.values.first;
              if (firstErr is List && firstErr.isNotEmpty) {
                errorMsg = firstErr.first.toString();
              } else {
                errorMsg = firstErr.toString();
              }
            } else if (errData['message'] != null) {
              errorMsg = errData['message'].toString();
            }
          }
        } else if (e.message != null && e.message!.contains('XMLHttpRequest')) {
          errorMsg = isTa
              ? 'உலாவி பாதுகாப்பு (CORS) காரணமாக இணைப்பு தடைபட்டுள்ளது. தயவுசெய்து Plesk-ல் Pull Updates செய்யவும் அல்லது மொபைல் சாதனத்தில் இயக்கவும்.'
              : 'Browser CORS security blocked the cross-origin request. Please pull updates in Plesk or test on mobile device.';
        } else if (e.message != null && e.message!.isNotEmpty) {
          errorMsg = e.message!;
        }
      }

      setState(() {
        _isSubmitting = false;
        _errorMessage = errorMsg;
      });
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
          drawer: const AppDrawer(currentRoute: 'submit'),
          backgroundColor: SubmitColors.lightBg,
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

                // 2. CIVIC TRICOLOR TOP ACCENT LINE (Indian National Accent)
                SizedBox(
                  height: 4,
                  child: Row(
                    children: [
                      Expanded(child: Container(color: SubmitColors.saffron)),
                      Expanded(child: Container(color: Colors.white)),
                      Expanded(child: Container(color: SubmitColors.green)),
                    ],
                  ),
                ),

                // 3. Scrollable Body
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
                          child: Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 720),
                              child: Row(
                                children: [
                                  InkWell(
                                    onTap: () => Navigator.pop(context),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.home_outlined, size: 15, color: SubmitColors.orange),
                                        const SizedBox(width: 4),
                                        Text(
                                          AppTranslations.tr('nav_home'),
                                          style: const TextStyle(fontSize: 12, color: SubmitColors.orange, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.chevron_right, size: 15, color: SubmitColors.grey),
                                  Text(
                                    isTa ? 'புகார் பதிவு' : 'Register Grievance',
                                    style: const TextStyle(fontSize: 12, color: SubmitColors.grey, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const Divider(height: 1, color: SubmitColors.borderLight),

                        Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 720),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: _registeredComplaintId != null
                                  ? _buildSuccessCard(_registeredComplaintId!, isTa)
                                  : _buildComplaintForm(isTa),
                            ),
                          ),
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

  // Success Confirmation Card (Shown after DB Storage)
  Widget _buildSuccessCard(String complaintId, bool isTa) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: SubmitColors.green.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            height: 72,
            width: 72,
            decoration: BoxDecoration(
              color: SubmitColors.green,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: SubmitColors.green.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.check_rounded, color: Colors.white, size: 42),
          ),
          const SizedBox(height: 16),

          Text(
            isTa ? 'மனு வெற்றிகரமாக பதிவு செய்யப்பட்டது!' : 'Grievance Successfully Registered!',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w900,
              color: SubmitColors.navy,
            ),
          ),
          const SizedBox(height: 8),

          Text(
            isTa
                ? 'உங்கள் பொதுக் கோரிக்கை முறைப்படி தரவுத்தளத்தில் (Database) பதிவு செய்யப்பட்டுள்ளது.'
                : 'Your petition has been securely recorded into the civic database and assigned to the nodal cell.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12.5, color: SubmitColors.grey, height: 1.45),
          ),
          const SizedBox(height: 20),

          // Generated Complaint ID Box with 1-Click Copy
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: SubmitColors.lightBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: SubmitColors.blue.withValues(alpha: 0.35)),
            ),
            child: Column(
              children: [
                Text(
                  isTa ? 'மனு எண் (Complaint Reference ID)' : 'Grievance Tracking Reference ID',
                  style: const TextStyle(fontSize: 11, color: SubmitColors.grey, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: SelectableText(
                          complaintId,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: SubmitColors.blue,
                            letterSpacing: 0.8,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: complaintId));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                const Icon(Icons.check_circle, color: Colors.white, size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    isTa ? 'மனு எண் நகலெடுக்கப்பட்டது: $complaintId' : 'Copied to clipboard: $complaintId',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            backgroundColor: SubmitColors.navy,
                            behavior: SnackBarBehavior.floating,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: SubmitColors.blue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.copy_rounded, color: SubmitColors.blue, size: 18),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  isTa
                      ? 'இந்த எண்ணைக் குறித்துக் கொண்டு SMS அல்லது ஆன்லைனில் நிலையை அறியலாம்.'
                      : 'Please save this ID for real-time tracking and department follow-ups.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 11, color: SubmitColors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Action Buttons
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TrackComplaintScreen(
                      initialComplaintId: complaintId,
                      initialMobile: _mobileController.text.trim(),
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.search, size: 18),
              label: Text(
                isTa ? 'புகார் நிலையை உடனடியாகக் கண்காணிக்க' : 'Track Status Now',
                style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: SubmitColors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
              ),
            ),
          ),
          const SizedBox(height: 10),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                setState(() {
                  _registeredComplaintId = null;
                  _subjectController.clear();
                  _descController.clear();
                  _selectedPhoto = null;
                });
              },
              icon: const Icon(Icons.add_circle_outline, size: 18),
              label: Text(
                isTa ? 'மற்றொரு மனு பதிவு செய்ய' : 'Register Another Grievance',
                style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: SubmitColors.navy,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                side: const BorderSide(color: Color(0xFFCBD5E1), width: 1.2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // The Main Registration Form
  Widget _buildComplaintForm(bool isTa) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. TOP HERO BANNER & TRUST BADGES
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFFBEB), Color(0xFFF8FAFC), Color(0xFFEFF6FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFFDE68A), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFEA580C).withValues(alpha: 0.06),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                // Official Badge (Fixed overflow on narrow screens)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: const Color(0xFFFDE68A)),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFD97706).withValues(alpha: 0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.shield_rounded, color: Color(0xFFD97706), size: 14),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          isTa ? 'அதிகாரப்பூர்வ குறைதீர்ப்பு படிவம்' : 'Official Civic Grievance Portal',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFFB45309),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  isTa ? 'பொது மக்கள் குறைதீர்க்கும் மனுப் பதிவு' : 'Public Grievance Redressal Form',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: SubmitColors.navy,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  isTa
                      ? 'உங்கள் பகுதி அடிப்படைத் தேவைகள் & பிரச்சனைகளை நேரடியாகப் பதிவு செய்க.'
                      : 'Submit your civic issues directly with instant tracking via SMS and live web portal.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12.5, color: Color(0xFF475569), height: 1.45),
                ),
                const SizedBox(height: 14),

                // 4 Trust Badges Strip (matching Web portal)
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _trustChip(Icons.lock_rounded, const Color(0xFF16A34A), '256-Bit SSL Encrypted'),
                    _trustChip(Icons.mark_chat_read_rounded, const Color(0xFF2563EB), 'SMS Tracking'),
                    _trustChip(Icons.map_rounded, const Color(0xFFDC2626), _districts.length == 1 ? (isTa ? 'திருநெல்வேலி' : 'Tirunelveli') : (isTa ? '38 மாவட்டங்கள்' : '38 Districts')),
                    _trustChip(Icons.phone_rounded, const Color(0xFFD97706), '9384995222'),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1, color: Color(0xFFE2E8F0)),
                const SizedBox(height: 14),

                // 4-Step Visual Stepper
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _stepPill('1', isTa ? 'மனுதாரர்' : 'Citizen', true),
                      const Icon(Icons.chevron_right, size: 16, color: Color(0xFF94A3B8)),
                      _stepPill('2', isTa ? 'இருப்பிடம்' : 'Location', true),
                      const Icon(Icons.chevron_right, size: 16, color: Color(0xFF94A3B8)),
                      _stepPill('3', isTa ? 'புகார்' : 'Grievance', true),
                      const Icon(Icons.chevron_right, size: 16, color: Color(0xFF94A3B8)),
                      _stepPill('4', isTa ? 'ஆதாரம்' : 'Evidence', true),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Error banner
          if (_errorMessage != null)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFECACA), width: 1.2),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline_rounded, color: SubmitColors.red, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Color(0xFF991B1B), fontSize: 12.5, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),

          // SECTION 1: CITIZEN DETAILS
          _formSectionCard(
            icon: Icons.person_pin_rounded,
            iconColor: const Color(0xFF2563EB),
            iconBgColor: const Color(0xFFEFF6FF),
            stepNumber: isTa ? 'படி 1 / 4' : 'Step 1/4',
            title: isTa ? '1. மனுதாரர் விவரங்கள் (Citizen Details)' : '1. Citizen Details',
            subtitle: isTa ? 'அதிகாரப்பூர்வ தொடர்பு மற்றும் நேரடி கள ஆய்விற்கான விவரங்கள்' : 'For official contact & field verification',
            children: [
              _fieldLabel(isTa ? 'முழுப் பெயர் (Full Name)' : 'Full Name', isRequired: true),
              TextFormField(
                controller: _nameController,
                decoration: _inputDeco(
                  isTa ? 'உங்கள் முழுப் பெயர் உள்ளிடவும்' : 'Enter your full name',
                  prefixIcon: const Icon(Icons.person_rounded, color: Color(0xFF2563EB), size: 20),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? (isTa ? 'பெயர் தேவை' : 'Name is required') : null,
              ),
              const SizedBox(height: 14),

              _fieldLabel(isTa ? 'பதிவு செய்யப்பட்ட கைபேசி எண் (Mobile)' : 'Mobile Number', isRequired: true),
              TextFormField(
                controller: _mobileController,
                keyboardType: TextInputType.phone,
                maxLength: 10,
                decoration: _inputDeco(
                  '10-digit mobile number',
                  prefixIcon: const Icon(Icons.phone_android_rounded, color: Color(0xFF16A34A), size: 20),
                  prefixText: '+91 ',
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return isTa ? 'கைபேசி எண் தேவை' : 'Mobile number is required';
                  }
                  if (!RegExp(r'^[6-9]\d{9}$').hasMatch(val.trim())) {
                    return isTa ? 'சரியான 10 இலக்க எண் உள்ளிடவும்' : 'Enter valid 10-digit mobile';
                  }
                  return null;
                },
              ),
              Padding(
                padding: const EdgeInsets.only(top: 2, bottom: 10),
                child: Text(
                  isTa ? 'SMS மூலம் நிலவர அறிவிப்புகள் மற்றும் கள ஆய்விற்கு பயன்படுத்தப்படும்.' : 'Used for SMS status alerts and field inquiry.',
                  style: const TextStyle(fontSize: 11, color: SubmitColors.grey),
                ),
              ),

              _fieldLabel(isTa ? 'மின்னஞ்சல் முகவரி (Email)' : 'Email Address'),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: _inputDeco(
                  'example@gmail.com',
                  prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF64748B), size: 20),
                ),
                validator: (val) {
                  if (val != null && val.trim().isNotEmpty && !val.contains('@')) {
                    return isTa ? 'சரியான மின்னஞ்சல் உள்ளிடவும்' : 'Enter valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              _fieldLabel(isTa ? 'முகவரி / தெருப் பெயர் (Street Address)' : 'Street Address', isRequired: true),
              TextFormField(
                controller: _addressController,
                decoration: _inputDeco(
                  isTa ? 'கதவு எண், தெருப் பெயர், குடியிருப்பு பகுதி' : 'Door No, Street Name, Locality',
                  prefixIcon: const Icon(Icons.home_work_rounded, color: Color(0xFF64748B), size: 20),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? (isTa ? 'முகவரி தேவை' : 'Address is required') : null,
              ),
            ],
          ),

          // SECTION 2: LOCATION DETAILS (Searchable like Select2)
          _formSectionCard(
            icon: Icons.location_on_rounded,
            iconColor: const Color(0xFFEA580C),
            iconBgColor: const Color(0xFFFFF7ED),
            stepNumber: isTa ? 'படி 2 / 4' : 'Step 2/4',
            title: isTa ? '2. பிரச்சனை உள்ள இடம் (Location Details)' : '2. Location of Grievance',
            subtitle: _districts.length == 1
                ? (isTa ? 'திருநெல்வேலி மாவட்டம் மற்றும் அனைத்து வட்டங்கள் நேரடி ஒருங்கிணைப்பு' : 'Tirunelveli District & Taluks Direct Sync')
                : (isTa ? '38 மாவட்டங்கள் மற்றும் அனைத்து வட்டங்கள் நேரடி ஒருங்கிணைப்பு' : 'Direct cascading across 38 districts'),
            children: [
              // 1. DISTRICT (Searchable Bottom Sheet)
              _locationSelectorTile(
                label: isTa ? 'மாவட்டம் (District)' : 'District',
                valueText: _selectedDistrictName,
                placeholder: isTa ? '-- மாவட்டம் தேர்வு செய்க --' : '-- Select District --',
                icon: Icons.apartment_rounded,
                iconColor: const Color(0xFF2563EB),
                onTap: () {
                  _openLocationPicker(
                    title: isTa ? 'மாவட்டம் தேர்வு செய்க' : 'Select District',
                    searchHint: isTa ? 'மாவட்டப் பெயர் உள்ளிட்டு தேடுக...' : 'Search district name...',
                    items: _districts,
                    selectedId: _selectedDistrictId,
                    onSelected: (itm) => _selectDistrict(itm['id'] as int),
                  );
                },
              ),
              const SizedBox(height: 14),

              // 2. REVENUE DIVISION (Searchable Bottom Sheet)
              _locationSelectorTile(
                label: isTa ? 'வருவாய் கோட்டம் (Revenue Division)' : 'Revenue Division',
                valueText: _selectedDivisionName,
                placeholder: _divisions.isEmpty
                    ? (isTa ? '-- முதலில் மாவட்டம் தேர்வு செய்க --' : '-- Select District First --')
                    : (isTa ? '-- கோட்டம் தேர்வு செய்க --' : '-- Select Division --'),
                icon: Icons.account_balance_rounded,
                iconColor: const Color(0xFF0284C7),
                onTap: _divisions.isEmpty
                    ? null
                    : () {
                        _openLocationPicker(
                          title: isTa ? 'வருவாய் கோட்டம் தேர்வு செய்க' : 'Select Revenue Division',
                          searchHint: isTa ? 'கோட்டப் பெயர் உள்ளிட்டு தேடுக...' : 'Search division name...',
                          items: _divisions,
                          selectedId: _selectedDivisionId,
                          onSelected: (itm) => _selectDivision(itm['id'] as int),
                        );
                      },
              ),
              const SizedBox(height: 14),

              // 3. REVENUE TALUK (Searchable Bottom Sheet)
              _locationSelectorTile(
                label: isTa ? 'வருவாய் வட்டம் / தாலுகா (Taluk)' : 'Revenue Taluk',
                valueText: _selectedTalukName,
                placeholder: _taluks.isEmpty
                    ? (isTa ? '-- முதலில் கோட்டம் தேர்வு செய்க --' : '-- Select Division First --')
                    : (isTa ? '-- வட்டம் / தாலுகா தேர்வு செய்க --' : '-- Select Taluk --'),
                icon: Icons.holiday_village_rounded,
                iconColor: const Color(0xFFD97706),
                onTap: _taluks.isEmpty
                    ? null
                    : () {
                        _openLocationPicker(
                          title: isTa ? 'வருவாய் வட்டம் / தாலுகா தேர்வு செய்க' : 'Select Revenue Taluk',
                          searchHint: isTa ? 'தாலுகா பெயர் உள்ளிட்டு தேடுக...' : 'Search taluk name...',
                          items: _taluks,
                          selectedId: _selectedTalukId,
                          onSelected: (itm) => _selectTaluk(itm['id'] as int),
                        );
                      },
              ),
              const SizedBox(height: 14),

              // 4. VILLAGE / TOWN (Full Width + Header Toggle Action)
              _fieldLabel(
                isTa ? 'வருவாய் கிராமம் / நகரம் (Village / Town)' : 'Revenue Village / Town',
                trailingAction: InkWell(
                  onTap: () {
                    setState(() {
                      _isManualVillage = !_isManualVillage;
                    });
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _isManualVillage ? const Color(0xFFEFF6FF) : const Color(0xFFFFF7ED),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _isManualVillage ? SubmitColors.blue : SubmitColors.orange,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _isManualVillage ? Icons.list_alt_rounded : Icons.edit_note_rounded,
                          size: 14,
                          color: _isManualVillage ? SubmitColors.blue : SubmitColors.orange,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _isManualVillage
                              ? (isTa ? 'பட்டியல் தேர்வு' : 'List')
                              : (isTa ? 'தட்டச்சு செய்ய' : 'Manual'),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: _isManualVillage ? SubmitColors.blue : SubmitColors.orange,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (!_isManualVillage)
                InkWell(
                  onTap: _villages.isEmpty && !_isLoadingVillages
                      ? () => setState(() => _isManualVillage = true)
                      : () => _openVillagePicker(isTa),
                  borderRadius: BorderRadius.circular(11),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(11),
                      border: Border.all(
                        color: const Color(0xFFCBD5E1),
                        width: 1.1,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.location_city_rounded, color: Color(0xFFEA580C), size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _villageController.text.isNotEmpty
                                ? _villageController.text
                                : (_isLoadingVillages
                                    ? (isTa ? 'கிராமங்கள் ஏற்றப்படுகிறது...' : 'Loading villages...')
                                    : (_villages.isEmpty
                                        ? (isTa ? '-- கிராமம் தட்டச்சு செய்க --' : '-- Type Village Manually --')
                                        : (isTa ? '-- கிராமம் அல்லது நகரம் தேர்வு செய்க --' : '-- Select Village or Town --'))),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: _villageController.text.isNotEmpty ? FontWeight.w600 : FontWeight.normal,
                              color: _villageController.text.isNotEmpty
                                  ? const Color(0xFF0F172A)
                                  : const Color(0xFF94A3B8),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (_isLoadingVillages)
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        else
                          const Icon(
                            Icons.search_rounded,
                            color: SubmitColors.blue,
                            size: 20,
                          ),
                      ],
                    ),
                  ),
                )
              else
                TextFormField(
                  controller: _villageController,
                  decoration: _inputDeco(
                    isTa
                        ? 'கிராமம் / நகர் / காலனி பெயர் உள்ளிடவும் (e.g. அண்ணா நகர்)'
                        : 'Enter village / locality name (e.g. Anna Nagar)',
                    prefixIcon: const Icon(Icons.edit_location_alt_rounded, color: Color(0xFFEA580C), size: 20),
                  ),
                ),
              const SizedBox(height: 4),
              Text(
                _isManualVillage
                    ? (isTa
                        ? 'உங்கள் கிராமம் அல்லது நகரம் அல்லது குடியிருப்பு பகுதியை உள்ளிடவும்.'
                        : 'Enter your village, town or residential colony name.')
                    : (isTa
                        ? "பட்டியலிலும் தேர்ந்தெடுக்கலாம் அல்லது மேலே உள்ள 'தட்டச்சு செய்ய' அழுத்தி நேரடியாகவும் உள்ளிடலாம்."
                        : "Select from searchable list or click 'Manual' above to type directly."),
                style: const TextStyle(fontSize: 10.5, color: SubmitColors.grey),
              ),
              const SizedBox(height: 14),

              // 5. WARD & LANDMARK
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _fieldLabel(isTa ? 'வார்டு எண்' : 'Ward No'),
                        TextFormField(
                          controller: _wardController,
                          keyboardType: TextInputType.text,
                          decoration: _inputDeco(
                            'e.g. 12',
                            prefixIcon: const Icon(Icons.tag_rounded, color: Color(0xFF64748B), size: 18),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _fieldLabel(isTa ? 'அடையாளக் குறி' : 'Landmark'),
                        TextFormField(
                          controller: _landmarkController,
                          decoration: _inputDeco(
                            isTa ? 'அருகில் உள்ள இடம்' : 'Near temple/school',
                            prefixIcon: const Icon(Icons.place_outlined, color: Color(0xFF64748B), size: 18),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),

          // SECTION 3: GRIEVANCE SPECIFICS
          _formSectionCard(
            icon: Icons.assignment_rounded,
            iconColor: const Color(0xFF7C3AED),
            iconBgColor: const Color(0xFFF5F3FF),
            stepNumber: isTa ? 'படி 3 / 4' : 'Step 3/4',
            title: isTa ? '3. புகார் விவரங்கள் (Grievance Details)' : '3. Grievance Specifics',
            subtitle: isTa ? 'துறை மற்றும் பிரச்சனை பற்றிய தெளிவான விவரம்' : 'Categorize and detail your civic complaint',
            children: [
              _fieldLabel(isTa ? 'கோரிக்கை வகை (Category)' : 'Grievance Category', isRequired: true),
              DropdownButtonFormField<int>(
                isExpanded: true,
                initialValue: _selectedCategoryId,
                decoration: _inputDeco(
                  '',
                  prefixIcon: const Icon(Icons.category_rounded, color: Color(0xFF7C3AED), size: 20),
                ),
                items: _categories.map((c) {
                  return DropdownMenuItem<int>(
                    value: c['id'],
                    child: Text(
                      isTa ? c['name_ta'] : c['name_en'],
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedCategoryId = val;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              _fieldLabel(isTa ? 'முன்னுரிமை நிலை (Priority Level)' : 'Priority Level'),
              _buildPrioritySelector(isTa),
              const SizedBox(height: 16),

              _fieldLabel(isTa ? 'கோரிக்கையின் சுருக்கத் தலைப்பு (Subject)' : 'Subject / Summary', isRequired: true),
              TextFormField(
                controller: _subjectController,
                decoration: _inputDeco(
                  isTa ? 'எ.கா. மெயின் ரோட்டில் குடிநீர் குழாய் பழுது' : 'e.g. Broken water pipeline on main road',
                  prefixIcon: const Icon(Icons.title_rounded, color: Color(0xFF2563EB), size: 20),
                ),
                validator: (val) => val == null || val.trim().length < 5
                    ? (isTa ? 'குறைந்தது 5 எழுத்துக்கள் தேவை' : 'Minimum 5 characters required')
                    : null,
              ),
              const SizedBox(height: 14),

              _fieldLabel(isTa ? 'முழு விளக்கம் (Detailed Description)' : 'Detailed Description', isRequired: true),
              TextFormField(
                controller: _descController,
                maxLines: 4,
                decoration: _inputDeco(
                  isTa
                      ? 'பிரச்சனை எப்போது தொடங்கியது, எத்தனை குடும்பங்கள் பாதிக்கப்பட்டுள்ளன, கோரப்படும் நடவடிக்கை என்ன என்பதை விரிவாக உள்ளிடவும்.'
                      : 'Provide full details: when it started, households affected, and specific action requested.',
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(bottom: 50),
                    child: Icon(Icons.edit_note_rounded, color: Color(0xFF2563EB), size: 20),
                  ),
                ),
                validator: (val) => val == null || val.trim().length < 20
                    ? (isTa ? 'குறைந்தது 20 எழுத்துக்கள் விளக்கம் தேவை' : 'Minimum 20 characters required')
                    : null,
              ),
            ],
          ),

          // SECTION 4: PHOTOS & EVIDENCE
          _formSectionCard(
            icon: Icons.camera_alt_rounded,
            iconColor: const Color(0xFF16A34A),
            iconBgColor: const Color(0xFFF0FDF4),
            stepNumber: isTa ? 'படி 4 / 4' : 'Step 4/4',
            title: isTa ? '4. களப் புகைப்படம் (Photo Evidence)' : '4. Photo Evidence',
            subtitle: isTa ? 'புகைப்படம் கள ஆய்வை பல மடங்கு விரைவுபடுத்தும்' : 'Visual proof significantly speeds up inspection',
            children: [
              _buildPhotoUploader(isTa),
            ],
          ),

          // SECTION 5: CONSENT & SUBMISSION
          _buildSubmitSection(isTa),
        ],
      ),
    );
  }

  // Trust micro chip helper
  Widget _trustChip(IconData icon, Color color, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF334155),
            ),
          ),
        ],
      ),
    );
  }

  // Stepper pill helper
  Widget _stepPill(String num, String title, bool isActive) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 3),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFFFF7ED) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive ? SubmitColors.orange : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: isActive ? SubmitColors.orange : const Color(0xFFE2E8F0),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                num,
                style: TextStyle(
                  color: isActive ? Colors.white : const Color(0xFF475569),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            title,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.bold,
              color: isActive ? SubmitColors.orange : const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  // Location selector tile helper (Searchable trigger)
  Widget _locationSelectorTile({
    required String label,
    required String valueText,
    required String placeholder,
    required IconData icon,
    required Color iconColor,
    required VoidCallback? onTap,
    bool isRequired = true,
  }) {
    final hasValue = valueText.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel(label, isRequired: isRequired),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(11),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            decoration: BoxDecoration(
              color: onTap == null ? const Color(0xFFF8FAFC) : Colors.white,
              borderRadius: BorderRadius.circular(11),
              border: Border.all(
                color: const Color(0xFFCBD5E1),
                width: 1.1,
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: onTap == null ? const Color(0xFF94A3B8) : iconColor, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    hasValue ? valueText : placeholder,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: hasValue ? FontWeight.w600 : FontWeight.normal,
                      color: hasValue
                          ? const Color(0xFF0F172A)
                          : (onTap == null ? const Color(0xFFCBD5E1) : const Color(0xFF94A3B8)),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down_rounded,
                  color: onTap == null ? const Color(0xFFCBD5E1) : const Color(0xFF64748B),
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Priority Selector 2x2 Grid (matching Web mobile layout)
  Widget _buildPrioritySelector(bool isTa) {
    final priorities = [
      {'key': 'low', 'ta': 'சாதாரண (Low)', 'en': 'Low', 'color': const Color(0xFF16A34A), 'bg': const Color(0xFFF0FDF4)},
      {'key': 'medium', 'ta': 'நடுத்தர (Medium)', 'en': 'Medium', 'color': const Color(0xFF2563EB), 'bg': const Color(0xFFEFF6FF)},
      {'key': 'high', 'ta': 'உயர் (High)', 'en': 'High', 'color': const Color(0xFFD97706), 'bg': const Color(0xFFFFFBEB)},
      {'key': 'urgent', 'ta': 'அவசரம் (Urgent)', 'en': 'Urgent', 'color': const Color(0xFFDC2626), 'bg': const Color(0xFFFEF2F2)},
    ];

    Widget priorityCard(Map<String, dynamic> p) {
      final isSelected = _selectedPriority == p['key'];
      final color = p['color'] as Color;
      final bg = p['bg'] as Color;
      final label = isTa ? p['ta'] as String : p['en'] as String;

      return InkWell(
        onTap: () {
          setState(() {
            _selectedPriority = p['key'] as String;
          });
        },
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? bg : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? color : const Color(0xFFCBD5E1),
              width: isSelected ? 1.8 : 1.0,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isSelected ? color : const Color(0xFF94A3B8),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    color: isSelected ? color : const Color(0xFF475569),
                  ),
                ),
              ),
              if (isSelected) ...[
                const SizedBox(width: 4),
                Icon(Icons.check, size: 14, color: color),
              ],
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        Row(
          children: [
            Expanded(child: priorityCard(priorities[0])),
            const SizedBox(width: 8),
            Expanded(child: priorityCard(priorities[1])),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: priorityCard(priorities[2])),
            const SizedBox(width: 8),
            Expanded(child: priorityCard(priorities[3])),
          ],
        ),
      ],
    );
  }

  // Photo Uploader Card
  Widget _buildPhotoUploader(bool isTa) {
    if (_selectedPhoto != null) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF0FDF4),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF86EFAC)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFDCFCE7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A), size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selectedPhoto!.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF14532D)),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isTa ? 'புகைப்படம் வெற்றிகரமாக இணைக்கப்பட்டது' : 'Photo attached successfully',
                    style: const TextStyle(fontSize: 11, color: Color(0xFF15803D)),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFDC2626)),
              tooltip: isTa ? 'நீக்குக' : 'Remove',
              onPressed: () {
                setState(() {
                  _selectedPhoto = null;
                });
              },
            ),
          ],
        ),
      );
    }

    return InkWell(
      onTap: _pickPhoto,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFCBD5E1), style: BorderStyle.solid, width: 1.2),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: Color(0xFFEFF6FF),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add_a_photo_rounded, color: Color(0xFF2563EB), size: 26),
            ),
            const SizedBox(height: 10),
            Text(
              isTa ? 'களப் புகைப்படம் இணைக்க இங்கே தட்டவும்' : 'Click to Upload Ground Photo Evidence',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 4),
            Text(
              isTa ? 'கேமரா அல்லது கேலரி (JPG, PNG - Max 5MB)' : 'Camera or Gallery (JPG, PNG - Max 5MB)',
              style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
            ),
          ],
        ),
      ),
    );
  }

  // Submit & Declaration Section
  Widget _buildSubmitSection(bool isTa) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Declaration Checkbox
          InkWell(
            onTap: () {
              setState(() {
                _privacyConsent = !_privacyConsent;
              });
            },
            borderRadius: BorderRadius.circular(8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 24,
                  width: 24,
                  child: Checkbox(
                    value: _privacyConsent,
                    activeColor: SubmitColors.orange,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    onChanged: (val) {
                      setState(() {
                        _privacyConsent = val ?? false;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    isTa
                        ? 'நான் அளித்துள்ள விவரங்கள் அனைத்தும் உண்மையானவை மற்றும் பொதுநலம் சார்ந்தவை என்பதை உறுதிப்படுத்துகிறேன். SMS / அழைப்பு மூலம் தொடர் தகவல்களைப் பெற சம்மதிக்கிறேன்.'
                        : 'I confirm that all details provided are genuine and relate to civic public interest. I consent to official field verification via SMS/Call.',
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: Color(0xFF334155),
                      height: 1.45,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Submit Button
          Container(
            width: double.infinity,
            height: 52,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF7A00), Color(0xFFEA580C)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(26),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFEA580C).withValues(alpha: 0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: _isSubmitting ? null : _submitGrievance,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
              ),
              icon: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.2),
                    )
                  : const Icon(Icons.send_rounded, color: Colors.white, size: 20),
              label: Text(
                _isSubmitting
                    ? (isTa ? 'தரவுத்தளத்தில் பதிவு செய்யப்படுகிறது...' : 'Registering in Database...')
                    : (isTa ? 'புகாரை உடனடியாகப் பதிவு செய்க' : 'Submit Grievance Now'),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _formSectionCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String stepNumber,
    required String title,
    String? subtitle,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Card Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                          color: SubmitColors.navy,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: const TextStyle(fontSize: 11, color: SubmitColors.grey),
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Text(
                    stepNumber,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF475569),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          // Section Card Body
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _fieldLabel(String text, {bool isRequired = false, Widget? trailingAction}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: RichText(
              text: TextSpan(
                text: text,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
                children: isRequired
                    ? const [
                        TextSpan(
                          text: ' *',
                          style: TextStyle(
                            color: Color(0xFFDC2626),
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ]
                    : null,
              ),
            ),
          ),
          ?trailingAction,
        ],
      ),
    );
  }

  InputDecoration _inputDeco(
    String hint, {
    String? prefixText,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 12.5, color: Color(0xFF94A3B8)),
      prefixText: prefixText,
      prefixStyle: const TextStyle(fontWeight: FontWeight.w700, color: SubmitColors.navy, fontSize: 13),
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      filled: true,
      fillColor: Colors.white,
      counterText: '',
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: const BorderSide(color: Color(0xFFCBD5E1), width: 1.1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: const BorderSide(color: Color(0xFFCBD5E1), width: 1.1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: const BorderSide(color: SubmitColors.orange, width: 1.8),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: const BorderSide(color: Color(0xFFDC2626), width: 1.2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: const BorderSide(color: Color(0xFFDC2626), width: 1.8),
      ),
    );
  }
}
