import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/slide_controller_bloc.dart';
import '../bloc/slide_controller_event.dart';
import '../models/slide_controller_state.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final TextEditingController _qrInputController = TextEditingController();
  String? result;
  bool isScanning = true;

  @override
  void dispose() {
    _qrInputController.dispose();
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
              'QR Code Input',
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
                onPressed: () => _pasteFromClipboard(),
                icon: Icon(
                  Icons.paste,
                  size: (isTablet ? 32 : 24) * scale,
                ),
                tooltip: 'Paste from Clipboard',
              ),
            ],
          ),
          body: Padding(
            padding: EdgeInsets.all(16 * scale),
            child: Column(
              children: [
                // QR Scanner icon and instructions
                Container(
                  padding: EdgeInsets.all(24 * scale),
                  decoration: BoxDecoration(
                    color: state.settings.isDarkMode 
                        ? Colors.white.withOpacity(0.1)
                        : Colors.black.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20 * scale),
                    border: Border.all(
                      color: state.settings.isDarkMode 
                          ? Colors.white.withOpacity(0.2)
                          : Colors.black.withOpacity(0.2),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.qr_code_2,
                        size: (isTablet ? 96 : 64) * scale,
                        color: state.settings.isDarkMode 
                            ? Colors.white.withOpacity(0.8)
                            : Colors.black.withOpacity(0.8),
                      ),
                      SizedBox(height: 16 * scale),
                      Text(
                        'Enter QR Code Content',
                        style: TextStyle(
                          fontSize: (isTablet ? 24 : 20) * scale,
                          fontWeight: FontWeight.bold,
                          color: state.settings.isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8 * scale),
                      Text(
                        'Paste or type the QR code content containing your computer\'s IP address',
                        style: TextStyle(
                          fontSize: (isTablet ? 16 : 14) * scale,
                          color: state.settings.isDarkMode 
                              ? Colors.white.withOpacity(0.7)
                              : Colors.black.withOpacity(0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: 32 * scale),
                
                // QR Content Input
                TextField(
                  controller: _qrInputController,
                  style: TextStyle(
                    color: state.settings.isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
                    fontSize: (isTablet ? 18 : 16) * scale,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Paste QR content here (e.g., 192.168.1.100 or http://192.168.1.100)',
                    hintStyle: TextStyle(
                      color: state.settings.isDarkMode 
                          ? Colors.white.withOpacity(0.5)
                          : Colors.black.withOpacity(0.5),
                      fontSize: (isTablet ? 16 : 14) * scale,
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
                    prefixIcon: Icon(
                      Icons.qr_code_scanner,
                      color: state.settings.isDarkMode 
                          ? Colors.white.withOpacity(0.7)
                          : Colors.black.withOpacity(0.7),
                      size: (isTablet ? 28 : 24) * scale,
                    ),
                  ),
                  maxLines: 3,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (value) => _processQRResult(value),
                ),
                
                SizedBox(height: 24 * scale),
                
                // Process Button
                SizedBox(
                  width: double.infinity,
                  height: (isTablet ? 56 : 48) * scale,
                  child: ElevatedButton.icon(
                    onPressed: () => _processQRResult(_qrInputController.text),
                    icon: Icon(
                      Icons.search,
                      size: (isTablet ? 24 : 20) * scale,
                    ),
                    label: Text(
                      'Process QR Content',
                      style: TextStyle(
                        fontSize: (isTablet ? 18 : 16) * scale,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12 * scale),
                      ),
                    ),
                  ),
                ),
                
                SizedBox(height: 24 * scale),
                
                // Result display
                if (result != null) ...[
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16 * scale),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      border: Border.all(color: Colors.green),
                      borderRadius: BorderRadius.circular(12 * scale),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: (isTablet ? 32 : 24) * scale,
                        ),
                        SizedBox(height: 8 * scale),
                        Text(
                          'Found IP Address:',
                          style: TextStyle(
                            fontSize: (isTablet ? 16 : 14) * scale,
                            color: Colors.green.shade700,
                          ),
                        ),
                        SizedBox(height: 4 * scale),
                        Text(
                          result!,
                          style: TextStyle(
                            fontSize: (isTablet ? 20 : 18) * scale,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 24 * scale),
                  
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _resetScanner(),
                          icon: Icon(
                            Icons.refresh,
                            size: (isTablet ? 20 : 16) * scale,
                          ),
                          label: Text(
                            'Try Again',
                            style: TextStyle(
                              fontSize: (isTablet ? 16 : 14) * scale,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade600,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              vertical: (isTablet ? 12 : 8) * scale,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 16 * scale),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _connectToIP(result!),
                          icon: Icon(
                            Icons.wifi,
                            size: (isTablet ? 20 : 16) * scale,
                          ),
                          label: Text(
                            'Connect',
                            style: TextStyle(
                              fontSize: (isTablet ? 16 : 14) * scale,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade600,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              vertical: (isTablet ? 12 : 8) * scale,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ] else if (!isScanning) ...[
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16 * scale),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      border: Border.all(color: Colors.orange),
                      borderRadius: BorderRadius.circular(12 * scale),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.warning,
                          color: Colors.orange,
                          size: (isTablet ? 32 : 24) * scale,
                        ),
                        SizedBox(height: 8 * scale),
                        Text(
                          'No valid IP address found',
                          style: TextStyle(
                            fontSize: (isTablet ? 16 : 14) * scale,
                            color: Colors.orange,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 8 * scale),
                        Text(
                          'Please check the QR content and try again',
                          style: TextStyle(
                            fontSize: (isTablet ? 14 : 12) * scale,
                            color: Colors.orange.shade700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 16 * scale),
                  
                  ElevatedButton.icon(
                    onPressed: () => _resetScanner(),
                    icon: Icon(
                      Icons.refresh,
                      size: (isTablet ? 20 : 16) * scale,
                    ),
                    label: Text(
                      'Try Again',
                      style: TextStyle(
                        fontSize: (isTablet ? 16 : 14) * scale,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
                
                const Spacer(),
                
                // Help text
                Container(
                  padding: EdgeInsets.all(16 * scale),
                  decoration: BoxDecoration(
                    color: state.settings.isDarkMode 
                        ? Colors.blue.withOpacity(0.1)
                        : Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12 * scale),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.blue,
                        size: (isTablet ? 24 : 20) * scale,
                      ),
                      SizedBox(height: 8 * scale),
                      Text(
                        'QR Code Examples:',
                        style: TextStyle(
                          fontSize: (isTablet ? 16 : 14) * scale,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                      SizedBox(height: 4 * scale),
                      Text(
                        '• 192.168.1.100\n• http://192.168.1.100:8000\n• http://localhost:3000',
                        style: TextStyle(
                          fontSize: (isTablet ? 14 : 12) * scale,
                          color: state.settings.isDarkMode 
                              ? Colors.white.withOpacity(0.7)
                              : Colors.black.withOpacity(0.7),
                          fontFamily: 'monospace',
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pasteFromClipboard() async {
    try {
      final clipboardData = await Clipboard.getData('text/plain');
      if (clipboardData != null && clipboardData.text != null) {
        _qrInputController.text = clipboardData.text!;
        _processQRResult(clipboardData.text!);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to paste from clipboard'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _processQRResult(String code) {
    if (code.trim().isEmpty) {
      setState(() {
        isScanning = false;
      });
      return;
    }

    // Validate if the scanned code looks like an IP address
    if (_isValidIP(code.trim())) {
      setState(() {
        result = code.trim();
        isScanning = false;
      });
    } else {
      // Try to extract IP from URL or other formats
      String? extractedIP = _extractIPFromString(code);
      if (extractedIP != null) {
        setState(() {
          result = extractedIP;
          isScanning = false;
        });
      } else {
        setState(() {
          isScanning = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No valid IP address found in: ${code.length > 50 ? '${code.substring(0, 50)}...' : code}'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  bool _isValidIP(String ip) {
    // Basic IP validation regex
    final ipRegex = RegExp(
      r'^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$'
    );
    return ipRegex.hasMatch(ip.trim());
  }

  String? _extractIPFromString(String input) {
    // Try to extract IP from various formats like URLs, JSON, etc.
    final ipRegex = RegExp(
      r'(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)'
    );
    final match = ipRegex.firstMatch(input);
    return match?.group(0);
  }

  void _connectToIP(String ip) {
    // Connect to the scanned IP
    context.read<SlideControllerBloc>().add(ConnectToServer(ip));
    
    // Show success message and go back
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Connecting to $ip...'),
        backgroundColor: Colors.green,
      ),
    );
    
    // Go back to the main screen
    Navigator.pop(context);
  }

  void _resetScanner() {
    setState(() {
      result = null;
      isScanning = true;
    });
    _qrInputController.clear();
  }
}
