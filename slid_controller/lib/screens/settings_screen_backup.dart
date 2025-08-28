import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../bloc/slide_controller_bloc.dart';
import '../bloc/slide_controller_event.dart';
import '../models/slide_controller_state.dart';
import '../services/settings_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SlideControllerBloc, SlideControllerState>(
      builder: (context, state) {
        final screenSize = MediaQuery.of(context).size;
        final isTablet = screenSize.width > 600;
        final scale = state.settings.uiScale;
        
        return Scaffold(
          backgroundColor: state.settings.isDarkMode ? Colors.black : const Color(0xFFF5F7FA),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(
              'Settings',
              style: TextStyle(
                color: state.settings.isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
                fontWeight: FontWeight.bold,
                fontSize: (isTablet ? 28 : 20) * scale,
              ),
            ),
            iconTheme: IconThemeData(
              color: state.settings.isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
              size: (isTablet ? 32 : 24) * scale,
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all((isTablet ? 24 : 16) * scale),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildThemeSection(context, state),
                  SizedBox(height: 24 * scale),
                  _buildConnectionSection(context, state),
                  SizedBox(height: 24 * scale),
                  _buildLaserPointerSection(context, state),
                  SizedBox(height: 24 * scale),
                  _buildPresentationSection(context, state),
                  SizedBox(height: 24 * scale),
                  _buildUISection(context, state),
                  SizedBox(height: 24 * scale),
                  _buildConnectionHistorySection(context, state),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  Widget _buildThemeSection(BuildContext context, SlideControllerState state) {
    return _buildSection(
      context,
      state,
      'Theme & Display',
      Icons.palette,
      [
        _buildSwitchTile(
          context,
          state,
          'Dark Mode',
          'Use dark theme throughout the app',
          Icons.dark_mode,
          state.settings.isDarkMode,
          (value) {
            context.read<SlideControllerBloc>().add(ToggleTheme());
          },
        ),
        _buildSliderTile(
          context,
          state,
          'UI Scale',
          'Adjust the size of UI elements',
          Icons.zoom_in,
          state.settings.uiScale,
          0.8,
          1.5,
          (value) {
            final newSettings = state.settings.copyWith(uiScale: value);
            context.read<SlideControllerBloc>().add(UpdateSettings(newSettings));
          },
        ),
        _buildSwitchTile(
          context,
          state,
          'Keep Screen On',
          'Prevent screen from turning off during presentations',
          Icons.screen_lock_portrait,
          state.settings.keepScreenOn,
          (value) {
            final newSettings = state.settings.copyWith(keepScreenOn: value);
            context.read<SlideControllerBloc>().add(UpdateSettings(newSettings));
          },
        ),
      ],
    );
  }

  Widget _buildConnectionSection(BuildContext context, SlideControllerState state) {
    return _buildSection(
      context,
      state,
      'Connection & Reliability',
      Icons.wifi,
      [
        _buildSwitchTile(
          context,
          state,
          'Auto Reconnect',
          'Automatically reconnect when connection is lost',
          Icons.autorenew,
          state.settings.autoReconnect,
          (value) {
            final newSettings = state.settings.copyWith(autoReconnect: value);
            context.read<SlideControllerBloc>().add(UpdateSettings(newSettings));
          },
        ),
        if (state.settings.autoReconnect) ...[
          _buildSliderTile(
            context,
            state,
            'Reconnect Attempts',
            'Maximum number of reconnection attempts',
            Icons.repeat,
            state.settings.reconnectAttempts.toDouble(),
            1.0,
            10.0,
            (value) {
              final newSettings = state.settings.copyWith(reconnectAttempts: value.round());
              context.read<SlideControllerBloc>().add(UpdateSettings(newSettings));
            },
            divisions: 9,
            label: '${state.settings.reconnectAttempts} attempts',
          ),
          _buildSliderTile(
            context,
            state,
            'Reconnect Delay',
            'Delay between reconnection attempts',
            Icons.timer,
            state.settings.reconnectDelaySeconds.toDouble(),
            1.0,
            10.0,
            (value) {
              final newSettings = state.settings.copyWith(reconnectDelaySeconds: value.round());
              context.read<SlideControllerBloc>().add(UpdateSettings(newSettings));
            },
            divisions: 9,
            label: '${state.settings.reconnectDelaySeconds} seconds',
          ),
        ],
      ],
    );
  }

  Widget _buildLaserPointerSection(BuildContext context, SlideControllerState state) {
    return _buildSection(
      context,
      state,
      'Laser Pointer',
      Icons.radio_button_on,
      [
        _buildSwitchTile(
          context,
          state,
          'Enable Laser Pointer',
          'Allow laser pointer functionality',
          Icons.radio_button_on,
          state.settings.laserPointerEnabled,
          (value) {
            final newSettings = state.settings.copyWith(laserPointerEnabled: value);
            context.read<SlideControllerBloc>().add(UpdateSettings(newSettings));
          },
        ),
        if (state.settings.laserPointerEnabled)
          _buildSliderTile(
            context,
            state,
            'Pointer Sensitivity',
            'Adjust laser pointer movement sensitivity',
            Icons.speed,
            state.settings.laserPointerSensitivity,
            0.1,
            2.0,
            (value) {
              final newSettings = state.settings.copyWith(laserPointerSensitivity: value);
              context.read<SlideControllerBloc>().add(UpdateSettings(newSettings));
            },
            divisions: 19,
            label: '${(state.settings.laserPointerSensitivity * 100).round()}%',
          ),
      ],
    );
  }

  Widget _buildPresentationSection(BuildContext context, SlideControllerState state) {
    return _buildSection(
      context,
      state,
      'Presentation',
      Icons.slideshow,
      [
        _buildSwitchTile(
          context,
          state,
          'Show Timer',
          'Display presentation timer on main screen',
          Icons.timer,
          state.settings.showTimer,
          (value) {
            final newSettings = state.settings.copyWith(showTimer: value);
            context.read<SlideControllerBloc>().add(UpdateSettings(newSettings));
          },
        ),
        _buildSwitchTile(
          context,
          state,
          'Auto Start Timer',
          'Start timer automatically when presentation begins',
          Icons.play_arrow,
          state.settings.autoStartTimer,
          (value) {
            final newSettings = state.settings.copyWith(autoStartTimer: value);
            context.read<SlideControllerBloc>().add(UpdateSettings(newSettings));
          },
        ),
      ],
    );
  }

  Widget _buildUISection(BuildContext context, SlideControllerState state) {
    return _buildSection(
      context,
      state,
      'User Experience',
      Icons.touch_app,
      [
        _buildSwitchTile(
          context,
          state,
          'Vibrate on Action',
          'Provide haptic feedback when buttons are pressed',
          Icons.vibration,
          state.settings.vibrateOnAction,
          (value) {
            final newSettings = state.settings.copyWith(vibrateOnAction: value);
            context.read<SlideControllerBloc>().add(UpdateSettings(newSettings));
          },
        ),
        _buildSwitchTile(
          context,
          state,
          'Sound Effects',
          'Play sounds for button presses and notifications',
          Icons.volume_up,
          state.settings.soundEffects,
          (value) {
            final newSettings = state.settings.copyWith(soundEffects: value);
            context.read<SlideControllerBloc>().add(UpdateSettings(newSettings));
          },
        ),
      ],
    );
  }

  Widget _buildConnectionHistorySection(BuildContext context, SlideControllerState state) {
    return _buildSection(
      context,
      state,
      'Connection History',
      Icons.history,
      [
        if (state.connectionHistory.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            child: Text(
              'No recent connections',
              style: TextStyle(
                color: state.settings.isDarkMode ? Colors.grey[400] : Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          )
        else
          ...state.connectionHistory.map((ip) => _buildHistoryTile(context, state, ip)),
        
        const SizedBox(height: 8),
        
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () async {
              // Show confirmation dialog
              final bool? shouldClear = await showDialog<bool>(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Clear History'),
                    content: const Text('Are you sure you want to clear the connection history?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text('Clear'),
                      ),
                    ],
                  );
                },
              );
              
              if (shouldClear == true) {
                // Clear history using the settings service
                final settingsService = SettingsService();
                await settingsService.clearConnectionHistory();
                
                // Reload connection history to update UI
                context.read<SlideControllerBloc>().add(LoadConnectionHistory());
                
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Connection history cleared')),
                  );
                }
              }
            },
            icon: const Icon(Icons.clear_all),
            label: const Text('Clear History'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.withOpacity(0.1),
              foregroundColor: Colors.red,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSection(
    BuildContext context,
    SlideControllerState state,
    String title,
    IconData icon,
    List<Widget> children,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: state.settings.isDarkMode 
            ? Colors.grey[900] 
            : Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: state.settings.isDarkMode ? Colors.blue[300] : Colors.blue[700],
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    color: state.settings.isDarkMode ? Colors.white : Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    ).animate().fadeIn(delay: 100.ms).slideX();
  }

  Widget _buildSwitchTile(
    BuildContext context,
    SlideControllerState state,
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return ListTile(
      leading: Icon(
        icon,
        color: state.settings.isDarkMode ? Colors.grey[300] : Colors.grey[700],
      ),
      title: Text(
        title,
        style: TextStyle(
          color: state.settings.isDarkMode ? Colors.white : Colors.black,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: state.settings.isDarkMode ? Colors.grey[400] : Colors.grey[600],
          fontSize: 12,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Colors.blue,
      ),
    );
  }

  Widget _buildSliderTile(
    BuildContext context,
    SlideControllerState state,
    String title,
    String subtitle,
    IconData icon,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged, {
    int? divisions,
    String? label,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: state.settings.isDarkMode ? Colors.grey[300] : Colors.grey[700],
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: state.settings.isDarkMode ? Colors.white : Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (label != null)
                Text(
                  label,
                  style: TextStyle(
                    color: state.settings.isDarkMode ? Colors.blue[300] : Colors.blue[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
          Text(
            subtitle,
            style: TextStyle(
              color: state.settings.isDarkMode ? Colors.grey[400] : Colors.grey[600],
              fontSize: 12,
            ),
          ),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
            activeColor: Colors.blue,
            inactiveColor: state.settings.isDarkMode ? Colors.grey[700] : Colors.grey[300],
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTile(BuildContext context, SlideControllerState state, String ip) {
    return ListTile(
      leading: Icon(
        Icons.computer,
        color: state.settings.isDarkMode ? Colors.grey[300] : Colors.grey[700],
      ),
      title: Text(
        ip,
        style: TextStyle(
          color: state.settings.isDarkMode ? Colors.white : Colors.black,
          fontFamily: 'monospace',
        ),
      ),
      subtitle: Text(
        'Tap to connect',
        style: TextStyle(
          color: state.settings.isDarkMode ? Colors.grey[400] : Colors.grey[600],
          fontSize: 12,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: state.settings.isDarkMode ? Colors.grey[400] : Colors.grey[600],
      ),
      onTap: () {
        // Connect to this IP
        context.read<SlideControllerBloc>().add(ConnectToServer(ip));
        Navigator.pop(context); // Go back to main screen
      },
    );
  }
}
