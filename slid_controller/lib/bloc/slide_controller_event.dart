import 'package:equatable/equatable.dart';
import '../models/slide_command.dart';
import '../models/app_settings.dart';

abstract class SlideControllerEvent extends Equatable {
  const SlideControllerEvent();

  @override
  List<Object?> get props => [];
}

class ConnectToServer extends SlideControllerEvent {
  final String serverIp;

  const ConnectToServer(this.serverIp);

  @override
  List<Object?> get props => [serverIp];
}

class DisconnectFromServer extends SlideControllerEvent {}

class SendSlideCommand extends SlideControllerEvent {
  final SlideCommand command;

  const SendSlideCommand(this.command);

  @override
  List<Object?> get props => [command];
}

class NextSlide extends SlideControllerEvent {}

class PreviousSlide extends SlideControllerEvent {}

class StartPresentation extends SlideControllerEvent {}

class EndPresentation extends SlideControllerEvent {}

// Advanced Features Events
class ToggleLaserPointer extends SlideControllerEvent {}

class SendLaserPointerMove extends SlideControllerEvent {
  final double xPercent;
  final double yPercent;

  const SendLaserPointerMove(this.xPercent, this.yPercent);

  @override
  List<Object?> get props => [xPercent, yPercent];
}

class SendLaserPointerClick extends SlideControllerEvent {
  final double xPercent;
  final double yPercent;

  const SendLaserPointerClick(this.xPercent, this.yPercent);

  @override
  List<Object?> get props => [xPercent, yPercent];
}

class ToggleBlackScreen extends SlideControllerEvent {}

class ToggleWhiteScreen extends SlideControllerEvent {}

class TogglePresentationView extends SlideControllerEvent {}

class VolumeUp extends SlideControllerEvent {}

class VolumeDown extends SlideControllerEvent {}

class ToggleMute extends SlideControllerEvent {}

class GoToFirstSlide extends SlideControllerEvent {}

class GoToLastSlide extends SlideControllerEvent {}

class StartTimer extends SlideControllerEvent {}

class StopTimer extends SlideControllerEvent {}

class ResetTimer extends SlideControllerEvent {}

class UpdateTimer extends SlideControllerEvent {
  final int seconds;

  const UpdateTimer(this.seconds);

  @override
  List<Object?> get props => [seconds];
}

// Settings Events
class LoadSettings extends SlideControllerEvent {}

class UpdateSettings extends SlideControllerEvent {
  final AppSettings settings;

  const UpdateSettings(this.settings);

  @override
  List<Object?> get props => [settings];
}

class ToggleTheme extends SlideControllerEvent {}

class AttemptReconnect extends SlideControllerEvent {}

class LoadConnectionHistory extends SlideControllerEvent {}
