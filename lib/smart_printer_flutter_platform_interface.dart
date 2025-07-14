import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'smart_printer_flutter_method_channel.dart';

abstract class SmartPrinterFlutterPlatform extends PlatformInterface {
  /// Constructs a SmartPrinterFlutterPlatform.
  SmartPrinterFlutterPlatform() : super(token: _token);

  static final Object _token = Object();

  static SmartPrinterFlutterPlatform _instance = MethodChannelSmartPrinterFlutter();

  /// The default instance of [SmartPrinterFlutterPlatform] to use.
  ///
  /// Defaults to [MethodChannelSmartPrinterFlutter].
  static SmartPrinterFlutterPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [SmartPrinterFlutterPlatform] when
  /// they register themselves.
  static set instance(SmartPrinterFlutterPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
