class ApiConfig {
  static const String baseUrl = 'https://thepeopleconnect.in';
  static const String submitComplaintUrl = '$baseUrl/complaints';
  static const String apiSubmitComplaintUrl = '$baseUrl/api/v1/citizen/complaints';
  static const String translateUrl = '$baseUrl/api/translate';
  static const String trackComplaintUrl = '$baseUrl/api/v1/citizen/complaints/track';
  static const String fallbackWebTrackUrl = '$baseUrl/track-complaint';
  static const String helplineNumber = '+919384995222';
  static const String supportEmail = 'thepeopleconnectofficial@gmail.com';

  // Meta Location & Settings APIs
  static const String metaSettingsUrl = '$baseUrl/api/v1/meta/settings';
  static const String metaDistrictsUrl = '$baseUrl/api/v1/meta/districts';
  static const String metaDivisionsUrl = '$baseUrl/api/v1/meta/divisions';
  static const String metaTaluksUrl = '$baseUrl/api/v1/meta/taluks';
  static const String metaVillagesUrl = '$baseUrl/api/v1/meta/villages';
  static const String metaCategoriesUrl = '$baseUrl/api/v1/meta/categories';
}
