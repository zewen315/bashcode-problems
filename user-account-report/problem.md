# User Account Report

Report which accounts in a `/etc/passwd`-style file have a real
login shell.

## Input
`$1` is the path to a file. Each line has 7 `:`-delimited fields,
same shape as `/etc/passwd`:
```
<username>:<password>:<uid>:<gid>:<gecos>:<home>:<shell>
```

## Output
For every line whose shell is **not** a no-login shell, print:
```
<username> <home> <shell>
```
in order. A shell counts as no-login if the last path component
(after the final `/`) is exactly `nologin` or `false` — regardless
of the directory it lives in (`/usr/sbin/nologin`, `/sbin/nologin`,
and `/bin/nologin` all count). Every other shell counts as a real
login shell, including unusual ones. Lines with a no-login shell are
omitted entirely. If none qualify, print nothing.

## Constraints
- At most 100,000 lines.
- Fields never contain `:` or whitespace themselves.

## Example
Input:
```
alice:x:1001:1001:Alice:/home/alice:/bin/bash
bob:x:1002:1002:Bob:/home/bob:/bin/zsh
deploy:x:1003:1003:Deploy:/srv/deploy:/usr/sbin/nologin
```

Output:
```
alice /home/alice /bin/bash
bob /home/bob /bin/zsh
```
