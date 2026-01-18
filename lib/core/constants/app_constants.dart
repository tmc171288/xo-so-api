/// App-wide constants
class AppConstants {
  // App Info
  static const String appName = 'Xổ Số Trực Tiếp';
  static const String appVersion = '1.0.0';
  
  // API Configuration
  static const String apiBaseUrl = 'http://103.185.184.164:3001';
  static const String socketUrl = 'http://103.185.184.164:3001';
  
  // Storage Keys
  static const String keyThemeMode = 'theme_mode';
  static const String keySelectedRegion = 'selected_region';
  static const String keyFavoriteNumbers = 'favorite_numbers';
  
  // Regions
  static const String regionNorth = 'north';
  static const String regionCentral = 'central';
  static const String regionSouth = 'south';
  
  // Cache Duration
  static const Duration cacheDuration = Duration(hours: 24);
  
  // Pagination
  static const int pageSize = 20;
}
