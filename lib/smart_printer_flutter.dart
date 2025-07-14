
import 'smart_printer_flutter_platform_interface.dart';

class SmartPrinterFlutter {
  Future<String?> getPlatformVersion() {
    return SmartPrinterFlutterPlatform.instance.getPlatformVersion();
  }
}
