# Changelog

All notable changes to this project will be documented in this file.

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