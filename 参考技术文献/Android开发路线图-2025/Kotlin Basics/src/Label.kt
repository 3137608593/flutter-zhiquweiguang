fun labelBreak() {
    loopI@ for (i in 1..10) {
        loopJ@ for (j in 1..10) {
            println("$i * $j = ${i * j}")
            if (j == 10) break@loopI // break to outer loop
        }
    }
}

fun labelContinue() {
    loopI@ for (i in 1..10) {
        loopJ@ for (j in 1..10) {
            if (j == 5) continue@loopI // skip current iteration of outer loop
            println("$i * $j = ${i * j}")
        }
    }
}

fun main() {
    // === Label in Kotlin ===
    // Definition:
    // - A label is an identifier followed by `@`, used to mark a loop or a lambda expression.
    // - Labels allow fine-grained control with `break`, `continue`, or `return` in nested loops or lambdas.
    //
    // Usage:
    // - Use labels to break or continue outer loops from inner loops.
    // - Use labels in lambdas to specify which function/lambda `return` should apply to.
    // - Helpful when working with nested loops or higher-order functions.
    //
    // Example: Label with break
    labelBreak()
    //
    // Example: Label with continue
    labelContinue()
    //
    // Example: Label with return in lambda
    fun test(name: String, operation: (String) -> Unit): Unit = operation(name)
    test("Ryan") test@ {
        if (it == "") {
            return@test // return only from lambda, not from main()
        } else {
            println("Hello $it") // Output: Hello Ryan
        }
    }
    //
    // How It Works:
    // - `loopI@` marks the outer loop; `break@loopI` exits it directly.
    // - `continue@loopI` skips to the next iteration of the outer loop.
    // - In lambdas, `return@test` ensures returning from the lambda, not the enclosing function.
    //
    // Notes & Tips:
    // - Labels improve readability in nested control flows.
    // - Avoid overusing labels; deep nesting often indicates code that could be refactored.
    // - Use labeled returns in lambdas to prevent accidentally returning from the wrong function.
}
