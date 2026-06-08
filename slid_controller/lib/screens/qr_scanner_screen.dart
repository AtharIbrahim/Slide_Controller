import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../bloc/slide_controller_bloc.dart';
import '../bloc/slide_controller_event.dart';
import '../models/slide_controller_state.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final MobileScannerController _scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );
  final TextEditingController _manualInputController = TextEditingController();

  String? _detectedIp;
  bool _isConnecting = false;

  @override
  void dispose() {
    _scannerController.dispose();
    _manualInputController.dispose();
    super.dispose();
  }

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
              'Scan Connection QR',
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
            actions: [
              IconButton(
                onPressed: _pasteFromClipboard,
                icon: Icon(Icons.paste, size: (isTablet ? 32 : 24) * scale),
                tooltip: 'Paste connection data',
              ),
            ],
          ),
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.all(16 * scale),
              child: Column(
                children: [
                  Expanded(
                    flex: 5,
                    child: _buildScannerView(context, state, isTablet, scale),
                  ),
                  SizedBox(height: 16 * scale),
                  _buildManualFallback(context, state, isTablet, scale),
                  if (state.errorMessage != null) ...[
                    SizedBox(height: 12 * scale),
                    _buildErrorBanner(context, state, scale),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildScannerView(BuildContext context, SlideControllerState state, bool isTablet, double scale) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24 * scale),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24 * scale),
        child: Stack(
          fit: StackFit.expand,
          children: [
            MobileScanner(
              controller: _scannerController,
              onDetect: _onDetect,
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.55),
                    Colors.transparent,
                    Colors.black.withOpacity(0.55),
                  ],
                  stops: const [0.0, 0.35, 1.0],
                ),
              ),
            ),
            Center(
              child: Container(
                width: isTablet ? 320 * scale : 240 * scale,
                height: isTablet ? 320 * scale : 240 * scale,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24 * scale),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.95),
                    width: 2,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 20 * scale,
              right: 20 * scale,
              top: 20 * scale,
              child: _buildInstructionCard(context, state, scale),
            ),
            Positioned(
              left: 20 * scale,
              right: 20 * scale,
              bottom: 20 * scale,
              child: _buildScanStatusCard(context, state, scale),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionCard(BuildContext context, SlideControllerState state, double scale) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 14 * scale),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.55),
        borderRadius: BorderRadius.circular(18 * scale),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Icon(Icons.qr_code_scanner, color: Colors.white, size: 24 * scale),
          SizedBox(width: 12 * scale),
          Expanded(
            child: Text(
              'Point the camera at the QR code on your desktop app. It will connect automatically.',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14 * scale,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanStatusCard(BuildContext context, SlideControllerState state, double scale) {
    final label = _detectedIp == null
        ? 'Scanning for desktop QR code...'
        : _isConnecting
            ? 'Connecting to $_detectedIp...'
            : 'Found $_detectedIp';

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 12 * scale),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.65),
        borderRadius: BorderRadius.circular(18 * scale),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 18 * scale,
            height: 18 * scale,
            child: _isConnecting
                ? const CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
                : Icon(
                    _detectedIp == null ? Icons.visibility : Icons.wifi,
                    color: Colors.white,
                    size: 18 * scale,
                  ),
          ),
          SizedBox(width: 12 * scale),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 13 * scale,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManualFallback(BuildContext context, SlideControllerState state, bool isTablet, double scale) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16 * scale),
      decoration: BoxDecoration(
        color: state.settings.isDarkMode ? Colors.white.withOpacity(0.08) : Colors.white,
        borderRadius: BorderRadius.circular(20 * scale),
        border: Border.all(
          color: state.settings.isDarkMode ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.06),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Manual fallback',
            style: TextStyle(
              fontSize: (isTablet ? 18 : 16) * scale,
              fontWeight: FontWeight.bold,
              color: state.settings.isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
            ),
          ),
          SizedBox(height: 8 * scale),
          TextField(
            controller: _manualInputController,
            style: TextStyle(
              color: state.settings.isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
              fontSize: (isTablet ? 16 : 15) * scale,
            ),
            decoration: InputDecoration(
              hintText: 'Paste ws://192.168.1.100:8080 or just the IP address',
              filled: true,
              fillColor: state.settings.isDarkMode ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.04),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14 * scale),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.all(16 * scale),
              prefixIcon: const Icon(Icons.link),
            ),
            textInputAction: TextInputAction.done,
            onSubmitted: _processConnectionValue,
          ),
          SizedBox(height: 12 * scale),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pasteFromClipboard,
                  icon: const Icon(Icons.paste),
                  label: const Text('Paste'),
                ),
              ),
              SizedBox(width: 12 * scale),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _processConnectionValue(_manualInputController.text),
                  icon: const Icon(Icons.wifi),
                  label: const Text('Connect'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorBanner(BuildContext context, SlideControllerState state, double scale) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14 * scale),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16 * scale),
        border: Border.all(color: Colors.red.withOpacity(0.4)),
      ),
      child: Text(
        state.errorMessage!,
        style: TextStyle(
          color: Colors.red.shade700,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isConnecting || _detectedIp != null) {
      return;
    }

    for (final barcode in capture.barcodes) {
      final rawValue = barcode.rawValue;
      if (rawValue == null || rawValue.trim().isEmpty) {
        continue;
      }

      final ip = _extractConnectionIp(rawValue);
      if (ip != null) {
        setState(() {
          _detectedIp = ip;
          _isConnecting = true;
        });
        _scannerController.stop();
        _connectToIP(ip);
        return;
      }
    }
  }

  Future<void> _pasteFromClipboard() async {
    try {
      final clipboardData = await Clipboard.getData('text/plain');
      final text = clipboardData?.text?.trim();
      if (text == null || text.isEmpty) {
        return;
      }

      _manualInputController.text = text;
      _processConnectionValue(text);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to read clipboard'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _processConnectionValue(String value) {
    final ip = _extractConnectionIp(value);
    if (ip == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No valid connection target found in the scanned code'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _detectedIp = ip;
      _isConnecting = true;
    });
    _scannerController.stop();
    _connectToIP(ip);
  }

  String? _extractConnectionIp(String input) {
    final value = input.trim();
    if (value.isEmpty) {
      return null;
    }

    if (_isValidIp(value)) {
      return value;
    }

    final uri = Uri.tryParse(value);
    if (uri != null && uri.host.isNotEmpty) {
      return uri.host;
    }

    final ipRegex = RegExp(
      r'(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)',
    );
    final match = ipRegex.firstMatch(value);
    return match?.group(0);
  }

  bool _isValidIp(String ip) {
    final ipRegex = RegExp(
      r'^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$',
    );
    return ipRegex.hasMatch(ip);
  }

  void _connectToIP(String ip) {
    context.read<SlideControllerBloc>().add(ConnectToServer(ip));

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Connecting to $ip...'),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pop(context);
  }
}
