import 'package:equatable/equatable.dart';

abstract class ServerEvent extends Equatable {
  const ServerEvent();

  @override
  List<Object> get props => [];
}

class InitializeServer extends ServerEvent {}

class CheckRequirements extends ServerEvent {}

class StartServer extends ServerEvent {}

class GetIpAddress extends ServerEvent {}

class RestartServer extends ServerEvent {}
