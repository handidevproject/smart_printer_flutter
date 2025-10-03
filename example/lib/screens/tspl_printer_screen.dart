import 'package:flutter/material.dart';
import 'package:smart_printer_flutter/smart_printer_flutter.dart';

///
/// Created by Handy on 01/10/25
/// Macbook Air M2 - 2022
/// it.handy@borwita.co.id / it.handy
///

class TsplScreen extends StatefulWidget {

  final SmartPrinterFlutter plugin;

  const TsplScreen({super.key, required this.plugin});

  @override
  State<TsplScreen> createState() => _TsplScreenState();
}

class _TsplScreenState extends State<TsplScreen> {

  late SmartPrinterFlutter _plugin;

  @override
  void initState() {
    _plugin = widget.plugin;
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TSPL Printer Example'),
      ),
      body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: StreamBuilder(
              stream: _plugin.statusStream,
              builder: (context, snapshot) {
                final status = snapshot.data ?? PrinterStatus(statusInt: 2);
                final isConnected = status.status == PeripheralStatus.connected;
                return Column(
                  children: [
                    ElevatedButton(
                      onPressed:() {
                        _plugin.tsplPrintText('My Name is Handy');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text(
                        "Print Text",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700),
                      ),
                    ),

                    const SizedBox(height: 8),
                  ],
                );
              }
          )
      ),
    );
  }
}

