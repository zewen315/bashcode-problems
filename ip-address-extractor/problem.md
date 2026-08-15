# IP Address Extractor

Find every valid IPv4 address in a file of free-form text. The whole
problem is really about getting the pattern exactly right — a naive
`[0-9]{1,3}(\.[0-9]{1,3}){3}` matches plenty of things that aren't
actually valid IP addresses.

## Input
`$1` is the path to a file. Each line is free-form text made of
whitespace-separated tokens (words, numbers, punctuation-attached
junk, anything).

## What counts as a valid IP
A token is a valid IPv4 address only if it is **exactly** four
dot-separated octets, each satisfying **all** of:
- A whole number from `0` to `255`.
- No leading zeros — `0` itself is fine, but `00`, `01`, `007` are
  not.

The match must consume the **entire token** — nothing before or
after. A token like `10.0.0.5:8080` or `1.2.3.4.5` is not a valid IP,
even though it contains what looks like one.

## Output
For every line (1-indexed) that contains at least one valid IP token,
print:

```
<line number>: <ip1> <ip2> ...
```

listing every valid IP found on that line, space-separated, in the
order they appear. Lines with no valid IP are omitted entirely. If no
line in the whole file has one, print nothing.

## Constraints
- At most 100,000 lines.
- Tokens are split purely on whitespace — punctuation like commas,
  colons, or extra `.`-groups can end up glued onto a token (e.g.
  `10.0.0.5:8080`, `1.2.3.4.5`, `192.168.1.1,`). None of those count
  as a match; only a token that is a valid IP and nothing else does.

## Example
Input:
```
connect to 192.168.1.1 or 10.0.0.1 failed, retry 999.1.1.1 later
```

`192.168.1.1` and `10.0.0.1` are valid. `999.1.1.1` isn't (`999` is
out of range).

Output:
```
1: 192.168.1.1 10.0.0.1
```
