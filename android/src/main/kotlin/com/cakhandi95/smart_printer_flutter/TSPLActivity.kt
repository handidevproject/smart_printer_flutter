package com.cakhandi95.smart_printer_flutter

import android.content.Context
import android.graphics.BitmapFactory
import android.util.Base64
import android.util.Log
import com.cakhandi95.smart_printer_flutter.models.QrcodeAttr
import com.cakhandi95.smart_printer_flutter.models.TPdfAttr
import com.cakhandi95.smart_printer_flutter.models.TextAttr
import com.cakhandi95.smart_printer_flutter.utils.LabelSize
import com.cakhandi95.smart_printer_flutter.utils.renderAllPagesFromPdf
import net.posprinter.TSPLConst
import net.posprinter.TSPLPrinter
import net.posprinter.model.AlgorithmType
import java.io.File

class TSPLActivity {

    companion object {
        val instance = TSPLActivity()
    }

    fun printText(attr: TextAttr, printer: TSPLPrinter) {
        if (attr.text.isEmpty()) return

        printer.sizeMm(60.0, 30.0)
            .density(10)
            .reference(0, 0)
            .direction(TSPLConst.DIRECTION_FORWARD)
            .cls()
            .text(attr.x, attr.y, attr.font, attr.rotation, attr.xMul, attr.yMul, attr.text)
            .print()

    }

    fun printImage(base64: String, with: Int, printer: TSPLPrinter) {
        val bytes = Base64.decode(base64, Base64.DEFAULT)
        val bm = BitmapFactory.decodeByteArray(bytes, 0, bytes.size) ?: return
        printer.sizeMm(60.0, 30.0)
            .cls()
            .bitmap(0, 0, TSPLConst.BMP_MODE_OVERWRITE, with, bm, AlgorithmType.Threshold)
            .print(1)
    }


    fun printQRCode(printer: TSPLPrinter, attr: QrcodeAttr) {
        printer.sizeMm(60.0, 30.0)
            .gapMm(0.0, 0.0)
            .cls()
            .qrcode(
                attr.x,
                attr.y,
                attr.eccLevel,
                attr.unitSize,
                attr.mode,
                attr.rotation,
                attr.code
            )
            .print()
    }


    fun printStatus(printer: TSPLPrinter, callback: (String) -> Unit) {
        printer.printerStatus(1000) {
            val status = when (it) {
                0 -> "Normal"
                1 -> "Head opened"
                2 -> "Paper Jam"
                3 -> "Paper Jam and head opened"
                4 -> "Out of paper"
                5 -> "Out of paper and head opened"
                8 -> "Out of ribbon"
                9 -> "Out of ribbon and head opened"
                10 -> "Out of ribbon and paper jam"
                11 -> "Out of ribbon, paper jam and head opened"
                12 -> "Out of ribbon and out of paper"
                13 -> "Out of ribbon, out of paper and head opened"
                16 -> "Pause"
                32 -> "Printing"
                else -> "Other error"
            }
            callback(status)
        }
    }

    fun printPDFBase64(base64: String, labelSize: LabelSize, printer: TSPLPrinter) {
        val bytes = Base64.decode(base64, Base64.DEFAULT)
        val pdfFile = File.createTempFile("temp_pdf", ".pdf")
        pdfFile.writeBytes(bytes)

        val (widthMm, heightMm) = labelSize.value.split("x").mapNotNull { it.toIntOrNull() }

        val bitmaps = renderAllPagesFromPdf(pdfFile, widthMm.toDouble())

        for ((index, bitmap) in bitmaps.withIndex()) {
            println("Page $index → bitmap: ${bitmap.width}x${bitmap.height} → height: ${heightMm} mm")

            printer
                .sizeMm(widthMm.toDouble(), heightMm.toDouble())
                .gapInch(0.0, 0.0)
                .offsetInch(0.0)
                .speed(5.0)
                .density(10)
                .direction(TSPLConst.DIRECTION_FORWARD)
                .reference(20, 0)
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
            // Thread.sleep(1000)
        }

        pdfFile.delete()
    }

    var isPrinting = false

    @Synchronized
    fun printPDFFromPath(context: Context, attr: TPdfAttr, printer: TSPLPrinter) {
        if (isPrinting) {
            Log.w("TSPLPrint", "Already printing, skipping duplicate call")
            return
        }
        isPrinting = true

        try {
            val file = File(attr.filePath)
            if (!file.exists()) {
                Log.e("TSPLActivity", "PDF not found: ${attr.filePath}")
                return
            }

            val (widthMm, heightMm) = attr.labelSize.value.split("x").mapNotNull { it.toIntOrNull() }
            val bitmaps = renderAllPagesFromPdf(file, widthMm.toDouble())

            for ((index, bitmap) in bitmaps.withIndex()) {
                println("Page $index → bitmap: ${bitmap.width}x${bitmap.height} → height: ${heightMm.toDouble()} mm")

                printer
                    .sizeMm(widthMm.toDouble(), heightMm.toDouble())
                    .gapInch(0.0, 0.0)
                    .offsetInch(0.0)
                    .speed(5.0)
                    .density(10)
                    .direction(TSPLConst.DIRECTION_FORWARD)
                    .reference(20, 0)
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
            }
        } catch (e: Exception) {
            Log.e("TSPLActivity", "Error printing PDF: ${e.message}", e)
        } finally {
            isPrinting = false
        }
    }
}