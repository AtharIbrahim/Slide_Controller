import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'bloc/server_bloc.dart';
import 'bloc/server_event.dart';
import 'bloc/server_state.dart';
import 'widgets/responsive_widget.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(1920, 1080), // Desktop-first design size
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return BlocProvider(
          create: (context) => ServerBloc()..add(InitializeServer()),
          child: MaterialApp(
            title: 'Slide Controller Server',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF6366F1),
                brightness: Brightness.light,
              ),
              useMaterial3: true,
              appBarTheme: const AppBarTheme(
                centerTitle: true,
                elevation: 0,
              ),
            ),
            debugShowCheckedModeBanner: false,
            home: const MyHomePage(title: 'Slide Controller Server'),
          ),
        );
      },
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: ResponsiveWidget(
          mobile: _buildMobileTitle(context),
          desktop: _buildDesktopTitle(context),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
      ),
      body: BlocBuilder<ServerBloc, ServerState>(
        builder: (context, state) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(ResponsiveHelper.getResponsivePadding(context)),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: ResponsiveHelper.getMaxWidth(context),
                ),
                child: ResponsiveWidget(
                  mobile: _buildMobileLayout(context, state),
                  desktop: _buildDesktopLayout(context, state),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMobileTitle(BuildContext context) {
    return Column(
      children: [
        Icon(Icons.slideshow, color: Theme.of(context).colorScheme.primary, size: 24),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildDesktopTitle(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.slideshow, color: Theme.of(context).colorScheme.primary, size: 28),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context, ServerState state) {
    return Column(
      children: [
        _buildStatusCard(context, state),
        const SizedBox(height: 16),
        _buildIPCard(context, state),
        const SizedBox(height: 24),
        _buildControlButtons(context, state),
        const SizedBox(height: 24),
        _buildFooter(context),
      ],
    );
  }

  Widget _buildDesktopLayout(BuildContext context, ServerState state) {
    return Column(
      children: [
        // Top row with status and IP cards
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 2, child: _buildStatusCard(context, state)),
            const SizedBox(width: 24),
            Expanded(flex: 2, child: _buildIPCard(context, state)),
            const SizedBox(width: 24),
            Expanded(flex: 1, child: _buildQRCard(context, state)),
          ],
        ),
        const SizedBox(height: 32),
        // Control buttons row
        _buildControlButtons(context, state),
        const SizedBox(height: 32),
        _buildFooter(context),
      ],
    );
  }

  Widget _buildStatusCard(BuildContext context, ServerState state) {
    Color statusColor;
    IconData statusIcon;
    
    if (state.isLoading) {
      statusColor = Colors.orange;
      statusIcon = Icons.hourglass_empty;
    } else if (state.serverRunning) {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
    } else {
      statusColor = Colors.red;
      statusIcon = Icons.error;
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(ResponsiveHelper.isMobile(context) ? 16 : 24),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  statusIcon,
                  color: statusColor,
                  size: ResponsiveHelper.isMobile(context) ? 24 : 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Server Status',
                    style: TextStyle(
                      fontSize: ResponsiveHelper.isMobile(context) ? 18 : 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: statusColor.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  if (state.isLoading)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    Icon(statusIcon, color: statusColor, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      state.statusMessage,
                      style: TextStyle(
                        fontSize: ResponsiveHelper.isMobile(context) ? 14 : 16,
                        color: statusColor.withOpacity(0.8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIPCard(BuildContext context, ServerState state) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(ResponsiveHelper.isMobile(context) ? 16 : 24),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  Icons.wifi,
                  color: Theme.of(context).colorScheme.primary,
                  size: ResponsiveHelper.isMobile(context) ? 24 : 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Network Information',
                    style: TextStyle(
                      fontSize: ResponsiveHelper.isMobile(context) ? 18 : 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.computer,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'IP Address:',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          state.ipAddress,
                          style: TextStyle(
                            fontSize: ResponsiveHelper.isMobile(context) ? 16 : 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: state.ipAddress));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              const Icon(Icons.check, color: Colors.white),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text('IP Address "${state.ipAddress}" copied to clipboard!'),
                              ),
                            ],
                          ),
                          backgroundColor: Colors.green,
                          duration: const Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    icon: const Icon(Icons.copy),
                    tooltip: 'Copy IP Address',
                  ),
                ],
              ),
            ),
            // Add QR code for mobile layout
            if (ResponsiveHelper.isMobile(context)) ...[
              const SizedBox(height: 16),
              _buildQRSection(context, state),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQRCard(BuildContext context, ServerState state) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  Icons.qr_code,
                  color: Theme.of(context).colorScheme.primary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'QR Code',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildQRSection(context, state),
          ],
        ),
      ),
    );
  }

  Widget _buildQRSection(BuildContext context, ServerState state) {
    if (state.ipAddress == 'Fetching IP...' || state.ipAddress == 'Error' || state.ipAddress == 'Not found') {
      return Container(
        height: ResponsiveHelper.isMobile(context) ? 150 : 200,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.wifi_off, size: 48, color: Colors.grey),
              SizedBox(height: 8),
              Text(
                'No IP Address',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    final qrSize = ResponsiveHelper.isMobile(context) ? 150.0 : 200.0;
    final serverUrl = 'http://${state.ipAddress}:5000';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          QrImageView(
            data: serverUrl,
            version: QrVersions.auto,
            size: qrSize,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            errorCorrectionLevel: QrErrorCorrectLevel.M,
          ),
          const SizedBox(height: 12),
          Text(
            'Scan to connect',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            serverUrl,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.grey,
              fontFamily: 'monospace',
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildControlButtons(BuildContext context, ServerState state) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: ResponsiveHelper.isMobile(context) ? 48 : 56,
          child: ElevatedButton.icon(
            onPressed: state.isLoading ? null : () {
              context.read<ServerBloc>().add(StartServer());
            },
            icon: state.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.play_arrow),
            label: Text(
              state.isLoading ? 'Processing...' : 'Start Server',
              style: TextStyle(
                fontSize: ResponsiveHelper.isMobile(context) ? 14 : 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        ResponsiveWidget(
          mobile: Column(
            children: [
              SizedBox(
                width: double.infinity,
                height: 44,
                child: OutlinedButton.icon(
                  onPressed: () => context.read<ServerBloc>().add(GetIpAddress()),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh IP'),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: OutlinedButton.icon(
                  onPressed: () => context.read<ServerBloc>().add(RestartServer()),
                  icon: const Icon(Icons.restart_alt),
                  label: const Text('Restart'),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
          desktop: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: () => context.read<ServerBloc>().add(GetIpAddress()),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh IP'),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: () => context.read<ServerBloc>().add(RestartServer()),
                    icon: const Icon(Icons.restart_alt),
                    label: const Text('Restart'),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(
            Icons.info_outline,
            color: Colors.grey[600],
            size: 20,
          ),
          const SizedBox(height: 8),
          Text(
            'Slide Controller Server v1.0\nManage your presentation server with ease',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: ResponsiveHelper.isMobile(context) ? 12 : 14,
            ),
          ),
        ],
      ),
    );
  }
}
