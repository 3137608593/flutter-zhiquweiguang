fun main() {
    // === Function Scope in Kotlin ===
    // Definition:
    // Function scope means a function defined inside another function
    // is only accessible within that outer function.

    // Usage:
    // Use nested functions to encapsulate logic relevant only inside the outer function.

    // Example:
    fun sayHello() {
        println("Hello World") // Prints greeting message
    }

    // Calling the nested function inside its scope
    sayHello()

    // How It Works:
    // - sayHello() is declared inside main(), so it can only be called inside main().
    // - It is not visible outside of main(), ensuring encapsulation.

    // Notes & Tips:
    // - Nested functions help keep code organized and avoid polluting the global scope.
    // - They are useful for helper functions only needed internally.
}
