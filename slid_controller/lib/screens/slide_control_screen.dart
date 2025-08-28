import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../bloc/slide_controller_bloc.dart';
import '../bloc/slide_controller_event.dart';
import '../models/slide_controller_state.dart';
import 'advanced_controls_screen.dart';
import 'settings_screen.dart';
import 'qr_scanner_screen.dart';

class SlideControlScreen extends StatefulWidget {
  const SlideControlScreen({super.key});

  @override
  State<SlideControlScreen> createState() => _SlideControlScreenState();
}

class _SlideControlScreenState extends State<SlideControlScreen> {
  @override
  void initState() {
    super.initState();
    // Load settings when the app starts
    context.read<SlideControllerBloc>().add(LoadSettings());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SlideControllerBloc, SlideControllerState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: state.settings.isDarkMode 
              ? Colors.black 
              : const Color(0xFFF5F7FA), // Updated light background
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(context, state),
                Expanded(
                  child: _buildControlArea(context, state),
                ),
                _buildFooter(context, state),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, SlideControllerState state) {
    final isDark = state.settings.isDarkMode;
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    final scale = state.settings.uiScale;
    
    return Container(
      padding: EdgeInsets.all(isTablet ? 24 * scale : 16 * scale),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark ? [
            Colors.blue.shade900,
            Colors.purple.shade900,
          ] : [
            Colors.blue.shade600,
            Colors.purple.shade600,
          ],
        ),
      ),
      child: Row(
        children: [
          Icon(
            _getConnectionIcon(state.connectionStatus),
            color: _getConnectionColor(state.connectionStatus),
            size: (isTablet ? 32 : 24) * scale,
          ),
          SizedBox(width: 12 * scale),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Slide Controller Pro',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: (isTablet ? 28 : 20) * scale,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _getStatusText(state),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: (isTablet ? 18 : 14) * scale,
                  ),
                ),
              ],
            ),
          ),
          // Settings button - always available
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BlocProvider.value(
                    value: context.read<SlideControllerBloc>(),
                    child: const SettingsScreen(),
                  ),
                ),
              );
            },
            icon: Icon(
              Icons.settings,
              color: Colors.white,
              size: (isTablet ? 32 : 24) * scale,
            ),
            tooltip: 'Settings',
          ),
          if (state.connectionStatus == ConnectionStatus.connected) ...[
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BlocProvider.value(
                      value: context.read<SlideControllerBloc>(),
                      child: const AdvancedControlsScreen(),
                    ),
                  ),
                );
              },
              icon: Icon(
                Icons.control_camera,
                color: Colors.white,
                size: (isTablet ? 32 : 24) * scale,
              ),
              tooltip: 'Advanced Controls',
            ),
            IconButton(
              onPressed: () {
                context.read<SlideControllerBloc>().add(DisconnectFromServer());
              },
              icon: Icon(
                Icons.close,
                color: Colors.white,
                size: (isTablet ? 32 : 24) * scale,
              ),
              tooltip: 'Disconnect',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildControlArea(BuildContext context, SlideControllerState state) {
    if (state.connectionStatus != ConnectionStatus.connected) {
      return _buildConnectionScreen(context, state);
    }

    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    final isLandscape = screenSize.width > screenSize.height;
    final scale = state.settings.uiScale;

    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity! > 0) {
          // Swipe right - previous slide
          context.read<SlideControllerBloc>().add(PreviousSlide());
        } else if (details.primaryVelocity! < 0) {
          // Swipe left - next slide
          context.read<SlideControllerBloc>().add(NextSlide());
        }
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(isTablet ? 32 * scale : 16 * scale),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (state.isPresenting) ...[
              Text(
                'Slide ${state.currentSlide}',
                style: TextStyle(
                  color: state.settings.isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
                  fontSize: (isTablet ? 72 : 48) * scale,
                  fontWeight: FontWeight.bold,
                ),
              ).animate().scale(),
              SizedBox(height: 12 * scale),
              if ((state.isTimerRunning || state.presentationTimer > 0) && state.settings.showTimer)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16 * scale, 
                    vertical: 8 * scale
                  ),
                  decoration: BoxDecoration(
                    color: state.settings.isDarkMode 
                        ? Colors.white.withOpacity(0.1)
                        : Colors.black.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20 * scale),
                  ),
                  child: Text(
                    '${(state.presentationTimer ~/ 60).toString().padLeft(2, '0')}:${(state.presentationTimer % 60).toString().padLeft(2, '0')}',
                    style: TextStyle(
                      color: state.settings.isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
                      fontSize: (isTablet ? 20 : 16) * scale,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              SizedBox(height: 20 * scale),
            ],
            
            // Control buttons - adapt layout for landscape/tablet
            isLandscape && isTablet
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildControlButton(
                        context,
                        state,
                        Icons.arrow_back_ios,
                        'Previous',
                        () => context.read<SlideControllerBloc>().add(PreviousSlide()),
                        enabled: state.currentSlide > 0,
                      ),
                      SizedBox(width: 80 * scale),
                      _buildControlButton(
                        context,
                        state,
                        Icons.arrow_forward_ios,
                        'Next',
                        () => context.read<SlideControllerBloc>().add(NextSlide()),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildControlButton(
                        context,
                        state,
                        Icons.arrow_back_ios,
                        'Previous',
                        () => context.read<SlideControllerBloc>().add(PreviousSlide()),
                        enabled: state.currentSlide > 0,
                      ),
                      _buildControlButton(
                        context,
                        state,
                        Icons.arrow_forward_ios,
                        'Next',
                        () => context.read<SlideControllerBloc>().add(NextSlide()),
                      ),
                    ],
                  ),
            
            SizedBox(height: 40 * scale),
            
            Text(
              '← Swipe to control slides →',
              style: TextStyle(
                color: state.settings.isDarkMode 
                    ? Colors.white.withOpacity(0.6)
                    : Colors.black.withOpacity(0.6),
                fontSize: (isTablet ? 20 : 16) * scale,
              ),
            ).animate().fadeIn(delay: 1.seconds),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton(
    BuildContext context,
    SlideControllerState state,
    IconData icon,
    String label,
    VoidCallback onPressed, {
    bool enabled = true,
  }) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    final scale = state.settings.uiScale;
    final buttonSize = (isTablet ? 100 : 80) * scale;
    final iconSize = (isTablet ? 40 : 30) * scale;
    
    return Column(
      children: [
        Container(
          width: buttonSize,
          height: buttonSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: enabled
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.blue.shade400,
                      Colors.purple.shade400,
                    ],
                  )
                : null,
            color: enabled ? null : Colors.grey.shade800,
            boxShadow: enabled
                ? [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.3),
                      blurRadius: 15 * scale,
                      spreadRadius: 2 * scale,
                    ),
                  ]
                : null,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(buttonSize / 2),
              onTap: enabled ? onPressed : null,
              child: Icon(
                icon,
                color: enabled ? Colors.white : Colors.grey.shade600,
                size: iconSize,
              ),
            ),
          ),
        ),
        SizedBox(height: 8 * scale),
        Text(
          label,
          style: TextStyle(
            color: enabled 
                ? (state.settings.isDarkMode ? Colors.white : const Color(0xFF1A1A1A))
                : Colors.grey.shade600,
            fontSize: (isTablet ? 18 : 14) * scale,
          ),
        ),
      ],
    );
  }

  Widget _buildConnectionScreen(BuildContext context, SlideControllerState state) {
    final TextEditingController ipController = TextEditingController();
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    final scale = state.settings.uiScale;
    
    // Pre-fill with last used IP if available
    if (state.settings.lastUsedIp.isNotEmpty) {
      ipController.text = state.settings.lastUsedIp;
    }
    
    return Padding(
      padding: EdgeInsets.all(isTablet ? 48 * scale : 32 * scale),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.wifi,
            size: (isTablet ? 120 : 80) * scale,
            color: state.settings.isDarkMode 
                ? Colors.white.withOpacity(0.6)
                : Colors.black.withOpacity(0.6),
          ).animate().scale(delay: 300.ms),
          
          SizedBox(height: 40 * scale),
          
          Text(
            'Connect to Computer',
            style: TextStyle(
              color: state.settings.isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
              fontSize: (isTablet ? 32 : 24) * scale,
              fontWeight: FontWeight.bold,
            ),
          ).animate().fadeIn(),
          
          SizedBox(height: 16 * scale),
          
          Text(
            'Enter your computer\'s IP address',
            style: TextStyle(
              color: state.settings.isDarkMode 
                  ? Colors.white.withOpacity(0.8)
                  : Colors.black.withOpacity(0.8),
              fontSize: (isTablet ? 20 : 16) * scale,
            ),
          ).animate().fadeIn(delay: 200.ms),
          
          SizedBox(height: 40 * scale),
          
          // Connection history quick access
          if (state.connectionHistory.isNotEmpty) ...[
            Text(
              'Recent connections:',
              style: TextStyle(
                color: state.settings.isDarkMode 
                    ? Colors.white.withOpacity(0.6)
                    : Colors.black.withOpacity(0.6),
                fontSize: (isTablet ? 16 : 14) * scale,
              ),
            ),
            SizedBox(height: 12 * scale),
            Container(
              height: 50 * scale,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: state.connectionHistory.length > 3 ? 3 : state.connectionHistory.length,
                itemBuilder: (context, index) {
                  final ip = state.connectionHistory[index];
                  return Padding(
                    padding: EdgeInsets.only(right: 8 * scale),
                    child: InkWell(
                      onTap: () {
                        ipController.text = ip;
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16 * scale,
                          vertical: 8 * scale,
                        ),
                        decoration: BoxDecoration(
                          color: state.settings.isDarkMode 
                              ? Colors.white.withOpacity(0.1)
                              : Colors.black.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8 * scale),
                          border: Border.all(
                            color: state.settings.isDarkMode 
                                ? Colors.white.withOpacity(0.3)
                                : Colors.black.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          ip,
                          style: TextStyle(
                            color: state.settings.isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
                            fontSize: (isTablet ? 16 : 12) * scale,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 24 * scale),
          ],
          
          // IP input with QR scanner button
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: ipController,
                  style: TextStyle(
                    color: state.settings.isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
                    fontSize: (isTablet ? 20 : 16) * scale,
                  ),
                  decoration: InputDecoration(
                    hintText: '192.168.1.100',
                    hintStyle: TextStyle(
                      color: state.settings.isDarkMode 
                          ? Colors.white.withOpacity(0.5)
                          : Colors.black.withOpacity(0.5),
                      fontSize: (isTablet ? 20 : 16) * scale,
                    ),
                    filled: true,
                    fillColor: state.settings.isDarkMode 
                        ? Colors.white.withOpacity(0.1)
                        : Colors.black.withOpacity(0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12 * scale),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.all(16 * scale),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
              ),
              SizedBox(width: 12 * scale),
              // QR Scanner Button
              Container(
                height: (isTablet ? 64 : 56) * scale,
                width: (isTablet ? 64 : 56) * scale,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.blue.shade600,
                      Colors.purple.shade600,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12 * scale),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.3),
                      blurRadius: 8 * scale,
                      spreadRadius: 2 * scale,
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12 * scale),
                    onTap: () => _openQRScanner(context),
                    child: Icon(
                      Icons.qr_code_scanner,
                      color: Colors.white,
                      size: (isTablet ? 32 : 24) * scale,
                    ),
                  ),
                ),
              ),
            ],
          ).animate().slideX(delay: 400.ms),
          
          SizedBox(height: 24 * scale),
          
          if (state.errorMessage != null)
            Container(
              padding: EdgeInsets.all(12 * scale),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8 * scale),
                border: Border.all(color: Colors.red.withOpacity(0.5)),
              ),
              child: Text(
                state.errorMessage!,
                style: TextStyle(
                  color: Colors.red,
                  fontSize: (isTablet ? 18 : 14) * scale,
                ),
              ),
            ).animate().shake(),
          
          SizedBox(height: 24 * scale),
          
          SizedBox(
            width: double.infinity,
            height: (isTablet ? 64 : 56) * scale,
            child: ElevatedButton(
              onPressed: (state.connectionStatus == ConnectionStatus.connecting ||
                         state.connectionStatus == ConnectionStatus.reconnecting)
                  ? null
                  : () {
                      if (ipController.text.isNotEmpty) {
                        context.read<SlideControllerBloc>().add(
                              ConnectToServer(ipController.text),
                            );
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12 * scale),
                ),
              ),
              child: (state.connectionStatus == ConnectionStatus.connecting ||
                      state.connectionStatus == ConnectionStatus.reconnecting)
                  ? SizedBox(
                      height: 24 * scale,
                      width: 24 * scale,
                      child: const CircularProgressIndicator(color: Colors.white),
                    )
                  : Text(
                      'Connect',
                      style: TextStyle(
                        fontSize: (isTablet ? 22 : 18) * scale,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ).animate().slideY(delay: 600.ms),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context, SlideControllerState state) {
    if (state.connectionStatus != ConnectionStatus.connected) {
      return const SizedBox.shrink();
    }

    final scale = state.settings.uiScale;

    return Container(
      padding: EdgeInsets.all(16 * scale),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildFooterButton(
            context,
            state,
            state.isPresenting ? Icons.stop : Icons.play_arrow,
            state.isPresenting ? 'End' : 'Start',
            () {
              if (state.isPresenting) {
                context.read<SlideControllerBloc>().add(EndPresentation());
              } else {
                context.read<SlideControllerBloc>().add(StartPresentation());
              }
            },
          ),
          // Add timer controls if presentation is active
          if (state.isPresenting && state.settings.showTimer) ...[
            _buildFooterButton(
              context,
              state,
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
            _buildFooterButton(
              context,
              state,
              Icons.refresh,
              'Reset',
              () {
                context.read<SlideControllerBloc>().add(ResetTimer());
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFooterButton(
    BuildContext context,
    SlideControllerState state,
    IconData icon,
    String label,
    VoidCallback onPressed,
  ) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    final scale = state.settings.uiScale;
    
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(
        icon,
        size: (isTablet ? 20 : 16) * scale,
      ),
      label: Text(
        label,
        style: TextStyle(
          fontSize: (isTablet ? 18 : 14) * scale,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(
          horizontal: (isTablet ? 32 : 24) * scale,
          vertical: (isTablet ? 16 : 12) * scale,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20 * scale),
        ),
      ),
    );
  }

  IconData _getConnectionIcon(ConnectionStatus status) {
    switch (status) {
      case ConnectionStatus.connected:
        return Icons.wifi;
      case ConnectionStatus.connecting:
        return Icons.wifi_find;
      case ConnectionStatus.reconnecting:
        return Icons.wifi_find;
      case ConnectionStatus.error:
        return Icons.wifi_off;
      case ConnectionStatus.disconnected:
        return Icons.wifi_off;
    }
  }

  Color _getConnectionColor(ConnectionStatus status) {
    switch (status) {
      case ConnectionStatus.connected:
        return Colors.green;
      case ConnectionStatus.connecting:
        return Colors.orange;
      case ConnectionStatus.reconnecting:
        return Colors.yellow;
      case ConnectionStatus.error:
        return Colors.red;
      case ConnectionStatus.disconnected:
        return Colors.grey;
    }
  }

  String _getStatusText(SlideControllerState state) {
    switch (state.connectionStatus) {
      case ConnectionStatus.connected:
        return 'Connected to ${state.serverIp}';
      case ConnectionStatus.connecting:
        return 'Connecting...';
      case ConnectionStatus.reconnecting:
        return 'Reconnecting... (${state.reconnectAttempt}/3)';
      case ConnectionStatus.error:
        return 'Connection failed';
      case ConnectionStatus.disconnected:
        return 'Not connected';
    }
  }

  void _openQRScanner(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: context.read<SlideControllerBloc>(),
          child: const QRScannerScreen(),
        ),
      ),
    );
  }
}
