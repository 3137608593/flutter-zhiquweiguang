import java.util.Locale.getDefault

fun toUpper(value: String): String = value.uppercase(getDefault())

fun main() {
    // === Lambda Expression in Kotlin ===
    // Definition:
    // - A lambda expression is an anonymous function that can be used as a value.
    // - It can take parameters, return a value, and be passed to or returned from functions.
    //
    // Usage:
    // - Use lambdas for short, inline functions without needing to declare a named function.
    // - Commonly used with higher-order functions like map, filter, reduce.
    // - Useful when passing behavior (logic) as an argument.
    //
    // Example:
    val lambdaName: (String, String) -> String = { firstName: String, lastName: String ->
        "$firstName $lastName"
    }
    val name = lambdaName("Ryan", "Aprianto")
    println(name) // Output: Ryan Aprianto
    //
    val sayHello: (String) -> String = {
        "Hello $it"
    }
    println(sayHello("Ryan")) // Output: Hello Ryan
    //
    val textToUpperCase: (String) -> String = ::toUpper
    println(textToUpperCase("Ryan")) // Output: RYAN
    //
    // How It Works:
    // - `lambdaName` defines a lambda with two parameters and concatenates them.
    // - `sayHello` uses the implicit parameter `it` for a single-argument lambda.
    // - `::toUpper` is a method reference, reusing the `toUpper` function as a lambda.
    //
    // Notes & Tips:
    // - Use `it` for single-parameter lambdas to make them shorter.
    // - Prefer method references when an existing function already does the job.
    // - Lambdas improve readability in functional programming style.
    // - Keep lambdas small and focused for best clarity.
}
