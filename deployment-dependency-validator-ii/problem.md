# Deployment Dependency Validator II

A follow-up to
[Deployment Dependency Validator I](../deployment-dependency-validator-i):
same *dependency declarations*, but now look for a **cycle** in the
dependency graph itself, rather than checking a proposed startup
order against it — there's no second file here, just the
declarations.

## Input
`$1` is the path to a file with one service per line, same format as
Part I's first file:

```
<service>: <dep1> <dep2> ...
```

Every dependency named anywhere is guaranteed to be a declared
service (no missing-service case to worry about here).

## Task
Find a cycle in the dependency graph, if one exists, using this exact
procedure — there can be more than one cycle in the graph, and this
is what pins down *which* one to report:

1. Consider services as roots for a depth-first search **in
   alphabetical order**, skipping any service already visited by an
   earlier root's search.
2. Within a single depth-first search, when visiting a service, walk
   its dependencies **in the order they're listed on its own line**
   (not alphabetically).
3. If a dependency is already on the *current* search path (not just
   visited at some point — actually still an ancestor in this
   specific search), that's a cycle. Report it immediately and stop
   entirely — don't look for any other cycles.

## Output
If a cycle is found:

```
CYCLE: <service> -> <service> -> ... -> <service>
```

The cycle starts at whichever service first reopened the loop (i.e.
the earliest point in the *current* search path that the repeated
dependency points back to — not necessarily the alphabetically-first
service overall), lists each service once around the loop in the
order the search visited them, and repeats the starting service again
at the end. If there's no cycle anywhere in the graph, print nothing.

## Constraints
- At most 100,000 services.
- A service listing itself as its own dependency is a valid (trivial)
  cycle.
- Every dependency named by any service is itself a declared service.

## Example
Input:
```
a: b
b: c
c: a
```

Depth-first search starts at `a` (alphabetically first, nothing
visited yet): `a -> b -> c`, and `c`'s dependency `a` is already on
the current path (at the very start of it) — cycle found.

Output:
```
CYCLE: a -> b -> c -> a
```
