package com.cakhandi95.smart_printer_flutter.models

import android.bluetooth.BluetoothDevice
import android.content.Context
import com.cakhandi95.smart_printer_flutter.utils.LabelSize
import com.cakhandi95.smart_printer_flutter.utils.renderAllPagesFromPdf
import net.posprinter.POSPrinter
import net.posprinter.TSPLConst
import net.posprinter.TSPLPrinter
import net.posprinter.model.AlgorithmType
import java.io.File

/**
 * Created by handy on 14/07/25.
 */

data class TextAttr(
    var text: String = "",

    // POSPrinter
    var align: Int = 0,
    var attribute: Int = 0,
    var height: Int = 1, // multiplier
    var width: Int = 1,

    // TSPLPrinter
    var x: Int = 0,
    var y: Int = 0,
    var font: String = TSPLConst.FNT_8_12,
    var rotation: Int = TSPLConst.ROTATION_0,
    var xMul: Int = 1,
    var yMul: Int = 1
) {
    companion object {
        fun from(map: Map<String, Any>): TextAttr {
            return TextAttr(
                text = map["text"] as? String ?: "",
                align = (map["align"] as? Number)?.toInt() ?: 0,
                attribute = (map["attribute"] as? Number)?.toInt() ?: 0,
                height = (map["height"] as? Number)?.toInt() ?: 1,
                width = (map["width"] as? Number)?.toInt() ?: 1,

                x = (map["x"] as? Number)?.toInt() ?: 0,
                y = (map["y"] as? Number)?.toInt() ?: 0,
                font = map["font"] as? String ?: TSPLConst.FNT_8_12,
                rotation = (map["rotation"] as? Number)?.toInt() ?: TSPLConst.ROTATION_0,
                xMul = (map["xMul"] as? Number)?.toInt() ?: 1,
                yMul = (map["yMul"] as? Number)?.toInt() ?: 1
            )
        }
    }

    fun printToPOS(printer: POSPrinter) {
        printer.printText(text, align, attribute, height * 16)
    }

    fun printToTSPL(printer: TSPLPrinter) {
        printer.text(x, y, font, rotation, xMul, yMul, text)
    }
}

data class BarcodeAttr(
    var content: String = "",

    // POSPrinter
    var typePos: Int = 0,
    var encoding: Int = 0,

    // TSPLPrinter
    var x: Int = 0,
    var y: Int = 0,
    var typeTspl: String = TSPLConst.CODE_TYPE_128,
    var height: Int = 100,
    var readable: Int = TSPLConst.READABLE_CENTER,
    var rotation: Int = TSPLConst.ROTATION_0,
    var narrow: Int = 2,
    var wide: Int = 2
) {
    companion object {
        fun from(map: Map<String, Any>): BarcodeAttr {
            return BarcodeAttr(
                content = map["content"] as? String ?: "",
                typePos = (map["type"] as? Number)?.toInt() ?: 0,
                encoding = (map["encoding"] as? Number)?.toInt() ?: 0,

                x = (map["x"] as? Number)?.toInt() ?: 0,
                y = (map["y"] as? Number)?.toInt() ?: 0,
                typeTspl = map["typeTspl"] as? String ?: TSPLConst.CODE_TYPE_128,
                height = (map["height"] as? Number)?.toInt() ?: 100,
                readable = (map["readable"] as? Number)?.toInt() ?: TSPLConst.READABLE_CENTER,
                rotation = (map["rotation"] as? Number)?.toInt() ?: TSPLConst.ROTATION_0,
                narrow = (map["narrow"] as? Number)?.toInt() ?: 2,
                wide = (map["wide"] as? Number)?.toInt() ?: 2
            )
        }
    }

    fun printToPOS(printer: POSPrinter) {
        printer.printQRCode(content, typePos, encoding)
    }

    fun printToTSPL(printer: TSPLPrinter) {
        printer.barcode(x, y, typeTspl, height, readable, rotation, narrow, wide, content)
    }
}

data class QrcodeAttr(
    var code: String = "",

    // POSPrinter
    var unitSize: Int = 4,
    var errLevel: Int = 0,
    var encoding: Int = 0,

    // TSPLPrinter
    var x: Int = 0,
    var y: Int = 0,
    var eccLevel: String = TSPLConst.EC_LEVEL_H,
    var mode: String = TSPLConst.QRCODE_MODE_MANUAL,
    var rotation: Int = TSPLConst.ROTATION_0
) {
    companion object {
        fun from(map: Map<String, Any>): QrcodeAttr {
            return QrcodeAttr(
                code = map["code"] as? String ?: "",
                unitSize = (map["unitSize"] as? Number)?.toInt() ?: 4,
                errLevel = (map["errLevel"] as? Number)?.toInt() ?: 0,
                encoding = (map["encoding"] as? Number)?.toInt() ?: 0,

                x = (map["x"] as? Number)?.toInt() ?: 0,
                y = (map["y"] as? Number)?.toInt() ?: 0,
                eccLevel = map["eccLevel"] as? String ?: TSPLConst.EC_LEVEL_H,
                mode = map["mode"] as? String ?: TSPLConst.QRCODE_MODE_MANUAL,
                rotation = (map["rotation"] as? Number)?.toInt() ?: TSPLConst.ROTATION_0
            )
        }
    }
    fun printToPOS(printer: POSPrinter) {
        printer.printQRCode(code, unitSize, errLevel, encoding)
    }

    fun printToTSPL(printer: TSPLPrinter) {
        printer.qrcode(x, y, eccLevel, unitSize, mode, rotation, code)
    }
}

data class TPdfAttr(
    val filePath: String,
    val labelSize: LabelSize
) {
    companion object {
        fun from(map: Map<String, Any>): TPdfAttr {
            return TPdfAttr(
                filePath = map["filePath"] as? String ?: "",
                labelSize = (map["labelSize"] as? LabelSize) ?: LabelSize.DEFAULT,
            )
        }
    }
    fun print(context: Context, printer: TSPLPrinter) {
        val file = File(filePath)
        if (!file.exists()) return

        val (widthMm, heightMm) = labelSize.value.split("x").mapNotNull { it.toIntOrNull() }

        val bitmaps = renderAllPagesFromPdf(file, widthMm.toDouble())

        //val bitmaps = renderAllPagesFromPdf(file, widthMm, heightMm)

        for (bitmap in bitmaps) {
            printer
                .sizeMm(widthMm.toDouble(), heightMm.toDouble())
                .gapInch(0.0, 0.0)
                .offsetInch(0.0)
                .speed(5.0)
                .density(10)
                .direction(TSPLConst.DIRECTION_FORWARD)
                .reference(0, 0)
                .cls()
                .bitmap(
                    0,
                    0,
                    TSPLConst.BMP_MODE_OVERWRITE,
                    bitmap.width,
                    bitmap,
                    AlgorithmType.Threshold
                )
                .print(1)

            // Optional: Delay per page
            // Thread.sleep(500)
        }
    }
}

/** Utils */
fun BluetoothDevice.toDict(): Map<String, Any?> {
    return mapOf(
        "name" to name,
        "uuid" to address,
        "state" to bondState,
    )
}

enum class PeripheralStatus(val value: Int) {
    CONNECTING(0),
    CONNECTED(1),
    DISCONNECTED(2),
    CONNECT_FAILED(3)
}