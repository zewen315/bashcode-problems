# Traffic Volume Report

Each line in the input file contains traffic data for one edge server:

```
<server> <requests_per_second> <duration_seconds>
```

For each server, calculate the total number of requests processed
during the interval:

```
total_requests = requests_per_second × duration_seconds
```

Print only servers whose total request count is **greater than 50,000**.

Output each matching server as:

```
<server> <total_requests>
```

Sort the output by total request count in **descending order**; ties
broken by server name ascending.

## Input
`$1` is the path to the traffic data file.

Example:
```
edge-sfo 1200 60
edge-nyc 850 30
edge-lhr 1500 60
edge-fra 600 60
```

You may assume:
- Every line contains exactly three whitespace-separated fields.
- `requests_per_second` and `duration_seconds` are non-negative integers.
- Server names contain no whitespace.

## Output
For the example above:
```
edge-lhr 90000
edge-sfo 72000
```

`edge-nyc` and `edge-fra` are omitted because their total request counts
do not exceed `50000`.
