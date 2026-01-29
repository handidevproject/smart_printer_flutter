package com.cakhandi95.smart_printer_flutter

import PosActivity
import android.Manifest
import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import android.util.Log
import com.cakhandi95.smart_printer_flutter.models.BarcodeAttr
import com.cakhandi95.smart_printer_flutter.models.QrcodeAttr
import com.cakhandi95.smart_printer_flutter.models.TPdfAttr
import com.cakhandi95.smart_printer_flutter.models.TextAttr
import com.cakhandi95.smart_printer_flutter.models.toDict
import com.cakhandi95.smart_printer_flutter.utils.LabelSize
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel.Result
import java.io.File
import com.cakhandi95.smart_printer_flutter.TSPLActivity

/** SmartPrinterFlutterPlugin */
class SmartPrinterFlutterPlugin: FlutterPlugin, MethodCallHandler {

    private val TAG = "SmartPrinterFlutterPlugin";

    private lateinit var channel: MethodChannel
    private lateinit var statusChannel: EventChannel
    private lateinit var scanningChannel: EventChannel
    private lateinit var peripheralChannel: EventChannel
    private lateinit var printerManager: PrinterManager

    private var statusEventSink: EventChannel.EventSink? = null
    private var scanningEventSink: EventChannel.EventSink? = null
    private var peripheralEventSink: EventChannel.EventSink? = null

    private lateinit var applicationContext: Context

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        applicationContext = flutterPluginBinding.applicationContext

