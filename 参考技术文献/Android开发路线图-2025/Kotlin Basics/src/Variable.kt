// === Constant and Variable Declaration in Kotlin ===

// Definition
// 'const val' declares compile-time constants that must be initialized at declaration and cannot change.
// 'var' declares mutable variables whose values can be reassigned.
// 'val' declares immutable variables which can be assigned only once.
// Nullable variables are declared by appending '?' to the type, allowing them to hold null.

// Usage
// Use 'const val' for fixed values known at compile time, declared at the top level.
// Use 'var' when you expect the value to change over time.
// Use 'val' when you want a read-only reference after initialization.
// Use nullable types to represent variables that may have no value (null).

// Example
const val VERSION: String = "1.0"

fun main() {
    var name: String = "Ryan"      // Mutable variable
    name = "Ryan Aprianto"         // Value reassigned

    val age: Int = 18              // Immutable variable

    val address: String? = null    // Nullable variable

    println("Name: $name")
    println("Age: $age")
    println("Address: $address")
    println("App Version: $VERSION")
}

// How It Works
// - 'const val' must be declared outside functions and initialized immediately.
// - 'var' variables can be reassigned any number of times.
// - 'val' variables cannot be reassigned after initialization.
// - Nullable types allow 'null' but require safe handling to avoid errors.

// Notes & Tips
// - Prefer 'val' over 'var' when reassignment is not needed to ensure immutability.
// - Use 'const val' for global constants for performance and clarity.
// - Avoid null where possible to reduce runtime exceptions.
// - Use Kotlin's null-safety features to handle nullable types safely.
