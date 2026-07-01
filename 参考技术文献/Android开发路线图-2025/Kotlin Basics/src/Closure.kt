fun main() {
    // === Closure in Kotlin ===
    // Definition:
    // - A closure is a function (lambda or anonymous function) that captures variables
    //   from its surrounding scope.
    // - It allows the function to access and modify variables declared outside of it.
    //
    // Usage:
    // - Use closures when you want a function to "remember" and manipulate external state.
    // - Common in callbacks, event handlers, or counters where state must persist.
    //
    // Example:
    var counter: Int = 0
    val lambdaIncrement: () -> Unit = { counter++ }
    //
    lambdaIncrement()
    println(counter) // Output: 1
    //
    // How It Works:
    // - `counter` is declared outside the lambda.
    // - The lambda `lambdaIncrement` captures the `counter` variable from outer scope.
    // - When invoked, it increments `counter` and the change persists.
    //
    // Notes & Tips:
    // - Closures can both read and modify captured variables.
    // - Be careful: excessive use of closures that modify external state
    //   can lead to hard-to-track side effects.
    // - Prefer closures for small, stateful behaviors like counters or accumulators.
    // - In Kotlin, lambdas and anonymous functions both support closures.
}
