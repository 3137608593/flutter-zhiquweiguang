fun main() {
    // === Comment in Kotlin ===
    // Definition:
    // - Comments are non-executable parts of the code, ignored by the compiler.
    // - They are used to explain code, improve readability, or temporarily disable code.

    // Usage:
    // - Kotlin supports two types of comments:
    //   1. Single-line comment: starts with `//` and continues until the end of the line.
    //   2. Multi-line (block) comment: enclosed between `/* ... */` or `/** ... */`.

    // Example:
    // Single-line comment
    println("This is a single-line comment example") // inline comment

    /*
       Multi-line comment
       This can span multiple lines.
     */
    println("This is a multi-line comment example")

    // How It Works:
    // - `//` ignores everything after it on the same line.
    // - `/* ... */` ignores everything inside, even across multiple lines.
    // - `/** ... */` is a special block for documentation tools like Dokka.

    // Notes & Tips:
    // - Use comments to clarify complex logic, not to restate obvious code.
    // - Prefer self-explanatory variable and function names over excessive comments.
    // - Use KDoc for documenting APIs, classes, and public functions.
}
