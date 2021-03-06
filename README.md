# BBTree

BBTree is a Bounded Balance Tree library for the [Koka programming language](https://github.com/koka-lang/koka).

*This repository is a very early work in process and is not complete, tested or ready for use!*

## BBTree Overview

BBTrees, also known as Weight Balanced Trees, or Adams Trees, are a persistent data structure
with a nice combination of properties:

* Generic (parameterized) key,value map
* Insert (`bbt-insert`), lookup (`bbt-lookup`), and delete (`bbt-delete`) in O(log(N)) time
* ??? Key-ordered iterators (`inorder` and `revorder`)
* Lookup by relative position from beginning or end (`bbt-getNth`) in O(log(N)) time
* Get the position (`bbt-rank`) by key in O(log(N)) time
* Efficient set operations using tree keys
* Map extensions to set operations with optional value merge control for duplicates

By "persistent" we mean that the BBTree always preserves the previous version of itself when it is modified. As such it is effectively immutable, as the operations do not (visibly) update the structure in-place, but instead always yield a new updated structure.

The BBTree data structure resides in heap memory, and is destroyed by the garbage collector when there are no longer any program references to it. When insertions or deletions to the tree are made, we attempt to reuse as much of the old structure as possible.

Because the BBTree is never mutated all library functions that operate on it are Koka `total` -- except that the effect `cmp` is used to pass in a comparison function.

~~A BBTree may be shared across threads safely (though updates in one thread will not be visible
in another until the modified tree is shared once again).~~ This was "apparent" to me, having used tracing GC based tools almost exclusively. Araq pointed out that with reference counting memory managers, tree nodes shares across threads need atomic refcounts, which are not available in Nim's ARC (as of v1.4).

## BBTree Credits

References:

*Implementing Sets Efficiently in a Functional Language*
Stephen Adams
CSTR 92-10
Department of Electronics and Computer Science University of Southampton Southampton S09 5NH

*Adams’ Trees Revisited Correct and Efficient Implementation*
Milan Straka
Department of Applied Mathematics Charles University in Prague, Czech Republic

[Weight-balanced trees](https://en.wikipedia.org/wiki/Weight-balanced_tree) on Wikipedia


## BBTree Details

TODO once the build and test procedure is worked out

### License

MIT. See file LICENSE.

## Notes

For comparison, take a look at [Lobster BBTree](https://github.com/dcurrie/lobster-bbtree) and [Nim BBTree](https://github.com/dcurrie/nim-bbtree)
