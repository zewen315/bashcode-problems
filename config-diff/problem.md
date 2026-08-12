# Config Diff

Given an old config and a new config, print the differences between
them.

## Input
Two arguments: the path to the old config, then the path to the new
config. Each file has one `KEY=VALUE` setting per line. For example, the
old config might be:

```
LOG_LEVEL=info
PORT=8080
RETRIES=3
```

and the new config:

```
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
- Each file has at most 10,000 lines.
- Keys are unique within each file.
- Keys and values never contain `=` themselves.

## Example
Old config:
```
LOG_LEVEL=info
PORT=8080
RETRIES=3
```

New config:
```
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
