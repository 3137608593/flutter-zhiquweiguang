import java.util.Locale.getDefault

infix fun String.to(type: String): String {
    return if (type == "UP")
        uppercase(getDefault())
    else
        lowercase(getDefault())
}

fun main() {
    // === Infix Function in Kotlin ===
    // Definition:
    // Infix functions allow calling functions using infix notation,
    // making the syntax cleaner and more readable.
    // They must be member functions or extension functions with a single parameter,
    // and marked with the 'infix' keyword.

    // Usage:
    // Use infix functions when you want to provide a natural language style
    // for calling functions with one argument.

    // Example:
    val result = "Ryan" to "UP" // Calls the infix extension function 'to'

    println(result) // Output: RYAN

    // How It Works:
    // - The 'to' function checks the 'type' parameter:
    //   if 'UP', converts the string to uppercase using locale default;
    //   otherwise converts to lowercase.
    // - Called as 'string to "UP"' due to infix notation.

    // Notes & Tips:
    // - Infix functions improve code readability by allowing natural syntax.
    // - They must have exactly one parameter.
    // - Use for DSLs or when it makes the code more expressive.
}