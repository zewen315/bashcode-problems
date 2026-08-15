# Service Health Summary

Report which services have at least one non-healthy instance, from
a nested JSON health-check sweep.

## Input
`$1` is the path to a single JSON file shaped like:
```json
{
  "services": [
    {
      "name": "api",
      "region": "us-east",
      "instances": [
        {"id": "api-1", "status": "healthy"},
        {"id": "api-2", "status": "failed"}
      ]
    }
  ]
}
```
- `services` is an array, in a fixed order.
- Each service has a `name` and an `instances` array (which may be
  empty).
- Each instance has an `id` and a `status`. `"healthy"` means OK;
  any other value (`"failed"`, `"degraded"`, `"unknown"`, ...) means
  not OK.

## Task
For every service that has **at least one** non-healthy instance,
print:
```
<service name>: <id1> <id2> ...
```
listing the ids of just its non-healthy instances, in the order they
appear. A service where every instance is `"healthy"` (or that has
no instances at all) is left out entirely.

## Output
One line per service with at least one non-healthy instance, in the
same order the services appear in the input. If every service is
fully healthy, print nothing.

## Constraints
- At most 10,000 services, each with at most 10,000 instances.
- `region` and any other extra fields may be present and should be
  ignored.

## Example
Input:
```json
{
  "services": [
    {
      "name": "api",
      "region": "us-east",
      "instances": [
        {"id": "api-1", "status": "healthy"},
        {"id": "api-2", "status": "failed"}
      ]
    },
    {
      "name": "worker",
      "region": "us-west",
      "instances": [
        {"id": "worker-1", "status": "healthy"},
        {"id": "worker-2", "status": "healthy"}
      ]
    }
  ]
}
```
Output:
```
api: api-2
```
