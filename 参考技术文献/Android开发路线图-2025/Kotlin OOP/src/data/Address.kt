package data

class Address {
    var street: String = ""
    var city: String = ""
    var county: String = "Indonesia"

    constructor(paramStreet: String, paramCity: String) {
        street = paramStreet
        city = paramCity
    }

    constructor(paramStreet: String, paramCity: String, paramCounty: String): this(paramStreet, paramCity) {
        county = paramCounty
    }
}