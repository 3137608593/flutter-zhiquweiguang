import java.util.Locale.getDefault

fun main() {
    // === Higher-Order Function in Kotlin ===
    // Definition:
    // - A higher-order function is a function that takes another function as a parameter
    //   or returns a function as a result.
    // - This allows passing behavior (logic) as an argument to functions.
    //
    // Usage:
    // - Useful for customizing behavior without rewriting functions.
    // - Commonly used in standard library functions like map, filter, reduce.
    // - Enables functional programming style and code reusability.
    //
    // Example:
    fun hello(name: String, transformer: (String) -> String): String {
        return "Hello ${transformer(name)}"
    }
    //
    val textToUpperCase: (String) -> String = { value: String ->
        value.uppercase(getDefault())
    }
    val result = hello("Ryan", textToUpperCase)
    println(result) // Output: Hello RYAN
    //
    // Trailing Lambda:
    val name = hello("Ryan") { value: String ->
        value.lowercase(getDefault())
    }
    println(name) // Output: Hello ryan
    //
    // How It Works:
    // - `hello` takes a string (`name`) and a transformer function.
    // - The transformer function modifies the name before returning the greeting.
    // - In `textToUpperCase`, the lambda converts text to uppercase.
    // - With trailing lambda, the function call looks cleaner when the last parameter is a lambda.
    //
    // Notes & Tips:
    // - Trailing lambdas improve readability when passing a function as the last parameter.
    // - Higher-order functions are the foundation for functional programming in Kotlin.
    // - Keep transformer functions small and reusable.
    // - Prefer method references (::functionName) when reusing existing functions.
}
