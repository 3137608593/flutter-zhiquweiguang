// === Single Expression Function in Kotlin ===

// Definition
// A function with a single expression can be written using '=' for brevity.
// The return type can be explicit or inferred.

// Usage
// Use single expression functions for simple, concise operations.

// Example
fun multiply(a: Int, b: Int): Int = a * b // Returns the product of two integers

fun main() {
    val result = multiply(5, 5) // Call the function and store the result
    println(result)             // Output: 25
}

// How It Works
// - The function body is replaced by a single expression after '='.
// - Kotlin infers the return type if not explicitly declared.
// - This syntax is ideal for small, straightforward functions.

// Notes & Tips
// - Use single expression functions to keep code concise and readable.
// - For complex logic, prefer block body functions with curly braces.
