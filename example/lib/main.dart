import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:smart_printer_flutter/smart_printer_flutter.dart';
import 'package:smart_printer_flutter_example/screens/pos_printer_screen.dart';
import 'package:smart_printer_flutter_example/screens/tspl_printer_screen.dart';
import 'select_device.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _plugin = SmartPrinterFlutter();

  final TextEditingController _ipController =
  TextEditingController(text: "192.168.1.10");

  final List<String> _modes = ["NET", "BT"];

  String _selectedMode = "NET";

  @override
  void initState() {
    super.initState();
  }

  void _connect() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Connected via $_selectedMode")),
    );
  }

  void _disconnect() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Disconnected")),
    );
  }

  Future<void> requestBluetoothPermissions() async {
    if (!Platform.isAndroid) return;

    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;
    final sdkInt = androidInfo.version.sdkInt;

    if (sdkInt >= 31) {
      final statusScan = await Permission.bluetoothScan.status;
      final statusConnect = await Permission.bluetoothConnect.status;

      if (!statusScan.isGranted) {
        await Permission.bluetoothScan.request();
      }

      if (!statusConnect.isGranted) {
        await Permission.bluetoothConnect.request();
      }
    } else {
      // Untuk Android < 12, Bluetooth permission biasa bisa diminta jika perlu
      final bluetooth = await Permission.bluetooth.status;
      if (!bluetooth.isGranted) {
        await Permission.bluetooth.request();
      }
    }
  }

  Widget _buildInputField() {
    switch (_selectedMode) {
      case "NET":
        return Expanded(
          child: TextField(
            controller: _ipController,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.green,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: BorderSide.none,
              ),
            ),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      default:
        return Expanded(
          child: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
            color: Colors.green,
            child: const Text(
              "please select device",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        );;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Smart Printer Flutter - Demo'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              // Dropdown + Field
              Row(
                children: [
                  DropdownButton<String>(
                    value: _selectedMode,
                    dropdownColor: Colors.green,
                    style: const TextStyle(color: Colors.green),
                    itemHeight: 70,
                    items: _modes
                        .map(
                          (mode) => DropdownMenuItem(
                        value: mode,
                        child: Text(
                          mode,
                          style: const TextStyle(color: Colors.black),
                        ),
                      ),
                    )
                        .toList(),
                    onChanged: (value) {
                      setState(() => _selectedMode = value!);
                      if (_selectedMode == "BT") {
                        requestBluetoothPermissions().then((_) {
                          debugPrint("Bluetooth permissions granted");
                        });
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  _buildInputField(),
                ],
              ),

              const SizedBox(height: 36),

              // StreamBuilder untuk listen status koneksi
              StreamBuilder<PrinterStatus>(
                stream: _plugin.statusStream,
                initialData: PrinterStatus(statusInt: 2),
                builder: (context, snapshot) {
                  final status = snapshot.data ?? PrinterStatus(statusInt: 2);
                  final isConnected = status.status == PeripheralStatus.connected;
                  final uuid = status.uuid ?? "-";
                  return Column(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          if (isConnected) {
                            if (_selectedMode == "NET") {
                              _plugin.connectEthernet(_ipController.text);
                            } else {
                              _plugin.connectBluetooth(uuid);
                            }
                          }
                        } ,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: const Text(
                          "CONNECT",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700),
                        ),
                      ),

                      const SizedBox(height: 8),

                      ElevatedButton(
                        onPressed: isConnected ? _plugin.disconnect : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                          isConnected ? Colors.green : Colors.grey,
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: const Text(
                          "DISCONNECT",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700),
                        ),
                      ),

                      const SizedBox(height: 8),

                      ElevatedButton(
                        onPressed: isConnected
                            ? () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (context) =>
                                PosPrinterScreen(plugin: _plugin,)),
                          );
                        } : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                          isConnected ? Colors.green : Colors.grey,
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: const Text(
                          "START POS PRINTER",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700),
                        ),
                      ),

                      const SizedBox(height: 8),


                      ElevatedButton(
                        onPressed: isConnected
                            ? () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (context) =>
                                    TsplScreen(plugin: _plugin,)),
                          );
                        } : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                          isConnected ? Colors.green : Colors.grey,
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: const Text(
                          "START TSPL PRINTER",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700),
                        ),
                      ),

                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
