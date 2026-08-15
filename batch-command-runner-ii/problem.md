# Batch Command Runner II

You are given a file containing one host name per line, a batch
size, and an arbitrary command with its arguments. Run the command
once per batch, appending the hosts in that batch to the command's
existing arguments.

## Input
```
./solution.sh <hosts_file> <batch_size> <command> [command_args...]
```
`$1` is the hosts file. `$2` is the batch size. `$3` is the command
to run. Everything from `$4` onward is that command's own existing
arguments (there is always at least one).

For example:
```
./solution.sh hosts.txt 2 ./deploy.sh --env prod
```
with `hosts.txt`:
```
api-01
api-02
worker-01
worker-02
worker-03
```
must behave as if the following commands were executed:
```
./deploy.sh --env prod api-01 api-02
./deploy.sh --env prod worker-01 worker-02
./deploy.sh --env prod worker-03
```

## Requirements
- Preserve the original host order.
- Run the supplied command once for each batch.
- Append each batch of hosts after all existing command arguments.
- The final batch may contain fewer hosts than `batch_size`.
- `batch_size` is guaranteed to be an integer greater than or equal
  to 1.
- Host names do not contain whitespace.
- At least one command argument is always provided after
  `batch_size`.
- If the host file is empty, do not run the command at all.
- Preserve the original boundaries of the supplied command
  arguments. An argument containing spaces must remain a single
  argument.
- Do not use `eval`.
- If any batch's command exits with a non-zero status, stop
  immediately and exit with that same status.
- If every batch succeeds, exit with status 0.

## Example
Suppose the supplied command is:
```
./record.sh "production cluster"
```
Running:
```
./solution.sh hosts.txt 3 ./record.sh "production cluster"
```
must preserve `"production cluster"` as one argument and execute the
equivalent of:
```
./record.sh "production cluster" api-01 api-02 worker-01
./record.sh "production cluster" worker-02 worker-03
```

## Exit status
If the command for a batch exits with status 7, the script must stop
processing further batches and exit with status 7 itself.

## Notes
This problem is designed around real shell argument handling. In
particular, be careful not to collapse the supplied command and its
arguments into a single string.

Your solution is judged by behavior, not by whether you use `xargs`,
arrays, or loops.
