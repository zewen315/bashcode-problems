# IP Address Extractor

Extract valid IPv4 addresses from free-form text.

## Input

`$1` is the path to a text file. Each line contains
whitespace-separated tokens.

## Valid IPv4 Address

A token is a valid IPv4 address if:

- It contains exactly four dot-separated octets.
- Each octet is an integer from `0` to `255`.
- Octets cannot have leading zeros, except `0` itself.
- The entire token must be the IPv4 address.

For example:

Valid:
- `0.0.0.0`
- `10.0.0.1`
- `192.168.1.1`
- `255.255.255.255`

Invalid:
- `256.1.1.1`
- `192.168.01.1`
- `1.2.3`
- `1.2.3.4.5`
- `10.0.0.5:8080`
- `192.168.1.1,`

## Output

For each line containing at least one valid IPv4 address, print:

    <line number>: <ip1> <ip2> ...

Preserve the order in which addresses appear.

Lines without a valid IPv4 address are omitted. If the entire file
contains no valid IPv4 addresses, print nothing.

Line numbers are 1-indexed.

## Constraints

- At most 100,000 lines.
- Tokens are separated by whitespace.

## Example

Input:

    connect to 192.168.1.1 or 10.0.0.1 failed, retry 999.1.1.1 later

Output:

    1: 192.168.1.1 10.0.0.1
