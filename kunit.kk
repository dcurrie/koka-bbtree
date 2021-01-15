
effect ustate {
  fun inc-ok(): ()
  fun inc-ng(): ()
  fun report(): (string,int,int)
  fun enter-tc(tcn: string): ()
}

fun ustate(action: () -> <ustate,exn,div|e> b ) : <exn,div|e> b {
  var oks := 0
  var ngs := 0
  var name := ""
  with handler {
    fun enter-tc(tcn: string){ name := tcn; oks := 0; ngs := 0 }
    fun inc-ok(){ oks := oks + 1 }
    fun inc-ng(){ ngs := ngs + 1 }
    fun report(){ (name, oks, ngs) }
  }
  action()
}

struct testcase {
  name: string
  func: () -> <ustate,exn,div> bool // <exn,ustate>
}

fun report-ng(tc: testcase, msg: string) {
  println(tc.name + " " + msg)
}

fun ku-assert-eqint(expected: int, actual: int): <exn,ustate> () {
  if (expected != actual) {
    throw(Error(Exception("Expected: " + expected.show + " actual: " + actual.show, ExnAssert)))
  }
  else {
    inc-ok()
  }
}

fun ku-assert-true(actual: bool): <exn,ustate> () {
  if (! actual) {
    throw(Error(Exception("Expected: true", ExnAssert)))
  }
  else {
    inc-ok()
  }
}

//

fun runtestcase(tc: testcase): <console,ustate,div> () {
  enter-tc(tc.name)
  match(try(tc.func)) {
    Ok(result) -> {
      if (result) {
        inc-ok()
      }
      else {
        inc-ng()
      }
    }
    Error(exception) -> {
      inc-ng()
      report-ng(tc, exception.show)
    }
  }
  val (_, oks, ngs) = report()
  println(tc.name + " Passed: " + oks.show + " Failed: " + ngs.show)
}
