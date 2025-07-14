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
import com.cakhandi95.smart_printer_flutter.utils.LabelSize
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import java.io.File

/** SmartPrinterFlutterPlugin */
class SmartPrinterFlutterPlugin: FlutterPlugin, MethodCallHandler {

  private val TAG = "SmartPrinterFlutterPlugin";

  private lateinit var channel: MethodChannel
  private lateinit var statusChannel: EventChannel
  private lateinit var scanningChannel: EventChannel
  private lateinit var peripheralChannel: EventChannel
  private lateinit var bleManager: BleManager


  private var statusEventSink: EventChannel.EventSink? = null
  private var scanningEventSink: EventChannel.EventSink? = null
  private var peripheralEventSink: EventChannel.EventSink? = null

  private lateinit var applicationContext: Context


  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    applicationContext = flutterPluginBinding.applicationContext

    Log.d(TAG, "onAttachedToEngine")
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "x_printer")
    channel.setMethodCallHandler(this)

    statusChannel = EventChannel(flutterPluginBinding.binaryMessenger, "x_printer/status")
    scanningChannel = EventChannel(flutterPluginBinding.binaryMessenger, "x_printer/scanning")
    peripheralChannel = EventChannel(flutterPluginBinding.binaryMessenger, "x_printer/peripheral")

    statusChannel.setStreamHandler(createStreamHandler { sink -> statusEventSink = sink })
    scanningChannel.setStreamHandler(createStreamHandler { sink -> scanningEventSink = sink })
    peripheralChannel.setStreamHandler(createStreamHandler { sink -> peripheralEventSink = sink })

    initBleManager()
  }

  private fun initBleManager() {
    if (::bleManager.isInitialized) return

    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S &&
      applicationContext.checkSelfPermission(Manifest.permission.BLUETOOTH_CONNECT)
      != PackageManager.PERMISSION_GRANTED) return

    bleManager = BleManager(
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
    if (!::bleManager.isInitialized) {
      initBleManager()
      if (!::bleManager.isInitialized) {
        result.error("PERMISSION_DENIED", "BLUETOOTH_CONNECT is denied", null)
        return
      }
    }
    when (call.method) {
      "connect" -> handleConnect(call, result)
      "disconnect" -> bleManager.disconnect()

      // POS printer handlers
      "pos_printText" -> handlePrintText(call, result)
      "pos_printImage" -> handlePrintImage(call, result)
      "pos_printQRCode" -> handlePrintQRCode(call, result)
      "pos_printBarcode" -> handlePrintBarcode(call, result)
      "cutPaper" -> handlePosCut(result)

      // TSPL printer handlers
      "tspl_printText" -> handleTsplPrintText(call, result)
      "tspl_printQRCode" -> handleTsplPrintQRCode(call, result)
      "tspl_printImage" -> handleTsplPrintImage(call, result)
      "tspl_printPDF" -> handleTsplPrintPDF(call, result)
      "tspl_printPDFBase64" -> handleTsplPrintPDFBase64(call, result)

      else -> result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
    statusChannel.setStreamHandler(null)
    scanningChannel.setStreamHandler(null)
    peripheralChannel.setStreamHandler(null)
  }

  private fun handleConnect(call: MethodCall, result: Result) {
    val deviceId = (call.argument<String>("deviceId") ?: "").ifEmpty {
      result.error("INVALID_ARGUMENTS", "deviceId required", null); return
    }
    bleManager.connectToDevice(deviceId)
    result.success(null)
  }

  /** POSPrinter */
  private fun handlePrintText(call: MethodCall, result: Result) {

    val args = call.arguments as? Map<String, Any> ?: run {
      invalidArgs(result)
      return
    }

    if (bleManager.posPrinter == null) {
      invalidPrinter(result)
      return
    }

    val attr = TextAttr.from(args)
    PosActivity.instance.printText(attr, bleManager.posPrinter!!)
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

    if (bleManager.posPrinter == null) {
      invalidPrinter(result)
      return
    }

    val width = args["width"] as? Double ?: 500

    PosActivity.instance.printImage(
      base64Encoded,
      width.toInt(),
      bleManager.posPrinter!!
    )
  }

  private fun handlePrintQRCode(call: MethodCall, result: Result) {
    val args = call.arguments as? Map<String, Any> ?: run {
      invalidArgs(result)
      return
    }

    val attr = QrcodeAttr.from(args);

    PosActivity.instance.printQRCode(bleManager.posPrinter!!, attr)
  }

  private fun handlePrintBarcode(call: MethodCall, result: Result) {
    val args = call.arguments as? Map<String, Any> ?: run {
      invalidArgs(result)
      return
    }

    val attr = BarcodeAttr.from(args)
    PosActivity.instance.printBarcode(bleManager.posPrinter!!, attr)
  }

  private fun handlePosCut(result: Result) {
    bleManager.posPrinter?.let {
      PosActivity.instance.cutPaper(it)
      result.success(null)
    } ?: invalidPrinter(result)
  }

  /** TSPLPrinter */
  private fun handleTsplPrintText(call: MethodCall, result: Result) {
    val args = call.arguments as? Map<String, Any> ?: return invalidArgs(result)

    val printer = bleManager.tsplPrinter ?: return invalidPrinter(result)

    val attr = TextAttr.from(args)
    TSPLActivity.instance.printText(attr, printer)

    result.success(null)
  }

  private fun handleTsplPrintQRCode(call: MethodCall, result: Result) {
    val args = call.arguments as? Map<String, Any> ?: return invalidArgs(result)

    val printer = bleManager.tsplPrinter ?: return invalidPrinter(result)

    val attr = QrcodeAttr.from(args)
    TSPLActivity.instance.printQRCode(printer, attr)

    result.success(null)
  }

  private fun handleTsplPrintImage(call: MethodCall, result: Result) {
    val args = call.arguments as? Map<String, Any> ?: return invalidArgs(result)

    val base64 = args["data"] as? String ?: return invalidArgs(result)
    val width = (args["width"] as? Double ?: 600.0).toInt()

    val printer = bleManager.tsplPrinter ?: return invalidPrinter(result)

    TSPLActivity.instance.printImage(base64, width, printer)

    result.success(null)
  }

  private fun handleTsplPrintPDF(call: MethodCall, result: Result) {
    val args = call.arguments as Map<String, Any>
    val filePath = args["filePath"] as? String
    val label = args["label"] as? LabelSize ?: LabelSize.DEFAULT

    if (filePath == null || filePath.isEmpty()) {
      result.error("INVALID_ARGUMENTS", "Missing filePath", null)
      return
    }

    val file = File(filePath)
    if (!file.exists()) {
      result.error("FILE_NOT_FOUND", "PDF not found", filePath)
      return
    }

    val attr = TPdfAttr(filePath = filePath, labelSize = label)
    bleManager.tsplPrinter?.let {
      TSPLActivity.instance.printPDFFromPath(applicationContext, attr, it)
      result.success(true)
    } ?: invalidPrinter(result)
  }

  private fun handleTsplPrintPDFBase64(call: MethodCall, result: Result) {
    val args = call.arguments as Map<String, Any>

    val base64Encoded = args["data"] as? String ?: run {
      result.error("INVALID_ARGUMENTS", "Missing base64", null)
      return
    }
    val label = args["label"] as? LabelSize ?: LabelSize.DEFAULT

    bleManager.tsplPrinter?.let {
      TSPLActivity.instance.printPDFBase64(base64Encoded, label, it)
      result.success(true)
    } ?: invalidPrinter(result)
  }

  private fun invalidArgs(result: Result) {
    result.error("INVALID_ARGUMENTS", "Invalid arguments", null)
  }

  private fun invalidPrinter(result: Result) {
    result.error("INVALID_PRINTER", "Invalid printer", null)
  }




}
