package com.cakhandi95.smart_printer_flutter.utils

enum class LabelSize(val widthMm: Double, val heightMm: Double) {
    SIZE_78x60(78.0, 60.0),
    SIZE_78x100(78.0, 100.0),
    SIZE_78x120(78.0, 120.0),
    SIZE_80x80(80.0, 80.0),
    SIZE_100x100(100.0, 100.0),
    SIZE_100x150(100.0, 150.0),
    SIZE_102x127(102.0, 127.0),
    SIZE_58_CONT(58.0, 200.0),
    SIZE_80_CONT(80.0, 200.0),
    DEFAULT(76.0, 100.0);

    companion object {
        fun get(label: String): Pair<Double, Double> {
            return when (label) {
                "78x60" -> SIZE_78x60
                "78x100" -> SIZE_78x100
                "78x120" -> SIZE_78x120
                "80x80" -> SIZE_80x80
                "100x100" -> SIZE_100x100
                "100x150" -> SIZE_100x150
                "102x127" -> SIZE_102x127
                "58 Continuous" -> SIZE_58_CONT
                "80 Continuous" -> SIZE_80_CONT
                else -> DEFAULT
            }.let { it.widthMm to it.heightMm }
        }
    }
}