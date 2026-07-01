// === While Loop in Kotlin ===

// Definition
// The 'while' loop executes a block repeatedly while the condition is true.

// Usage
// Use 'while' loops when the number of iterations is not predetermined.

// Example
fun main() {
    var i = 0

    while (i <= 10) {
        println(i) // Prints current value of i
        i++        // Increment i by 1
    }
}

// How It Works
// - The condition is evaluated before each iteration.
// - If the condition is false initially, the loop body does not run.

// Notes & Tips
// - Use 'while' for loops where iteration count depends on dynamic conditions.
// - Be careful to avoid infinite loops by ensuring the condition eventually becomes false.
