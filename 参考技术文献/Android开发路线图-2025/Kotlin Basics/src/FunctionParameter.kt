// === Function Parameters in Kotlin ===
// Definition: Functions can accept input values called parameters.
// Parameters allow passing data into functions for processing.

// Usage: Pass data to a function through parameters to customize its behavior.

fun sayHello(firstName: String, lastName: String?) {
    // Check if 'lastName' is null to customize the greeting
    if (lastName == null)
        println("Hello $firstName!")
    else
        println("Hello $firstName $lastName!")
}

fun main() {
    // Example: Calling function with parameters
    sayHello("Ryan", "Aprianto") // Output: Hello Ryan Aprianto!
}

// How It Works:
// - Parameters are defined in parentheses after the function name.
// - Nullable parameters (e.g., String?) can hold a null value.
// - Null checks allow customizing behavior based on parameter values.

// Notes & Tips:
// - Parameters can be nullable or non-nullable.
// - Use null checks to handle optional parameters safely.
// - String templates simplify output formatting.
