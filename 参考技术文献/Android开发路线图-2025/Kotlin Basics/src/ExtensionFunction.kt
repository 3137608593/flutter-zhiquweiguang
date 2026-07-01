// === Extension Function in Kotlin ===

// Definition:
// Extension functions allow you to add new functions to existing classes
// without modifying their source code. They are defined outside the class
// but can be called as if they were part of the class.

// Usage:
// Use extension functions to make your code cleaner and extend the
// functionality of a class you don’t own or can’t modify.

// Example:
fun String.hello(): String = "Hello $this"

fun main() {
    val name: String = "Ryan" // Create a String variable
    println(name.hello()) // Output: Hello Ryan
}

// How It Works:
// - `fun String.hello()` means we are adding a function `hello()` to String.
// - Inside the function, `this` refers to the current String instance.
// - When `name.hello()` is called, it returns "Hello Ryan".

// Notes & Tips:
// - Extension functions do not actually modify the original class; they are
//   resolved statically at compile time.
// - If a class already has a member function with the same signature,
//   the member function will take precedence over the extension.
