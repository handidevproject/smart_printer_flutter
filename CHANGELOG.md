# Changelog

All notable changes to this project will be documented in this file.

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
