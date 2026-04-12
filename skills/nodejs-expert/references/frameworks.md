# Node.js / TypeScript Frameworks Reference

## Express (minimal, mature)

### Project structure
```
src/
├── index.ts              # Entry point, app setup
├── routes/               # Route handlers
│   ├── users.ts
│   └── auth.ts
├── middleware/            # Custom middleware
│   ├── auth.ts
│   ├── errorHandler.ts
│   └── validate.ts
├── services/             # Business logic
├── repositories/         # Database access
├── models/               # Database models (Prisma/Drizzle)
├── schemas/              # Zod validation schemas
└── utils/
```

### Setup
```typescript
import express from "express";
import helmet from "helmet";
import cors from "cors";
import { errorHandler } from "./middleware/errorHandler.js";
import { usersRouter } from "./routes/users.js";

const app = express();

app.use(helmet());
app.use(cors());
app.use(express.json());

app.use("/api/v1/users", usersRouter);
app.use(errorHandler); // Error handler MUST be last

app.listen(3000, () => console.log("Server running on :3000"));
```

### Error handling middleware
```typescript
import type { ErrorRequestHandler } from "express";

export const errorHandler: ErrorRequestHandler = (err, req, res, next) => {
  if (err instanceof AppError) {
    res.status(err.statusCode).json({
      error: { code: err.code, message: err.message },
    });
    return;
  }
  console.error("Unhandled error:", err);
  res.status(500).json({ error: { code: "INTERNAL", message: "Internal server error" } });
};
```

### Validation middleware (Zod)
```typescript
import type { RequestHandler } from "express";
import type { ZodSchema } from "zod";

export function validate(schema: ZodSchema): RequestHandler {
  return (req, res, next) => {
    const result = schema.safeParse(req.body);
    if (!result.success) {
      res.status(422).json({ error: result.error.flatten() });
      return;
    }
    req.body = result.data;
    next();
  };
}
```

---

## Fastify (performance-focused, schema-first)

### Setup
```typescript
import Fastify from "fastify";
import { TypeBoxTypeProvider } from "@fastify/type-provider-typebox";
import { Type } from "@sinclair/typebox";

const app = Fastify({ logger: true })
  .withTypeProvider<TypeBoxTypeProvider>();

app.get("/users/:id", {
  schema: {
    params: Type.Object({ id: Type.String() }),
    response: {
      200: Type.Object({
        id: Type.String(),
        name: Type.String(),
        email: Type.String(),
      }),
    },
  },
}, async (request) => {
  const { id } = request.params;
  return getUserById(id);
});

await app.listen({ port: 3000 });
```

---

## NestJS (enterprise, opinionated, Angular-inspired)

### Module + Controller + Service pattern
```typescript
// users.module.ts
@Module({
  imports: [DatabaseModule],
  controllers: [UsersController],
  providers: [UsersService, UsersRepository],
})
export class UsersModule {}

// users.controller.ts
@Controller("users")
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Get(":id")
  async findOne(@Param("id") id: string): Promise<UserDto> {
    return this.usersService.findById(id);
  }

  @Post()
  @UsePipes(new ZodValidationPipe(CreateUserSchema))
  async create(@Body() dto: CreateUserDto): Promise<UserDto> {
    return this.usersService.create(dto);
  }
}

// users.service.ts
@Injectable()
export class UsersService {
  constructor(private readonly repo: UsersRepository) {}

  async findById(id: string): Promise<UserDto> {
    const user = await this.repo.findById(id);
    if (!user) throw new NotFoundException(`User ${id} not found`);
    return user;
  }
}
```

---

## Next.js (full-stack React)

### App Router structure (Next.js 14+)
```
app/
├── layout.tsx              # Root layout
├── page.tsx                # Home page
├── globals.css
├── api/
│   └── users/
│       └── route.ts        # API route handler
├── users/
│   ├── page.tsx            # /users page
│   └── [id]/
│       └── page.tsx        # /users/:id page
└── components/
    ├── UserCard.tsx
    └── UserList.tsx
```

### Server Components (default in App Router)
```tsx
// app/users/page.tsx — Server Component (no "use client")
export default async function UsersPage() {
  const users = await db.query.users.findMany();

  return (
    <div>
      <h1>Users</h1>
      {users.map((user) => (
        <UserCard key={user.id} user={user} />
      ))}
    </div>
  );
}
```

### API Route Handler
```typescript
// app/api/users/route.ts
import { NextResponse } from "next/server";

export async function GET() {
  const users = await db.query.users.findMany();
  return NextResponse.json(users);
}

export async function POST(request: Request) {
  const body = await request.json();
  const validated = CreateUserSchema.parse(body);
  const user = await db.insert(users).values(validated).returning();
  return NextResponse.json(user, { status: 201 });
}
```

---

## Database ORMs

### Prisma
```prisma
// prisma/schema.prisma
model User {
  id        String   @id @default(cuid())
  email     String   @unique
  name      String
  posts     Post[]
  createdAt DateTime @default(now())
}
```

```typescript
import { PrismaClient } from "@prisma/client";
const prisma = new PrismaClient();

const user = await prisma.user.findUnique({ where: { id } });
const users = await prisma.user.findMany({ include: { posts: true } });
await prisma.user.create({ data: { name, email } });
```

### Drizzle ORM (lightweight, SQL-like)
```typescript
import { pgTable, serial, text, timestamp } from "drizzle-orm/pg-core";

export const users = pgTable("users", {
  id: serial("id").primaryKey(),
  name: text("name").notNull(),
  email: text("email").notNull().unique(),
  createdAt: timestamp("created_at").defaultNow(),
});

// Query
const result = await db.select().from(users).where(eq(users.id, id));
await db.insert(users).values({ name, email });
```
