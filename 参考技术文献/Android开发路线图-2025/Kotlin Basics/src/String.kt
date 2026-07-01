// === String Values in Kotlin ===

// Definition
// A String is a sequence of characters enclosed in double quotes ("").

// Usage
// Use strings to represent text data. Multiline strings and string templates are supported.

// Example
fun main() {
    val firstname: String = "Ryan"
    val lastname: String = "Aprianto"

    // Multiline string using triple quotes
    val simpleAddress: String = """
        Jl. Merdeka No. 123,
        Cirebon City,
        West Java 45100,
        Indonesia
    """

    // Using trimMargin() with default margin prefix '|'
    val formattedAddress: String = """
        |Ryan Aprianto
        |Jl. Merdeka No. 123
        |Cirebon City, West Java 45100
        |Indonesia
    """.trimMargin()

    // Using trimMargin() with custom margin prefix '>'
    val profileDescription: String = """
        >Hello, my name is Ryan Aprianto.
        >I'm a software developer who enjoys working with Kotlin.
        >This is a sample of a well-formatted multiline string using '>'.
    """.trimMargin(">")

    // String templates with variables and expressions
    val fullName: String = "$firstname $lastname"
    val description: String = "$fullName has ${fullName.length} characters"

    // Output
    println(simpleAddress)
    println(formattedAddress)
    println(profileDescription)
    println(fullName)
    println(description)
}

// How It Works
// - Triple quotes """ allow strings to span multiple lines without escape characters.
// - trimMargin() removes leading whitespace up to a specified margin prefix (default '|').
// - String templates with '$' embed variables directly inside strings.
// - Expressions can be embedded using ${} inside string templates.

// Notes & Tips
// - Use multiline strings to maintain text formatting easily.
// - Use trimMargin() to handle indentation cleanly in multiline strings.
// - String templates reduce the need for manual concatenation.
// - Use ${} for embedding expressions or complex values inside strings.
