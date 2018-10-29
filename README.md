# Lua Data Structures

This is a collection of some useful datastructures for Lua.

Lua is a very pleasant language to use, but its small, minimal standard library
lacks good implementations of data structures that are necessary to make some
algorithms fast.

# The data structures

**Ropes**. Ropes are an often overlooked data-structure. They're like lists, but
give you fast `O(log n)` gets **and** concatenations. The ropes implemented here
are immutable, like Lua's strings. See `rope.lua`.

**Max heaps**, aka **priority queues**. A heap is a collection that gives fast
access to the "biggest" or "highest priority" value. The heaps implemented here
also allow elements to be quickly removed, which leads to a way to get fast
priority-updates. See `maxheap.lua`.

**Immutable maps**. A map behaves like a table, associated values with keys.
These maps are *immutable*, meaning updates to a map create *new* maps rather
than modify existing ones, while sharing as much memory as possible. This allows
you to efficiently track all versions of a table as it changes over time. See
`map.lua`.
