# CPU Usage

Given CPU usage information for a set of services, identify the
services running high CPU usage and count how many are in a critical
state.

## Input
`$1` is the path to a file with one service per line:

```
<service> <cpu_usage>
```

## Rules
For each service:
- If CPU usage is less than `80`, ignore it.
- If CPU usage is greater than or equal to `80`, add the service to
  the high-CPU list.
- If CPU usage is greater than or equal to `90`, also count it as
  critical (it's still on the high-CPU list too, not instead of it).

## Output
After processing all services:
- If no service has CPU usage `>= 80`, print:
  ```
  ALL HEALTHY
  ```
- Otherwise, print the high-CPU services in their original input
  order, space-separated, followed by the critical count:
  ```
  High CPU: <service1> <service2> ...
  Critical: <count>
  ```

## Constraints
- At most 100,000 services.
- `cpu_usage` is a non-negative integer.
- `service` contains no whitespace.

## Example 1
Input:
```
api 40
worker 85
database 70
cache 95
```

Output:
```
High CPU: worker cache
Critical: 1
```

## Example 2
Input:
```
api 20
worker 79
```

Output:
```
ALL HEALTHY
```

## Example 3
Input:
```
api 90
worker 100
```

Output:
```
High CPU: api worker
Critical: 2
```
