class AppConstants {
  // API Configuration
  // Use IP address instead of localhost for mobile devices
  static const String baseUrl = 'http://192.168.1.142:8080/api/v1';
  static const String faceRecognitionUrl = 'http://192.168.1.142:5001';
  
  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  
  // Face Recognition
  static const double faceSimilarityThreshold = 0.6;
  
  // Date Format
  static const String dateFormat = 'EEEE, dd MMM yyyy';
  static const String timeFormat = 'HH:mm:ss';
  
  // App Info
  static const String appName = 'PT. Classik Creactive';
}