        Log.d(TAG, "onAttachedToEngine")
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "smart_printer_flutter")
        channel.setMethodCallHandler(this)

        statusChannel = EventChannel(flutterPluginBinding.binaryMessenger, "smart_printer_flutter/status")
        scanningChannel = EventChannel(flutterPluginBinding.binaryMessenger, "smart_printer_flutter/scanning")
        peripheralChannel = EventChannel(flutterPluginBinding.binaryMessenger, "smart_printer_flutter/peripherals")

        statusChannel.setStreamHandler(createStreamHandler { sink -> statusEventSink = sink })
        scanningChannel.setStreamHandler(createStreamHandler { sink -> scanningEventSink = sink })
        peripheralChannel.setStreamHandler(createStreamHandler { sink -> peripheralEventSink = sink })

        initPrinterManager()
    }

    private fun initPrinterManager() {
        if (::printerManager.isInitialized) return

        printerManager = PrinterManager(
            context = applicationContext,
            onStatusChanged = { status -> statusEventSink?.success(status) },
            onScanningChanged = { scanningEventSink?.success(it) },
            onDevicesChanged = { devices -> peripheralEventSink?.success(devices.map { it.toDict() }) }
        )
    }

    private fun createStreamHandler(assign: (EventChannel.EventSink?) -> Unit) =
        object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                assign(events)
            }

            override fun onCancel(arguments: Any?) {
                assign(null)
            }
        }

    override fun onMethodCall(call: MethodCall, result: Result) {
        if (!::printerManager.isInitialized) {
             initPrinterManager()
             if (!::printerManager.isInitialized) {
                 result.error("NOT_INITIALIZED", "PrinterManager not initialized", null)
                 return
             }
        }

        when (call.method) {

            // Scan Bluetooth
            "startScan" -> printerManager.startScan()
            "stopScan" -> printerManager.stopScan()

            // Connection
            "connectBluetooth" -> {
                val mac = call.argument<String>("mac") ?: return result.error("INVALID_ARGUMENTS", "mac required", null)
                printerManager.connectBluetooth(mac)
                result.success(null)
            }

            "connectEthernet" -> {
                val ip = call.argument<String>("ip") ?: return result.error("INVALID_ARGUMENTS", "ip required", null)
                printerManager.connectEthernet(ip)
                result.success(null)
            }

            "connectUSB" -> {
                val path = call.argument<String>("path") ?: return result.error("INVALID_ARGUMENTS", "path required", null)
                printerManager.connectUSB(path)
                result.success(null)
            }

            "connectSerial" -> {
                val port = call.argument<String>("port") ?: return result.error("INVALID_ARGUMENTS", "port required", null)
                val baud = call.argument<String>("baudrate") ?: return result.error("INVALID_ARGUMENTS", "baudrate required", null)
                printerManager.connectSerial(port, baud)
                result.success(null)
            }

            "disconnect" -> {
                printerManager.disconnect()
                result.success(null)
            }

            "isScanning" -> result.success(printerManager.isScanning)
            "isConnected" -> result.success(printerManager.isConnected)

            // === Printer actions (POS / TSPL) ===
            "pos_printText" -> handlePrintText(call, result)
            "pos_printImage" -> handlePrintImage(call, result)
            "pos_printQRCode" -> handlePrintQRCode(call, result)
            "pos_printBarcode" -> handlePrintBarcode(call, result)
            "cutPaper" -> handlePosCut(result)

            "tspl_printText" -> handleTsplPrintText(call, result)
            "tspl_printQRCode" -> handleTsplPrintQRCode(call, result)
            "tspl_printImage" -> handleTsplPrintImage(call, result)
            "tspl_printPDF" -> handleTsplPrintPDF(call, result)
            "tspl_printPDFBase64" -> handleTsplPrintPDFBase64(call, result)

            "printStatus" -> {
                val printer = printerManager.tsplPrinter
                if (printer == null) {
                    result.error("NO_PRINTER", "Printer not connected", null)
                    return
                }

                printer.printerStatus(1000) { statusCode ->
                    result.success(statusCode) // kirim integer ke Flutter
                }
            }

            else -> result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        statusChannel.setStreamHandler(null)
        scanningChannel.setStreamHandler(null)
        peripheralChannel.setStreamHandler(null)
    }

    /** POSPrinter */
    private fun handlePrintText(call: MethodCall, result: Result) {

        val args = call.arguments as? Map<String, Any> ?: run {
            invalidArgs(result)
            return
        }

        if (printerManager.posPrinter == null) {
            invalidPrinter(result)
            return
        }

        val attr = TextAttr.from(args)
        PosActivity.instance.printText(attr, printerManager.posPrinter!!)
        result.success(null)
    }

    private fun handlePrintImage(call: MethodCall, result: Result) {
        val args = call.arguments as? Map<String, Any> ?: run {
            invalidArgs(result)
            return
        }

        val base64Encoded = args["data"] as? String ?: run {
            invalidArgs(result)
            return
        }

        if (printerManager.posPrinter == null) {
            invalidPrinter(result)
            return
        }

        val width = args["width"] as? Double ?: 500

        PosActivity.instance.printImage(
            base64Encoded,
            width.toInt(),
            printerManager.posPrinter!!
        )
        
        result.success(null)
    }

    private fun handlePrintQRCode(call: MethodCall, result: Result) {
        val args = call.arguments as? Map<String, Any> ?: run {
            invalidArgs(result)
            return
        }

        val attr = QrcodeAttr.from(args);

        PosActivity.instance.printQRCode(printerManager.posPrinter!!, attr)
        result.success(null)
    }

    private fun handlePrintBarcode(call: MethodCall, result: Result) {
        val args = call.arguments as? Map<String, Any> ?: run {
            invalidArgs(result)
            return
        }

        val attr = BarcodeAttr.from(args)
        PosActivity.instance.printBarcode(printerManager.posPrinter!!, attr)
        result.success(null)
    }

    private fun handlePosCut(result: Result) {
        printerManager.posPrinter?.let {
            PosActivity.instance.cutPaper(it)
            result.success(null)
        } ?: invalidPrinter(result)
    }

    /** TSPLPrinter */
    private fun handleTsplPrintText(call: MethodCall, result: Result) {
        val args = call.arguments as? Map<String, Any> ?: return invalidArgs(result)

        val printer = printerManager.tsplPrinter ?: return invalidPrinter(result)

        val attr = TextAttr.from(args)
        TSPLActivity.instance.printText(attr, printer)

        result.success(null)
    }

    private fun handleTsplPrintQRCode(call: MethodCall, result: Result) {
        val args = call.arguments as? Map<String, Any> ?: return invalidArgs(result)

        val printer = printerManager.tsplPrinter ?: return invalidPrinter(result)

        val attr = QrcodeAttr.from(args)
        TSPLActivity.instance.printQRCode(printer, attr)

        result.success(null)
    }

    private fun handleTsplPrintImage(call: MethodCall, result: Result) {
        try {
            val args = call.arguments as? Map<*, *> ?: return invalidArgs(result)

            val base64 = args["data"] as? String
            if (base64.isNullOrBlank()) {
                return result.error("INVALID_ARGUMENTS", "'data' (base64) is missing or empty", null)
            }

            val widthValue = args["width"]
            val width = when (widthValue) {
                is Int -> widthValue
                is Double -> widthValue.toInt()
                is Float -> widthValue.toInt()
                is Number -> widthValue.toInt()
                else -> 600 // default
            }

            val printer = printerManager.tsplPrinter
            if (printer == null) return invalidPrinter(result)

            TSPLActivity.instance.printImage(base64, width, printer)

            result.success(null)
        } catch (e: Exception) {
            Log.e("SmartPrinterPlugin", "Error in handleTsplPrintImage", e)
            result.error("UNEXPECTED_ERROR", e.message, e)
        }
    }

    private fun handleTsplPrintPDF(call: MethodCall, result: Result) {
        try {
            val args = call.arguments as? Map<*, *> ?: return invalidArgs(result)

            val filePath = args["filePath"] as? String
            if (filePath.isNullOrBlank()) {
                result.error("INVALID_ARGUMENTS", "Missing or empty 'filePath'", null)
                return
            }

            val labelRaw = args["label"] as? String
            val label = LabelSize.from(labelRaw)

            val file = File(filePath)
            if (!file.exists()) {
                result.error("FILE_NOT_FOUND", "PDF not found at path", filePath)
                return
            }

            val attr = TPdfAttr(filePath = filePath, labelSize = label)

            val printer = printerManager.tsplPrinter
            if (printer == null) {
                invalidPrinter(result)
                return
            }

            TSPLActivity.instance.printPDFFromPath(applicationContext, attr, printer)
            result.success(true)

        } catch (e: Exception) {
            Log.e("SmartPrinterPlugin", "Exception in handleTsplPrintPDF", e)
            result.error("UNEXPECTED_ERROR", e.message, e)
        }
    }

    private fun handleTsplPrintPDFBase64(call: MethodCall, result: Result) {
        try {
            val args = call.arguments as? Map<*, *> ?: run {
                result.error("INVALID_ARGUMENTS", "Arguments must be a map", null)
                return
            }

            val base64Encoded = args["base64"] as? String
            if (base64Encoded.isNullOrBlank()) {
                result.error("INVALID_ARGUMENTS", "Missing or empty 'base64'", null)
                return
            }

            val labelRaw = args["label"] as? String
            val label = LabelSize.from(labelRaw)

            val printer = printerManager.tsplPrinter
            if (printer == null) {
                invalidPrinter(result)
                return
            }

            TSPLActivity.instance.printPDFBase64(base64Encoded, label, printer)
            result.success(true)
        } catch (e: Exception) {
            result.error("UNEXPECTED_ERROR", e.message, e)
        }
    }

    private fun invalidArgs(result: Result) {
        result.error("INVALID_ARGUMENTS", "Invalid arguments", null)
    }

    private fun invalidPrinter(result: Result) {
        result.error("INVALID_PRINTER", "Invalid printer", null)
    }

}
