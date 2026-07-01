package app

import data.ExecutiveCustomer
import data.PremiumCustomer

fun main() {
    val premium = PremiumCustomer("Ryan")
   println(premium.name)

    val executive = ExecutiveCustomer("Ryan", 100000)
    println(executive.name)
    println(executive.balance)
}