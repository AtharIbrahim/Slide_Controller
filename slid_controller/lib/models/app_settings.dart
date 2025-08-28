import 'package:equatable/equatable.dart';

class AppSettings extends Equatable {
  final bool isDarkMode;
  final bool autoReconnect;
  final int reconnectAttempts;
  final int reconnectDelaySeconds;
  final bool laserPointerEnabled;
  final double laserPointerSensitivity;
  final bool vibrateOnAction;
  final bool keepScreenOn;
  final bool showTimer;
  final String lastUsedIp;
  final bool autoStartTimer;
  final bool soundEffects;
  final double uiScale;

  const AppSettings({
    this.isDarkMode = true,
    this.autoReconnect = true,
    this.reconnectAttempts = 3,
    this.reconnectDelaySeconds = 2,
    this.laserPointerEnabled = true,
    this.laserPointerSensitivity = 1.0,
    this.vibrateOnAction = true,
    this.keepScreenOn = true,
    this.showTimer = true,
    this.lastUsedIp = '',
    this.autoStartTimer = false,
    this.soundEffects = false,
    this.uiScale = 1.0,
  });

  AppSettings copyWith({
    bool? isDarkMode,
    bool? autoReconnect,
    int? reconnectAttempts,
    int? reconnectDelaySeconds,
    bool? laserPointerEnabled,
    double? laserPointerSensitivity,
    bool? vibrateOnAction,
    bool? keepScreenOn,
    bool? showTimer,
    String? lastUsedIp,
    bool? autoStartTimer,
    bool? soundEffects,
    double? uiScale,
  }) {
    return AppSettings(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      autoReconnect: autoReconnect ?? this.autoReconnect,
      reconnectAttempts: reconnectAttempts ?? this.reconnectAttempts,
      reconnectDelaySeconds: reconnectDelaySeconds ?? this.reconnectDelaySeconds,
      laserPointerEnabled: laserPointerEnabled ?? this.laserPointerEnabled,
      laserPointerSensitivity: laserPointerSensitivity ?? this.laserPointerSensitivity,
      vibrateOnAction: vibrateOnAction ?? this.vibrateOnAction,
      keepScreenOn: keepScreenOn ?? this.keepScreenOn,
      showTimer: showTimer ?? this.showTimer,
      lastUsedIp: lastUsedIp ?? this.lastUsedIp,
      autoStartTimer: autoStartTimer ?? this.autoStartTimer,
      soundEffects: soundEffects ?? this.soundEffects,
      uiScale: uiScale ?? this.uiScale,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isDarkMode': isDarkMode,
      'autoReconnect': autoReconnect,
      'reconnectAttempts': reconnectAttempts,
      'reconnectDelaySeconds': reconnectDelaySeconds,
      'laserPointerEnabled': laserPointerEnabled,
      'laserPointerSensitivity': laserPointerSensitivity,
      'vibrateOnAction': vibrateOnAction,
      'keepScreenOn': keepScreenOn,
      'showTimer': showTimer,
      'lastUsedIp': lastUsedIp,
      'autoStartTimer': autoStartTimer,
      'soundEffects': soundEffects,
      'uiScale': uiScale,
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      isDarkMode: json['isDarkMode'] ?? true,
      autoReconnect: json['autoReconnect'] ?? true,
      reconnectAttempts: json['reconnectAttempts'] ?? 3,
      reconnectDelaySeconds: json['reconnectDelaySeconds'] ?? 2,
      laserPointerEnabled: json['laserPointerEnabled'] ?? true,
      laserPointerSensitivity: json['laserPointerSensitivity']?.toDouble() ?? 1.0,
      vibrateOnAction: json['vibrateOnAction'] ?? true,
      keepScreenOn: json['keepScreenOn'] ?? true,
      showTimer: json['showTimer'] ?? true,
      lastUsedIp: json['lastUsedIp'] ?? '',
      autoStartTimer: json['autoStartTimer'] ?? false,
      soundEffects: json['soundEffects'] ?? false,
      uiScale: json['uiScale']?.toDouble() ?? 1.0,
    );
  }

  @override
  List<Object?> get props => [
        isDarkMode,
        autoReconnect,
        reconnectAttempts,
        reconnectDelaySeconds,
        laserPointerEnabled,
        laserPointerSensitivity,
        vibrateOnAction,
        keepScreenOn,
        showTimer,
        lastUsedIp,
        autoStartTimer,
        soundEffects,
        uiScale,
      ];
}
