# Solution

Three flags, defaults for the ones not given, last-one-wins for
repeats. Two ways to walk the argument list.

## 1. `getopts`

```bash
n=0
v=false
o=none
while getopts "n:vo:" opt; do
  case "$opt" in
    n) n="$OPTARG" ;;
    v) v=true ;;
    o) o="$OPTARG" ;;
  esac
done
echo "n=$n"
echo "v=$v"
echo "o=$o"
```

`"n:vo:"` is the option string: `n` and `o` are each followed by `:`,
meaning they consume the next argument as `$OPTARG`; `v` has no `:`,
meaning it's a bare flag. `getopts` handles the actual argv walking —
each call advances past one option (or one option *and* its value)
and updates `OPTIND` internally, so the `while` loop naturally stops
once every flag has been consumed. "Last occurrence wins" falls out
for free: each case just overwrites the variable, so processing `-n 1
-n 99` in order simply leaves `n` at `99`.

## 2. Manual loop, `shift`

```bash
n=0
v=false
o=none
while [ $# -gt 0 ]; do
  case "$1" in
    -n) n="$2"; shift 2 ;;
    -v) v=true; shift ;;
    -o) o="$2"; shift 2 ;;
    *) shift ;;
  esac
done
echo "n=$n"
echo "v=$v"
echo "o=$o"
```

Same result without `getopts`: `$1` is always the next unprocessed
token, and each branch manually decides how much to consume —
`shift 2` for `-n`/`-o` (the flag and its value), plain `shift` for
`-v` (no value to skip). This is the shape `getopts` exists to save
you from writing by hand once option strings get more complex, but
it's a fine, explicit way to do it for a small fixed set of flags.
