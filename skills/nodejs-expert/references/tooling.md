# Node.js / TypeScript Tooling Ecosystem

## Package Managers

| Tool | Speed | Disk usage | Monorepo | Install |
|------|-------|-----------|---------|---------|
| **pnpm** | Fast | Low (content-addressable store) | ✅ Workspaces | `npm i -g pnpm` |
| **bun** | Fastest | Low | ✅ Workspaces | `curl -fsSL https://bun.sh/install \| bash` |
| **npm** | Moderate | High | ✅ Workspaces | Built-in with Node |
| **yarn** | Fast | Moderate | ✅ (Berry) | `corepack enable` |

## Runtime

| Runtime | Best For |
|---------|----------|
| **Node.js** | Production servers, broad ecosystem |
| **Bun** | Fast scripts, bundling, new projects |
| **Deno** | Security-first, web standards |

### Node.js version management
```bash
# fnm (recommended — fast, cross-platform)
curl -fsSL https://fnm.vercel.app/install | bash
fnm install 22
fnm use 22

# nvm (widely used)
nvm install 22
nvm use 22

# .node-version or .nvmrc file
echo "22" > .node-version
```

## TypeScript Tools

| Tool | Purpose |
|------|---------|
| **tsc** | Type checking + compilation (official) |
| **tsx** | Run TypeScript directly (dev, scripts) |
| **tsup** | Bundle TypeScript libraries |
| **tsc-alias** | Resolve path aliases after build |

```bash
# Run TS directly (dev mode)
pnpm tsx src/index.ts
pnpm tsx watch src/index.ts  # watch mode

# Type check without emitting
pnpm tsc --noEmit

# Build library
pnpm tsup src/index.ts --format esm,cjs --dts
```

## Code Quality

| Tool | Purpose | Speed |
|------|---------|-------|
| **ESLint** | Linter (most plugins, ecosystem) | Moderate |
| **Biome** | Linter + formatter (Rust-based) | ⚡ Very fast |
| **Prettier** | Formatter | Moderate |
| **oxlint** | Linter (Rust-based, compatible with ESLint rules) | ⚡⚡ Fastest |

### Recommended: ESLint + Prettier (mature) OR Biome (fast, all-in-one)

## Testing

| Tool | Purpose | Speed |
|------|---------|-------|
| **Vitest** | Unit/integration (Vite-powered, ESM-native) | ⚡ Fast |
| **Jest** | Unit/integration (mature, CJS-focused) | Moderate |
| **Playwright** | E2E browser testing | — |
| **Supertest** | HTTP integration testing | — |
| **MSW** | Mock HTTP requests (interceptor) | — |

### Vitest config
```typescript
// vitest.config.ts
import { defineConfig } from "vitest/config";

export default defineConfig({
  test: {
    globals: true,
    environment: "node",
    coverage: {
      provider: "v8",
      reporter: ["text", "lcov"],
      thresholds: { lines: 80, functions: 80, branches: 80 },
    },
    include: ["src/**/*.test.ts", "tests/**/*.test.ts"],
  },
});
```

### Jest config (if using Jest)
```json
{
  "preset": "ts-jest",
  "testEnvironment": "node",
  "roots": ["<rootDir>/src", "<rootDir>/tests"],
  "collectCoverageFrom": ["src/**/*.ts", "!src/**/*.d.ts"]
}
```

## Build Tools

| Tool | Purpose |
|------|---------|
| **tsup** | Library bundling (esbuild-based) |
| **esbuild** | Ultra-fast bundling |
| **Vite** | Frontend dev server + bundling |
| **Turbopack** | Next.js bundler (Rust-based) |
| **Rollup** | Library bundling (tree-shaking) |
| **webpack** | Legacy bundling |

## Monorepo Tools

| Tool | Purpose |
|------|---------|
| **Turborepo** | Build orchestration, caching |
| **Nx** | Full monorepo toolkit |
| **pnpm workspaces** | Dependency management |
| **Changesets** | Versioning + changelogs |

### pnpm workspace setup
```yaml
# pnpm-workspace.yaml
packages:
  - "packages/*"
  - "apps/*"
```

## HTTP & API

| Tool | Purpose |
|------|---------|
| **Express** | Minimal web framework (most popular) |
| **Fastify** | Performance-focused web framework |
| **NestJS** | Enterprise framework (DI, modules) |
| **tRPC** | End-to-end type-safe APIs |
| **Hono** | Ultralight, edge-first web framework |

## Database

| Tool | Type | Best For |
|------|------|----------|
| **Prisma** | ORM | Full-featured, migrations, studio |
| **Drizzle** | ORM | Lightweight, SQL-like, type-safe |
| **Kysely** | Query builder | Type-safe SQL without ORM |
| **pg** | Driver | Raw PostgreSQL |
| **better-sqlite3** | Driver | Embedded SQLite |

## Validation

| Tool | Purpose |
|------|---------|
| **Zod** | Runtime validation + TypeScript inference |
| **Valibot** | Like Zod, smaller bundle |
| **AJV** | JSON Schema validation (fast) |
| **TypeBox** | JSON Schema + TypeScript (Fastify) |

## Process Management

| Tool | Purpose |
|------|---------|
| **PM2** | Production process manager |
| **nodemon** | Dev auto-restart (legacy) |
| **tsx watch** | Dev auto-restart (modern) |

## Docker

### Multi-stage Dockerfile (Node.js)
```dockerfile
FROM node:22-slim AS base
RUN corepack enable pnpm

FROM base AS deps
WORKDIR /app
COPY package.json pnpm-lock.yaml ./
RUN pnpm install --frozen-lockfile

FROM base AS build
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .
RUN pnpm build

FROM base AS production
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY --from=build /app/dist ./dist
COPY package.json ./
USER node
CMD ["node", "dist/index.js"]
```

## CI/CD (GitHub Actions)
```yaml
name: CI
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: pnpm/action-setup@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 22
          cache: pnpm
      - run: pnpm install --frozen-lockfile
      - run: pnpm lint
      - run: pnpm typecheck
      - run: pnpm test:coverage
```

## Profiling

```bash
# CPU profiling
node --prof src/index.js
node --prof-process isolate-*.log > profile.txt

# Heap snapshot
node --inspect src/index.js
# Then in Chrome DevTools: Memory → Take heap snapshot

# Clinic.js (comprehensive)
npx clinic doctor -- node src/index.js
npx clinic flame -- node src/index.js
```
