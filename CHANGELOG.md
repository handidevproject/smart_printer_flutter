# Changelog

All notable changes to this project will be documented in this file.

## 0.2.1 - 2026-02-04
### ✨ Features
- **Printer**
    - Implementation POS SYSTEM

## 0.2.0 - 2025-10-03
### ✨ Features
- **Printer Connections**
  - Added support for multiple printer connection types:
    - `connectBluetooth(String mac)`
    - `connectEthernet(String ip)`
    - `connectSerial(String port, String baudrate)`
    - `connectUSB(String path)`
- **Dart API**
  - Updated Dart interface, method channel, and example app to align with new connection methods.
- **Testing**
  - Added TODOs for upcoming test implementations.
  - Removed unused test code in `smart_printer_flutter_method_channel_test.dart`.

### ♻️ Refactor
- **Core Manager**
  - Renamed `BleManager` → `PrinterManager` to reflect broader responsibilities.
  - Integrated Ethernet, USB, and Serial support into `PrinterManager`.
- **Plugin Integration**
  - Updated `SmartPrinterFlutterPlugin` to use the new `PrinterManager`.
- **Bluetooth**
  - Refactored Bluetooth device discovery to use modern Android APIs.
- **Mocks**
  - Reorganized mock `SmartPrinterFlutterPlatform` to group connection methods together.

### 🧹 Cleanup
- Removed commented-out code related to bitmap rendering and TSPL commands in `TSPLActivity.kt`.
- Removed unnecessary `Thread.sleep(1000)` delay.
- Deleted outdated TODO related to `isPrinted` in `printPdfFromPath`.

### 🏗️ Build
- Upgraded Android Gradle Plugin → `8.9.3`.
- Updated Gradle Wrapper → `8.11.1`.

## 0.1.1 - 2025-09-26
### ✨ Features
- **Printer**
  - Add `getPrinterStatus` method to fetch and interpret printer status codes.
- **Android**
  - Implement native BLE logic to retrieve printer status.

### ♻️ Refactor
- **PDF Rendering & Printing**
  - Rework `renderAllPagesFromPdf` to calculate bitmap dimensions based on printer DPI and aspect ratio, with a 4mm safety margin.
  - Update calls to `renderAllPagesFromPdf` to pass the `printer` object.
- **TSPL Print Parameters**
  - Adjust speed from `5.0` → `3.0`.
  - Adjust density from `10` → `1`.
  - Change reference point from `(20, 0)` → `(0, 0)`.
- **Code Cleanup**
  - Remove redundant author KDoc from `PdfUtils.kt`.

## 0.1.0 - 2025-09-15
### ✨ Features
- **Printer**
  - Add `getPrinterStatus` method to fetch and interpret printer status codes.
- **Android**
  - Implement native BLE logic to retrieve printer status.

###  Fixes
- **Printing**
  - Add error handling and logging in `TSPLActivity`.
  - Prevent concurrent PDF print jobs in Dart.
### Chore
- Minor cleanup and logging improvements.


## 0.0.6
- Added proper MIT `LICENSE` file (replacing placeholder template).
- Added `NOTICE` file to clarify usage of trademarks (XPrinter, TSPL, ZPL, ESC/POS).
- Compliance improvements for pub.dev publishing requirements.

## 0.0.5
- Update plugin version in pubspec.yaml
- Replace print with debugPrint in example and method channel
- Remove unused imports and test code
- Add initializeBle to MockSmartPrinterFlutterPlatform
- Update example pubspec.lock

## 0.0.4
- Fix bug in Android Bluetooth connection.
- Add support for printing QR codes and barcodes.
- Update dependencies (permission_handler 12.0.1).

## 0.0.3

* Update Change log.

## 0.0.2

* Update README.md with new features.

## 0.0.1

* Init Release.