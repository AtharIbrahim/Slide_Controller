import 'package:equatable/equatable.dart';

enum ServerStatus { initial, loading, requirementsChecking, installing, starting, running, error }

class ServerState extends Equatable {
  const ServerState({
    this.status = ServerStatus.initial,
    this.statusMessage = 'Initializing...',
    this.ipAddress = 'Fetching IP...',
    this.requirementsInstalled = false,
    this.serverRunning = false,
    this.errorMessage,
  });

  final ServerStatus status;
  final String statusMessage;
  final String ipAddress;
  final bool requirementsInstalled;
  final bool serverRunning;
  final String? errorMessage;

  bool get isLoading => status == ServerStatus.loading || 
                       status == ServerStatus.requirementsChecking ||
                       status == ServerStatus.installing ||
                       status == ServerStatus.starting;

  ServerState copyWith({
    ServerStatus? status,
    String? statusMessage,
    String? ipAddress,
    bool? requirementsInstalled,
    bool? serverRunning,
    String? errorMessage,
  }) {
    return ServerState(
      status: status ?? this.status,
      statusMessage: statusMessage ?? this.statusMessage,
      ipAddress: ipAddress ?? this.ipAddress,
      requirementsInstalled: requirementsInstalled ?? this.requirementsInstalled,
      serverRunning: serverRunning ?? this.serverRunning,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        statusMessage,
        ipAddress,
        requirementsInstalled,
        serverRunning,
        errorMessage,
      ];
}
