
import std/num/random

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
  random-int().show
    + " " + prng-int(10).show + " " + prng-int(10).show
    + " " + x.show
}

fun istate-test(): <exn,div,random> string {
    istate(100, -9, show-a-couple-prng)
}

public fun main() {
  println("Random numbers " + pseudo-random(7, istate-test))
}

// works, too
// public fun main() {
//   fun istate-test(): <exn,div,random> string { // ,istate<int>
//     istate(100, -9, show-a-couple-prng)
//   }
//   println("Random numbers " + pseudo-random(7, istate-test))
// }

// works
//public fun main() {
//  println("Random numbers " + pseudo-random(7, fn() { istate(100, -9, show-a-couple-prng) }))
//}
