package data

open class Customer(val name: String, val type: String, val balance: Long) {
    constructor(name: String, type: String): this(name, type, 0L)
    constructor(name: String) : this(name, "Standard", 0L)
}

class PremiumCustomer : Customer {
    constructor(name: String): super(name, "Premium")
    constructor(name: String, balance: Long): super(name, "Premium", balance)
}

class ExecutiveCustomer(name: String, balance: Long) : Customer(name, "Executive", balance){
    constructor(name: String): this(name, 0L)
}