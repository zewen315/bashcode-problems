# Log Context Extractor

When you're chasing an incident, a bare list of `ERROR` lines is
rarely enough — you need the lines around each one too. This is
exactly `grep -n -C N`'s job, and its output format is specific
enough that reproducing it by hand is the real exercise.

## Input
`$1` is the path to a log file. `$2` is the pattern to search for — a
plain literal substring, not a regex. `$3` is the context size `N`:
the number of lines to include before and after each match.

## Task
A line matches if it contains `$2` as a substring anywhere in it. For
every match, its "window" is that line plus up to `N` lines before it
and `N` lines after it (clipped at the start/end of the file — a
match near either edge simply gets a smaller window there).

If two windows overlap, or are directly adjacent (no line falls
between them), merge them into a single block instead of printing
either separately or twice.

## Output
Print every line inside every window, grouped into blocks:
- A line that is itself a match: `<line number>:<line content>`
- A line that's only there for context: `<line number>-<line content>`

Between two separate blocks (a real gap of at least one omitted line
between them), print a line containing exactly `--`. No `--` before
the first block, after the last block, or between lines that got
merged into the same block.

If nothing matches, print nothing.

## Constraints
- At most 100,000 lines in the file.
- `N` is a non-negative integer (`0` means: only the matching lines
  themselves, no surrounding context — separators still apply
  between non-adjacent matches).
- Line numbers are 1-indexed, counting from the top of the file.

## Example
File (line numbers shown for reference — not part of the file's
actual content, just its position from the top):
```
line 1: INFO start
line 2: INFO connecting
line 3: ERROR timeout
line 4: INFO retry
line 5: INFO ok
```
Command: pattern `ERROR`, `N = 1`.

Output:
```
2-INFO connecting
3:ERROR timeout
4-INFO retry
```
