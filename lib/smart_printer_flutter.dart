import 'printer_models.dart';
import 'smart_printer_flutter_platform_interface.dart';
export 'printer_models.dart';

class SmartPrinterFlutter {
  static final SmartPrinterFlutter _instance = SmartPrinterFlutter._internal();

  /// Singleton instance
  factory SmartPrinterFlutter() => _instance;

  SmartPrinterFlutter._internal();

  final _platform = SmartPrinterFlutterPlatform.instance;

  // =======================
  // BLE Connection Methods
  // =======================

  /// Start scanning for nearby printers.
  Future<void> startScan() => _platform.startScan();

  /// Stop scanning.
  Future<void> stopScan() => _platform.stopScan();

  /// Connects to a printer via Bluetooth using the printer's [mac] address.
  ///
  /// Example: await connectBluetooth("00:11:22:33:44:55");
  Future<void> connectBluetooth(String mac) => _platform.connectBluetooth(mac);

  /// Connects to a printer over Ethernet using the provided [ip] address.
  ///
  /// Example: await connectEthernet("192.168.0.100");
  Future<void> connectEthernet(String ip) => _platform.connectEthernet(ip);

  /// Connects to a printer via Serial (COM) port with a given [port] and [baudrate].
  ///
  /// Example: await connectSerial("COM3", "9600");
  Future<void> connectSerial(String port, String baudrate) =>
      _platform.connectSerial(port, baudrate);

  /// Connects to a printer via USB using the device [path].
  ///
  /// Example: await connectUSB("/dev/usb/lp0");
  Future<void> connectUSB(String path) => _platform.connectUSB(path);

  /// Disconnect the currently connected device.
  Future<void> disconnect() => _platform.disconnect();

  /// Check if a printer is connected.
  Future<bool> get isConnected => _platform.isConnected;

  /// Check if the device is currently scanning.
  Future<bool> isScanning() => _platform.isScanning();

  /// Gets the details of the currently connected printer.
  Future<Peripheral?> getConnectedDevice() => _platform.getConnectedDevice();

  // =======================
  // POS Printer Methods
  // =======================

  /// Print text using POS printer.
  Future<void> posPrintText(
    String text, {
    PTextAlign align = PTextAlign.left,
    PTextAttribute attribute = PTextAttribute.normal,
    PTextW width = PTextW.w1,
    PTextH height = PTextH.h1,
  }) =>
      _platform.posPrintText(
        text,
        align: align,
        attribute: attribute,
        width: width,
        height: height,
      );

  /// Print an image using POS printer.
  Future<void> posPrintImage(String base64Encoded, double width) =>
      _platform.posPrintImage(base64Encoded, width);

  /// Print a QR code using POS printer.
  Future<void> posPrintQRCode(
    String code, {
    int unitSize = 5,
    ErrLevel errLevel = ErrLevel.L,
    PStringEncoding encoding = PStringEncoding.utf8,
  }) =>
      _platform.posPrintQRCode(
        code,
        unitSize: unitSize,
        errLevel: errLevel,
        encoding: encoding,
      );

  /// Print a barcode using POS printer.
  Future<void> posPrintBarcode(
    String content, {
    PBarcodeType type = PBarcodeType.code39,
    PStringEncoding encoding = PStringEncoding.utf8,
  }) =>
      _platform.posPrintBarcode(
        content,
        type: type,
        encoding: encoding,
      );

  /// Cut paper (if the printer supports it).
  Future<void> cutPaper() => _platform.cutPaper();

  // =======================
  // TSPL Printer Methods
  // =======================

  /// Print text using TSPL printer.
  Future<void> tsplPrintText(
    String text, {
    PTextAlign align = PTextAlign.left,
    PTextAttribute attribute = PTextAttribute.normal,
    PTextW width = PTextW.w1,
    PTextH height = PTextH.h1,
  }) =>
      _platform.tsplPrintText(
        text,
        align: align,
        attribute: attribute,
        width: width,
        height: height,
      );

  /// Print QR code using TSPL printer.
  Future<void> tsplPrintQRCode(
    String code, {
    int x = 0,
    int y = 0,
    ErrLevel errLevel = ErrLevel.L,
    QRCodeMode mode = QRCodeMode.M,
    int rotate = 0,
  }) =>
      _platform.tsplPrintQRCode(
        code,
        x: x,
        y: y,
        errLevel: errLevel,
        mode: mode,
        rotate: rotate,
      );

  /// Print image using TSPL printer.
  Future<void> tsplPrintImage(String base64Encoded, int width) =>
      _platform.tsplPrintImage(base64Encoded, width);

  /// Print a PDF file by path using TSPL printer.
  Future<void> tsplPrintPDF(String filePath, LabelSize labelSize) =>
      _platform.tsplPrintPDF(filePath, labelSize);

  /// Print a base64-encoded PDF using TSPL printer.
  Future<void> tsplPrintPDFBase64(String base64Encoded, LabelSize labelSize) =>
      _platform.tsplPrintPDFBase64(base64Encoded, labelSize);

  // =======================
  // Streams
  // =======================

  /// Stream to listen to printer status.
  Stream<PrinterStatus> get statusStream => _platform.statusStream;

  /// Stream to listen to scanning state.
  Stream<bool> get isScanningStream => _platform.isScanningStream;

  /// Stream to listen to discovered peripherals.
  Stream<List<Peripheral>> get peripheralsStream => _platform.peripheralsStream;

  /// Get the current printer status (human-readable string).
  Future<String> getPrinterStatus() => _platform.getPrinterStatus();
}
