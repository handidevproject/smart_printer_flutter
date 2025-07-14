import 'package:flutter_test/flutter_test.dart';
import 'package:smart_printer_flutter/smart_printer_flutter.dart';
import 'package:smart_printer_flutter/smart_printer_flutter_platform_interface.dart';
import 'package:smart_printer_flutter/smart_printer_flutter_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockSmartPrinterFlutterPlatform
    with MockPlatformInterfaceMixin
    implements SmartPrinterFlutterPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final SmartPrinterFlutterPlatform initialPlatform = SmartPrinterFlutterPlatform.instance;

  test('$MethodChannelSmartPrinterFlutter is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelSmartPrinterFlutter>());
  });

  test('getPlatformVersion', () async {
    SmartPrinterFlutter smartPrinterFlutterPlugin = SmartPrinterFlutter();
    MockSmartPrinterFlutterPlatform fakePlatform = MockSmartPrinterFlutterPlatform();
    SmartPrinterFlutterPlatform.instance = fakePlatform;

    expect(await smartPrinterFlutterPlugin.getPlatformVersion(), '42');
  });
}
