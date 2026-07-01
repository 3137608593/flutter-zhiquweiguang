package app

import data.HandPhone
import data.Laptop

fun printObject(any: Any) {
    when (any) {
        is Laptop -> println("Laptop with name: ${any.name}")
        is HandPhone -> println("HandPhone with name: ${any.name}")
        else -> println(any)
    }
}

fun printString(any: Any) {
    val value = any as String
    println(value)
}

fun printStringSafe(any: Any) {
    val value: String? = any as? String
    println(value)
}

fun main() {
    printString("Samsung S20")
    printStringSafe(1)
    printObject(Laptop("ASUS"))
}