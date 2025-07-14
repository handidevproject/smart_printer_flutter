import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'smart_printer_flutter_platform_interface.dart';

/// An implementation of [SmartPrinterFlutterPlatform] that uses method channels.
class MethodChannelSmartPrinterFlutter extends SmartPrinterFlutterPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('smart_printer_flutter');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
