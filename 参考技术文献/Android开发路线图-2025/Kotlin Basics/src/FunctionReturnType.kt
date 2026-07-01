// === Function with Return Type in Kotlin ===

// Definition
// Functions can return a value by specifying the return type after the parameter list.

// Usage
// Use return type to indicate the type of value the function will produce.

// Example
fun sum(a: Int, b: Int): Int {
    return a + b // Return the sum of two integers
}

fun main() {
    val result = sum(a = 10, b = 20) // Store returned value in a variable
    println(result) // Output: 30
}

// How It Works
// 1. The function `sum` takes two integers as parameters.
// 2. The `: Int` after the parameter list specifies the return type.
// 3. The `return` statement sends the result back to the caller.
// 4. In `main`, the returned value is stored in `result` and printed.

// Notes & Tips
// Always specify the return type explicitly for better readability.
// Kotlin can infer the return type, but explicit declaration is recommended for public APIs.
