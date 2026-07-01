// === Range in Kotlin ===

// Definition
// A range represents a sequence of values between a start and an end value (inclusive).
// The ".." operator creates an increasing range.

// Usage
// Use ranges for iteration, conditional checks, or sequences of values.

// Example
fun main() {
    val range = 1..100           // Numbers from 1 to 100

    // Common Range Operations
    // count()      -> returns the number of elements
    // contains(x)  -> checks if a value is in the range
    // first        -> returns the first element
    // last         -> returns the last element
    // step         -> returns the step value

    // Reversed Range
    val values = 100 downTo 0    // Numbers from 100 down to 0

    // Range with Step
    val numbers = 100 downTo 0 step 10  // 100, 90, 80, ..., 0

    println(numbers.toList())    // Output: [100, 90, 80, 70, 60, 50, 40, 30, 20, 10, 0]
}

// How It Works
// - ".." creates an increasing range including start and end.
// - "downTo" creates a decreasing range.
// - "step" defines the interval between elements in the range.
// - Ranges are often used in loops and conditional expressions.

// Notes & Tips
// - Use ranges to simplify loops and conditions involving sequences.
// - Use "downTo" for descending sequences.
// - Use "step" to control increments or decrements within the range.
// - Convert ranges to lists with toList() when you need to access elements directly.
