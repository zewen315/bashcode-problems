# Solution

A line is invalid for one of two reasons, and `awk` can check both in
a single pattern (see `solution.sh` below for the full one-liner):

- `NF != 3` catches any line that doesn't have exactly 3
  whitespace-separated fields — including a blank line, which `awk`
  reports as `NF == 0`.
- `$3 !~ /^[0-9]+$/` catches lines that *do* have 3 fields but whose
  third field (the port) isn't made up entirely of digits — the
  anchored regex `^[0-9]+$` requires the whole field to be one or more
  digits, so something like `8080x` or an empty field both fail it.
- Because these are combined with `||`, a line only needs to fail
  *one* of the two checks to be reported — and short-circuiting means
  `$3` is only evaluated when `NF == 3` actually holds (though in
  `awk`, referencing a field that doesn't exist just yields an empty
  string rather than erroring, so this isn't strictly required for
  correctness here — just worth knowing).
- `{ print NR }` prints the 1-indexed line number for every line that
  matches, in the order `awk` reads them — which is already ascending,
  so no sort is needed.
