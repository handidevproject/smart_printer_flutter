package com.cakhandi95.smart_printer_flutter.utils

import android.graphics.Bitmap
import android.graphics.pdf.PdfRenderer
import android.os.ParcelFileDescriptor
import androidx.core.graphics.createBitmap
import net.posprinter.TSPLPrinter
import java.io.File

fun renderAllPagesFromPdf(
    file: File,
    widthMm: Double,
    printer: TSPLPrinter,
    dpi: Int? = null
): List<Bitmap> {
    val bitmaps = mutableListOf<Bitmap>()
    val fileDescriptor = ParcelFileDescriptor.open(file, ParcelFileDescriptor.MODE_READ_ONLY)
    val renderer = PdfRenderer(fileDescriptor)

    val printerDpi = dpi ?: 203

    val safeWidthMm = widthMm - 4.0
    val widthPx = ((safeWidthMm / 25.4) * printerDpi).toInt()


    for (i in 0 until renderer.pageCount) {
        renderer.openPage(i).use { page ->
            val aspect = page.width.toFloat() / page.height.toFloat()
            val heightPx = (widthPx / aspect).toInt()

            val bitmap = createBitmap(widthPx, heightPx)
            page.render(bitmap, null, null, PdfRenderer.Page.RENDER_MODE_FOR_PRINT)

            bitmaps.add(bitmap)
        }
    }

    renderer.close()
    fileDescriptor.close()
    return bitmaps
}