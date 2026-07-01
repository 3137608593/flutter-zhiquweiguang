// === Function with Default Parameters in Kotlin ===
// Definition: A function can have default values for parameters.
//   When no argument is provided for such a parameter, the default value is used.

// Usage: Useful when some arguments are optional, so the caller doesn't need to pass all parameters.

// Example:
fun hello(firstName: String, lastName: String = "") {
    println("Hello $firstName $lastName")
}

fun main() {
    hello("Ryan") // Output: Hello Ryan
    hello("Ryan", "Aprianto") // Output: Hello Ryan Aprianto
}

// How It Works:
//   1. The `lastName` parameter has a default value of an empty string.
//   2. When calling `hello("Ryan")`, `lastName` uses the default value.
//   3. When calling `hello("Ryan", "Aprianto")`, `lastName` is overridden.
// Notes & Tips:
//   - Default parameters reduce the need for method overloading.
//   - Defaults can be any constant or computed value.
//   - Parameters with defaults must come after non-default parameters.
