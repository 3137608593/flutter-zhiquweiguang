fun main() {
    // === Recursive Function in Kotlin ===
    // Definition:
    // A recursive function calls itself to solve a problem by breaking it down into smaller subproblems.

    // Usage:
    // Use recursion for problems that can be divided into similar subproblems, like factorial calculation.

    // Example:
    fun factorialLoop(value: Int): Int {
        var result = 1
        for (i in value downTo 1) {
            result *= i
        }
        return result
    }

    fun factorialRecursive(value: Int): Int {
        return when (value) {
            1 -> 1
            else -> value * factorialRecursive(value - 1)
        }
    }

    println(factorialLoop(10))       // Output: 3628800
    println(factorialRecursive(10))  // Output: 3628800

    // How It Works:
    // - The loop version multiplies values from 'value' down to 1.
    // - The recursive version calls itself with a smaller value until base case (1) is reached.

    // Notes & Tips:
    // - Ensure base case exists in recursion to avoid infinite loops.
    // - Recursive functions are elegant but may cause stack overflow if too deep.
}
