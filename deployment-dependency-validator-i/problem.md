# Deployment Dependency Validator I

Given a set of services and what each one depends on, find every
dependency that points at a service that was never actually declared.

## Input
`$1` is the path to a file with one service per line:

```
<service>: <dep1> <dep2> ...
```

A service's dependency list may be empty (just `<service>:` with
nothing after it). Every service named on the left of a `:` counts as
**declared**, even if its own dependency list is empty.

## Task
For every service, check each of its dependencies: if that dependency
was never declared (never appears on the left of a `:` anywhere in
the file), it's missing.

## Output
One line per distinct `(service, missing dependency)` pair:

```
MISSING: <service> depends on undefined service <other>
```

In the order services are declared in the input, and within a
service's own list, in the order its dependencies are listed. If a
service lists the same missing dependency more than once, report it
only once. Print nothing if every dependency resolves to a declared
service.

## Constraints
- At most 100,000 services.
- Each service is declared at most once.
- Service names contain no whitespace or `:`.
- A service depending on itself doesn't count as missing, as long as
  it's declared (it is, by definition, if it has its own line).

## Example
Input:
```
api: auth db
auth: db
db:
cache: redis
```

`redis` is never declared, so `cache`'s dependency on it is missing.
Everything else (`auth`, `db`) is declared.

Output:
```
MISSING: cache depends on undefined service redis
```
