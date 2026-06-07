import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:process_run/process_run.dart';
import 'server_event.dart';
import 'server_state.dart';

const int _serverPort = 8080;

class _PythonCommand {
  const _PythonCommand(this.executable, this.launchArguments);

  final String executable;
  final List<String> launchArguments;
}

class ServerBloc extends Bloc<ServerEvent, ServerState> {
  ServerBloc() : super(const ServerState()) {
    on<InitializeServer>(_onInitializeServer);
    on<CheckRequirements>(_onCheckRequirements);
    on<StartServer>(_onStartServer);
    on<GetIpAddress>(_onGetIpAddress);
    on<RestartServer>(_onRestartServer);
  }

  Future<void> _onInitializeServer(InitializeServer event, Emitter<ServerState> emit) async {
    emit(state.copyWith(status: ServerStatus.loading));
    
    // Get IP address first
    await _getIpAddress(emit);
    
    // Check requirements
    await _checkRequirements(emit);
    
    // Start server if requirements are installed
    if (state.requirementsInstalled) {
      await _startServer(emit);
    }
  }

  Future<void> _onCheckRequirements(CheckRequirements event, Emitter<ServerState> emit) async {
    await _checkRequirements(emit);
  }

  Future<void> _onStartServer(StartServer event, Emitter<ServerState> emit) async {
    if (!state.requirementsInstalled) {
      await _checkRequirements(emit);
    }
    if (state.requirementsInstalled) {
      await _startServer(emit);
    }
  }

  Future<void> _onGetIpAddress(GetIpAddress event, Emitter<ServerState> emit) async {
    await _getIpAddress(emit);
  }

  Future<void> _onRestartServer(RestartServer event, Emitter<ServerState> emit) async {
    emit(state.copyWith(status: ServerStatus.loading));
    await _getIpAddress(emit);
    await _checkRequirements(emit);
    if (state.requirementsInstalled) {
      await _startServer(emit);
    }
  }

