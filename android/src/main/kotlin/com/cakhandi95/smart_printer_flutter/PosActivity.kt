
import android.graphics.BitmapFactory
import android.util.Base64
import com.cakhandi95.smart_printer_flutter.models.BarcodeAttr
import com.cakhandi95.smart_printer_flutter.models.QrcodeAttr
import com.cakhandi95.smart_printer_flutter.models.TextAttr
import net.posprinter.POSConst
import net.posprinter.POSPrinter

class PosActivity {

    companion object {
        val instance = PosActivity()
    }

    fun printText(attr: TextAttr, printer: POSPrinter) {
        val aligns =
            arrayOf(POSConst.ALIGNMENT_LEFT, POSConst.ALIGNMENT_CENTER, POSConst.ALIGNMENT_RIGHT)
        val attributes = arrayOf(
            POSConst.FNT_DEFAULT,
            POSConst.FNT_FONTB,
            POSConst.FNT_FONTB,
            POSConst.FNT_REVERSE,
            POSConst.FNT_UNDERLINE,
            POSConst.FNT_UNDERLINE2
        )
        val textSize = arrayOf(
            POSConst.TXT_1WIDTH,
            POSConst.TXT_2WIDTH,
            POSConst.TXT_3WIDTH,
            POSConst.TXT_4WIDTH,
        )

        printer.initializePrinter().printText(
            "${attr.text}\n",
            aligns[attr.align],
            attributes[attr.attribute],
            textSize[attr.height]
        )
    }

    fun printImage(base64: String, with: Int, printer: POSPrinter) {
        val bytes = Base64.decode(base64, Base64.DEFAULT)
        val bm = BitmapFactory.decodeByteArray(bytes, 0, bytes.size)
        printer.initializePrinter()
            .printBitmap(bm, POSConst.ALIGNMENT_CENTER, with)
    }

    fun cutPaper(printer: POSPrinter) {
        printer.initializePrinter()
            .feedLine(3)
            .cutHalfAndFeed(1)
    }

    fun printQRCode(printer: POSPrinter, attr: QrcodeAttr) {
        val arrLevels = arrayOf(
            POSConst.QRCODE_EC_LEVEL_L,
            POSConst.QRCODE_EC_LEVEL_M,
            POSConst.QRCODE_EC_LEVEL_Q,
            POSConst.QRCODE_EC_LEVEL_H
        )

        printer.printQRCode(
            attr.code,
            attr.unitSize,
            arrLevels[attr.errLevel - 48],
            POSConst.ALIGNMENT_CENTER
        )
    }

    fun printBarcode(printer: POSPrinter, attr: BarcodeAttr) {
        val types = arrayOf(
            POSConst.BCS_UPCA,
            POSConst.BCS_UPCE,
            POSConst.BCS_EAN13,
            POSConst.BCS_EAN13,
            POSConst.BCS_Code39,
            POSConst.BCS_ITF,
            POSConst.BCS_Codabar,
            POSConst.BCS_Code93,
            POSConst.BCS_Code128,
        )

        printer.printBarCode(
            attr.content,
            types[attr.typePos],
            3,
            70,
            POSConst.ALIGNMENT_CENTER
        )
    }
}