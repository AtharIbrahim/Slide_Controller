import 'dart:async';
import 'dart:convert';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../models/slide_command.dart';

class BluetoothSlideControllerService {
  static const String serviceUuid = '6b39b4f0-5b34-4bb9-8a2e-3c6c2ecf9101';
  static const String commandCharacteristicUuid = '6b39b4f0-5b34-4bb9-8a2e-3c6c2ecf9102';

  BluetoothDevice? _device;
  BluetoothCharacteristic? _commandCharacteristic;
  bool _isConnected = false;

  StreamSubscription<BluetoothConnectionState>? _connectionSubscription;

  final StreamController<bool> _connectionStateController = StreamController<bool>.broadcast();
  final StreamController<String> _errorController = StreamController<String>.broadcast();

  bool get isConnected => _isConnected;
  Stream<bool> get connectionStateStream => _connectionStateController.stream;
  Stream<String> get errorStream => _errorController.stream;

  Future<bool> connect(BluetoothDevice device) async {
    try {
      disconnect();

      _device = device;
      await device.connect(
        license: License.nonprofit,
        timeout: const Duration(seconds: 12),
        mtu: null,
      );

      final services = await device.discoverServices();
      _commandCharacteristic = _findCommandCharacteristic(services);

      if (_commandCharacteristic == null) {
        throw Exception('Bluetooth command characteristic not found on the desktop app.');
      }

      _connectionSubscription = device.connectionState.listen((state) {
        if (state == BluetoothConnectionState.disconnected) {
          _handleDisconnection();
        }
      });

      _isConnected = true;
      _connectionStateController.add(true);
      return true;
    } catch (e) {
      _errorController.add('Bluetooth connection failed: $e');
      disconnect();
      return false;
    }
  }

  Future<bool> sendCommand(SlideCommand command, {bool isHeartbeat = false}) async {
    return sendMessage({
      'command': command.value,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'heartbeat': isHeartbeat,
    });
  }

  Future<bool> sendMessage(Map<String, dynamic> message) async {
    if (!_isConnected || _commandCharacteristic == null) {
      return false;
    }

    try {
      final payload = utf8.encode(jsonEncode(message));
      await _commandCharacteristic!.write(
        payload,
        withoutResponse: _commandCharacteristic!.properties.writeWithoutResponse,
      );
      return true;
    } catch (e) {
      _errorController.add('Bluetooth send failed: $e');
      _handleDisconnection();
      return false;
    }
  }

  BluetoothCharacteristic? _findCommandCharacteristic(List<BluetoothService> services) {
    for (final service in services) {
      if (service.uuid.str128.toLowerCase() == serviceUuid) {
        for (final characteristic in service.characteristics) {
          if (characteristic.uuid.str128.toLowerCase() == commandCharacteristicUuid) {
            return characteristic;
          }
        }
      }
    }
    return null;
  }

  void _handleDisconnection() {
    if (_isConnected) {
      _isConnected = false;
      _connectionStateController.add(false);
      _errorController.add('Bluetooth connection lost');
    }
  }

  void disconnect() {
    _connectionSubscription?.cancel();
    _connectionSubscription = null;
    _device?.disconnect();
    _device = null;
    _commandCharacteristic = null;
    _isConnected = false;
    _connectionStateController.add(false);
  }

  void dispose() {
    _connectionSubscription?.cancel();
    _connectionStateController.close();
    _errorController.close();
    disconnect();
  }
}
