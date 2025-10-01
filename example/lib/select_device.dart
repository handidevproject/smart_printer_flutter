import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:smart_printer_flutter/smart_printer_flutter.dart';

class SelectDevice extends StatefulWidget {

  const SelectDevice({super.key, required this.plugin});

  final SmartPrinterFlutter plugin;

  @override
  State<SelectDevice> createState() => _SelectDeviceState();
}

class _SelectDeviceState extends State<SelectDevice> {


  @override
  void initState() {
    requestBluetoothPermissions().then((_) {
      debugPrint("Bluetooth permissions granted");
      widget.plugin.startScan();
      widget.plugin.statusStream.listen((value) {
        if (kDebugMode) {
          print(">>> status: ${value.status.name}");
        }
      });
    }).catchError((error) {
      Navigator.pop(context);
    });
    super.initState();
  }

  @override
  void dispose() {
    widget.plugin.stopScan();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Device Bluetooth"),
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  widget.plugin.startScan();
                },
                child: const Text("Start Scan"),
              ),
              ElevatedButton(
                onPressed: () {
                  widget.plugin.stopScan();
                },
                child: const Text("Stop Scan"),
              ),
            ],
          ),
          StreamBuilder(
            stream: widget.plugin.isScanningStream,
            builder: (context, snapshot) {
              if (snapshot.data == true) {
                return const LinearProgressIndicator();
              }
              return Container();
            },
          ),
          Expanded(
            child: StreamBuilder<List<Peripheral>>(
              stream: widget.plugin.peripheralsStream,
              builder: (context, snapshot) {
                if (snapshot.data?.isNotEmpty != true) {
                  return Container();
                }
                final peripherals = snapshot.data!;
                return ListView.builder(
                  itemBuilder: (context, index) {
                    final peripheral = peripherals[index];
                    return ListTile(
                      title: Text(peripheral.name ?? ''),
                      subtitle: Text(peripheral.uuid ?? ''),
                      onTap: () {
                        print('uuid: ${peripheral.uuid}');
                        print('state: ${peripheral.state}');
                        if (peripheral.uuid == null ||
                            peripheral.state == PeripheralState.connected) {
                          return;
                        }
                        widget.plugin.connectBluetooth(peripheral.uuid!);
                      },
                    );
                  },
                  itemCount: peripherals.length,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
