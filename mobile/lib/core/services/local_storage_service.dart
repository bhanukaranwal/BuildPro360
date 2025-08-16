import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();
  
  factory LocalStorageService() {
    return _instance;
  }
  
  LocalStorageService._internal();
  
  // Secure storage for sensitive data
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  // Keys
  static const String _authTokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';
  static const String _usernameKey = 'username';
  static const String _userEmailKey = 'user_email';
  static const String _userRoleKey = 'user_role';
  static const String _biometricEnabledKey = 'biometric_enabled';
  static const String _fcmTokenKey = 'fcm_token';
  static const String _darkModeKey = 'dark_mode';
  static const String _cacheTimeKey = 'cache_time';
  
  // Authentication
  Future<void> saveAuthToken(String token) async {
    await _secureStorage.write(key: _authTokenKey, value: token);
  }
  
  Future<String?> getAuthToken() async {
    return await _secureStorage.read(key: _authTokenKey);
  }
  
  Future<void> clearAuthToken() async {
    await _secureStorage.delete(key: _authTokenKey);
  }
  
  // User data
  Future<void> saveUserData({
    required String userId,
    required String username,
    String? email,
    String? role,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userIdKey, userId);
    await prefs.setString(_usernameKey, username);
    
    if (email != null) {
      await prefs.setString(_userEmailKey, email);
    }
    
    if (role != null) {
      await prefs.setString(_userRoleKey, role);
    }
  }
  
  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }
  
  Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_usernameKey);
  }
  
  Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userEmailKey);
  }
  
  Future<String?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userRoleKey);
  }
  
  Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userIdKey);
    await prefs.remove(_usernameKey);
    await prefs.remove(_userEmailKey);
    await prefs.remove(_userRoleKey);
  }
  
  // Biometric authentication
  Future<void> setBiometricEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_biometricEnabledKey, enabled);
  }
  
  Future<bool> isBiometricEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_biometricEnabledKey) ?? false;
  }
  
  // FCM token
  Future<void> saveString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }
  
  Future<String?> getString(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }
  
  // Theme settings
  Future<void> setDarkMode(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkModeKey, enabled);
  }
  
  Future<bool> isDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_darkModeKey) ?? false;
  }
  
  // Caching
  Future<void> cacheData(String key, dynamic data) async {
    final prefs = await SharedPreferences.getInstance();
    
    final cacheData = {
      'data': data,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    
    await prefs.setString(key, json.encode(cacheData));
  }
  
  Future<dynamic> getCachedData(String key, {Duration? maxAge}) async {
    final prefs = await SharedPreferences.getInstance();
    final cachedString = prefs.getString(key);
    
    if (cachedString != null) {
      final cached = json.decode(cachedString);
      final timestamp = cached['timestamp'] as int;
      final age = DateTime.now().millisecondsSinceEpoch - timestamp;
      
      final maxAgeMs = maxAge?.inMilliseconds ?? const Duration(hours: 24).inMilliseconds;
      
      if (age <= maxAgeMs) {
        return cached['data'];
      }
    }
    
    return null;
  }
  
  Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    
    for (final key in keys) {
      if (key.startsWith('cache_')) {
        await prefs.remove(key);
      }
    }
  }
  
  Future<void> setCacheTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_cacheTimeKey, DateTime.now().millisecondsSinceEpoch);
  }
  
  Future<DateTime?> getLastCacheTime() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt(_cacheTimeKey);
    
    if (timestamp != null) {
      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    }
    
    return null;
  }
}