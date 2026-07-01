fun main() {
    // === Break and Continue in Kotlin ===
    // Definition:
    //   'break' is used to exit the nearest enclosing loop immediately.
    //   'continue' skips the current iteration and moves to the next one.
    //
    // Usage:
    //   Use 'break' to stop loops when a certain condition is met.
    //   Use 'continue' to skip over certain iterations without ending the loop.
    //

    // Example:
    var i = 0
    // Example 1: Using 'break' to exit an infinite loop when condition is met
    while (true) {
        println("Enter number: $i")
        i++
        if (i > 10) break  // Exit loop when i becomes greater than 10
    }

    // Example 2: Using 'continue' to skip even numbers in a loop
    for (j in 1..10) {
        if (j % 2 == 0) {
            continue  // Skip this iteration if 'j' is even
        }
        println(j)  // Prints only odd numbers
    }

    // How It Works:
    //   'break' immediately terminates the loop and continues with the next statement after the loop.
    //   'continue' skips the current iteration and proceeds with the next one in the loop.
    //
    // Notes & Tips:
    //   - Use 'break' to stop loops early when a condition is met.
    //   - Use 'continue' to skip specific iterations based on a condition.
    //   - Both improve control flow and readability in loops.
}
