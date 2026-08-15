# Access Log Field Extractor

Extract two fields from a pipe-delimited access log and normalize
the case.

## Input
`$1` is the path to a file. Each line has exactly 5 `|`-delimited
fields:
```
<date>|<service>|<region>|<status>|<latency_ms>
```

## Output
For each line, print:
```
<service> <status>
```
lowercased. Every line produces exactly one output line, in order.

## Constraints
- At most 100,000 lines.
- Fields never contain `|` or whitespace themselves.

## Example
Input:
```
2026-08-15|API|us-east|200|143
2026-08-15|Worker-1|us-west|500|892
2026-08-15|search|us-east|200|231
```

Output:
```
api 200
worker-1 500
search 200
```
