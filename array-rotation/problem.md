# Array Rotation

Given an array and a rotation count, rotate the array to the right by
that many positions: every element moves right by `k` spots, wrapping
around from the end back to the start.

## Input
`$1` is the path to a file with two lines:

```
<space-separated array elements>
<k>
```

`k` is a non-negative integer and may be larger than the number of
elements.

## Output
The rotated array, space-separated, on one line.

## Constraints
- The array has between 1 and 100,000 elements.
- Elements contain no whitespace.
- If `k` is larger than the array length (or a multiple of it), rotate
  by `k mod length` instead — e.g. rotating a 3-element array by `3`
  (or `6`, or `0`) leaves it unchanged.

## Example
Input:
```
apple banana cherry date
2
```

`cherry` and `date` (the last two) wrap around to the front, and
everything else shifts right by two.

Output:
```
cherry date apple banana
```
