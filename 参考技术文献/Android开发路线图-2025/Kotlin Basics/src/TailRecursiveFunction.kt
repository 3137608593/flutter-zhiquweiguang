fun main() {
    // === Tail Recursive Function in Kotlin ===
    // Definition:
    // - A tail recursive function is a recursive function where the recursive call is the last operation.
    // - With the 'tailrec' modifier, the Kotlin compiler can optimize the recursion into a loop to avoid stack growth.

    // Usage:
    // - Use for deep-recursion patterns (e.g., countdown, factorial) to prevent StackOverflowError.
    // - Prefer when each step can pass forward an accumulated state (accumulator).

    // Example:
    tailrec fun display(value: Int) {
        println(value)
        if (value > 0) {
            display(value - 1) // tail call: no work after this call
        }
    }

    tailrec fun factorialTail(value: Int, acc: Long = 1L): Long {
        return if (value <= 1) acc           // base case (handles 0! and 1!)
        else factorialTail(value - 1, acc * value) // tail call with updated accumulator
    }

    display(5)                      // Output: 5 4 3 2 1 0
    println(factorialTail(10))      // Output: 3628800

    // How It Works:
    // - 'tailrec' marks the function for tail-call optimization.
    // - The compiler rewrites eligible tail calls into a loop, so each call reuses the same stack frame.
    // - In 'factorialTail', the result is carried in 'acc'; the last operation is the recursive call.

    // Notes & Tips:
    // - The recursive call must be the very last operation (no extra work after it).
    // - Avoid placing tail calls inside try/finally or followed by additional operations.
    // - Use an accumulator parameter to carry intermediate results.
    // - Prefer wider types (e.g., Long) for computations like factorial to reduce overflow risk.
}
