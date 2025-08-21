import 'package:flutter_test/flutter_test.dart';
import 'package:smart_printer_flutter/printer_models.dart';
import 'package:smart_printer_flutter/smart_printer_flutter.dart';
import 'package:smart_printer_flutter/smart_printer_flutter_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockSmartPrinterFlutterPlatform
    with MockPlatformInterfaceMixin
    implements SmartPrinterFlutterPlatform {

  @override
  Future<void> connect(String deviceId) {
    // TODO: implement connect
    throw UnimplementedError();
  }

  @override
  Future<void> cutPaper() {
    // TODO: implement cutPaper
    throw UnimplementedError();
  }

  @override
  Future<void> disconnect() {
    // TODO: implement disconnect
    throw UnimplementedError();
  }

  @override
  // TODO: implement isConnected
  Future<bool> get isConnected => throw UnimplementedError();

  @override
  Future<bool> isScanning() {
    // TODO: implement isScanning
    throw UnimplementedError();
  }

  @override
  // TODO: implement isScanningStream
  Stream<bool> get isScanningStream => throw UnimplementedError();

  @override
  // TODO: implement peripheralsStream
  Stream<List<Peripheral>> get peripheralsStream => throw UnimplementedError();

  @override
  Future<void> posPrintBarcode(String content, {PBarcodeType type = PBarcodeType.code39, PStringEncoding encoding = PStringEncoding.utf8}) {
    // TODO: implement posPrintBarcode
    throw UnimplementedError();
  }

  @override
  Future<void> posPrintImage(String base64Encoded, double width) {
    // TODO: implement posPrintImage
    throw UnimplementedError();
  }

  @override
  Future<void> posPrintQRCode(String code, {int unitSize = 5, ErrLevel errLevel = ErrLevel.L, PStringEncoding encoding = PStringEncoding.utf8}) {
    // TODO: implement posPrintQRCode
    throw UnimplementedError();
  }

  @override
  Future<void> posPrintText(String text, {PTextAlign align = PTextAlign.left, PTextAttribute attribute = PTextAttribute.normal, PTextW width = PTextW.w1, PTextH height = PTextH.h1}) {
    // TODO: implement posPrintText
    throw UnimplementedError();
  }

  @override
  Future<void> startScan() {
    // TODO: implement startScan
    throw UnimplementedError();
  }

  @override
  // TODO: implement statusStream
  Stream<PrinterStatus> get statusStream => throw UnimplementedError();

  @override
  Future<void> stopScan() {
    // TODO: implement stopScan
    throw UnimplementedError();
  }

  @override
  Future<void> tsplPrintImage(String base64Encoded, int width) {
    // TODO: implement tsplPrintImage
    throw UnimplementedError();
  }

  @override
  Future<void> tsplPrintPDF(String filePath, LabelSize labelSize) {
    // TODO: implement tsplPrintPDF
    throw UnimplementedError();
  }

  @override
  Future<void> tsplPrintPDFBase64(String base64Encoded, LabelSize labelSize) {
    // TODO: implement tsplPrintPDFBase64
    throw UnimplementedError();
  }

  @override
  Future<void> tsplPrintQRCode(String code, {int x = 0, int y = 0, ErrLevel errLevel = ErrLevel.L, QRCodeMode mode = QRCodeMode.M, int rotate = 0}) {
    // TODO: implement tsplPrintQRCode
    throw UnimplementedError();
  }

  @override
  Future<void> tsplPrintText(String text, {PTextAlign align = PTextAlign.left, PTextAttribute attribute = PTextAttribute.normal, PTextW width = PTextW.w1, PTextH height = PTextH.h1}) {
    // TODO: implement tsplPrintText
    throw UnimplementedError();
  }
  @override
  Future<void> initializeBle() {
    // TODO: implement initializeBle
    throw UnimplementedError();
  }
}

void main() {
  // final SmartPrinterFlutterPlatform initialPlatform = SmartPrinterFlutterPlatform.instance;

  // test('$MethodChannelSmartPrinterFlutter is the default instance', () {
  //   expect(initialPlatform, isInstanceOf<MethodChannelSmartPrinterFlutter>());
  // });

  // test('getPlatformVersion', () async {
  //   SmartPrinterFlutter smartPrinterFlutterPlugin = SmartPrinterFlutter();
  //   MockSmartPrinterFlutterPlatform fakePlatform = MockSmartPrinterFlutterPlatform();
  //   SmartPrinterFlutterPlatform.instance = fakePlatform;

  //   expect(await smartPrinterFlutterPlugin.getPlatformVersion(), '42');
  // });
}
