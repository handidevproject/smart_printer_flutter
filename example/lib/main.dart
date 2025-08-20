import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:smart_printer_flutter/smart_printer_flutter.dart';
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
  final contentController = TextEditingController();

  bool _isConnected = false;

  @override
  void initState() {
    super.initState();

    requestBluetoothPermissions().then((_) {
      print("Bluetooth permissions granted");
      WidgetsBinding.instance.addPostFrameCallback(
        (_) {
          _getCurrentState();
        },
      );

      _plugin.statusStream.listen((event) {
        print(">>> status: ${event.status.name}");
        _getCurrentState();
      });
    }).catchError((error) {
      print("Error requesting Bluetooth permissions: $error");
    });
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

  void _getCurrentState() {
    _plugin.isConnected.then((value) {
      print(">>> isConnected: $value");
      setState(() {
        _isConnected = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('XPrinter Plugin Example'),
        ),
        body: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: StreamBuilder<PrinterStatus>(
                    stream: _plugin.statusStream,
                    builder: (context, snapshot) {
                      if (snapshot.data == null) {
                        return Column(
                          children: [
                            _isConnected
                                ? const Text('connected')
                                : const Text('disconnected'),
                            if (_isConnected) _buildDisconnectButton(),
                          ],
                        );
                      }
                      return Column(
                        children: [
                          Text('${snapshot.data?.status.name}'),
                          if (snapshot.data?.status ==
                              PeripheralStatus.connected)
                            _buildDisconnectButton(),
                        ],
                      );
                    },
                  ),
                ),
                Expanded(
                  child: Builder(builder: (context) {
                    return TextButton(
                      onPressed: () {
                        Navigator.of(context)
                            .push(MaterialPageRoute(builder: (context) {
                          return SelectDevice(plugin: _plugin);
                        }));
                      },
                      child: const Text('Select Device'),
                    );
                  }),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: TextFormField(
                controller: contentController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Content',
                ),
                minLines: 2,
                maxLines: 5,
              ),
            ),
            Expanded(child: Container()),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: _printText,
                    child: const Text('Print Text'),
                  ),
                ),
                Expanded(
                  child: TextButton(
                    onPressed: _selectImage,
                    child: const Text('Print Image'),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: _cutPaper,
                    child: const Text('Cut Paper'),
                  ),
                ),
                Expanded(
                  child: TextButton(
                    onPressed: _printExample,
                    child: const Text('Print Example'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  TextButton _buildDisconnectButton() {
    return TextButton(
      onPressed: () {
        _plugin.disconnect();
      },
      child: const Text('Disconnect'),
    );
  }

  void _printText() {
    _plugin.posPrintText(contentController.text);
  }

  void _cutPaper() {
    _plugin.cutPaper();
  }

  void _printExample() {
    _plugin.posPrintText('=======================================');
    _plugin.posPrintText("Left");
    _plugin.posPrintText(
      "Center",
      align: PTextAlign.center,
    );
    _plugin.posPrintText(
      "Right",
      align: PTextAlign.right,
    );

    _plugin.posPrintText('=======================================');
    _plugin.posPrintText("FontB", attribute: PTextAttribute.fontB);
    _plugin.posPrintText("Bold", attribute: PTextAttribute.bold);
    _plugin.posPrintText(
      "Underline",
      attribute: PTextAttribute.underline,
    );
    _plugin.posPrintText(
      "Underline2",
      attribute: PTextAttribute.underline2,
    );
    _plugin.posPrintText('=======================================');
    _plugin.posPrintText(
      "W1",
      width: PTextW.w2,
      height: PTextH.h2,
    );
    _plugin.posPrintText(
      "W2",
      width: PTextW.w2,
      height: PTextH.h2,
    );
    _plugin.posPrintText(
      "W3",
      width: PTextW.w3,
      height: PTextH.h3,
    );
    _plugin.posPrintText(
      "W4",
      width: PTextW.w4,
      height: PTextH.h4,
    );

    _plugin.cutPaper();
  }

  void _selectImage() async {
    final ImagePicker picker = ImagePicker();

    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      _printImage(image);
    }
  }

  void _printImage(XFile file) async {
    final img.Image? image = img.decodeImage(await file.readAsBytes());

    if (image != null) {
      final img.Image resizedImage = img.copyResize(image, width: 460);

      final List<int> compressedImage = img.encodePng(resizedImage);

      final String base64Image = base64Encode(compressedImage);

      _plugin.posPrintImage(base64Image, 460.0);
      _plugin.cutPaper();
    } else {
      print('Failed to decode image');
    }
  }
}
