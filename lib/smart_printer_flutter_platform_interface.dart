import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:smart_printer_flutter/printer_models.dart';
import 'smart_printer_flutter_method_channel.dart';

/// Abstract class that defines the platform interface for SmartPrinterFlutter.
/// This class should be extended when implementing platform-specific
/// functionality (e.g., using MethodChannel for Android or iOS).
abstract class SmartPrinterFlutterPlatform extends PlatformInterface {
  SmartPrinterFlutterPlatform() : super(token: _token);

  static final Object _token = Object();

  static SmartPrinterFlutterPlatform _instance =
  MethodChannelSmartPrinterFlutter();

  /// The current platform-specific implementation of [SmartPrinterFlutterPlatform].
  static SmartPrinterFlutterPlatform get instance => _instance;

  /// Sets the platform-specific implementation.
  /// Throws an error if the token is invalid, ensuring only trusted implementations are used.
  static set instance(SmartPrinterFlutterPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  // ===========================================================================
  // General Methods
  // ===========================================================================

  Future<void> initializeBle();

  /// Starts scanning for available Bluetooth printers.
  Future<void> startScan();

  /// Stops the Bluetooth scanning process.
  Future<void> stopScan();

  /// Connects to a printer over Ethernet using the provided [ip] address.
  ///
  /// Example: await connectEthernet("192.168.0.100");
  Future<void> connectEthernet(String ip);

  /// Connects to a printer via Bluetooth using the printer's [mac] address.
  ///
  /// Example: await connectBluetooth("00:11:22:33:44:55");
  Future<void> connectBluetooth(String mac);

  /// Connects to a printer via USB using the device [path].
  ///
  /// Example: await connectUSB("/dev/usb/lp0");
  Future<void> connectUSB(String path);

  /// Connects to a printer via Serial (COM) port with a given [port] and [baudrate].
  ///
  /// Example: await connectSerial("COM3", "9600");
  Future<void> connectSerial(String port, String baudrate);

  /// Disconnects from the currently connected printer.
  Future<void> disconnect();

  /// Checks whether a Bluetooth scanning process is currently active.
  Future<bool> isScanning();

  /// Checks if a printer is currently connected.
  Future<bool> get isConnected;

  /// Gets the details of the currently connected printer.
  Future<Peripheral?> getConnectedDevice() {
    throw UnimplementedError('getConnectedDevice() has not been implemented.');
  }

  // ===========================================================================
  // POS Printer Methods
  // ===========================================================================

  /// Prints a text string to the POS printer with optional formatting options.
  ///
  /// - [align]: Text alignment (left, center, right).
  /// - [attribute]: Text style attributes (bold, underline, etc).
  /// - [width]: Width multiplier for the text.
  /// - [height]: Height multiplier for the text.
  Future<void> posPrintText(
      String text, {
        PTextAlign align = PTextAlign.left,
        PTextAttribute attribute = PTextAttribute.normal,
        PTextW width = PTextW.w1,
        PTextH height = PTextH.h1,
      }) {
    throw UnimplementedError('posPrintText() has not been implemented.');
  }

  /// Prints a base64-encoded image to the POS printer.
  ///
  /// - [base64Encoded]: Base64 string representation of the image.
  /// - [width]: Desired width of the printed image.
  Future<void> posPrintImage(String base64Encoded, double width);

  /// Prints a QR code to the POS printer.
  ///
  /// - [code]: The content of the QR code.
  /// - [unitSize]: Size of each module in the QR code.
  /// - [errLevel]: Error correction level (L, M, Q, H).
  /// - [encoding]: Encoding of the content string.
  Future<void> posPrintQRCode(
      String code, {
        int unitSize = 5,
        ErrLevel errLevel = ErrLevel.L,
        PStringEncoding encoding = PStringEncoding.utf8,
      }) {
    throw UnimplementedError('printQrCode() has not been implemented.');
  }

  /// Prints a barcode to the POS printer.
  ///
  /// - [content]: The content of the barcode.
  /// - [type]: Type of barcode (e.g., Code39, Code128).
  /// - [encoding]: Encoding of the content string.
  Future<void> posPrintBarcode(
      String content, {
        PBarcodeType type = PBarcodeType.code39,
        PStringEncoding encoding = PStringEncoding.utf8,
      });

  /// Sends a cut paper command to the POS printer.
  Future<void> cutPaper();

  // ===========================================================================
  // TSPL Printer Methods
  // ===========================================================================

  /// Prints text on TSPL printers with optional formatting.
  ///
  /// - [text]: The text to print.
  /// - [align]: Text alignment.
  /// - [attribute]: Text attribute (bold, underline).
  /// - [width]: Width multiplier.
  /// - [height]: Height multiplier.
  Future<void> tsplPrintText(
      String text, {
        PTextAlign align = PTextAlign.left,
        PTextAttribute attribute = PTextAttribute.normal,
        PTextW width = PTextW.w1,
        PTextH height = PTextH.h1,
      });

  /// Prints a QR code on TSPL printers.
  ///
  /// - [code]: QR code content.
  /// - [unitSize]: Size of each module.
  /// - [errLevel]: Error correction level.
  /// - [encoding]: Encoding of the string.
  Future<void> tsplPrintQRCode(
      String code, {
        int x = 0,
        int y = 0,
        ErrLevel errLevel = ErrLevel.L,
        QRCodeMode mode = QRCodeMode.M,
        int rotate = 0,
      });

  /// Prints an image (base64-encoded) on TSPL printers.
  ///
  /// - [base64Encoded]: Base64 image data.
  /// - [width]: Image width in pixels.
  Future<void> tsplPrintImage(String base64Encoded, int width);

  /// Prints a PDF file by specifying the file path and label size.
  ///
  /// - [filePath]: Path to the PDF file.
  /// - [labelSize]: Label dimensions (e.g., "78x60").
  Future<void> tsplPrintPDF(String filePath, LabelSize labelSize);

  /// Prints a base64-encoded PDF directly on TSPL printer.
  ///
  /// - [base64Encoded]: Base64 string of PDF content.
  /// - [labelSize]: Label dimensions (e.g., "100x100").
  Future<void> tsplPrintPDFBase64(String base64Encoded, LabelSize labelSize);

  // ===========================================================================
  // Streams
  // ===========================================================================

  /// A stream that emits real-time status updates from the printer.
  Stream<PrinterStatus> get statusStream;

  /// A stream that indicates the current scanning state (true if scanning).
  Stream<bool> get isScanningStream;

  /// A stream that emits a list of discovered Bluetooth peripherals.
  Stream<List<Peripheral>> get peripheralsStream;

  /// Requests the current printer status (int code mapped in Dart).
  Future<String> getPrinterStatus();
}
