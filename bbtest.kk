import bbtree
import kunit

import std/time/timer
import std/num/random

// is-balanced() returns size in nodes or -1 for error
//
fun is-balanced(node: bbtree<k,v>): div int {
  fun isbal(tl: bbtree<k,v>, tr: bbtree<k,v>, sz: int) {
    val sl = tree-size(tl)
    val sr = tree-size(tr)
    if (sz != (sl + 1 + sr)) return -1
    if ((sl + sr) > 1) {
      if (sr > (omega * sl)) return -1
      if (sl > (omega * sr)) return -1
    }
    val slb = is-balanced(tl)
    val srb = is-balanced(tr)
    if ((slb < 0) || (sl != slb)) return -1
    if ((srb < 0) || (sr != srb)) return -1
    sz
  }
  match (node) {
    Tip                    -> 0
    Node(tl, tr, tz, _, _) -> isbal(tl, tr, tz)
  }
}

fun is-well-balanced(node: bbtree<k,v>): div bool {
  val z = is-balanced(node)
  z >= 0 && z == tree-size(node)
}

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

// fun show-a-couple-prng(): <exn,div,random,istate<int>> string {
//   val x : int = get(prng-int(10))
//   set(13,42)
//   val y : int = get(13)
//   random-int().show + " " + random-int().show + " " + random-int().show
//     + " " + prng-int(10).show // + " " + prng-int(10).show // uncomment to kill koka
//     + " " + x.show + " " + y.show
// }

// fun istate-test(): <exn,div,random> string {
//     istate(100, -9, show-a-couple-prng)
// }
//
// public fun main() {
//   val bbt0: bbtree<int,int> = Tip
//   val bbt1 = bbt-ofint-insert(bbt0, 1, -1)
//   val x = bbt-ofint-lookup(bbt1, 1, 42)
//   println("A random number is " + pseudo-random(7, istate-test))
//   println("The number is " + x.show)
//   println("The tree is " +
//            (if ( is-ofint-ordered(bbt1, -99999999999) ) { "ordered" }
//             else { "unordered" }))
// }


val tc1 = Testcase("empty and one element bb trees balanced", fn (): <div,exn,ustate> bool {
  val bbt0: bbtree<int,int> = Tip
  ku-assert-true(is-ofint-ordered(bbt0,-1))
  ku-assert-eqint(tree-size(bbt0), 0)
  ku-assert-true(is-well-balanced(bbt0))
  val bbt1 = bbt-ofint-insert(bbt0, 1, -1)
  ku-assert-true(is-ofint-ordered(bbt1,-999))
  ku-assert-eqint(tree-size(bbt1), 1)
  ku-assert-true(is-well-balanced(bbt1))
  True
})

val tc2 = Testcase("bbtree insert, lookup, ordered, balanced", fn (): <div,exn,ustate> bool {
  val bbt0: bbtree<int,int> = Tip
  val bbt1 = bbt-ofint-insert(bbt0, 1, -1)
  val res = bbt-ofint-lookup(bbt1, 1, -42)
  ku-assert-eqint(res, -1)
  val rez = bbt-ofint-lookup(bbt1, 3, -42)
  ku-assert-eqint(rez, -42)
  ku-assert-true(is-ofint-ordered(bbt1,-999))
  ku-assert-eqint(tree-size(bbt1), 1)
  ku-assert-true(is-well-balanced(bbt1))
  True
})

val tc3 = Testcase("bbtree insert 21 items, ordered, balanced", fn (): <div,exn,ustate> bool {
  var bbtn: bbtree<int,int> := Tip
  for(1,21) fn(i) { bbtn := bbt-ofint-insert(bbtn, i, -1) }
  ku-assert-true(is-ofint-ordered(bbtn,-999))
  ku-assert-eqint(tree-size(bbtn), 21)
  ku-assert-true(is-well-balanced(bbtn))
  True
})

public fun main() {
  fun runalltcs() {
    runtestcase(tc1)
    runtestcase(tc2)
    runtestcase(tc3)
  }
  ustate(runalltcs)
}
