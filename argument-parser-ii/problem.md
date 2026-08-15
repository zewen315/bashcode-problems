# Argument Parser II

A follow-up to [Argument Parser I](../argument-parser-i): the same
three flags, but now each one also has a long-option spelling — which
`getopts` (the bash builtin) can't parse at all. It only understands
single-character options.

## Input
Same as Part I: no input file, just your script's own command-line
flags, in any order, zero or more times each. Each flag can be given
in **any** of its forms:

```
-n <count>          or   --count <count>   or   --count=<count>
-v                   or   --verbose
-o <name>            or   --output <name>   or   --output=<name>
```

## Output
Same three lines, same fixed order, regardless of which form each
flag was given in:

```
n=<value or 0 if never given>
v=<true if given in any form, otherwise false>
o=<value or none if never given>
```

## Constraints
- A flag may appear more than once, mixing forms freely — the last
  occurrence wins, whichever spelling it used.
- Values never contain whitespace or `=`.
- At most 20 flags total.

## Example
Invocation:
```
./solution.sh -n 5 --verbose --output=report
```

Output:
```
n=5
v=true
o=report
```
