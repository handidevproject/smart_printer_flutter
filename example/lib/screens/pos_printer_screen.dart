import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:smart_printer_flutter/smart_printer_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;

///
/// Created by Handy on 01/10/25
/// Macbook Air M2 - 2022
/// it.handy@borwita.co.id / it.handy
///

class PosPrinterScreen extends StatefulWidget {

  final SmartPrinterFlutter plugin;

  const PosPrinterScreen({super.key, required this.plugin});

  @override
  State<PosPrinterScreen> createState() => _PosPrinterScreenState();
}

class _PosPrinterScreenState extends State<PosPrinterScreen> {

  final contentController = TextEditingController();
  late SmartPrinterFlutter _plugin;

  @override
  void initState() {
    _plugin = widget.plugin;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('POS Printer Example'),
      ),
      body: SafeArea(
          child: StreamBuilder(
              stream: _plugin.statusStream,
              initialData: PrinterStatus(statusInt: 2),
              builder: (context, snapshot) {
                final status = snapshot.data ?? PrinterStatus(statusInt: 2);
                final isConnected = status.status == PeripheralStatus.connected;
                return Column(
                  children: [
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
                            onPressed: isConnected ? _printText : null,
                            child: const Text('Print Text'),
                          ),
                        ),
                        Expanded(
                          child: TextButton(
                            onPressed: isConnected ? _selectImage : null,
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
                            onPressed: isConnected ? _cutPaper : null,
                            child: const Text('Cut Paper'),
                          ),
                        ),
                        Expanded(
                          child: TextButton(
                            onPressed:  isConnected ? _printExample : null,
                            child: const Text('Print Example'),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              }
          )
      ),
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
      debugPrint('Failed to decode image');
    }
  }

}

