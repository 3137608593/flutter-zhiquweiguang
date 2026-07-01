// === Number Types in Kotlin ===

// Definition
// Kotlin provides several numeric types to represent integer and floating-point numbers,
// each with a specific size and range.

// Usage
// Use appropriate numeric types depending on the range and precision you need.
// Use explicit conversions when changing between numeric types.

// Example
fun main() {
    // Integer Types
    val age: Byte = 27                    // 8-bit signed integer (-128 to 127)
    val height: Int = 169                 // 32-bit signed integer (default for integers)
    val distance: Short = 2000            // 16-bit signed integer (-32,768 to 32,767)
    val balance: Long = 1_000_000L       // 64-bit signed integer (use 'L' suffix)

    // Floating-Point Types
    val value: Float = 3.14F              // 32-bit floating point (use 'F' suffix)
    val radius: Double = 20.0             // 64-bit floating point (default for decimals)

    // Number Literals
    val decimalLiteral: Int = 100         // Decimal (base 10)
    val hexadecimalLiteral: Int = 0xFF    // Hexadecimal (base 16), equals 255 decimal
    val binaryLiteral: Int = 0b0001       // Binary (base 2), equals 1 decimal

    // Using Underscores for Readability
    val price: Long = 1_000_000_000L      // Underscores improve readability

    // Number Conversion (explicit)
    val number: Int = 11
    val byte: Byte = number.toByte()           // Convert Int to Byte
    val integer: Int = number.toInt()           // Convert Int to Int (no-op)
    val short: Short = number.toShort()         // Convert Int to Short
    val long: Long = number.toLong()            // Convert Int to Long
    val float: Float = number.toFloat()         // Convert Int to Float
    val double: Double = number.toDouble()      // Convert Int to Double

    // Output
    println(balance) // Output: 1000000
}

// How It Works
// - Kotlin numeric types have fixed sizes and ranges.
// - Use suffixes 'L' for Long and 'F' for Float literals.
// - Underscores (_) can be used inside numeric literals for clarity.
// - Kotlin does not do implicit widening conversions; explicit conversion is required.

// Notes & Tips
// - Use the smallest type that fits your data to save memory.
// - Always append suffixes for Long and Float literals.
// - Use explicit conversion functions to convert between types safely.
// - Underscores in numeric literals improve code readability.
