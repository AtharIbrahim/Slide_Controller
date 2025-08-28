import 'package:equatable/equatable.dart';
import 'app_settings.dart';

enum ConnectionStatus { disconnected, connecting, connected, error, reconnecting }

class SlideControllerState extends Equatable {
  final ConnectionStatus connectionStatus;
  final String? serverIp;
  final int currentSlide;
  final String? errorMessage;
  final bool isPresenting;
  final bool isLaserPointerActive;
  final bool isBlackScreen;
  final bool isWhiteScreen;
  final bool isMuted;
  final int presentationTimer; // in seconds
  final bool isTimerRunning;
  final AppSettings settings;
  final int reconnectAttempt;
  final List<String> connectionHistory;

  const SlideControllerState({
    this.connectionStatus = ConnectionStatus.disconnected,
    this.serverIp,
    this.currentSlide = 0,
    this.errorMessage,
    this.isPresenting = false,
    this.isLaserPointerActive = false,
    this.isBlackScreen = false,
    this.isWhiteScreen = false,
    this.isMuted = false,
    this.presentationTimer = 0,
    this.isTimerRunning = false,
    this.settings = const AppSettings(),
    this.reconnectAttempt = 0,
    this.connectionHistory = const [],
  });

  SlideControllerState copyWith({
    ConnectionStatus? connectionStatus,
    String? serverIp,
    int? currentSlide,
    String? errorMessage,
    bool? isPresenting,
    bool? isLaserPointerActive,
    bool? isBlackScreen,
    bool? isWhiteScreen,
    bool? isMuted,
    int? presentationTimer,
    bool? isTimerRunning,
    AppSettings? settings,
    int? reconnectAttempt,
    List<String>? connectionHistory,
  }) {
    return SlideControllerState(
      connectionStatus: connectionStatus ?? this.connectionStatus,
      serverIp: serverIp ?? this.serverIp,
      currentSlide: currentSlide ?? this.currentSlide,
      errorMessage: errorMessage ?? this.errorMessage,
      isPresenting: isPresenting ?? this.isPresenting,
      isLaserPointerActive: isLaserPointerActive ?? this.isLaserPointerActive,
      isBlackScreen: isBlackScreen ?? this.isBlackScreen,
      isWhiteScreen: isWhiteScreen ?? this.isWhiteScreen,
      isMuted: isMuted ?? this.isMuted,
      presentationTimer: presentationTimer ?? this.presentationTimer,
      isTimerRunning: isTimerRunning ?? this.isTimerRunning,
      settings: settings ?? this.settings,
      reconnectAttempt: reconnectAttempt ?? this.reconnectAttempt,
      connectionHistory: connectionHistory ?? this.connectionHistory,
    );
  }

  @override
  List<Object?> get props => [
        connectionStatus,
        serverIp,
        currentSlide,
        errorMessage,
        isPresenting,
        isLaserPointerActive,
        isBlackScreen,
        isWhiteScreen,
        isMuted,
        presentationTimer,
        isTimerRunning,
        settings,
        reconnectAttempt,
        connectionHistory,
      ];
}
