// === Basic Mathematical Operations in Kotlin (+, -, *, /, %) ===

// Definition
// Mathematical operators perform arithmetic calculations on numeric values.
// Common operators include addition (+), subtraction (-), multiplication (*), division (/), and modulus (%).

// Usage
// Use these operators to perform basic math calculations in your programs.
// Use parentheses to control the order of operations.

// Example
fun main() {
    val math = 10.0 / 3.0  // Division of two Double numbers
    val result = 10 + (10 * 2) // Operator precedence: multiplication before addition

    println(math)   // Output: 3.3333333333333335
    println(result) // Output: 30

    // Augmented assignment example
    var augmentedMath = math
    augmentedMath += 10  // Equivalent to augmentedMath = augmentedMath + 10
    println(augmentedMath)   // Output: 13.333333333333334

    // Unary operators example
    augmentedMath++       // Increment by 1
    println(augmentedMath)   // Output: 14.333333333333334
}

// How It Works
// - Operators like +, -, *, /, and % perform arithmetic operations.
// - Augmented assignments combine an operation with assignment (e.g., +=).
// - Unary operators modify a single operand (++ increments, -- decrements).
// - Operator precedence determines the order operations are performed.

// Notes & Tips
// - Use parentheses to ensure the desired order of evaluation.
// - Augmented assignments simplify code for modifying variables.
// - Unary operators provide shorthand for incrementing, decrementing, negating, or logical NOT.
