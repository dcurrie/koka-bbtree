module bbtree

// balance criteria
public val omega = 3 // public for unit test
val alpha = 2

public effect cmp<k> {
  fun cmp(x: k, y: k) : order
}

public type bbtree<k,v> {
  Tip
  Node(left: bbtree<k,v>, right: bbtree<k,v>, size: int, key: k, value: v)
}

private fun node-size(n: bbtree<k,v>): int {
  match(n) {
    Node(_, _, size, _, _) -> size
    _ -> 0
  }
}

public fun tree-size(tree: bbtree<k,v>): int {
  node-size(tree)
}

private fun new-leaf(key: k, value: v): bbtree<k,v> {
  // constructor for a leaf node
  Node(Tip, Tip, 1, key, value)
}

private fun new-node(left: bbtree<k,v>, key: k, value: v, right: bbtree<k,v>): bbtree<k,v> {
  // constructor for a new internal node
  Node(left, right, node-size(left) + 1 + node-size(right), key, value)
}

private fun single-L(left: bbtree<k,v>, key: k, value: v, right: bbtree<k,v>): bbtree<k,v> {
  match(right) {
    Node(rl, rr, _, rk, rv) ->
      new-node(new-node(left, key, value, rl), rk, rv, rr)
    _ -> left // can't happen, just for typecheck
  }
}

private fun double-L(left: bbtree<k,v>, key: k, value: v, right: bbtree<k,v>): bbtree<k,v> {
  match(right) {
    Node(Node(rll, rlr, _, rlk, rlv), rr, _, rk, rv) ->
      new-node(new-node(left, key, value, rll), rlk, rlv,
               new-node(rlr, rk, rv, rr))
    _ -> left // can't happen, just for typecheck
  }
}

private fun single-R(left: bbtree<k,v>, key: k, value: v, right: bbtree<k,v>): bbtree<k,v> {
  match(left) {
    Node(ll, lr, _, lk, lv) ->
        new-node(ll, lk, lv, new-node(lr, key, value, right))
    _ -> right // can't happen, just for typecheck
  }
}

private fun double-R(left: bbtree<k,v>, key: k, value: v, right: bbtree<k,v>): bbtree<k,v> {
  match(left) {
    Node(ll, Node(lrl, lrr, _, lrk, lrv), _, lk, lv) ->
      new-node(new-node(ll, lk, lv, lrl), lrk, lrv,
               new-node(lrr, key, value, right))
    _ -> right // can't happen, just for typecheck
  }
}

private fun balance(left: bbtree<k,v>, key: k, value: v, right: bbtree<k,v>): bbtree<k,v> {
  val sr = node-size(right)
  val sl = node-size(left)
  if ((sl + sr) <= 1) {
    new-node(left, key, value, right)
  }
  elif (sr > (omega * sl)) {
    match(right) {
      Node(rl, rr, _, _, _) ->
        if (node-size(rl) < (alpha * node-size(rr))) {
          single-L(left, key, value, right)
        }
        else {
          double-L(left, key, value, right)
        }
      _ -> right // can't happen, just for typecheck
    }
  }
  elif (sl > (omega * sr)) {
    match(left) {
      Node(ll, lr, _, _, _) ->
        if (node-size(lr) < (alpha * node-size(ll))) {
          single-R(left, key, value, right)
        }
        else {
          double-R(left, key, value, right)
        }
      _ -> left // can't happen, just for typecheck
    }
  }
  else {
    new-node(left, key, value, right)
  }
}

// `bbt-insert` returns a new tree with the (`key`, `value`) pair added, or
// replaced if `key` is already in the `tree`. O(log N)
//
public fun bbt-insert(tree: bbtree<k,v>, key: k, value: v): cmp<k> bbtree<k,v> {
  match(tree) {
    Node(tl, tr, _, tk, tv) ->
      match(cmp(key, tk)) {
        Lt -> balance(bbt-insert(tl, key, value), tk, tv, tr)
        Gt -> balance(tl, tk, tv, bbt-insert(tr, key, value))
        Eq -> new-node(tl, key, value, tr)
      }
    Tip -> new-leaf(key, value)
  }
}

// `bbt-lookup` retrieves the value for `key` in the `tree` iff `key` is in the
// tree.  Otherwise, `default` is returned. O(log N)
public fun bbt-lookup(tree: bbtree<k,v>, key: k, default: v): cmp<k> v {
  match(tree) {
    Node(tl, tr, _, tk, tv) ->
      match(cmp(key, tk)) {
        Lt -> bbt-lookup(tl, key, default)
        Gt -> bbt-lookup(tr, key, default)
        Eq -> tv
      }
    Tip -> default
  }
}

