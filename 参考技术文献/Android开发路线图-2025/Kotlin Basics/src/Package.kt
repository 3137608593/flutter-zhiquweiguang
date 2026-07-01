import com.company.basics.util.* // import all functions from util package

fun main() {
    // === Package & Import in Kotlin ===
    // Definition:
    // - A package is a way to group related classes, functions, and properties.
    // - An import statement allows access to elements defined in other packages.
    // - Kotlin automatically places files in the `default` package if no package is declared.
    //
    // Usage:
    // - Use packages to organize code into logical modules (e.g., `com.company.basics.util`).
    // - Use imports to access functions, classes, or objects from other packages without
    //   writing the full package path.
    // - `import com.company.basics.util.*` imports everything from the `util` package.
    //
    // Example:
    sayHello("Ryan")    // Output: Hello Ryan
    sayGoodbye("Ryan")  // Output: Goodbye Ryan
    //
    // How It Works:
    // - `sayHello` and `sayGoodbye` are defined in the package `com.company.basics.util`.
    // - The `import com.company.basics.util.*` statement makes these functions available
    //   directly in this file.
    // - Without import, you would need to call them with full path:
    //   -> com.company.basics.util.sayHello("Ryan")
    //
    // Notes & Tips:
    // - Always use meaningful package names that reflect your project structure.
    // - Prefer importing specific functions/classes instead of `*` for clarity:
    //   -> import com.company.basics.util.sayHello
    // - Package naming convention follows reverse domain names (e.g., `com.company.project.module`).
    // - Organizing with packages improves code readability and maintainability.
}