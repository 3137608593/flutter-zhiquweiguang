fun main() {
    // === Comparison Operators in Kotlin (>=, <=, >, <, ==, !=) ===
    //
    // Definition:
    // Comparison operators are used to compare two values and return a Boolean result (true or false).
    //
    // Usage:
    // - >= : greater than or equal to
    // - <= : less than or equal to
    // - >  : greater than
    // - <  : less than
    // - == : equal to
    // - != : not equal to
    //
    // Example:
    val a = 100
    val b = 200

    // 100 <= 200 → true because 100 is less than 200
    val isLessOrEqual: Boolean = a <= b
    println(isLessOrEqual) // Output: true

    // 100 == 200 → false because they are different
    val isEqual: Boolean = a == b
    println(isEqual) // Output: false

    // 100 != 200 → true because they are different
    val isNotEqual: Boolean = a != b
    println(isNotEqual) // Output: true
    //
    // How It Works:
    // - The operator compares the left-hand value with the right-hand value.
    // - The expression evaluates to a Boolean (`true` or `false`).
    // - Example: a <= b → checks if 'a' is less than or equal to 'b'.
    //
    // Notes & Tips:
    // - Use comparison operators in if-else statements or loops to control logic flow.
    // - Comparison results can be stored in variables for later use.
    // - Works with numbers, characters, and other comparable data types.
}
