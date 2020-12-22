import bbtree

public fun main() {
  val bbt0: bbtree<int,int> = Nil
  val bbt1 = bbt-ofint-insert(bbt0, 1, -1)
  val x = bbt-ofint-lookup(bbt1, 1, 42)
  println("The number is " + x.show)
}
