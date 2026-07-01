package data

open class Shape {
    open val corner: Int = 87

    open fun draw() {
        println("Draw Shape")
    }
}

class Rectangle : Shape() {
    override val corner: Int = 4

    val parentCorner: Int = super.corner / 2

    override fun draw() {
        println("Draw Rectangle")
        super.draw()
    }
}