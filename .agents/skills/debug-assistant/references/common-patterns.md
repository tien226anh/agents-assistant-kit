# Common Bug Patterns

Reference for the debug-assistant skill. Common bug patterns organized by category.

## Null / Undefined

**Pattern**: Value is unexpectedly null/undefined because an upstream function returns early or a field is optional.

**Where to look**:
- API responses with optional fields
- Database queries that return no rows
- Config values that are unset in certain environments
- Chained property access: `obj.a.b.c` where any level can be null

**Fix pattern**: Add explicit null checks at the boundary where the value enters your code, not at every usage site.

## Off-by-One

**Pattern**: Loop iterates one too many or too few times; array index out of bounds; fence-post errors.

**Where to look**:
- `for i in range(len(items))` vs `for i in range(len(items) - 1)`
- String slicing: `s[0:n]` includes 0 but excludes n
- Pagination: `offset = page * size` vs `offset = (page - 1) * size`
- Date ranges: inclusive vs exclusive end dates

**Fix pattern**: Write a test with boundary values (0, 1, n-1, n, n+1).

## Race Condition

**Pattern**: Code works most of the time but fails intermittently, especially under load.

**Where to look**:
- Shared mutable state without locks (global variables, class-level state)
- Read-then-write sequences without transactions (check-then-act)
- File system operations (multiple processes writing the same file)
- Cache invalidation timing

**Fix pattern**: Use transactions, locks, or atomic operations. If you need check-then-act, do it in a single atomic operation.

## Resource Leak

**Pattern**: Memory/connections/file handles grow over time; app slows or crashes after running for hours.

**Where to look**:
- Database connections not returned to pool (missing `finally` / `with`)
- File handles opened but not closed on error paths
- Event listeners added but never removed
- Goroutines / tasks spawned but never awaited or cancelled

**Fix pattern**: Use context managers (`with`, `try/finally`, `defer`). Check every error path, not just the happy path.

## Encoding / Unicode

**Pattern**: Text appears garbled, `?` characters, or crashes on certain input.

**Where to look**:
- Reading files without specifying encoding: `open(f)` vs `open(f, encoding='utf-8')`
- HTTP responses without Content-Type charset
- Database collation mismatches
- String length vs byte length (emojis, CJK characters)

**Fix pattern**: Be explicit about encoding at every boundary (file I/O, HTTP, database).

## Async / Promise Errors

**Pattern**: Error is silently swallowed; function appears to do nothing; unhandled promise rejection.

**Where to look**:
- Missing `await` on async function calls
- `.catch()` handler that doesn't re-throw or log
- `Promise.all()` vs `Promise.allSettled()` — all fails fast on first error
- Mixing callbacks and promises in the same flow

**Fix pattern**: Always `await` async calls. Use try/catch at the top level. Never have an empty `.catch()`.

## Environment-Specific

**Pattern**: Works on my machine, fails in CI/staging/production.

**Where to look**:
- Different OS (path separators, case sensitivity, line endings)
- Different versions (Node 18 vs 20, Python 3.10 vs 3.12)
- Missing environment variables or config files
- Different timezone settings
- Network access restrictions

**Fix pattern**: Log the environment info at startup. Make config explicit, never implicit.
