// === Function Returning Unit in Kotlin ===

// Definition
// 'Unit' is the Kotlin equivalent of 'void' in other languages.
// It indicates the function does not return a meaningful value.

// Usage
// Use Unit-returning functions for performing actions without returning data.

// Example
fun printHello(name: String): Unit {
    println("Hello $name") // Prints a greeting message
}

fun main() {
    printHello("Ryan") // Output: Hello Ryan
}

// How It Works
// - Functions that return Unit do not return a value you can use.
// - Declaring ': Unit' is optional since it's the default for functions without a return.

// Notes & Tips
// - Use Unit functions for side-effect operations such as printing or logging.
// - Omitting ': Unit' makes the code cleaner but explicit declaration can improve readability.
