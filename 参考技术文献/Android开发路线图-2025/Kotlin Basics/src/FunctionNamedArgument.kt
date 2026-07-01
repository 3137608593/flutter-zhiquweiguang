// === Function with Named Arguments in Kotlin ===

// Definition
// Named arguments allow specifying parameter values by their parameter name
// when calling a function, improving readability and flexibility.

// Usage
// Use when calling a function to clearly indicate which value belongs to which parameter.
// You can pass arguments in any order.

// Example
fun fullName(
    firstName: String,
    middleName: String,
    lastName: String
) {
    println("Hello $firstName $middleName $lastName")
}

fun main() {
    fullName(middleName = "Aprianto", firstName = "Ryan", lastName = "")
    // Output: Hello Ryan Aprianto 
}

// How It Works
// 1. The function fullName takes three parameters: firstName, middleName, lastName.
// 2. When calling the function, we specify the parameter names explicitly.
// 3. This allows arguments to be provided in any order, improving clarity.
// 4. Kotlin matches values to parameters based on their names, not position.

// Notes & Tips
// - Improves code readability, especially in functions with many parameters.
// - Helps prevent errors from incorrect argument ordering.
// - Works well with default parameter values.
