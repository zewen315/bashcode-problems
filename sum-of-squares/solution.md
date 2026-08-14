# Solution

Looping from `1` to `n` and accumulating `i*i` works, but there's a
closed-form identity that avoids the loop entirely:

```
1^2 + 2^2 + ... + n^2 = n(n+1)(2n+1) / 6
```

- `n = $1` reads the single integer from the input file.
- `n * (n + 1) * (2 * n + 1) / 6` evaluates the formula directly. The
  product of three consecutive-ish terms is always divisible by 6, so
  the division is exact — no rounding or truncation needed, even for
  `n = 0` (every term is `0`, so the whole expression is `0`).
- The constraint `n <= 100000` keeps the intermediate product well
  under `2^53`, so `awk`'s double-precision arithmetic represents it
  exactly.
