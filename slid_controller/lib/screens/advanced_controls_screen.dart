import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../bloc/slide_controller_bloc.dart';
import '../bloc/slide_controller_event.dart';
import '../models/slide_controller_state.dart';

class AdvancedControlsScreen extends StatelessWidget {
  const AdvancedControlsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Advanced Controls',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: BlocBuilder<SlideControllerBloc, SlideControllerState>(
        builder: (context, state) {
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTimerSection(context, state),
                  const SizedBox(height: 24),
                  _buildPresentationControls(context, state),
                  const SizedBox(height: 24),
                  _buildNavigationControls(context, state),
                  const SizedBox(height: 24),
                  _buildVolumeControls(context, state),
                  const SizedBox(height: 24),
                  _buildScreenControls(context, state),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimerSection(BuildContext context, SlideControllerState state) {
    final minutes = state.presentationTimer ~/ 60;
    final seconds = state.presentationTimer % 60;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.purple.shade900,
            Colors.indigo.shade900,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.timer,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 12),
              const Text(
                'Presentation Timer',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          ).animate().scale(),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildTimerButton(
                context,
                state.isTimerRunning ? Icons.pause : Icons.play_arrow,
                state.isTimerRunning ? 'Pause' : 'Start',
                () {
                  if (state.isTimerRunning) {
                    context.read<SlideControllerBloc>().add(StopTimer());
                  } else {
                    context.read<SlideControllerBloc>().add(StartTimer());
                  }
                },
              ),
              _buildTimerButton(
                context,
                Icons.refresh,
                'Reset',
                () => context.read<SlideControllerBloc>().add(ResetTimer()),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimerButton(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onPressed,
  ) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white.withOpacity(0.2),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildPresentationControls(BuildContext context, SlideControllerState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Presentation Controls', Icons.slideshow),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildFeatureButton(
                context,
                Icons.radio_button_on,
                'Laser Pointer',
                state.isLaserPointerActive,
                () => context.read<SlideControllerBloc>().add(ToggleLaserPointer()),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildFeatureButton(
                context,
                Icons.monitor,
                'Presenter View',
                false,
                () => context.read<SlideControllerBloc>().add(TogglePresentationView()),
              ),
            ),
          ],
        ),
        
        // Laser Pointer Control Area
        if (state.isLaserPointerActive) ...[
          const SizedBox(height: 20),
          _buildLaserPointerControl(context, state),
        ],
      ],
    );
  }

  Widget _buildLaserPointerControl(BuildContext context, SlideControllerState state) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.red.withOpacity(0.3)),
      borderRadius: BorderRadius.circular(12),
      color: Colors.red.withOpacity(0.05),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.control_camera, color: Colors.red, size: 20),
            const SizedBox(width: 8),
            Text(
              'Laser Pointer Control',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.red,
                fontSize: 16,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'Tap or drag on the area below to move the laser pointer on your screen',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.red.withOpacity(0.5)),
            borderRadius: BorderRadius.circular(8),
            color: Colors.black.withOpacity(0.1),
          ),
          child: Builder(
            builder: (BuildContext builderContext) {
              return GestureDetector(
                onTapDown: (details) {
                  final RenderBox renderBox = builderContext.findRenderObject() as RenderBox;
                  final size = renderBox.size;
                  _handleLaserPointerMove(context, details.localPosition, size);
                },
                onPanUpdate: (details) {
                  final RenderBox renderBox = builderContext.findRenderObject() as RenderBox;
                  final size = renderBox.size;
                  _handleLaserPointerMove(context, details.localPosition, size);
                },
                onTapUp: (details) {
                  final RenderBox renderBox = builderContext.findRenderObject() as RenderBox;
                  final size = renderBox.size;
                  final double xPercent = (details.localPosition.dx / size.width) * 100;
                  final double yPercent = (details.localPosition.dy / size.height) * 100;
                  final double clampedX = xPercent.clamp(0.0, 100.0);
                  final double clampedY = yPercent.clamp(0.0, 100.0);
                  
                  context.read<SlideControllerBloc>().add(
                    SendLaserPointerClick(clampedX, clampedY),
                  );
                },
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.my_location,
                          color: Colors.red.withOpacity(0.7),
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Touch to Control Pointer',
                          style: TextStyle(
                            color: Colors.red.withOpacity(0.7),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => context.read<SlideControllerBloc>().add(
                  SendLaserPointerClick(50.0, 50.0),
                ),
                icon: Icon(Icons.touch_app),
                label: Text('Center Click'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.withOpacity(0.1),
                  foregroundColor: Colors.red,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => context.read<SlideControllerBloc>().add(
                  ToggleLaserPointer(),
                ),
                icon: Icon(Icons.power_settings_new),
                label: Text('Toggle'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.withOpacity(0.1),
                  foregroundColor: Colors.blue,
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

void _handleLaserPointerMove(BuildContext context, Offset localPosition, Size containerSize) {
  if (containerSize.width <= 0 || containerSize.height <= 0) return;
  
  final double xPercent = (localPosition.dx / containerSize.width) * 100;
  final double yPercent = (localPosition.dy / containerSize.height) * 100;
  
  final double clampedX = xPercent.clamp(0.0, 100.0);
  final double clampedY = yPercent.clamp(0.0, 100.0);
  
  print('Laser pointer move: x=$clampedX%, y=$clampedY% (Container: ${containerSize.width}x${containerSize.height})');
  
  context.read<SlideControllerBloc>().add(
    SendLaserPointerMove(clampedX, clampedY),
  );
}

  Widget _buildNavigationControls(BuildContext context, SlideControllerState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Navigation', Icons.navigation),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                context,
                Icons.first_page,
                'First Slide',
                () => context.read<SlideControllerBloc>().add(GoToFirstSlide()),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                context,
                Icons.last_page,
                'Last Slide',
                () => context.read<SlideControllerBloc>().add(GoToLastSlide()),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildVolumeControls(BuildContext context, SlideControllerState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Volume', Icons.volume_up),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                context,
                Icons.volume_up,
                'Volume Up',
                () => context.read<SlideControllerBloc>().add(VolumeUp()),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildFeatureButton(
                context,
                state.isMuted ? Icons.volume_off : Icons.volume_up,
                'Mute',
                state.isMuted,
                () => context.read<SlideControllerBloc>().add(ToggleMute()),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildActionButton(
                context,
                Icons.volume_down,
                'Volume Down',
                () => context.read<SlideControllerBloc>().add(VolumeDown()),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildScreenControls(BuildContext context, SlideControllerState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Screen Controls', Icons.desktop_windows),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildFeatureButton(
                context,
                Icons.brightness_1,
                'Black Screen',
                state.isBlackScreen,
                () => context.read<SlideControllerBloc>().add(ToggleBlackScreen()),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildFeatureButton(
                context,
                Icons.brightness_high,
                'White Screen',
                state.isWhiteScreen,
                () => context.read<SlideControllerBloc>().add(ToggleWhiteScreen()),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFeatureButton(
    BuildContext context,
    IconData icon,
    String label,
    bool isActive,
    VoidCallback onPressed,
  ) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        gradient: isActive
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.green.shade400, Colors.teal.shade400],
              )
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.grey.shade700, Colors.grey.shade800],
              ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: Colors.green.withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onPressed,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onPressed,
  ) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue.shade600, Colors.purple.shade600],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onPressed,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

}
