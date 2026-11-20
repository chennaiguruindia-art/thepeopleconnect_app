import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../config/api_config.dart';

class GeminiTranslationService {
  static final GeminiTranslationService _instance = GeminiTranslationService._internal();
  factory GeminiTranslationService() => _instance;

  GeminiTranslationService._internal();

  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 8),
      receiveTimeout: const Duration(seconds: 8),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ),
  );

  // In-memory cache to store translated strings forever (avoids repeated API calls)
  static final Map<String, String> _cache = {};

  // ValueNotifier to trigger reactive UI updates when new dynamic translations arrive
  static final ValueNotifier<int> translationUpdateCount = ValueNotifier<int>(0);

  /// Translate a single text string using your Laravel Backend Gemini API
  Future<String> translate(
    String text, {
    String target = 'en',
    String source = 'ta',
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || target == source) {
      return text;
    }

    final cacheKey = '${source}_${target}_$trimmed';
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    }

    try {
      final response = await _dio.post(
        ApiConfig.translateUrl,
        data: {
          'text': trimmed,
          'target': target,
          'source': source,
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final translated = (response.data['translation'] as String?)?.trim();
        if (translated != null && translated.isNotEmpty) {
          _cache[cacheKey] = translated;
          translationUpdateCount.value++;
          return translated;
        }
      }
    } catch (e) {
      debugPrint('Gemini backend translation fallback: $e');
    }

    // Return original text if network/API fails
    return text;
  }

  /// Translate multiple texts in a single batch call to reduce round-trips
  Future<Map<String, String>> translateBatch(
    List<String> texts, {
    String target = 'en',
    String source = 'ta',
  }) async {
    if (texts.isEmpty || target == source) {
      return {for (var t in texts) t: t};
    }

    final Map<String, String> results = {};
    final List<String> uncached = [];

    for (var text in texts) {
      final trimmed = text.trim();
      final cacheKey = '${source}_${target}_$trimmed';
      if (_cache.containsKey(cacheKey)) {
        results[text] = _cache[cacheKey]!;
      } else if (trimmed.isNotEmpty) {
        uncached.add(trimmed);
      } else {
        results[text] = text;
      }
    }

    if (uncached.isEmpty) {
      return results;
    }

    try {
      final response = await _dio.post(
        ApiConfig.translateUrl,
        data: {
          'texts': uncached,
          'target': target,
          'source': source,
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final dynamic translationsData = response.data['translations'];
        if (translationsData is List && translationsData.length == uncached.length) {
          for (int i = 0; i < uncached.length; i++) {
            final orig = uncached[i];
            final trans = translationsData[i].toString();
            final cacheKey = '${source}_${target}_$orig';
            _cache[cacheKey] = trans;
            results[orig] = trans;
          }
          translationUpdateCount.value++;
          return results;
        }
      }
    } catch (e) {
      debugPrint('Gemini backend batch translation fallback: $e');
    }

    // Fallback: fill uncached with original text
    for (var t in uncached) {
      results[t] = t;
    }
    return results;
  }

  /// Check if a translation is already cached
  static String? getCached(String text, {String target = 'en', String source = 'ta'}) {
    final cacheKey = '${source}_${target}_${text.trim()}';
    return _cache[cacheKey];
  }

  /// Pre-cache a key-value pair
  static void cache(String original, String translated, {String target = 'en', String source = 'ta'}) {
    final cacheKey = '${source}_${target}_${original.trim()}';
    _cache[cacheKey] = translated;
  }
}
