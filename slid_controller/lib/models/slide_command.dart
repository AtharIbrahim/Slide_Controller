enum SlideCommand {
  next,
  previous,
  startPresentation,
  endPresentation,
  // New advanced features
  laserPointer,
  blackScreen,
  whiteScreen,
  presentationView,
  volumeUp,
  volumeDown,
  mute,
  fullScreen,
  exitFullScreen,
  firstSlide,
  lastSlide,
}

extension SlideCommandExtension on SlideCommand {
  String get value {
    switch (this) {
      case SlideCommand.next:
        return 'next';
      case SlideCommand.previous:
        return 'previous';
      case SlideCommand.startPresentation:
        return 'start_presentation';
      case SlideCommand.endPresentation:
        return 'end_presentation';
      case SlideCommand.laserPointer:
        return 'laser_pointer';
      case SlideCommand.blackScreen:
        return 'black_screen';
      case SlideCommand.whiteScreen:
        return 'white_screen';
      case SlideCommand.presentationView:
        return 'presentation_view';
      case SlideCommand.volumeUp:
        return 'volume_up';
      case SlideCommand.volumeDown:
        return 'volume_down';
      case SlideCommand.mute:
        return 'mute';
      case SlideCommand.fullScreen:
        return 'full_screen';
      case SlideCommand.exitFullScreen:
        return 'exit_full_screen';
      case SlideCommand.firstSlide:
        return 'first_slide';
      case SlideCommand.lastSlide:
        return 'last_slide';
    }
  }
}
