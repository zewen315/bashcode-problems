# Zombie Process Report

Given a static `ps`-style snapshot, find every zombie process, group
them by parent, and report each parent's zombie children.

## Input
`$1` is the path to a file with one process per line:

```
<pid> <ppid> <state> <cmd>
```

## Task
1. Find every process whose `state` is exactly `Z` (zombie).
2. Group them by `ppid`.
3. For each group, look up that `ppid` as a `pid` elsewhere in the
   *same* snapshot to get the parent's `cmd`. If no process in the
   snapshot has that `pid`, the parent's command is `UNKNOWN`. This
   lookup doesn't care whether the parent itself is a zombie or not —
   whatever `cmd` is on that `pid`'s line is what gets used.

## Output
```
PARENT <ppid> (<parent_cmd>): <count> zombies
  <pid> <cmd>
  <pid> <cmd>
```

One such block per parent group, each zombie child indented two
spaces. Groups are sorted by zombie count **descending**; ties are
broken by `ppid` ascending. Within a group, children are sorted by
`pid` ascending. If there are no zombies at all, print nothing.

## Constraints
- At most 100,000 processes.
- Each `pid` appears at most once in the snapshot.
- `cmd` contains no whitespace.
- A process's `ppid` can equal its own `pid` (bad data, not a real
  process tree) — don't try to resolve it any further than the one
  direct lookup described above; there's no chain to follow and
  nothing to detect a cycle in.

## Example
Input:
```
1 0 S init
100 1 S sshd
200 100 Z <defunct>
201 100 Z <defunct>
300 1 S cron
400 300 Z <defunct>
500 9999 Z orphan-zombie
```

Zombies: `200` and `201` (parent `100`, `sshd`), `400` (parent `300`,
`cron`), `500` (parent `9999`, not present in the snapshot →
`UNKNOWN`).

Output:
```
PARENT 100 (sshd): 2 zombies
  200 <defunct>
  201 <defunct>
PARENT 300 (cron): 1 zombies
  400 <defunct>
PARENT 9999 (UNKNOWN): 1 zombies
  500 orphan-zombie
```
