package com.cakhandi95.smart_printer_flutter.utils

import android.graphics.Bitmap
import android.graphics.pdf.PdfRenderer
import android.os.ParcelFileDescriptor
import androidx.core.graphics.createBitmap
import java.io.File

/**
 * Created by handy on 14/07/25.
 * it.handy@borwita.co.id / it.handy
 */

fun renderAllPagesFromPdf(
    file: File,
    labelWidthMm: Double,
): List<Bitmap> {
    val result = mutableListOf<Bitmap>()
    val fileDescriptor = ParcelFileDescriptor.open(file, ParcelFileDescriptor.MODE_READ_ONLY)
    val pdfRenderer = PdfRenderer(fileDescriptor)

    val dpi = 197
    val dotsPerMm = dpi / 25.4
    val targetWidthDots = (labelWidthMm * dotsPerMm).toInt()

    for (i in 0 until pdfRenderer.pageCount) {
        val page = pdfRenderer.openPage(i)
        val scaleFactor = targetWidthDots.toFloat() / page.width.toFloat()
        val targetHeightDots = (page.height * scaleFactor).toInt()

        val bitmap = createBitmap(targetWidthDots, targetHeightDots, Bitmap.Config.ARGB_8888)
        page.render(bitmap, null, null, PdfRenderer.Page.RENDER_MODE_FOR_PRINT)
        result.add(bitmap)
        page.close()
    }

    pdfRenderer.close()
    fileDescriptor.close()

    return result
}