fun main() {
    // === Return with If and When Expressions in Kotlin ===
    // Definition:
    // 'if' and 'when' can be used as expressions that return a value.

    // Usage:
    // Use 'if' or 'when' to return different values based on conditions.

    // Example:
    fun sayHello(name: String): String {
        return if (name == "") {
            "Hello Bro!"
        } else {
            "Hello $name"
        }
    }

    fun saySomething(word: String): String {
        return when(word) {
            "" -> "Hello Bro!"
            else -> "Hello $word"
        }
    }

    println(sayHello("Ryan"))    // Output: Hello Ryan
    println(saySomething("World")) // Output: Hello World

    // How It Works:
    // - 'if' expression returns a value depending on the condition.
    // - 'when' expression matches cases and returns corresponding values.

    // Notes & Tips:
    // - Both 'if' and 'when' are expressions, not just statements.
    // - Use them to simplify return logic inside functions.
}
