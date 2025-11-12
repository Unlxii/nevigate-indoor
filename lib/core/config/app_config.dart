class AppConfig {
  static const String appName = 'Indoor Navigation';
  static const String appVersion = '1.0.0';
  
  // UWB Configuration
  static const int minAnchors = 2;
  static const double positioningAccuracy = 0.3; // meters
  static const int uwbUpdateInterval = 100; // milliseconds
  
  // Bluetooth Configuration
  static const String deviceNamePrefix = 'ESP_UWB_';
  static const Duration scanTimeout = Duration(seconds: 10);
  static const Duration connectionTimeout = Duration(seconds: 5);
  
  // Admin Configuration
  static const List<String> adminEmails = [
    'admin@example.com',
    // Add admin emails here
  ];
  
  // Navigation Configuration
  static const double walkingSpeed = 1.4; // m/s
  static const double pathRefreshRate = 1.0; // seconds
  
  // Map Configuration
  static const double defaultZoom = 1.0;
  static const double minZoom = 0.5;
  static const double maxZoom = 3.0;
}
