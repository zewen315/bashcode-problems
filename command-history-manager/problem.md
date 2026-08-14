# Command History Manager

Simulate a deploy tool's command history. Process a sequence of
operations, one per line, and support undoing the most recent one.

## Input
`$1` is the path to a file with one operation per line:

```
ADD <name>
UNDO
PRINT
```

- `ADD <name>` records a command as having been run.
- `UNDO` removes the most recently added command. If there's nothing
  to undo, it does nothing.
- `PRINT` prints the currently recorded commands, oldest first, one
  per line. If there are none, it prints nothing.

## Output
The concatenation of everything every `PRINT` produces, in order.

## Constraints
- At most 100,000 lines.
- `<name>` contains no whitespace.
- `UNDO` only ever undoes the most recent `ADD` — there's no redo.

## Example
Input:
```
ADD deploy
ADD restart
ADD status
UNDO
ADD rollback
PRINT
```

`UNDO` removes `status` (the most recent), leaving `deploy` and
`restart`, then `rollback` gets added.

Output:
```
deploy
restart
rollback
```
