# Config File Validator

Given a config file and a list of required keys, report every problem
found with the config.

## Input
Two arguments: the path to the config file, then the path to the
required-keys file.

The config file has zero or more lines. Each non-blank line is meant
to be `KEY=VALUE` (the key is everything before the first `=`; the
value is everything after it, and may itself contain `=` characters).
Blank lines are ignored.

The required-keys file has one key per line — every key that must be
present in the config.

## Output
Check the config file for these problems, in this order:

1. **Malformed lines** — any non-blank line with no `=` at all, or
   with nothing before the first `=` (an empty key). Print
   `Malformed line: <the original line>` for each one, in the order
   they appear in the file.
2. **Duplicate keys** — any key that appears as a valid `KEY=VALUE`
   line more than once. Print `Duplicate key: <KEY>` for each one,
   sorted alphabetically.
3. **Missing required keys** — any key from the required-keys file
   that never appears as a valid `KEY=VALUE` line in the config. Print
   `Missing required key: <KEY>` for each one, sorted alphabetically.

If none of the above found anything, print exactly `VALID` instead.

A key still counts as present even if it's also duplicated, and even
if a value is empty (`KEY=` is valid, just with an empty value).

## Constraints
- Both files have at most 100,000 lines.
- A key may contain any characters except `=` or a newline (there's no
  restriction to letters/digits/underscores).

## Example
Config file:
```
PORT=8080
HOST=localhost
PORT=9090
=invalid
DEBUG
TIMEOUT=30
```

Required keys:
```
PORT
HOST
API_KEY
TIMEOUT
```

Output:
```
Malformed line: =invalid
Malformed line: DEBUG
Duplicate key: PORT
Missing required key: API_KEY
```
