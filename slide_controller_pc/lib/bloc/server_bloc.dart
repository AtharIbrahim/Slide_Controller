import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:process_run/process_run.dart';
import 'server_event.dart';
import 'server_state.dart';

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
      // Get the current directory
      String workingDir = '${Directory.current.path}${Platform.pathSeparator}python_server';
      
      // Check if requirements are installed
      var result = await runExecutableArguments('python', 
          ['-m', 'pip', 'check'],
          workingDirectory: workingDir);
      
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
        
        var installResult = await runExecutableArguments('python', 
            ['-m', 'pip', 'install', '-r', 'requirements.txt'],
            workingDirectory: workingDir);
        
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
      // Get the current directory
      String workingDir = '${Directory.current.path}${Platform.pathSeparator}python_server';
      
      // Start the server in background
      Process.start('python', ['slide_controller_server.py'],
          workingDirectory: workingDir, mode: ProcessStartMode.detached);
      
      // Wait a bit and assume server started successfully
      await Future.delayed(const Duration(seconds: 3));
      
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
