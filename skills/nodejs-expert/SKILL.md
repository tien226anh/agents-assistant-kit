---
name: nodejs-expert
description: Use when working on Node.js or TypeScript projects. Covers project setup, package management (npm/pnpm/bun), testing (vitest/jest), linting (eslint/biome), type safety, frameworks (Express/Fastify/NestJS/Next.js), async patterns, error handling, debugging, and performance profiling.
---

# Node.js & TypeScript Expert

## When to use
Use this skill when working on any Node.js, JavaScript, or TypeScript project — setting up environments, writing code, debugging, testing, or following best practices.

## Stack Detection

Before applying this skill, check the project stack:
- `package.json` exists → Node.js project
- `tsconfig.json` exists → TypeScript
- `pyproject.toml` / `requirements.txt` exists → Use **python-expert** skill instead
- Both exist → Monorepo, check which directory the user is working in

## Project Setup

### Initialize (TypeScript, recommended)
```bash
# With pnpm (recommended)
pnpm init
pnpm add -D typescript @types/node
npx tsc --init

# With bun
bun init

# With npm
npm init -y
npm install -D typescript @types/node
```

### tsconfig.json (strict, modern)
```json
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "Node16",
    "moduleResolution": "Node16",
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "resolveJsonModule": true,
    "declaration": true,
    "declarationMap": true,
    "sourceMap": true,
    "noUncheckedIndexedAccess": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "exactOptionalPropertyTypes": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist"]
}
```

### package.json essentials
```json
{
  "name": "my-project",
  "version": "1.0.0",
  "type": "module",
  "engines": { "node": ">=20" },
  "scripts": {
    "dev": "tsx watch src/index.ts",
    "build": "tsc",
    "start": "node dist/index.js",
    "test": "vitest",
    "test:coverage": "vitest --coverage",
    "lint": "eslint src/",
    "lint:fix": "eslint src/ --fix",
    "typecheck": "tsc --noEmit",
    "format": "prettier --write ."
  }
}
```

## Package Managers

| Tool | Speed | Lockfile | Workspaces | Best For |
|------|-------|---------|-----------|----------|
| **pnpm** | ⚡ Fast | `pnpm-lock.yaml` | ✅ | Most projects (recommended) |
| **bun** | ⚡⚡ Fastest | `bun.lockb` | ✅ | New projects, performance |
| **npm** | Moderate | `package-lock.json` | ✅ | Compatibility, CI |
| **yarn** | Fast | `yarn.lock` | ✅ | Legacy, Berry features |

### pnpm cheat sheet
```bash
pnpm add express                    # Add dependency
pnpm add -D vitest                  # Add dev dependency
pnpm remove express                 # Remove
pnpm install                        # Install from lockfile
pnpm update                         # Update deps
pnpm dlx create-next-app            # Run package without installing (like npx)
pnpm exec vitest                    # Run binary from node_modules
```

## TypeScript Patterns

### Strict typing (never use `any`)
```typescript
// ✅ Use unknown for truly unknown types
function parseInput(raw: unknown): Config {
  if (!isConfig(raw)) throw new Error("Invalid config");
  return raw;
}

// ✅ Use type narrowing
function processValue(value: string | number): string {
  if (typeof value === "number") {
    return value.toFixed(2);
  }
  return value.toUpperCase();
}

// ✅ Use satisfies for type checking without widening
const routes = {
  home: "/",
  about: "/about",
  user: "/user/:id",
} satisfies Record<string, string>;

// ✅ Use branded types for IDs
type UserId = string & { readonly __brand: "UserId" };
type OrderId = string & { readonly __brand: "OrderId" };

function getUser(id: UserId): Promise<User> { ... }
```

### Zod for runtime validation
```typescript
import { z } from "zod";

const UserSchema = z.object({
  name: z.string().min(1).max(100),
  email: z.string().email(),
  age: z.number().int().min(0).max(150),
  role: z.enum(["admin", "user", "moderator"]),
});

type User = z.infer<typeof UserSchema>;

// Validate at runtime (API boundaries, env vars, config files)
const user = UserSchema.parse(requestBody); // throws on invalid
const result = UserSchema.safeParse(data);   // returns { success, data, error }
```

### Error handling
```typescript
// Custom error classes
class AppError extends Error {
  constructor(
    message: string,
    public readonly code: string,
    public readonly statusCode: number = 500,
  ) {
    super(message);
    this.name = "AppError";
  }
}

class NotFoundError extends AppError {
  constructor(resource: string, id: string) {
    super(`${resource} not found: ${id}`, "NOT_FOUND", 404);
  }
}

class ValidationError extends AppError {
  constructor(message: string) {
    super(message, "VALIDATION_ERROR", 422);
  }
}

// Result pattern (alternative to throwing)
type Result<T, E = Error> =
  | { ok: true; value: T }
  | { ok: false; error: E };

function parseConfig(raw: string): Result<Config> {
  try {
    const data = JSON.parse(raw);
    return { ok: true, value: ConfigSchema.parse(data) };
  } catch (e) {
    return { ok: false, error: e instanceof Error ? e : new Error(String(e)) };
  }
}
```

## Code Quality Tools

### ESLint (flat config, ESLint 9+)
```javascript
// eslint.config.js
import eslint from "@eslint/js";
import tseslint from "typescript-eslint";

export default tseslint.config(
  eslint.configs.recommended,
  ...tseslint.configs.strictTypeChecked,
  {
    languageOptions: {
      parserOptions: {
        projectService: true,
        tsconfigRootDir: import.meta.dirname,
      },
    },
    rules: {
      "@typescript-eslint/no-unused-vars": ["error", { argsIgnorePattern: "^_" }],
      "@typescript-eslint/consistent-type-imports": "error",
      "@typescript-eslint/no-floating-promises": "error",
    },
  },
  { ignores: ["dist/", "node_modules/"] },
);
```

