// === If Expression in Kotlin ===

// Definition
// The 'if' expression is used to execute code conditionally.
// It can have multiple branches: if, else if, and else.
// In Kotlin, 'if' is an expression, meaning it returns a value.

// Usage
// Use if expressions to branch logic based on conditions.
// Since 'if' returns a value, you can assign it directly to variables.

// Example
fun main() {
    val score = 90

    // Using if-else for branching logic
    if (score > 80) {
        println("Excellent") // Runs if score is greater than 80
    } else if (score > 70) {
        println("Not Bad") // Runs if score is not greater than 80 but greater than 70
    } else {
        println("Try again later!") // Runs if all above conditions are false
    }

    // Using if as an expression returning a value
    val performance = if (score > 80) {
        "Excellent"
    } else if (score > 70) {
        "Not Bad"
    } else {
        "Try again later!"
    }

    println("Performance: $performance") // Output: Performance: Excellent
}

// How It Works
// - 'if' checks conditions sequentially until one is true.
// - The code block of the first true condition executes.
// - When used as an expression, 'if' returns the last expression in the executed block.

// Notes & Tips
// - Use 'if' expressions to write concise, readable conditional logic.
// - Assigning 'if' results to variables helps reduce repetitive code.
// - Always include an 'else' branch when using 'if' as an expression to cover all cases.
