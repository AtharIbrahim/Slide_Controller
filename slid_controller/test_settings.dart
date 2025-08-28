import 'lib/services/settings_service.dart';
import 'lib/models/app_settings.dart';

void main() async {
  print('Testing settings service...');
  
  final settingsService = SettingsService();
  
  // Test loading settings
  print('Loading settings...');
  final initialSettings = await settingsService.loadSettings();
  print('Initial settings: isDarkMode=${initialSettings.isDarkMode}, laserPointerEnabled=${initialSettings.laserPointerEnabled}');
  
  // Test saving settings
  print('Saving new settings...');
  final newSettings = initialSettings.copyWith(
    isDarkMode: !initialSettings.isDarkMode,
    lastUsedIp: '192.168.1.100',
  );
  
  await settingsService.saveSettings(newSettings);
  print('Settings saved');
  
  // Test loading again
  print('Loading settings again...');
  final loadedSettings = await settingsService.loadSettings();
  print('Loaded settings: isDarkMode=${loadedSettings.isDarkMode}, lastUsedIp=${loadedSettings.lastUsedIp}');
  
  if (loadedSettings.isDarkMode == newSettings.isDarkMode) {
    print('✅ Settings are being saved and loaded correctly!');
  } else {
    print('❌ Settings are NOT being saved properly!');
  }
}
