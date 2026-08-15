# Log File Digest

Print a quick size summary of a log file.

## Input
`$1` is the path to a file.

## Output
Three numbers on one line, space-separated:
```
<lines> <words> <non_blank_lines>
```
- `lines`: total number of lines in the file.
- `words`: total number of whitespace-separated words across every
  line.
- `non_blank_lines`: number of lines with at least one character. A
  line containing only whitespace (e.g. a line of spaces) still
  counts as non-blank — only a completely empty line (zero
  characters) doesn't.

## Constraints
- At most 100,000 lines.

## Example
Input:
```
INFO service started
WARN low disk space

INFO retry succeeded
```
(line 3 is empty)

Output:
```
4 10 3
```
