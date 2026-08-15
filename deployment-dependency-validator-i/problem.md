# Deployment Dependency Validator I

Given a set of services' dependencies and a proposed startup order,
check whether that order actually works — does every service's
dependencies get started before its own turn comes?

## Input
`$1` is the path to a file with one service per line:

```
<service>: <dep1> <dep2> ...
```

A service's dependency list may be empty (just `<service>:`).

`$2` is the path to a file listing services one per line, in the
order they're attempted to start. Every service named in `$2` is
guaranteed to be declared in `$1` and named at most once, but `$2`
isn't required to include every declared service — one that's simply
never attempted is never "started," which can still cause something
else to fail.

## Task
Simulate starting services in the order given by `$2`. For each
service, in turn: it starts successfully only if *every* one of its
declared dependencies has *already* started earlier in the same
simulation. If even one dependency hasn't started yet — whether
because it's scheduled later, was never attempted at all, or was
itself attempted earlier and failed — this service fails to start
too, and it never gets a second chance.

Failures cascade: a service that fails to start never counts as
"started" for anything that depends on it later.

## Output
For every service that fails, one line per unmet dependency (in the
order that service's own dependency list declares them):

```
MISSING: <service> depends on <dep>, which never started
```

If every attempted service starts successfully, print:

```
ALL SERVICES STARTED
```

## Constraints
- At most 100,000 services, at most 100,000 lines in the startup
  order.
- Each service is declared at most once in `$1`, and named at most
  once in `$2`.
- Service names contain no whitespace or `:`.

## Example
`$1`:
```
api: auth db
auth: db
db:
cache: redis
redis:
```

`$2` (`api` is attempted before either of its dependencies):
```
api
db
auth
redis
cache
```

`api` fails — neither `auth` nor `db` has started yet at that point.
Everything else starts fine, in the order given.

Output:
```
MISSING: api depends on auth, which never started
MISSING: api depends on db, which never started
```
