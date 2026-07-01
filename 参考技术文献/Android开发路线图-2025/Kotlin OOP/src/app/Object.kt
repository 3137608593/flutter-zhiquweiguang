package app

import data.Person

fun main() {
    val person = Person()

    person.firstName = "Ryan"
    person.lastName = "Aprianto"

    println(person.lastName)
}