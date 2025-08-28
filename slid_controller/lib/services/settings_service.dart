import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_settings.dart';

class SettingsService {
  static const String _settingsKey = 'app_settings';
  static const String _connectionHistoryKey = 'connection_history';
  
  static SettingsService? _instance;
  SharedPreferences? _prefs;
  static bool _isInitialized = false;
  
  SettingsService._internal();
  
  factory SettingsService() {
    _instance ??= SettingsService._internal();
    return _instance!;
  }
  
  // Initialize SharedPreferences once at app startup
  static Future<void> initialize() async {
    if (!_isInitialized) {
      try {
        final instance = SettingsService();
        instance._prefs = await SharedPreferences.getInstance();
        _isInitialized = true;
        print('SharedPreferences initialized successfully');
      } catch (e) {
        print('Failed to initialize SharedPreferences: $e');
        _isInitialized = false;
      }
    }
  }
  
  Future<void> _ensureInitialized() async {
    if (_prefs == null || !_isInitialized) {
      await initialize();
    }
  }
  
  Future<AppSettings> loadSettings() async {
    try {
      await _ensureInitialized();
      
      if (_prefs == null) {
        print('SharedPreferences not initialized, returning default settings');
        return const AppSettings();
      }
      
      final settingsJson = _prefs!.getString(_settingsKey);
      
      if (settingsJson != null && settingsJson.isNotEmpty) {
        print('Loading settings from storage: $settingsJson');
        try {
          final Map<String, dynamic> data = jsonDecode(settingsJson);
          final settings = AppSettings.fromJson(data);
          print('Settings loaded successfully: isDarkMode=${settings.isDarkMode}, uiScale=${settings.uiScale}');
          return settings;
        } catch (jsonError) {
          print('Error parsing settings JSON: $jsonError');
          // Return default settings if JSON is corrupted
          return const AppSettings();
        }
      } else {
        print('No saved settings found, using defaults');
        return const AppSettings();
      }
    } catch (e) {
      print('Error loading settings: $e');
      return const AppSettings();
    }
  }
  
  Future<bool> saveSettings(AppSettings settings) async {
    try {
      await _ensureInitialized();
      
      if (_prefs == null) {
        print('SharedPreferences not initialized, cannot save settings');
        return false;
      }
      
      final settingsJson = jsonEncode(settings.toJson());
      print('Attempting to save settings: $settingsJson');
      
      final success = await _prefs!.setString(_settingsKey, settingsJson);
      
      if (success) {
        print('Settings saved successfully');
        // Verify the save by reading it back
        final verification = _prefs!.getString(_settingsKey);
        print('Verification read: $verification');
      } else {
        print('Failed to save settings');
      }
      
      return success;
    } catch (e) {
      print('Error saving settings: $e');
      return false;
    }
  }
  
  Future<List<String>> getConnectionHistory() async {
    try {
      await _ensureInitialized();
      final history = _prefs!.getStringList(_connectionHistoryKey) ?? [];
      return history;
    } catch (e) {
      print('Error loading connection history: $e');
      return [];
    }
  }
  
  Future<void> addToConnectionHistory(String ip) async {
    try {
      await _ensureInitialized();
      final history = await getConnectionHistory();
      
      history.remove(ip);
      history.insert(0, ip);
      
      if (history.length > 10) {
        history.removeRange(10, history.length);
      }
      
      await _prefs!.setStringList(_connectionHistoryKey, history);
      print('Added to connection history: $ip');
    } catch (e) {
      print('Error adding to connection history: $e');
    }
  }
  
  Future<void> clearConnectionHistory() async {
    try {
      await _ensureInitialized();
      await _prefs!.remove(_connectionHistoryKey);
    } catch (e) {
      print('Error clearing connection history: $e');
    }
  }
  
  Future<void> setLastUsedIp(String ip) async {
    final settings = await loadSettings();
    await saveSettings(settings.copyWith(lastUsedIp: ip));
    await addToConnectionHistory(ip);
  }
}