  Future<void> _checkRequirements(Emitter<ServerState> emit) async {
    emit(state.copyWith(
      status: ServerStatus.requirementsChecking,
      statusMessage: 'Checking Python requirements...',
    ));

    try {
      final workingDir = _resolveServerDirectory();
      if (workingDir == null) {
        emit(state.copyWith(
          requirementsInstalled: false,
          statusMessage: 'Could not find python_server directory.',
          status: ServerStatus.error,
          errorMessage: 'Expected slide_controller_server.py inside python_server.',
        ));
        return;
      }

      final python = await _resolvePythonCommand();
      if (python == null) {
        emit(state.copyWith(
          requirementsInstalled: false,
          statusMessage: 'Python launcher not found.',
          status: ServerStatus.error,
          errorMessage: 'Could not find py -3.10, py -3, python3, or python on this machine.',
        ));
        return;
      }
      
      // Check if requirements are installed
      final result = await runExecutableArguments(
        python.executable,
        [...python.launchArguments, '-m', 'pip', 'check'],
        workingDirectory: workingDir.path,
      );
      
      if (result.exitCode == 0) {
        emit(state.copyWith(
          requirementsInstalled: true,
          statusMessage: 'Requirements already installed!',
          status: ServerStatus.initial,
        ));
      } else {
        // Try to install requirements
        emit(state.copyWith(
          status: ServerStatus.installing,
          statusMessage: 'Installing requirements...',
        ));
        
        final installResult = await runExecutableArguments(
          python.executable,
          [...python.launchArguments, '-m', 'pip', 'install', '-r', 'requirements.txt'],
          workingDirectory: workingDir.path,
        );
        
        if (installResult.exitCode == 0) {
          emit(state.copyWith(
            requirementsInstalled: true,
            statusMessage: 'Requirements installed successfully!',
            status: ServerStatus.initial,
          ));
        } else {
          emit(state.copyWith(
            requirementsInstalled: false,
            statusMessage: 'Failed to install requirements!',
            status: ServerStatus.error,
            errorMessage: 'Requirements installation failed',
          ));
        }
      }
    } catch (e) {
      emit(state.copyWith(
        requirementsInstalled: false,
        statusMessage: 'Python not found or requirements check failed!',
        status: ServerStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _startServer(Emitter<ServerState> emit) async {
    emit(state.copyWith(
      status: ServerStatus.starting,
      statusMessage: 'Starting server...',
    ));

    try {
      final workingDir = _resolveServerDirectory();
      if (workingDir == null) {
        emit(state.copyWith(
          serverRunning: false,
          statusMessage: 'Could not find python_server directory.',
          status: ServerStatus.error,
          errorMessage: 'Expected slide_controller_server.py inside python_server.',
        ));
        return;
      }

      final python = await _resolvePythonCommand();
      if (python == null) {
        emit(state.copyWith(
          serverRunning: false,
          statusMessage: 'Python launcher not found.',
          status: ServerStatus.error,
          errorMessage: 'Could not find py -3.10, py -3, python3, or python on this machine.',
        ));
        return;
      }

      await Process.start(
        python.executable,
        [...python.launchArguments, 'slide_controller_server.py'],
        workingDirectory: workingDir.path,
        mode: ProcessStartMode.detached,
      );

      emit(state.copyWith(
        statusMessage: 'Waiting for server to become reachable...',
      ));

      final serverReady = await _waitForServerReady();
      if (!serverReady) {
        emit(state.copyWith(
          serverRunning: false,
          statusMessage: 'Server did not become reachable on port $_serverPort.',
          status: ServerStatus.error,
          errorMessage: 'The Python process started, but the WebSocket server was not reachable.',
        ));
        return;
      }

      emit(state.copyWith(
        serverRunning: true,
        statusMessage: 'Server is running successfully! 🚀',
        status: ServerStatus.running,
      ));
    } catch (e) {
      emit(state.copyWith(
        serverRunning: false,
        statusMessage: 'Server failed to start! Please check Python installation.',
        status: ServerStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<bool> _waitForServerReady() async {
    for (var attempt = 0; attempt < 20; attempt++) {
      try {
        final socket = await Socket.connect(
          InternetAddress.loopbackIPv4,
          _serverPort,
          timeout: const Duration(seconds: 1),
        );
        socket.destroy();
        return true;
      } catch (_) {
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }

    return false;
  }

  Directory? _resolveServerDirectory() {
    var currentDirectory = Directory.current;

    for (var i = 0; i < 8; i++) {
      final candidate = Directory('${currentDirectory.path}${Platform.pathSeparator}python_server');
      final serverFile = File('${candidate.path}${Platform.pathSeparator}slide_controller_server.py');

      if (candidate.existsSync() && serverFile.existsSync()) {
        return candidate;
      }

      final parentDirectory = currentDirectory.parent;
      if (parentDirectory.path == currentDirectory.path) {
        break;
      }
      currentDirectory = parentDirectory;
    }

    return null;
  }

  Future<_PythonCommand?> _resolvePythonCommand() async {
    final candidates = <_PythonCommand>[
      if (Platform.isWindows) const _PythonCommand('py', ['-3.10']),
      if (Platform.isWindows) const _PythonCommand('py', ['-3']),
      const _PythonCommand('python3', []),
      const _PythonCommand('python', []),
    ];

    for (final candidate in candidates) {
      try {
        final result = await runExecutableArguments(
          candidate.executable,
          [...candidate.launchArguments, '--version'],
        );

        if (result.exitCode == 0) {
          return candidate;
        }
      } catch (_) {
        // Try the next candidate.
      }
    }

    return null;
  }

  Future<void> _getIpAddress(Emitter<ServerState> emit) async {
    try {
      for (var interface in await NetworkInterface.list()) {
        for (var addr in interface.addresses) {
          if (addr.type == InternetAddressType.IPv4 && !addr.isLoopback) {
            emit(state.copyWith(ipAddress: addr.address));
            return;
          }
        }
      }
      emit(state.copyWith(ipAddress: 'Not found'));
    } catch (e) {
      emit(state.copyWith(
        ipAddress: 'Error',
        errorMessage: 'Failed to get IP address: ${e.toString()}',
      ));
    }
  }
}
