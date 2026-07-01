fun main() {
    // === Do-While Loop in Kotlin ===
    // Definition:
    // 'do-while' is a looping structure that executes a block of code at least once,
    // and then repeats it as long as the condition evaluates to true.
    // The condition is checked after each iteration.

    // Usage:
    // Used when you need the code to run first before evaluating the condition.
    // Syntax:
    // do {
    //     // code block
    // } while (condition)

    // Example:
    var i = 0
    do {
        println(i) // Prints the current value of 'i'
        i++        // Increment 'i' by 1
    } while (i < 10)

    // How It Works:
    // 1. The code block inside 'do { ... }' runs first.
    // 2. After execution, the condition in 'while' is evaluated.
    // 3. If the condition is true, the loop runs again.
    // 4. This continues until the condition becomes false.

    // Notes & Tips:
    // - 'do-while' guarantees the loop runs at least once.
    // - Avoid infinite loops by ensuring the condition will eventually be false.
    // - Useful for menu-driven programs or user input validation.
}
