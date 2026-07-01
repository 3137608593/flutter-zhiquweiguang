fun main() {
    // === Boolean in Kotlin ===

    // Definition:
    // A Boolean in Kotlin is a primitive data type that can only have one of two values: true or false.

    // Usage:
    // Booleans are commonly used in conditions, logical operations, and controlling program flow.
    // Boolean literals are written in lowercase: true and false.

    // Example:
    val correct: Boolean = true    // Declares a Boolean variable with value 'true'
    val wrong: Boolean = false     // Declares a Boolean variable with value 'false'

    println(correct) // Output: true
    println(wrong)   // Output: false

    // How It Works:
    // - Boolean variables store logical states.
    // - They can be assigned directly with true/false or as the result of expressions.
    // - For example: val isGreater = (5 > 3) // true

    // Notes & Tips:
    // - Use Booleans with if, while, when, etc., to control program behavior.
    // - Avoid comparing Boolean with true/false directly, prefer: if (isActive) { ... }
    // - Boolean operations include: && (AND), || (OR), ! (NOT).
}
