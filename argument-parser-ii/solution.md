# Solution

`getopts` (the bash builtin from Part I) can't do this — it only
understands single-character options, nothing starting with `--`. Two
ways to handle both forms anyway.

## 1. `getopt` (the external command), then a normal loop

```bash
ARGS=$(getopt -o n:vo: -l count:,verbose,output: -- "$@")
eval set -- "$ARGS"

n=0
v=false
o=none
while true; do
  case "$1" in
    -n|--count) n="$2"; shift 2 ;;
    -v|--verbose) v=true; shift ;;
    -o|--output) o="$2"; shift 2 ;;
    --) shift; break ;;
    *) shift ;;
  esac
done
echo "n=$n"
echo "v=$v"
echo "o=$o"
```

`getopt` (unlike the `getopts` builtin) understands both short and
long options in one pass — `-o n:vo:` declares the short ones exactly
like `getopts` did, `-l count:,verbose,output:` declares their long
equivalents (a trailing `:` again means "takes a value"). Its job is
purely to *normalize*: it rewrites `--output=report` into `--output
'report'` and appends a trailing `--`, so every value — regardless of
which form or spacing it was originally given in — comes out the same
shape. `eval set -- "$ARGS"` replaces the script's own `$@` with that
normalized version, and the loop after that is exactly Part I's manual
loop, just matching `-n|--count` and `-o|--output` together as
equivalent branches. The `--` case marks the end of options and
`break`s out.

## 2. Fully manual, no external tools

```bash
n=0
v=false
o=none
while [ $# -gt 0 ]; do
  case "$1" in
    -n|--count) n="$2"; shift 2 ;;
    --count=*) n="${1#--count=}"; shift ;;
    -v|--verbose) v=true; shift ;;
    -o|--output) o="$2"; shift 2 ;;
    --output=*) o="${1#--output=}"; shift ;;
    *) shift ;;
  esac
done
echo "n=$n"
echo "v=$v"
echo "o=$o"
```

No normalization step — instead, the `--flag=value` form gets its own
`case` branch per option: `--count=*)` matches the whole token, and
`${1#--count=}` strips the `--count=` prefix off the front, leaving
just the value. `-n`/`--count` (space-separated) is handled the same
way as Part I, matched together as one branch since they behave
identically once split. This avoids depending on `getopt` at all, at
the cost of one extra `case` arm per option that supports the `=`
form.