fun glue(left: bbtree<k,v>, right: bbtree<k,v>): bbtree<k,v> {
  fun extract-min(l,r,k,v) {
    match(l) {
      Tip -> (k,v,r)
      Node(ll, lr, _, lk, lv) -> match(extract-min(ll,lr,lk,lv)) {
        (mink, minv, nodep) -> (mink, minv, balance(nodep, k, v, r))
      }
    }
  }
  fun extract-max(l,r,k,v) {
    match(r) {
      Tip -> (k,v,l)
      Node(rl, rr, _, rk, rv) -> match(extract-max(rl,rr,rk,rv)) {
        (maxk, maxv, nodep) -> (maxk, maxv, balance(l, k, v, nodep))
      }
    }
  }
  match (left, right) {
    (l, Tip) -> l
    (Tip, r) -> r
    (Node, Node(l,r,_,k,v)) | node-size(left) > node-size(right)
      -> match(extract-max(l,r,k,v)) {
           (maxk, maxv, leftp) -> new-node(leftp, maxk, maxv, right)
         }
    (Node(l,r,_,k,v),Node)
      -> match(extract-min(l,r,k,v)) {
           (mink, minv, rightp) -> new-node(left, mink, minv, rightp)
         }
  }
}

// `bbt-delete` deletes `key` from `tree`. Does nothing if the key does
// not exist. O(log N)
public fun bbt-delete(tree: bbtree<k,v>, key: k): cmp<k> bbtree<k,v> {
  match(tree) {
    Node(tl, tr, _, tk, tv) ->
      match(cmp(key, tk)) {
        Lt -> balance(bbt-delete(tl, key), tk, tv, tr)
        Gt -> balance(tl, tk, tv, bbt-delete(tr, key))
        Eq -> glue(tl, tr)
      }
    Tip -> tree
  }
}


// ##### map & fold #####

public fun fold(t: bbtree<k,v>, b: b, f: (k, v, b) -> b): b {
  match (t) {
    Tip                     -> b
    Node(tl, tr, _, tk, tv) -> tr.fold(f(tk, tv, tl.fold(b, f)), f)
  }
}

public fun map(t: bbtree<k,v>, f: (k, v) -> b): bbtree<k,b> {
  match (t) {
    Tip                     -> Tip
    Node(tl, tr, _, tk, tv) -> new-node(map(tl, f), tk, f(tk, tv), map(tr, f))
  }
}


// ##### iterators #####

public struct keyval<k,v> {
  key: k
  value: v
}

public effect yieldkv<k,v> {
  control yield(kv: keyval<k,v>) : bool
}

// `inorder` traversal of the tree `tree`, i.e., from smallest to largest key.
// Use of an explicit stack faciliates early exit when `yield` returns false.
//
public fun inorder(tree: bbtree<k,v>) : <div,yieldkv<k,v>> () {
  var stack := Nil // : list<bbtree<k,v>>
  var curr := tree
  var cont := True
  while { match((stack, curr)) {
            (Nil, Tip) -> False
            _ -> cont
        }
  } {
    while { match(curr) {
              Tip -> False
              Node(nl, _, _, _, _) -> {
                stack := Cons(curr, stack)
                curr := nl
                cont
              }
            }
    } {}
    match(stack) {
      Cons(Node(_, nr, _, nk, nv)) -> {
        cont := yield(Keyval(nk, nv))
        curr := nr
      }
      _ -> ()
    }
  }
#  match(tree) {
#    Node(tl, tr, _, tk, tv) -> {
#      inorder(tl)
#      yield(Keyval(tk, tv))
#      inorder(tr)
#    }
#    Tip -> ()
#  }
}

public fun revorder(tree: bbtree<k,v>) : <div,yieldkv<k,v>> () {
  match(tree) {
    Node(tl, tr, _, tk, tv) -> {
      inorder(tr)
      yield(Keyval(tk, tv))
      inorder(tl)
    }
    Tip -> ()
  }
}

// #############################################################################
// BBTree of int keys and generic values

private fun cmp-int(x: int, y:int): order { compare(x,y) }

public fun bbt-ofint-insert(tree: bbtree<int,v>, key: int, value: v): bbtree<int,v> {
  with fun cmp(x: int, y:int) { compare(x,y) }
  #with fun cmp = cmp-int # NG
  bbt-insert(tree, key, value)
}

public fun bbt-ofint-lookup(tree: bbtree<int,v>, key: int, default: v): v {
  with fun cmp(x: int, y:int) { compare(x,y) }
  bbt-lookup(tree, key, default)
}

public fun bbt-ofint-delete(tree: bbtree<int,v>, key: int): bbtree<int,v> {
  with fun cmp(x: int, y:int) { compare(x,y) }
  bbt-delete(tree, key)
}
