# PATH Inspector

Remove duplicate entries from a `PATH`-style string, keeping order.

## Input
`$1` is the path to a file with a single line: a `:`-delimited list
of directories, same shape as the `$PATH` environment variable.

## Output
The same list with duplicate entries removed — only the **first**
occurrence of each entry is kept, in its original position. Print
the result as a single `:`-delimited line.

## Constraints
- At most 10,000 entries.
- The line never starts or ends with `:`, and never contains `::`
  (no empty entries).
- Entries are compared exactly — case-sensitive, no path
  normalization.

## Example
Input:
```
/usr/local/bin:/usr/bin:/bin:/usr/local/bin:/opt/binz
```

Output:
```
/usr/local/bin:/usr/bin:/bin:/opt/binz
```
