// === Function with Varargs Parameter in Kotlin ===

// Definition
// The `vararg` keyword allows a function to accept a variable number of arguments of the same type.
// Inside the function, the parameter behaves like an array and can be iterated.

// Usage
// Useful when the number of inputs is not fixed, such as for sum, average, or logging functions.

// Example
fun finalValue(name: String, vararg values: Int): Unit {
    var total = 0.0 // Store the sum of values

    // Loop through each value passed to the vararg
    for (value in values) {
        total += value
    }

    total /= values.size // Calculate the average

    println("Final Value $name = $total") // Display the result
}

fun main() {
    // Calling the function with multiple integers without creating an array
    finalValue("Ryan", 10, 10, 10) // Output: Final Value Ryan = 10.0
}

// How It Works
// - The `vararg` parameter collects all passed arguments into an array.
// - You can loop through this array like a normal array.
// - Division by `values.size` gives the average in this example.

// Notes & Tips
// - You can pass zero or more arguments to a vararg parameter.
// - Use the spread operator (*) to pass an existing array to a vararg.
