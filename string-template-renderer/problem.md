# String Template Renderer

Given a template file and a variables file, render the template by
substituting each `{{KEY}}` placeholder with its value.

## Input
Two arguments: the path to the template file, then the path to the
variables file.

The template contains zero or more placeholders of the form `{{KEY}}`.
The variables file has one `KEY=VALUE` setting per line, e.g.:

```
NAME=Alice
BALANCE=$100.50
EMAIL=alice@example.com
```

## Output
Print the template with every `{{KEY}}` replaced by its value:

- If `KEY` exists in the variables file, replace the placeholder
  (braces included) with its value, used exactly as written — values
  may contain any character, including `$`, `.`, `/`, `&`, or `%`, and
  must be substituted literally, not treated as part of a pattern.
- If `KEY` does **not** exist in the variables file, leave the
  placeholder (including the braces) unchanged.
- The same placeholder may appear more than once in the template, and
  should be replaced every time it appears.

## Constraints
- The template has at most 100,000 lines.
- `KEY` consists only of letters, digits, and underscores.
- A `{{...}}` placeholder never spans more than one line.
- Keys in the variables file are unique; values never contain a
  newline, but may otherwise contain any character.

## Example
Template:
```
Hello {{NAME}}, your balance is {{BALANCE}}.
Contact: {{EMAIL}}
```

Variables:
```
NAME=Alice
BALANCE=$100.50
EMAIL=alice@example.com
```

Output:
```
Hello Alice, your balance is $100.50.
Contact: alice@example.com
```
