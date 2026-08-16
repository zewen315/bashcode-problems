# BashCode — Factual Project Brief
(Prepared from direct inspection of the `bashcode` and `bashcode-problems` repositories and git history. No claims below are invented — anything uncertain is flagged in section 10.)

## 1. Product overview

**What it is:** BashCode (bashcode.net) is a hands-on practice platform for Bash scripting and Linux command-line tools, aimed at SRE/DevOps/platform/backend-Linux engineers and people interview-prepping for those roles. Per the repo's own README: "Problems are multi-step/practical, not single-command drills."

**Main user workflow** (from the README's own diagram):
```
/problems → /problems/[slug] → write Bash in Monaco
→ Run (visible sample tests) → Submit (hidden tests in a sandbox)
→ Accepted / Wrong Answer / Timeout / No Tests Found
```

**Problem it solves:** algorithm-interview platforms (LeetCode-style) don't test the actual day-to-day skill of SRE/DevOps work — parsing logs, auditing filesystems, batch-running commands across a fleet, diffing configs. BashCode's problems are explicitly designed around realistic operational scenarios instead of single-command tutorials or abstract algorithm puzzles, and grade by *output/behavior*, never by which specific commands were used — the README states multiple correct solutions must pass.

## 2. Current user-facing features

| Feature | Status | Notes |
|---|---|---|
| Problem browsing (list, filters, search) | Complete | `/problems` — status/star columns, pagination, Tools/Topics filter chips, difficulty filter |
| Monaco code editor | Complete | Bash syntax highlighting, autosave to localStorage, Reset button |
| Run (sample tests) | Complete | Runs against visible sample cases only, not graded |
| Submit (hidden tests, real judge) | Complete | Full hidden test suite, real Docker sandbox, verdict returned |
| Visible + hidden test cases | Complete | `tests/samples/N` (shown) vs. full `tests/N` (graded) |
| Solutions | Complete | Always-visible solution explanation per problem (`solution.md`), not gated behind solving it |
| Authentication | Complete | Google + GitHub OAuth, server-side sessions (cookie-based) |
| Progress / history | Complete | Solved/starred/attempted tracking, activity calendar heat map, leaderboard, submission history with the actual submitted code retrievable; Postgres-backed when signed in, localStorage when signed out, merged on login |
| Discussions / comments | Complete | Per-problem markdown comments, single-level replies, likes, self-delete and account-deletion-safe deletion, an aggregated `/discussions` feed |
| Problem upvote/downvote | Complete | Signed-in gated; counts always visible |
| Notifications | Complete | Replies, likes, welcome message, global announcements — merged into one paginated inbox |
| Feedback form | Complete | Real endpoint, sends email via Resend's API (not just a stub — verified in code) |
| Support / tipping | Complete, but external | `/donate` page links out to Buy Me a Coffee; no in-app payment processing |
| Ads | Complete (code-side) | Google AdSense, real publisher ID and ad unit, `ads.txt` published; consent handled by AdSense's own certified CMP, no custom cookie-banner code |
| Social posting (Twitter/X) | Complete, manually triggered | A script (not the web app) generates a branded card image per problem and posts it to `@BashCodeNet` via the X API — run by hand, no scheduler |
| Beta banner | Complete | Site-wide "BashCode is in beta" notice |
| Analytics / monitoring | **Not implemented** | No Google Analytics, Sentry, Plausible, or similar found anywhere in the codebase |

## 3. Problem library

- **41 problems** currently exist (verified by counting problem directories in `bashcode-problems`, excluding `.git`/`.github`).
- **Topics:** `text-processing` (21), `shell-programming` (13), `files` (7).
- **Difficulty:** easy (18), medium (18), hard (5).
- **Tools explicitly tagged** across problems: `awk`, `sort`, `sed`, `grep`, `find`, `xargs`, `jq`, `cut`, `tr`, `wc`, `tail`, `stat`, `date`, `getopts`, `uniq`, `head` (11 problems have no single dominant "tool" tag — they're closer to general shell-scripting logic).

**5 representative problems** (chosen because they require multi-step reasoning over real inputs, not a single command):

1. **Deployment Filesystem Audit** (hard) — recursively scans a real nested directory tree for four distinct classes of problems (broken symlinks, empty files, non-executable `.sh` files, world-writable entries). Teaches recursive filesystem traversal and multi-condition auditing, not a single `find` flag.
2. **Permission Auditor** (medium) — given a real directory (not pre-formatted text), the solver has to inspect it themselves (`ls -l`, `stat`, etc.) and flag files by combined permission-bit logic (world-writable vs. world-writable-*and*-executable). Teaches real filesystem inspection instead of parsing a given string.
3. **Zombie Process Report** (hard) — parses a `ps`-style process snapshot, filters for zombie state, groups by parent PID, and cross-references parent PIDs back into the same snapshot to resolve parent command names (with an `UNKNOWN` fallback). Teaches multi-pass data correlation, not a single-line filter.
4. **Batch Command Runner II** (hard) — takes a host list, a batch size, and an arbitrary command with its own existing arguments, and must construct and run that command once per batch with the right hosts appended. Teaches dynamic command construction/argument handling, close to real fleet-ops tooling.
5. **Fleet Status Report** (medium) — given a manifest of service names and a directory of per-service `.status` files, produces an ordered status report, correctly handling services with no status file present. Teaches directory-driven multi-file aggregation.

## 4. Judge architecture

**Flow:** Browser (Monaco editor) → FastAPI `/submit` → judge (`judge/run_submission.py`, Python, invoked synchronously, no queue) → a fresh, disposable Docker container per submission → result parsed and returned as JSON → rendered in the Submissions/Result panel.

**Execution model — verified directly from `run_submission.py`'s actual `docker run` invocation:**
- Docker is the sandbox (there is no alternative runtime).
- `--network=none` — no network access at all inside the sandbox.
- `--user 65534:65534` — runs as the fixed low-privilege `nobody` UID, never root.
- `--cap-drop=ALL` and `--security-opt no-new-privileges` — all Linux capabilities dropped.
- `--pids-limit 64` — caps process/thread count (fork-bomb protection).
- `--memory 64m --memory-swap 64m` — 64MB memory ceiling, no swap.
- `--cpus 0.5` — half a CPU core.
- `--read-only` root filesystem, with a `--tmpfs /tmp:rw,size=16m,mode=1777` for any scratch writes.
- A hard 5-second wall-clock timeout (`TIME_LIMIT_S = 5`), enforced by the judge polling `docker inspect` and force-`kill`ing the container if it's still running at the deadline.
- Every container is created fresh per test case and `docker rm -f`'d immediately after — nothing persists between runs.
- Input files are mounted individually as read-only (`-v host:/sandbox/input/<name>:ro`) — the test directory itself (which sits next to `expected.out`) is never mounted, so a submission can't just `cat` its own answer key.

**What the judge can validate:** stdout content (exact match against `expected.out`, whitespace-stripped), exit status (opt-in via a reserved `expected.exit` file — only checked for problems where a specific exit code is itself part of the task; grading defaults to stdout-only since tools like `grep -c` legitimately exit non-zero on "no match"), and — for a subset of problems — actual filesystem state (a `1-setup.sh` script is executed on the host to materialize a real directory tree, which is then mounted read-only into the sandbox; used for `find`/permission/timestamp-style problems).

**Visible vs. hidden tests:** `tests/samples/N` directories are the visible cases shown on the Testcase tab and used by the "Run" button (no grading). `tests/N` directories are the full hidden set used only by "Submit," never exposed to the frontend beyond pass/fail + the first failure's detail.

**Test isolation:** every test case within a submission gets its own fresh container (not one container reused across a problem's whole test suite) — one test's state (including a filesystem fixture from `1-setup.sh`) can never leak into another's.

**Concurrency:** a `threading.Semaphore` (`MAX_CONCURRENT_JUDGE_RUNS`, default 4) bounds how many judge runs can execute at once — a queue was explicitly deferred ("only add one if concurrency actually demands it," per the README) since this runs synchronously on a single droplet.

## 5. Architecture and tech stack

- **Frontend:** Next.js 16 (App Router), TypeScript, Tailwind CSS v4, Base UI (`@base-ui/react`) as the primitive component library, Monaco Editor (`@monaco-editor/react`) for the code editor, `react-markdown` for rendering problem statements/comments, `react-resizable-panels` for the split-pane workspace.
- **Backend:** FastAPI, synchronous (no asyncio), Python. Deliberate per the README: "run synchronously — no queue."
- **Database:** self-hosted PostgreSQL (not a managed service), schema-migrated via sequential `db/migrations/*.sql` files applied automatically on every backend startup.
- **Authentication:** Google OAuth and GitHub OAuth, server-side session cookies (no third-party auth-as-a-service like Auth0/Clerk).
- **Hosting/deployment:** Docker Compose on a single DigitalOcean Droplet.
- **Reverse proxy / TLS:** Caddy (automatic Let's Encrypt certificate provisioning).
- **DNS/CDN:** Cloudflare (proxied).
- **Sandbox/runtime infrastructure:** Docker, invoked by the judge process directly against the host's Docker daemon (Docker-outside-of-Docker) to spawn each submission's disposable container.
- **Email:** Resend (feedback form's outbound email — confirmed as a real, wired-up HTTP call in the code, not a stub).
- **Advertising:** Google AdSense (real publisher/ad-unit IDs, `ads.txt` published).
- **Analytics/monitoring:** none found in the codebase.
- **Other third-party service:** Twitter/X API (via `tweepy`), for the manual social-posting script.
- **Support/tipping:** Buy Me a Coffee (external link only).

## 6. Engineering details worth mentioning publicly

1. **Untrusted-code execution, defense in depth.** Every submission runs in a disposable Docker container with no network, dropped capabilities, a non-root fixed UID, a hard memory/CPU/PID ceiling, a read-only root filesystem, and a hard wall-clock timeout — layered specifically because, per the repo's own stated principle, "every submission is untrusted/potentially malicious code, no exceptions." The README is explicit that Docker alone is "MVP-acceptable but not a real hostile-code security boundary," and names gVisor/Firecracker as the next step if real hostile traffic shows up.
2. **Grading on behavior, not on which commands were used.** The judge only compares stdout (and, opt-in, exit code) against expected output — never checks which commands appear in the submitted script. This was a deliberate, stated design principle from the start, not an afterthought.
3. **Filesystem fixtures as a first-class test-case type.** Beyond flat input files, a test case can be a `1-setup.sh` script that's executed on the host to materialize a real directory tree (with real permissions, timestamps, symlinks), which then gets mounted into the sandbox — letting `find`/permission-auditing problems test against a genuine filesystem instead of a pre-formatted text description of one.
4. **A small but deliberate test-input DSL, grown incrementally.** Reserved filenames handle distinct input shapes without special-casing the judge: `1-args.txt` (positional CLI args instead of a file), `9-argv.txt` (literal trailing args *alongside* mounted files — for commands with a mix of file input and scalar arguments), `description.md` (a human-written override for when raw input isn't fit to display, e.g. a setup script's source), `expected.exit` (opt-in exit-code grading).
5. **Data model for anonymous → signed-in progress.** Progress (solved/starred/activity) lives in `localStorage` for anonymous users and Postgres for signed-in ones, with an explicit merge-and-clear step on login — designed so no trace of a previous account's data persists in browser storage after logout, per a decision doc referenced in the README.
6. **Comment/vote deletion semantics.** Comments survive a user's account deletion (rendered as authored by "deleted user") rather than cascading away, while votes and the user's own row do cascade-delete — an explicit, considered distinction, not an oversight.
7. **Docker-outside-of-Docker path matching.** The backend container's judge calls shell out to the *host's* Docker daemon via a mounted socket. That daemon resolves bind-mount paths against its own filesystem, not the calling container's — so the problems directory and scratch directory have to be mounted at byte-identical absolute paths on both host and container, a constraint documented and deliberately preserved through several later features.
8. **A real production incident during Caddy config deployment.** A `git pull`-based deploy updated `infra/Caddyfile` on disk, but the already-running Caddy container kept serving the old config indefinitely — Docker resolves a single-file bind mount to the host file's inode at container-creation time, not its path, so the file being replaced (not edited in place) by git never propagated in. Diagnosed and documented (`docker compose up -d --force-recreate caddy` as the real fix) after it caused a real, live `www.bashcode.net` outage.
9. **Rate limiting without a database round-trip.** A simple in-memory sliding-window limiter (per-IP, IP taken from `X-Forwarded-For` when behind Caddy) protects `/submit`, `/run`, and `/feedback` — no Redis or external store, appropriate for a single-instance deployment.
10. **A generated social-media asset pipeline with no headless browser.** The Twitter/X card image is rendered directly with Pillow (already a dependency for avatar handling) rather than a Playwright/Chromium screenshot — avoids adding a browser runtime to the backend image for something invoked a few times a week, not continuously. The card's height is computed from actual content (a two-input-file example needs more room than a one-liner) rather than a fixed canvas size, after an early version clipped/overlapped content on exactly that case.

## 7. Development history

*(All dates from `git log`, both repos; not independently verified against any external source — see section 10.)*

- **First commit:** 2026-08-10, in `bashcode` — "Initial commit," immediately followed the same day by a full written project spec, a working judge prototype (disposable Docker sandbox), a minimal FastAPI `/submit` endpoint, and a Next.js frontend with `/problems` list + workspace. **The core loop (browse → view → presumably run against a real judge) existed on day one**, per commit history.
- **Total commits:** 121 in `bashcode` (app code) + 44 in `bashcode-problems` (problem content) = **165 commits**.
- **Span:** all commits fall between 2026-08-10 and 2026-08-16 — **7 calendar days** of active development, per commit timestamps.
- **Rough chronology of major features, by day:**
  - **Day 1 (Aug 10):** judge prototype, FastAPI `/submit`, Next.js frontend, dark mode, initial nav/logo.
  - **Day 2 (Aug 11):** Docker Compose deployment (Caddy, Dockerfiles), problem sub-navigation and tabs, the Run/Submit split.
  - **Day 3 (Aug 12):** self-hosted Postgres + auth schema, GitHub/Google OAuth login, account settings, avatar upload, notifications, leaderboard, activity calendar, per-problem discussions — the single busiest day in the log.
  - **Day 4 (Aug 13):** notification polish, real `/donate` page.
  - **Day 5 (Aug 14):** filesystem-based test cases, hand-written test descriptions, argument-parsing test cases.
  - **Day 6 (Aug 15):** literal trailing args + exit-code grading, problem upvote/downvote, AdSense integration, `ads.txt`.
  - **Day 7 (Aug 16):** the Twitter/X social-posting script and its first real posts.

## 8. Claude Code / vibe coding

The repository does not attribute authorship of specific code to a person or a tool, so I'm not asserting who wrote what. Below are questions worth answering yourself, from memory of the actual sessions, before writing anything on this topic:

- What did you personally design up front (the judge's security model, the "grade behavior not commands" principle, the two-repo public/private split) versus what emerged as you went?
- Which parts did you specify at a high level and let get built out (e.g. "add OAuth login") versus review/rewrite in detail line by line?
- When something broke in production (the `www` Caddy outage is a good concrete example, or the AdSense layout bug from earlier this week), how did you go about diagnosing it — did you specify the debugging approach, or did that get proposed and you verified it?
- How did you communicate requirements — a written spec up front (the README suggests one existed from commit #2), or mostly conversational, iterative instructions?
- Where do you feel the tool was clearly faster than doing it yourself, and where did you end up spending real time correcting or redirecting it?
- Is there a moment where your own domain judgment (as an SRE/DevOps-adjacent engineer, presumably) caught something a generic coding assistant wouldn't have known to flag — e.g. the sandbox's specific security flags, or a realistic problem scenario?
- How much of the *testing/verification* (checking things actually work against the real running app, not just that code compiles) did you do yourself versus delegate?

## 9. Metrics worth mentioning

- **41** problems live.
- **3** topic categories (text-processing, shell-programming, files), spanning **~16** distinct named tools/utilities across problems (awk, sort, sed, grep, find, xargs, jq, cut, tr, wc, tail, stat, date, getopts, uniq, head).
- **18 / 18 / 5** easy/medium/hard split.
- **2** OAuth providers (Google, GitHub).
- **13** sequential DB migrations, **12** database tables.
- **32** backend API endpoints across 7 route modules.
- **14** distinct frontend routes/pages.
- **51** React components, **83** TypeScript/TSX source files, **~7,360** lines of frontend code.
- **~2,170** lines of backend Python (excluding the judge itself), **~310** lines in the core judge script.
- **165** total commits (121 app + 44 problem content) across **7 days**.

*(Avoided: any "users," "solves," or traffic numbers — nothing in the codebase indicates real usage volume, and the app has no analytics integration to source that from even if it existed.)*

## 10. Final structured brief

### A. Facts safe to state directly
- BashCode is a hands-on Bash/Linux practice platform at bashcode.net, built for SRE/DevOps-style real-world problems rather than algorithm interview puzzles.
- Every submission runs in a genuinely sandboxed, disposable Docker container: no network, non-root, capabilities dropped, memory/CPU/PID/time limits, fresh per test case.
- Grading is behavior-based (stdout/exit code), never based on which commands were used.
- 41 problems across 3 topic areas and a real spread of difficulty (18/18/5).
- Full account system with real OAuth (Google + GitHub), progress tracking, discussions, voting, notifications, leaderboard.
- Self-hosted on a single DigitalOcean droplet via Docker Compose, Caddy, Cloudflare — a deliberately simple, boring stack (explicitly stated project principle: "no microservices, Kubernetes, Kafka").
- Built and shipped, by your own git history, in about a week.
- The core browse → judge loop existed on day one of development.

### B. Claims that need your personal confirmation before publishing
- Any specific split of "what I designed" vs. "what Claude Code produced" — the repo itself doesn't and can't establish this; only you can say it accurately.
- Whether you personally reviewed/tested each feature before it shipped (this brief can show the code and tests exist and look coherent, not that you did or didn't review every line).
- "Built solo" — true as far as the repo shows (single apparent author voice throughout, no co-author lines besides the AI co-author trailer), but worth stating in your own words rather than inferred from git.
- Any claim about *why* you built it (the 2am-disk-full-alert framing from the earlier draft, or anything about your own job/background) — not something the repo can confirm either way.
- Current real-world usage, traffic, or user count — genuinely unknown from the codebase; don't imply any number.

### C. Do NOT claim these — incomplete, unverified, or explicitly out of scope
- Any analytics/usage numbers — no analytics tool is integrated at all.
- Automated/scheduled social posting ("we post a new challenge every day/automatically") — it's a manually-triggered script, no scheduler exists. (Note: the actual welcome tweet you posted already says "new Bash challenge here every few days" — worth being consistent with that framing, not overclaiming automation.)
- In-app payments/monetization beyond an external Buy Me a Coffee link — there's no Stripe or similar integration.
- Kubernetes labs, SRE troubleshooting simulations, or an AI tutor — the README explicitly lists these as out of scope for now; don't imply they exist.
- A "real security boundary" for untrusted code — the repo's own README explicitly calls Docker-only isolation "MVP-acceptable but not a real hostile-code security boundary." Describe the real protections (they're substantial) without overselling them as airtight.
- Any claim that AdSense consent/cookie-management is fully live for EU visitors — the certified CMP integration exists in code, but whether a consent message has actually been published in the AdSense dashboard isn't something the codebase can confirm.

### D. Suggested screenshots
1. The `/problems` list page — shows the filter chips, difficulty/status columns, and the sheer count of problems at a glance.
2. A problem page mid-solve — Monaco editor on the right, problem statement on the left, ideally with a Run result showing a passed sample test.
3. A "Wrong Answer" result panel showing the diff-style expected/got breakdown, to illustrate real judging (not just "matched"/"didn't match").
4. The Submissions tab with a past submission expanded, showing the actual retrievable code and verdict.
5. One of the generated Twitter/X card images (e.g. the Prod Services or Config Diff one) next to the actual live tweet — nicely shows both the product and the "I even automated my own marketing" angle.

### E. Possible article angles/titles
1. **"I built a Bash practice platform in a week — here's what actually shipped."** — leans into the build-speed narrative your own git history supports well.
2. **"Why grep -c legitimately exits non-zero, and other things I had to teach my own judge."** — a technical-craft angle, using a real detail from the judge's exit-code handling as the hook.
3. **"LeetCode never taught me what to do at 2am. So I built something that does."** — the product-motivation angle (needs your personal confirmation per section B).
4. **"Everything I got wrong building a sandbox for untrusted code."** — an engineering-lessons angle, drawing on the security-flags list and the real `www` outage as concrete "here's what actually broke" material.
5. **"What building with Claude Code actually looked like, day by day."** — a process/meta angle, using the day-by-day commit history in section 7 as the narrative spine, with your own answers from section 8 filling in the human side.
