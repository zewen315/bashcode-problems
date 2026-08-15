# Argument Parser I

Unlike every other problem here, there's no input *file* — the input
is your script's own command-line flags, exactly what `getopts` is
for.

## Input
Your script is invoked with some combination of these flags, in any
order, zero or more times each:

```
-n <count>   an integer
-v           a boolean flag (no value)
-o <name>    a string
```

Any flag may be omitted. `-n` and `-o` always take the very next
argument as their value.

## Output
Print exactly three lines, in this fixed order, regardless of what
order the flags were given in:

```
n=<value or 0 if -n was never given>
v=<true if -v was given, otherwise false>
o=<value or none if -o was never given>
```

## Constraints
- A flag may appear more than once — the last occurrence wins.
- Values never contain whitespace.
- At most 20 flags total.

## Example
Invocation:
```
./solution.sh -n 5 -v -o report
```

Output:
```
n=5
v=true
o=report
```
