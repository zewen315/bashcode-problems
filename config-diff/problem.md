# Config Diff

Given a file containing an old config and a new config, print the
differences between them.

## Input
A single argument: the path to a file with `KEY=VALUE` settings for the
old config, then a line containing exactly `---`, then the `KEY=VALUE`
settings for the new config. For example:

```
LOG_LEVEL=info
PORT=8080
RETRIES=3
---
LOG_LEVEL=debug
PORT=9090
WORKERS=4
```

## Output
For every key that appears in either config, sorted by key name
ascending:

- If the key exists in both configs with different values, print
  `- KEY=old_value` followed by `+ KEY=new_value`.
- If the key only exists in the old config (removed), print
  `- KEY=old_value`.
- If the key only exists in the new config (added), print
  `+ KEY=new_value`.
- If the key exists in both configs with the same value, print nothing
  for it.

## Constraints
- The file has at most 10,000 lines total, and contains exactly one
  `---` separator line.
- Keys are unique within each config section.
- Keys and values never contain `=` themselves, and no key is literally
  named `---`.

## Example
Input:
```
LOG_LEVEL=info
PORT=8080
RETRIES=3
---
LOG_LEVEL=debug
PORT=9090
WORKERS=4
```

Output:
```
- LOG_LEVEL=info
+ LOG_LEVEL=debug
- PORT=8080
+ PORT=9090
- RETRIES=3
+ WORKERS=4
```
