module bbtree

// balance criteria
private val omega = 3
private val alpha = 2

public effect cmp<k> {
  fun cmp(x: k, y: k) : order
}

public type bbtree<k,v> {
  BbNil
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
    Node(BbNil, BbNil, 1, key, value)
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
        // BbNil -> // identifier BbNil is ambiguous!
        _ -> new-leaf(key, value)
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
        // BbNil -> // identifier BbNil is ambiguous!
        _ -> default
    }
}

#private fun extract-min(node: bbtree<k,v>): exn (k, v, bbtree<k,v>) {
#    match(node) {
#        Node(BbNil, tr, _, tk, tv) ->
#            (tk, tv, tr)
#        Node(tl, tr, _, tk, tv) ->
#            match(extract-min(tl)) {
#                (mink, minv, nodep) -> (mink, minv, balance(nodep, tk, tv, tr))
#            }
#    }
#}
#private fun extract-max(node: bbtree<k,v>): exn (k, v, bbtree<k,v>) {
#    match(node) {
#        Node(tl, BbNil, _, tk, tv) ->
#            (tk, tv, tl)
#        Node(tl, tr, _, tk, tv) ->
#            match(extract-max(tr)) {
#                (maxk, maxv, nodep) -> (maxk, maxv, balance(tl, tk, tv, nodep))
#            }
#    }
#}
private fun glue(left: bbtree<k,v>, right: bbtree<k,v>): bbtree<k,v> {
    fun extract-min(node: bbtree<k,v>): (k, v, bbtree<k,v>) {
        match(node) {
            Node(BbNil, tr, _, tk, tv) ->
                (tk, tv, tr)
            Node(tl, tr, _, tk, tv) ->
                match(extract-min(tl)) {
                    (mink, minv, nodep) -> (mink, minv, balance(nodep, tk, tv, tr))
                }
        }
    }
    fun extract-max(node: bbtree<k,v>): (k, v, bbtree<k,v>) {
        match(node) {
            Node(tl, BbNil, _, tk, tv) ->
                (tk, tv, tl)
            Node(tl, tr, _, tk, tv) ->
                match(extract-max(tr)) {
                    (maxk, maxv, nodep) -> (maxk, maxv, balance(tl, tk, tv, nodep))
                }
        }
    }
    match (left, right) {
        (l, BbNil) -> l
        (BbNil, r) -> r
        _ ->
            if (node-size(left) > node-size(right)) {
                match(extract-max(left)) {
                    (maxk, maxv, leftp) -> new-node(leftp, maxk, maxv, right)
                }
            }
            else {
                match(extract-min(right)) {
                    (mink, minv, rightp) -> new-node(left, mink, minv, rightp)
                }
            }
    }
}

public fun bbt-delete(tree: bbtree<k,v>, key: k): cmp<k> bbtree<k,v> {
    match(tree) {
        Node(tl, tr, _, tk, tv) ->
            match(cmp(key, tk)) {
                Lt -> balance(bbt-delete(tl, key), tk, tv, tr)
                Gt -> balance(tl, tk, tv, bbt-delete(tr, key))
                Eq -> glue(tl, tr)
            }
        // BbNil -> // identifier BbNil is ambiguous!
        _ -> tree
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



