# Prod Services

Given a list of hostnames, print the unique service names that are
running in the `prod` environment.

## Input
A single argument: the path to a file with one fully-qualified hostname
per line, in the form:

```
<service>-<environment>-<instance>.<domain>
```

For example:

```
api-prod-01.bashcode.net
search-prod-02.bashcode.net
checkout-staging-01.bashcode.net
```

## Output
The unique service names whose environment is exactly `prod`, sorted
alphabetically, one per line.

## Constraints
- The file has at most 100,000 lines.
- `service` and `environment` never contain `-` or `.` themselves.
- Environment matching is case-sensitive — only exactly `prod` counts.

## Example
Input:
```
api-prod-01.bashcode.net
search-prod-02.bashcode.net
checkout-staging-01.bashcode.net
api-prod-03.bashcode.net
worker-dev-01.bashcode.net
```

Output:
```
api
search
```
