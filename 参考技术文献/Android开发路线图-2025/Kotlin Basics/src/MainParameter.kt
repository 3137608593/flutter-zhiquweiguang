fun main(args: Array<String>) {
    // === Main Parameter in Kotlin ===
    // Definition:
    // - The `main` function is the entry point of a Kotlin program.
    // - It can take an optional parameter `args: Array<String>` which holds
    //   command-line arguments passed when running the program.
    //
    // Usage:
    // - Use `args` to handle external input provided at runtime.
    // - Each argument is stored as a string inside the array.
    // - Commonly used for configuration, flags, or dynamic inputs.
    //
    // Example:
    for (value in args) {
        println(value)
    }
    // If the program is run with arguments:
    // > kotlin MainKt Hello World
    // Output:
    // Hello
    // World
    //
    // How It Works:
    // - When executing the program, arguments passed in the command line
    //   are collected into the `args` array.
    // - The loop iterates through `args` and prints each argument.
    //
    // Notes & Tips:
    // - `args` is always an array of strings; convert values if needed
    //   (e.g., to Int using `toInt()`).
    // - Use `args.isNotEmpty()` before accessing to avoid errors on empty input.
    // - Main parameters are essential for making programs dynamic and reusable.
}
