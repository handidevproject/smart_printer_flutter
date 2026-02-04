import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:smart_printer_flutter/printer_models.dart';
import 'smart_printer_flutter_platform_interface.dart';

/// Implementation of [SmartPrinterFlutterPlatform] using [MethodChannel].
///
/// This class communicates between Flutter and the native Android/iOS
/// implementation via method and event channels. Each printer action
/// (like scanning, printing, cutting, etc.) is invoked through specific
/// channel methods.
class MethodChannelSmartPrinterFlutter extends SmartPrinterFlutterPlatform {
  /// Method channel for calling native methods.
  static const MethodChannel _channel = MethodChannel('smart_printer_flutter');

  /// Event channel for receiving printer status updates.
  static const EventChannel _statusEventChannel = EventChannel(
    'smart_printer_flutter/status',
  );

  /// Event channel for receiving scanning status (isScanning).
  static const EventChannel _scanningEventChannel = EventChannel(
    'smart_printer_flutter/scanning',
  );

  /// Event channel for receiving list of discovered Bluetooth peripherals.
  static const EventChannel _peripheralsEventChannel = EventChannel(
    'smart_printer_flutter/peripherals',
  );

  /// Starts scanning for nearby Bluetooth devices.
  @override
  Future<void> startScan() async {
    await _channel.invokeMethod('startScan');
  }

  /// Stops an ongoing scan for Bluetooth devices.
  @override
  Future<void> stopScan() async {
    await _channel.invokeMethod('stopScan');
  }

  /// Connects to a printer via Bluetooth using the printer's [mac] address.
  ///
  /// Example: await connectBluetooth("00:11:22:33:44:55");
  @override
  Future<void> connectBluetooth(String mac) async {
    await _channel.invokeMethod("connectBluetooth", {"mac": mac});
  }

  /// Connects to a printer over Ethernet using the provided [ip] address.
  ///
  /// Example: await connectEthernet("192.168.0.100");
  @override
  Future<void> connectEthernet(String ip) async {
    await _channel.invokeMethod("connectEthernet", {"ip": ip});
  }

  /// Connects to a printer via Serial (COM) port with a given [port] and [baudrate].
  ///
  /// Example: await connectSerial("COM3", "9600");
  @override
  Future<void> connectSerial(String port, String baudrate) async {
    await _channel.invokeMethod("connectSerial", {
      "port": port,
      "baudrate": baudrate,
    });
  }

  /// Connects to a printer via USB using the device [path].
  ///
  /// Example: await connectUSB("/dev/usb/lp0");
  @override
  Future<void> connectUSB(String path) async {
    await _channel.invokeMethod("connectUSB", {"path": path});
  }

  /// Disconnects the currently connected Bluetooth device.
  @override
  Future<void> disconnect() async {
    await _channel.invokeMethod('disconnect');
  }

  // TODO ALY
  /// Requests the current printer status from the native layer.
  ///
  /// This method calls a native function that returns an integer status code.
  /// The integer code is then mapped into a human-readable status message.
  ///
  @override
  Future<String> getPrinterStatus() async {
    try {
      final code = await _channel.invokeMethod<int>('printStatus') ?? -1;
      switch (code) {
        case 0:
          return "Normal";
        case 1:
          return "Head opened";
        case 2:
          return "Paper Jam";
        case 3:
          return "Paper Jam and head opened";
        case 4:
          return "Out of paper";
        case 5:
          return "Out of paper and head opened";
        case 8:
          return "Out of ribbon";
        case 9:
          return "Out of ribbon and head opened";
        case 10:
          return "Out of ribbon and paper jam";
        case 11:
          return "Out of ribbon, paper jam and head opened";
        case 12:
          return "Out of ribbon and out of paper";
        case 13:
          return "Out of ribbon, out of paper and head opened";
        case 16:
          return "Pause";
        case 32:
          return "Printing";
        default:
          return "Other error ($code)";
      }
    } catch (e) {
      return "Error: $e";
    }
  }

  /// Returns whether a scan is currently in progress.
  @override
  Future<bool> isScanning() async {
    final result = await _channel.invokeMethod<bool>('isScanning');
    return result ?? false;
  }

  /// Returns whether a device is currently connected.
  @override
  Future<bool> get isConnected async {
    final connected = await _channel.invokeMethod<bool>('isConnected') ?? false;
    return connected;
  }

  /// Gets the details of the currently connected printer.
  @override
  Future<Peripheral?> getConnectedDevice() async {
    final result = await _channel.invokeMethod('getConnectedDevice');
    if (result == null) return null;
    return Peripheral.fromJson(Map<String, dynamic>.from(result));
  }

  /// Sends text to the POS printer with optional formatting.
  @override
  Future<void> posPrintText(
      String text, {
        PTextAlign align = PTextAlign.left,
        PTextAttribute attribute = PTextAttribute.normal,
        PTextW width = PTextW.w1,
        PTextH height = PTextH.h1,
      }) async {
    await _channel.invokeMethod('pos_printText', {
      'text': text,
      'align': align.index,
      'attribute': attribute.index,
      'width': width.index,
      'height': height.index,
    });
  }

  /// Sends an image to the POS printer.
  ///
  /// [base64Encoded] is the image in base64 format, and [width] is the target width.
  @override
  Future<void> posPrintImage(String base64Encoded, double width) async {
    await _channel.invokeMethod('pos_printImage', {
      'data': base64Encoded,
      'width': width,
    });
  }

