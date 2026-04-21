class AppConfig {
  AppConfig._();

  static const String baseUrl = 'https://roadhero.online/api/v1/driver/';
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration trackingPollInterval = Duration(seconds: 8);

  // Map defaults (Addis Ababa center)
  static const double defaultLat = 9.02497;
  static const double defaultLng = 38.74689;
  static const double defaultZoom = 14.0;
  static const double defaultSearchRadius = 500.0;

  static const String mapTileUrl =
      'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  // Change this line
  static const String mapUserAgent = 'road_hero_ethiopia_driver_final_v1';
}
