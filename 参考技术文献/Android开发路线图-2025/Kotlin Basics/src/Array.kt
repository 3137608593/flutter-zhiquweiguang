fun main() {
    // === Arrays in Kotlin ===

    // Definition:
    // An Array in Kotlin is a fixed-size collection that stores multiple elements of the same type.
    // Arrays can hold primitive types (Int, Double, Boolean, etc.) or objects.
    // Arrays are zero-indexed: the first element is at index 0.

    // Usage:
    // Use arrays when you know the number of elements will remain constant.
    // Suitable for storing sequential data that doesn't change in size.

    // Example 1: Creating and Modifying an Array
    val names: Array<String> = arrayOf("Ryan", "Aprianto") // Create an Array of Strings
    names[1] = "Ryan Aprianto" // Update the second element
    println(names[1]) // Output: Ryan Aprianto

    // Example 2: Nullable Array Elements
    // Create an Array that can store null values
    val balances: Array<Int?> = arrayOfNulls(5) // All elements initially null
    balances[0] = 1000 // Assign a value to the first index
    println(balances[0]) // Output: 1000

    // How It Works:
    // - arrayOf(...) creates an Array with the given elements.
    // - arrayOfNulls(size) creates an Array of the specified size filled with null.
    // - Elements are accessed or updated using [index] notation.
    // - Indexing starts at 0, so names[1] refers to the second element.

    // Notes & Tips:
    // - Arrays have a fixed size — you cannot add or remove elements.
    // - For dynamic collections, use List or MutableList.
    // - Accessing an invalid index will throw IndexOutOfBoundsException.
    // - Iterate over arrays using loops (for, forEach, indices).
}
