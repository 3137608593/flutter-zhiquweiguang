inline fun hello(
    firstName: () -> String,
    noinline lastName: () -> String
): String {
    return "Hello ${firstName()} ${lastName()}"
}

fun main() {
    // === Inline Function in Kotlin ===
    // Definition:
    // - An inline function is a function marked with the `inline` modifier.
    // - Instead of creating function objects for lambda parameters,
    //   the compiler inlines the code (copies it to the call site).
    // - This reduces runtime overhead of lambda expressions.
    //
    // Usage:
    // - Use inline functions when passing lambdas to avoid object creation
    //   and improve performance.
    // - Add `noinline` if some lambda parameters should not be inlined
    //   (e.g., stored in variables or passed elsewhere).
    //
    // Example:
    println(hello({ "Ryan" }, { "Aprianto" })) // Output: Hello Ryan Aprianto
    //
    // How It Works:
    // - `hello` takes two lambda parameters: `firstName` (inlined) and `lastName` (not inlined).
    // - At the call site, the compiler replaces the inline lambda `{"Ryan"}` directly,
    //   avoiding extra function object creation.
    // - `noinline` on `lastName` means it remains a normal lambda object.
    //
    // Notes & Tips:
    // - Use `inline` to improve performance when lambdas are frequently used.
    // - Use `noinline` for lambdas that need to be treated as objects.
    // - Be careful: inlining large functions can increase bytecode size (code bloat).
    // - Inline functions are commonly used with higher-order functions in the Kotlin standard library.
}
