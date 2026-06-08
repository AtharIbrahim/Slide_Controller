import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:web_socket_channel/io.dart';

class BleCommandBridge {
  static const String serviceUuid = '6b39b4f0-5b34-4bb9-8a2e-3c6c2ecf9101';
  static const String commandCharacteristicUuid = '6b39b4f0-5b34-4bb9-8a2e-3c6c2ecf9102';

  bool _initialized = false;
  bool _advertising = false;

  bool get isAdvertising => _advertising;

  Future<void> initializeAndAdvertise() async {
    if (_initialized) {
      return;
    }

    _initialized = true;
    _advertising = false;

    throw UnsupportedError('Bluetooth peripheral mode is not available in this Windows build.');
  }

  Future<void> _forwardCommandToLocalServer(Uint8List? value) async {
    if (value == null || value.isEmpty) {
      return;
    }

    final payloadText = utf8.decode(value);

    Map<String, dynamic> message;
    try {
      message = jsonDecode(payloadText) as Map<String, dynamic>;
    } catch (_) {
      message = <String, dynamic>{'command': payloadText};
    }

    final channel = IOWebSocketChannel.connect(Uri.parse('ws://127.0.0.1:8080'));
    await channel.ready;
    channel.sink.add(jsonEncode(message));
    await Future<void>.delayed(const Duration(milliseconds: 50));
    await channel.sink.close();
  }

  Future<void> dispose() async {
    _advertising = false;
    _initialized = false;
  }
}