  /// Sends a QR code to the POS printer.
  ///
  /// Accepts optional configuration: [unitSize], [errLevel], and [encoding].
  @override
  Future<void> posPrintQRCode(
      String code, {
        int unitSize = 5,
        ErrLevel errLevel = ErrLevel.L,
        PStringEncoding encoding = PStringEncoding.utf8,
      }) async {
    await _channel.invokeMethod('pos_printQRCode', {
      'code': code,
      'unitSize': unitSize,
      'errLevel': errLevel.index,
      'encoding': encoding.index,
    });
  }

  /// Sends a barcode to the POS printer.
  @override
  Future<void> posPrintBarcode(
      String content, {
        PBarcodeType type = PBarcodeType.code39,
        PStringEncoding encoding = PStringEncoding.utf8,
      }) async {
    await _channel.invokeMethod('pos_printBarcode', {
      'content': content,
      'type': type.index,
      'encoding': encoding.index,
    });
  }

  /// Triggers the paper cutter if available.
  @override
  Future<void> cutPaper() async {
    await _channel.invokeMethod('cutPaper');
  }

  /// Sends formatted text to the TSPL printer.
  @override
  Future<void> tsplPrintText(
      String text, {
        PTextAlign align = PTextAlign.left,
        PTextAttribute attribute = PTextAttribute.normal,
        PTextW width = PTextW.w1,
        PTextH height = PTextH.h1,
      }) async {
    await _channel.invokeMethod('tspl_printText', {
      'text': text,
      'align': align.index,
      'attribute': attribute.index,
      'width': width.index,
      'height': height.index,
    });
  }

  /// Sends a QR code to the TSPL printer with positioning and rotation.
  @override
  Future<void> tsplPrintQRCode(
      String code, {
        int x = 0,
        int y = 0,
        ErrLevel errLevel = ErrLevel.L,
        QRCodeMode mode = QRCodeMode.M,
        int rotate = 0,
      }) async {
    await _channel.invokeMethod('tspl_printQRCode', {
      'code': code,
      'x': x,
      'y': y,
      'eccLevel': errLevel.index,
      'mode': mode.index,
      'rotation': rotateLevels[QRCodeRotate.values[rotate]] ?? 0,
    });
  }

  /// Sends a base64-encoded image to the TSPL printer.
  @override
  Future<void> tsplPrintImage(String base64Encoded, int width) async {
    await _channel.invokeMethod('tspl_printImage', {
      'base64': base64Encoded,
      'width': width,
    });
  }

  /// Sends a PDF file path to be printed using TSPL.
  bool _isPrinting = false;

  @override
  Future<void> tsplPrintPDF(String filePath, LabelSize labelSize) async {
    if (_isPrinting) {
      print('[Flutter] Skipping print, already in progress');
      return;
    }

    _isPrinting = true;
    try {
      print('[Flutter] Calling tspl_printPDF...');
      await _channel.invokeMethod('tspl_printPDF', {
        'filePath': filePath,
        'label': labelSize.value,
      });
    } catch (e) {
      print('[Flutter] Error printing: $e');
    } finally {
      _isPrinting = false;
    }
  }

  /// Sends a base64-encoded PDF to be printed using TSPL.
  @override
  Future<void> tsplPrintPDFBase64(
      String base64Encoded,
      LabelSize labelSize,
      ) async {
    await _channel.invokeMethod('tspl_printPDFBase64', {
      'base64': base64Encoded,
      'label': labelSize.value,
    });
  }

  /// Stream that provides printer status updates from the native layer.
  @override
  Stream<PrinterStatus> get statusStream =>
      _statusEventChannel.receiveBroadcastStream().map((event) {
        return PrinterStatus.fromJson(Map<String, dynamic>.from(event));
      });

  /// Stream that emits a boolean indicating whether scanning is active.
  @override
  Stream<bool> get isScanningStream => _scanningEventChannel
      .receiveBroadcastStream()
      .map((event) => event == true);

  /// Stream of discovered Bluetooth peripherals.
  @override
  Stream<List<Peripheral>> get peripheralsStream =>
      _peripheralsEventChannel.receiveBroadcastStream().map((event) {
        final list = List<Map>.from(event);
        return list
            .map((e) => Peripheral.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      });

  @override
  Future<void> initializeBle() async {
    await requestBluetoothPermissions();

    try {
      final success = await MethodChannel(
        'smart_printer_flutter',
      ).invokeMethod('initBleManager');
      print("BLE Manager initialized: $success");
    } on PlatformException catch (e) {
      print("Gagal inisialisasi BLE: ${e.message}");
    }
  }

  Future<void> requestBluetoothPermissions() async {
    if (!Platform.isAndroid) return;

    // Android 12 (API 31) ke atas wajib pakai permission khusus
    if (Platform.isAndroid) {
      final bluetoothConnectStatus = await Permission.bluetoothConnect.status;
      if (!bluetoothConnectStatus.isGranted) {
        await Permission.bluetoothConnect.request();
      }

      final bluetoothScanStatus = await Permission.bluetoothScan.status;
      if (!bluetoothScanStatus.isGranted) {
        await Permission.bluetoothScan.request();
      }
    } else {
      // Android < 12 tetap perlu Location untuk BLE scanning
      final locationStatus = await Permission.location.status;
      if (!locationStatus.isGranted) {
        await Permission.location.request();
      }
    }

    // Optional: cek apakah ditolak permanen
    if (await Permission.bluetoothConnect.isPermanentlyDenied ||
        await Permission.bluetoothScan.isPermanentlyDenied ||
        await Permission.location.isPermanentlyDenied) {
      // Arahkan user ke Settings
      await openAppSettings();
    }
  }
}
