# Render Progress Bar

Given a list of named downloads and their completion percentage, render
an ASCII progress bar for each one.

## Input
A single argument: the path to a file with one entry per line, in the
form:

```
<name> <percent>
```

`percent` is an integer from `0` to `100`.

## Output
For each line, in the same order as the input, print:

```
<name> [<bar>] <percent>%
```

The bar is always exactly 20 characters wide, made of `#` for the
completed portion and `-` for the remaining portion. The number of `#`
characters is `percent` scaled to a 20-character bar and rounded to the
nearest integer (e.g. `13%` of 20 is `2.6`, which rounds to `3`).

## Constraints
- The file has at most 100,000 lines.
- `name` contains no whitespace.
- `percent` is always an integer in `[0, 100]`.

## Example
Input:
```
download-a 25
download-b 60
download-c 100
```

Output:
```
download-a [#####---------------] 25%
download-b [############--------] 60%
download-c [####################] 100%
```
