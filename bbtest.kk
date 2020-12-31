import bbtree
import std/num/int32
import std/num/random

/* works, and short circuit for failure case, but effecty
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
*/

fun is-ofint-ordered(tree: bbtree<int,v>, min: int): bool {
  fun ok(tk: int, _, ordlast: (bool, int)): (bool,int) {
    match(ordlast) {
      (ord,last) ->
        if (ord && ((last < tk) || (last == min))) { (True, tk) }
        else { (False, tk) }
    }
  }
  match(tree.fold((True, min), ok)) { (ord,_) -> ord }
}

// effect prng {
//   fun next() : int
//   fun seed(x : int) : ()
// }
//
// fun random-test(init: int, action: () -> <prng|e> b) : e b {
//   var state := init
//   with fun seed(x) { state := x }
//   with fun next() {
//     state := state ^ (state >> 12) // a
//     state := state ^ (state << 25) // b
//     state := state ^ (state >> 27) // c
//     return state * 2685821657736338717
//   }
//   action()
// }
//
// pseudo-random( seed : int, action : () -> <random|e> a) : e a {

effect istate<a> {
  fun get(i: int) : a
  fun set(i: int, x : a) : ()
}

fun istate(size: int, init: a, action: () -> <istate<a>,exn,div|e> b ) : <exn,div|e> b {
  var st := vector(size, init)
  with handler {
    fun get(i){ st[i] }
    fun set(i,x){ st[i] := x }
  }
  action()
}

fun prng-int(n: int): random int {
  abs(random-int()) % n
}
fun show-a-couple-prng(): <exn,div,random,istate<int>> string {
  val x : int = get(prng-int(10))
  set(13,42)
  val y : int = get(13)
  random-int().show + " " + random-int().show + " " + random-int().show
    + " " + prng-int(10).show // + " " + prng-int(10).show // uncomment to kill koka
    + " " + x.show + " " + y.show
}
fun istate-test(): <exn,div,random,istate<int>> string {
    istate(100, -9, show-a-couple-prng)
}
public fun main() {
  val bbt0: bbtree<int,int> = Tip
  val bbt1 = bbt-ofint-insert(bbt0, 1, -1)
  val x = bbt-ofint-lookup(bbt1, 1, 42)
  println("A random number is "
    + pseudo-random(7, fn() { istate(100, -9, show-a-couple-prng) }))
  println("The number is " + x.show)
  println("The tree is " +
           (if ( is-ofint-ordered(bbt1, -99999999999) ) { "ordered" }
            else { "unordered" }))
}
