import kunit

val tc1 = Testcase("Tc one", fn (): <exn,ustate> bool {
  val y = 5 * 8
  ku-assert-eqint(40, y)
  ku-assert-eqint(41, y)
  True
})

val tc2 = Testcase("Tc two", fn (): <exn,ustate> bool {
  val y = 5 * 8
  val z = vector(3,0)
  ku-assert-eqint(40, y)
  ku-assert-eqint(0, z[y]) // exn
  True
})


fun runalltcs() {
  runtestcase(tc1)
  runtestcase(tc2)
}

public fun main() {
  ustate(runalltcs)
}
