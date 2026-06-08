import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../bloc/slide_controller_bloc.dart';
import '../bloc/slide_controller_event.dart';
import '../services/bluetooth_slide_controller_service.dart';

class BluetoothScannerScreen extends StatefulWidget {
  const BluetoothScannerScreen({super.key});

  @override
  State<BluetoothScannerScreen> createState() => _BluetoothScannerScreenState();
}

class _BluetoothScannerScreenState extends State<BluetoothScannerScreen> {
  StreamSubscription<List<ScanResult>>? _scanSubscription;
  StreamSubscription<bool>? _scanStateSubscription;
  final List<ScanResult> _results = [];
  bool _isScanning = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _startScan();
  }

  @override
  void dispose() {
    _scanSubscription?.cancel();
    _scanStateSubscription?.cancel();
    FlutterBluePlus.stopScan();
    super.dispose();
  }

  Future<void> _startScan() async {
    try {
      await FlutterBluePlus.stopScan();
      _scanSubscription?.cancel();
      _scanStateSubscription?.cancel();

      setState(() {
        _results.clear();
        _errorMessage = null;
        _isScanning = true;
      });

      _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
        final filtered = results
            .where((result) => result.advertisementData.serviceUuids.any(
                  (uuid) => uuid.str128.toLowerCase() == BluetoothSlideControllerService.serviceUuid,
                ))
            .toList();

        if (!mounted) return;
        setState(() {
          _results
            ..clear()
            ..addAll(filtered);
        });
      });

      _scanStateSubscription = FlutterBluePlus.isScanning.listen((scanning) {
        if (!mounted) return;
        setState(() {
          _isScanning = scanning;
        });
      });

      await FlutterBluePlus.startScan(
        withServices: [Guid(BluetoothSlideControllerService.serviceUuid)],
        timeout: const Duration(seconds: 12),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isScanning = false;
        _errorMessage = 'Bluetooth scan failed: $e';
      });
    }
  }

  Future<void> _connect(BluetoothDevice device) async {
    if (!mounted) return;

    context.read<SlideControllerBloc>().add(ConnectToBluetoothDevice(device));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Connecting over Bluetooth...'),
        backgroundColor: Colors.blue,
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bluetooth Connection'),
        actions: [
          IconButton(
            onPressed: _isScanning ? null : _startScan,
            icon: const Icon(Icons.refresh),
            tooltip: 'Rescan',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (_errorMessage != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                color: Colors.red.withOpacity(0.12),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(color: Colors.red.shade700),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: _isScanning
                        ? const CircularProgressIndicator(strokeWidth: 2)
                        : const Icon(Icons.bluetooth_searching),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Look for the desktop app advertising the Slide Controller BLE service.',
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _results.isEmpty
                  ? const Center(child: Text('No Bluetooth devices found yet.'))
                  : ListView.builder(
                      itemCount: _results.length,
                      itemBuilder: (context, index) {
                        final result = _results[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: ListTile(
                            leading: const Icon(Icons.desktop_windows),
                            title: Text(
                              result.device.platformName.isNotEmpty
                                  ? result.device.platformName
                                  : 'Slide Controller Device',
                            ),
                            subtitle: Text(result.device.remoteId.str),
                            trailing: ElevatedButton(
                              onPressed: () => _connect(result.device),
                              child: const Text('Connect'),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
