package com.cakhandi95.smart_printer_flutter.utils

enum class LabelSize(val value: String) {
    SIZE_78x60("78x60"),
    SIZE_78x100("78x100"),
    SIZE_78x120("78x120"),
    SIZE_80x80("80x80"),
    SIZE_100x100("100x100"),
    SIZE_100x150("100x150"),
    SIZE_102x127("102x127"),
    SIZE_58_CONT("58x200"),
    SIZE_80_CONT("80x200"),
    DEFAULT("76x100");

    companion object {
        fun from(value: String?): LabelSize {
            return values().firstOrNull { it.value == value }
                ?: SIZE_78x60 // default
        }
    }
}