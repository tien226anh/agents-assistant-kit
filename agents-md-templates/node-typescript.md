# AGENTS.md

## Project Overview
Node.js/TypeScript web application.

## Command Safety
**Read-only commands only.** Agents must NEVER run commands that mutate state, delete data, modify infrastructure, or have destructive side-effects.

- ✅ **Allowed**: `git status`, `git diff`, `pnpm test`, `pnpm lint`, `pnpm typecheck`, `curl` (GET), `docker ps`, `kubectl get`, `prisma studio` (read only)
- ❌ **Forbidden**: `rm`, `git push`, `git commit`, `pnpm prisma migrate deploy`, `docker rm`, `kubectl delete`, database writes, any deploy command
- When the user explicitly asks to run a mutating command, confirm with the user before executing.

## Setup Commands
- Install dependencies: `pnpm install`
- Run dev server: `pnpm dev`
- Run tests: `pnpm test`
- Lint: `pnpm lint`
- Format: `pnpm format`
- Type check: `pnpm typecheck`
- Build: `pnpm build`

## Code Style
- TypeScript strict mode — no `any` types, no `@ts-ignore`
- Use `const` by default, `let` when needed, never `var`
- Single quotes, no semicolons (enforced by ESLint/Prettier)
- Prefer functional patterns: `map`/`filter`/`reduce` over `for` loops
- Use `async`/`await` over `.then()` chains
- Named exports over default exports
- Barrel files (`index.ts`) only at package boundaries, not in every directory
- Use `satisfies` for type-safe object literals: `const config = { ... } satisfies Config`

## Testing Instructions
- Run all tests: `pnpm test`
- Run specific test: `pnpm vitest run src/auth/login.test.ts`
- Run in watch mode: `pnpm vitest`
- Coverage: `pnpm vitest run --coverage`
- Use `vi.mock()` for module mocking, `vi.fn()` for function stubs
- Use `msw` for HTTP request mocking

## Architecture Notes
- **Runtime**: Node.js 20+
- **Framework**: (fill in: Next.js / Express / Fastify / Hono)
- **Database**: (fill in: Prisma + PostgreSQL / Drizzle + SQLite / etc.)
- **Package manager**: pnpm with workspaces (if monorepo)
- **File structure**:
  ```
  src/
  ├── app/           # Route handlers / pages
  ├── lib/           # Shared utilities and business logic
  ├── models/        # Data models / schemas (Zod / Prisma)
  ├── services/      # External service integrations
  └── types/         # Shared TypeScript type definitions
  ```

## Gotchas
- Use `import type { ... }` for type-only imports (enables proper tree-shaking)
- Avoid `enum` — use `as const` objects or union types instead
- `process.env` values are always `string | undefined` — validate with Zod at startup
- All dates should use `Date` objects, not string timestamps
- Error responses use a consistent shape: `{ error: { code: string, message: string } }`
- Never use `console.log` in production code — use the project's logger

## PR Conventions
- Branch: `feature/`, `fix/`, `chore/`, `refactor/`
- Commits: Conventional Commits (`feat(auth): add OAuth provider`)
- Pre-commit: `pnpm lint && pnpm typecheck && pnpm test`
- Title format: `[component] description`
