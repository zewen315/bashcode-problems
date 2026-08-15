# Batch Command Runner I

You are given a file containing one host name per line and a batch
size. Build deployment commands by grouping the hosts in their
original order. Each command may contain at most the requested
number of hosts.

## Input
`$1` is the path to the hosts file. `$2` is the batch size.

## Task
For every batch, print:
```
deploy <host1> <host2> ...
```
The final batch may contain fewer hosts than the batch size.

## Output
One line per batch, in the format above, in the same order as the
hosts file.

## Constraints
- `batch_size` is guaranteed to be an integer greater than or equal
  to 1.
- Host names do not contain whitespace.
- If the host file is empty, print nothing and exit successfully.
- Do not print extra status or diagnostic messages.

## Example 1
Input file (`hosts.txt`):
```
api-01
api-02
worker-01
worker-02
worker-03
```
Command:
```
./solution.sh hosts.txt 2
```
Output:
```
deploy api-01 api-02
deploy worker-01 worker-02
deploy worker-03
```

## Example 2
Command:
```
./solution.sh hosts.txt 3
```
Output:
```
deploy api-01 api-02 worker-01
deploy worker-02 worker-03
```

## Notes
Your solution is judged by its output, not by which commands you use.
