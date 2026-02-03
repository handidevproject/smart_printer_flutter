/// Text alignment options for printing.
enum PTextAlign { left, center, right }

/// Text attributes for printing.
enum PTextAttribute { normal, fontB, bold, reverse, underline, underline2 }

/// Text width options for printing.
enum PTextW { w1, w2, w3, w4 }

/// Text height options for printing.
enum PTextH { h1, h2, h3, h4 }

/// String encoding options.
enum PStringEncoding { utf8, ascii, utf16 }

/// QR Code error correction levels.
enum ErrLevel { L, M, Q, H }

enum QRCodeMode { A, M }

enum QRCodeRotate { rotate0, rotate90, rotate180, rotate270, rotate360 }

/// Mapping of QR error correction levels to their respective values.
const errLevels = {
  ErrLevel.L: 48,
  ErrLevel.M: 49,
  ErrLevel.Q: 50,
  ErrLevel.H: 51,
};

const rotateLevels = {
  QRCodeRotate.rotate0: 0,
  QRCodeRotate.rotate90: 90,
  QRCodeRotate.rotate180: 180,
  QRCodeRotate.rotate270: 270,
  QRCodeRotate.rotate360: 360,
};

/// Barcode types supported.
enum PBarcodeType {
  upcA,
  upcE,
  ean13,
  eab13,
  code39,
  itf,
  codabar,
  code93,
  code128
}

/// Represents the state of a peripheral device.
enum PeripheralState { disconnected, connected }

/// Represents a peripheral device.
class Peripheral {
  final String? name;
  final String? uuid;
  final int? stateStr;
  final String? type;
  final String? protocol;

  Peripheral({this.name, this.uuid, this.stateStr, this.type, this.protocol});

  /// Creates a [Peripheral] instance from a JSON map.
  factory Peripheral.fromJson(Map<String, dynamic> json) {
    return Peripheral(
      name: json['name'],
      uuid: json['uuid'],
      stateStr: json['state'],
      type: json['type'],
      protocol: json['protocol'],
    );
  }

  /// Gets the [PeripheralState] based on [stateCode].
  PeripheralState get state {
    switch (stateStr) {
      case 0:
        return PeripheralState.disconnected;
      case 2:
        return PeripheralState.connected;
      default:
        return PeripheralState.disconnected;
    }
  }
}

/// Represents the status of a printer.
class PrinterStatus {
  final int statusInt;
  final String? uuid;
  final String? statusMessage;

  PrinterStatus({required this.statusInt, this.uuid, this.statusMessage});

  /// Creates a [PrinterStatus] instance from a JSON map.
  factory PrinterStatus.fromJson(Map<String, dynamic> json) {
    return PrinterStatus(
      statusInt: json['status'],
      uuid: json['uuid'],
      statusMessage: json['statusMessage'],
    );
  }

  /// Gets the [PeripheralStatus] based on [statusCode].
  PeripheralStatus get status {
    switch (statusInt) {
      case 0:
        return PeripheralStatus.connecting;
      case 1:
        return PeripheralStatus.connected;
      case 2:
        return PeripheralStatus.disconnected;
      case 3:
        return PeripheralStatus.connectFailed;
      default:
        return PeripheralStatus.disconnected;
    }
  }
}

/// Represents the status of a peripheral device.
enum PeripheralStatus { connecting, connected, disconnected, connectFailed }

/// Label size enum used for TSPL printing.
enum LabelSize {
  mm78x60,
  mm78x100,
  mm78x120,
  mm80x80,
  mm100x100,
  mm100x150,
  mm102x127,
  mm58Cont,
  mm80Cont
}

extension LabelSizeExtension on LabelSize {
  String get value {
    switch (this) {
      case LabelSize.mm78x60:
        return "78x60";
      case LabelSize.mm78x100:
        return "78x100";
      case LabelSize.mm78x120:
        return "78x120";
      case LabelSize.mm80x80:
        return "80x80";
      case LabelSize.mm100x100:
        return "100x100";
      case LabelSize.mm100x150:
        return "100x150";
      case LabelSize.mm102x127:
        return "102x127";
      case LabelSize.mm58Cont:
        return "58x200";
      case LabelSize.mm80Cont:
        return "80x200";
    }
  }

  static LabelSize from(String label) {
    switch (label) {
      case "78x60":
        return LabelSize.mm78x60;
      case "78x100":
        return LabelSize.mm78x100;
      case "78x120":
        return LabelSize.mm78x120;
      case "80x80":
        return LabelSize.mm80x80;
      case "100x100":
        return LabelSize.mm100x100;
      case "100x150":
        return LabelSize.mm100x150;
      case "102x127":
        return LabelSize.mm102x127;
      case "58x200":
        return LabelSize.mm58Cont;
      case "80x200":
        return LabelSize.mm80Cont;
      default:
        throw Exception("Unknown label size: $label");
    }
  }
}