### Biome (alternative — linter + formatter in one, very fast)
```json
// biome.json
{
  "$schema": "https://biomejs.dev/schemas/1.9.0/schema.json",
  "organizeImports": { "enabled": true },
  "linter": {
    "enabled": true,
    "rules": { "recommended": true }
  },
  "formatter": {
    "enabled": true,
    "indentStyle": "space",
    "indentWidth": 2
  }
}
```

```bash
biome check .              # Lint + format check
biome check --write .      # Lint + format + auto-fix
```

### Prettier (formatter)
```bash
prettier --write .         # Format all files
prettier --check .         # Check formatting
```

## Testing (Vitest — recommended)

```bash
pnpm add -D vitest @vitest/coverage-v8

# Run tests
pnpm vitest                      # Watch mode
pnpm vitest run                  # Single run
pnpm vitest run --coverage       # With coverage
pnpm vitest run tests/auth.test.ts  # Specific file
```

### Test patterns
```typescript
import { describe, it, expect, beforeEach, vi } from "vitest";

describe("UserService", () => {
  let service: UserService;
  let mockRepo: ReturnType<typeof vi.mocked<UserRepository>>;

  beforeEach(() => {
    mockRepo = {
      findById: vi.fn(),
      create: vi.fn(),
      update: vi.fn(),
    };
    service = new UserService(mockRepo);
  });

  it("should return user by id", async () => {
    // Arrange
    const expected = { id: "1", name: "Alice", email: "alice@test.com" };
    mockRepo.findById.mockResolvedValue(expected);

    // Act
    const result = await service.getUser("1");

    // Assert
    expect(result).toEqual(expected);
    expect(mockRepo.findById).toHaveBeenCalledWith("1");
  });

  it("should throw NotFoundError for missing user", async () => {
    mockRepo.findById.mockResolvedValue(null);

    await expect(service.getUser("999")).rejects.toThrow(NotFoundError);
  });
});
```

### Mocking
```typescript
// Mock a module
vi.mock("./database", () => ({
  getConnection: vi.fn().mockResolvedValue(mockConnection),
}));

// Spy on existing function
const spy = vi.spyOn(logger, "error");
await doSomethingRisky();
expect(spy).toHaveBeenCalledWith(expect.stringContaining("failed"));

// Mock timers
vi.useFakeTimers();
vi.setSystemTime(new Date("2024-01-01"));
// ... test
vi.useRealTimers();

// Mock fetch
vi.stubGlobal("fetch", vi.fn().mockResolvedValue(
  new Response(JSON.stringify({ data: "test" }), { status: 200 }),
));
```

## Async Patterns

```typescript
// Concurrent execution with Promise.all
const [users, orders] = await Promise.all([
  fetchUsers(),
  fetchOrders(),
]);

// With error handling per promise
const results = await Promise.allSettled([
  fetchUsers(),
  fetchOrders(),
]);
results.forEach((result) => {
  if (result.status === "fulfilled") console.log(result.value);
  if (result.status === "rejected") console.error(result.reason);
});

// Retry pattern
async function withRetry<T>(
  fn: () => Promise<T>,
  maxRetries = 3,
  delayMs = 1000,
): Promise<T> {
  for (let attempt = 1; attempt <= maxRetries; attempt++) {
    try {
      return await fn();
    } catch (error) {
      if (attempt === maxRetries) throw error;
      await new Promise((r) => setTimeout(r, delayMs * attempt));
    }
  }
  throw new Error("Unreachable");
}

// Graceful shutdown
process.on("SIGTERM", async () => {
  console.log("Shutting down...");
  await server.close();
  await db.disconnect();
  process.exit(0);
});
```

## Debugging

```typescript
// Node.js built-in debugger
// Run: node --inspect src/index.ts
// Then attach VS Code debugger or open chrome://inspect

// debugger statement
function processItem(item: Item) {
  debugger; // Pauses here when debugger is attached
  return transform(item);
}

// Console methods (beyond console.log)
console.table(users);           // Tabular format
console.dir(obj, { depth: 5 }); // Deep inspect
console.time("operation");
await heavyOperation();
console.timeEnd("operation");   // Prints elapsed time
console.trace("Called from");   // Print stack trace
```

## Gotchas

- **`"type": "module"`** — Always set in package.json for ESM. Use `.mjs` extension if you need ESM in a CJS project.
- **Top-level await** — Works in ESM modules only (`"type": "module"`).
- **`==` vs `===`** — Always use `===`. Enable ESLint's `eqeqeq` rule.
- **`for...in` on arrays** — Never. Use `for...of`, `.map()`, `.forEach()`.
- **Floating promises** — Always `await` promises or handle them. Enable `@typescript-eslint/no-floating-promises`.
- **`JSON.parse()` returns `any`** — Always validate with Zod or a type guard after parsing.
- **Event loop blocking** — Never use synchronous file I/O or CPU-heavy computations on the main thread.
- **Memory leaks** — Watch for unremoved event listeners, unclosed streams, and growing caches.

For framework-specific patterns (Express, Fastify, NestJS, Next.js), see [references/frameworks.md](references/frameworks.md).
For Node.js tooling ecosystem overview, see [references/tooling.md](references/tooling.md).

## Integration

- **Before this skill:** code-planner
- **After this skill:** code-review, test-writer
- **Complementary skills:** debug-assistant, refactor
