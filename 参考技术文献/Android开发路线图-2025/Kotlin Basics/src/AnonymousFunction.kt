import java.util.Locale.getDefault

fun main() {
    // === Anonymous Function in Kotlin ===
    // Definition:
    // - An anonymous function is a function without a name, defined using the `fun` keyword.
    // - It can be stored in variables or passed directly as an argument to higher-order functions.
    // - Unlike lambdas, anonymous functions allow explicit return types and multiple return points.
    //
    // Usage:
    // - Use when you need more control than lambdas (e.g., explicit parameter types, multiple returns).
    // - Handy for short-lived functions without declaring a named function.
    // - Common in scenarios similar to lambdas but requiring more clarity or complexity.
    //
    // Example:
    fun hello(name: String, transformer: (String) -> String): String {
        return "Hello ${transformer(name)}"
    }
    //
    val upper = fun(value: String): String {
        return if (value == "") {
            "Ups!"
        } else {
            value.uppercase(getDefault())
        }
    }
    println(hello("Ryan", upper)) // Output: Hello RYAN
    //
    // Anonymous Function as Parameter:
    println(hello("Ryan", fun(value: String): String {
        return value.lowercase(getDefault())
    })) // Output: Hello ryan
    //
    // How It Works:
    // - `upper` stores an anonymous function that checks input:
    //   -> returns "Ups!" if empty, otherwise converts text to uppercase.
    // - Anonymous function can also be passed directly into `hello` as an argument.
    // - Unlike lambdas, anonymous functions use explicit `return` statements.
    //
    // Notes & Tips:
    // - Prefer lambdas for concise code; use anonymous functions for clarity in complex logic.
    // - Anonymous functions support multiple `return` points, unlike lambdas.
    // - Both lambdas and anonymous functions are interchangeable in many HOF contexts.
    // - Keep them small and focused to maintain readability.
}
