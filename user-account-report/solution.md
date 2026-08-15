# Solution

## 1. `awk`, one pass

```bash
awk -F: '
{
  n = split($7, parts, "/")
  base = parts[n]
  if (base != "nologin" && base != "false") {
    print $1, $6, $7
  }
}' "$1"
```

`-F:` splits every line on `:`, so `$1`/`$6`/`$7` are `username`,
`home`, and `shell` directly. `split($7, parts, "/")` breaks the
shell path on `/`; the last path component is whatever landed at
index `n` (the count `split` itself returns), regardless of how many
directories came before it — that's what makes `/sbin/nologin`,
`/usr/sbin/nologin`, and `/bin/nologin` all resolve to the same
`base`. Comparing that against literal `"nologin"`/`"false"` is the
whole filter; everything else falls through to `print`.

## 2. `cut` + `grep`

```bash
cut -d: -f1,6,7 --output-delimiter=' ' "$1" | grep -vE '/(nologin|false)$'
```

`cut -d: -f1,6,7 --output-delimiter=' '` does the extraction — same
shape as pulling fields out of the access log, just a different
delimiter and a third field. The filtering happens *after*
extraction instead of during it: since `shell` is always the last of
the three space-separated fields on each output line, `grep -vE
'/(nologin|false)$'` anchored at the end of the line (`$`) is
guaranteed to be testing the shell, not the username or home
directory — `-v` drops any line where that anchored pattern matches,
leaving only the real login shells.
