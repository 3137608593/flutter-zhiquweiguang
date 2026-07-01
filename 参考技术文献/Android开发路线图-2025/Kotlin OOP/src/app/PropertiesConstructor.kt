package app

import data.User

fun main() {
    val user = User("Admin", "password")

    user.username = "Superadmin"

    println(user.username)
}