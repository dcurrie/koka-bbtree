import bbtree

fun is-ordered(tree: bbtree<k,v>, min: k): <div,cmp<k>> bool {
  var last := min
  var result := True
  with control yield(kv) { // : keyval<k,v>
    if ((cmp(last, min) == Eq) || (cmp(last, key(kv)) == Lt)) {
      last := key(kv)
      True
    }
    else {
      False
    }
  }
  inorder(tree)
  result
}

fun is-ofint-ordered(tree: bbtree<int,v>, min: int): div bool {
  with fun cmp(x: int, y:int) { compare(x,y) }
  is-ordered(tree, min)
}

public fun main() {
  val bbt0: bbtree<int,int> = Tip
  val bbt1 = bbt-ofint-insert(bbt0, 1, -1)
  val x = bbt-ofint-lookup(bbt1, 1, 42)
  println("The number is " + x.show)
  println("The tree is " +
           (if ( is-ofint-ordered(bbt1, -99999999999) ) { "ordered" }
            else { "unordered" }))
}
