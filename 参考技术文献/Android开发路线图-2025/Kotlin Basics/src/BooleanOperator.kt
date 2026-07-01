fun main() {
    // === Boolean Operators in Kotlin (&&, ||, !) ===

    // Definition:
    // Boolean operators are used to combine or modify Boolean values (true/false).
    // Common operators:
    // - AND (&&): true if both operands are true.
    // - OR (||): true if at least one operand is true.
    // - NOT (!): inverts the Boolean value.

    // Usage:
    // Use Boolean operators in conditional checks, logical comparisons,
    // and control flow statements to make decisions based on multiple conditions.

    // Example 1: Logical AND (&&)
    val finalExam = 80
    val attendance = 80
    val passFinalExam = finalExam > 75 // true because 80 > 75
    val passAttendance = attendance > 75 // true because 80 > 75
    val pass = passFinalExam && passAttendance
    println(pass) // Output: true (both conditions are true)

    // Example 2: Logical OR (||)
    val passOr = passFinalExam || passAttendance
    println(passOr) // Output: true (at least one condition is true)

    // Example 3: Logical NOT (!)
    val notPass = !pass
    println(notPass) // Output: false (pass is true, so !pass is false)

    // How It Works:
    // - AND (&&) returns true only if both operands are true.
    // - OR (||) returns true if at least one operand is true.
    // - NOT (!) inverts the Boolean value: true becomes false, and false becomes true.
    // - These operators are often used in if statements, loops, and complex conditions.

    // Notes & Tips:
    // - Use && when all conditions must be true.
    // - Use || when at least one condition can be true.
    // - Use ! to invert a Boolean value.
    // - Be mindful of operator precedence: && is evaluated before ||.
}
