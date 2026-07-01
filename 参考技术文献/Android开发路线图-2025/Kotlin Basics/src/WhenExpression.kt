// === When Expression in Kotlin ===

// Definition
// 'when' is a versatile control structure replacing 'switch'.
// It matches values, groups cases, checks ranges, tests types, or acts like if-else chains.

// Usage
// Use 'when' to handle multiple conditions cleanly and readably.

// Example
fun main() {
    val grade: Char = 'A'

    // Basic value matching
    when (grade) {
        'A' -> println("Grade A: Excellent")
        'B' -> println("Grade B: Good")
        'C' -> println("Grade C: Fair")
        'D' -> println("Grade D: Needs Improvement")
        else -> println("Invalid input")
    }

    // Group multiple cases
    when (grade) {
        'A', 'B', 'C' -> println("Status: Passed")
        else -> println("Status: Not Passed")
    }

    // Check membership with 'in' and '!in'
    val passValues: Array<Char> = arrayOf('A', 'B', 'C')
    when (grade) {
        in passValues -> println("Passed using 'in'")
        !in passValues -> println("Not Passed using '!in'")
    }

    // Type checking with 'is' and '!is'
    when (val name = "Ryan") {
        is String -> println("Name is a String: $name")
        !is String -> println("Not a String")
    }

    // When without subject (if-else chain)
    when {
        grade in passValues -> println("Condition-based Passed")
        else -> println("Condition-based Not Passed")
    }
}

// How It Works
// - 'when' compares the subject against cases or evaluates conditions without a subject.
// - It can be used as an expression returning a value.
// - The 'else' branch handles any unmatched cases.

// Notes & Tips
// - Prefer 'when' over complex if-else chains for clarity.
// - Ensure all possible cases are handled or provide an 'else' branch.
// - Use ranges, collections, and type checks inside 'when' for flexible matching.
