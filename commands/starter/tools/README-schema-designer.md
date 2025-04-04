# Git Monkey Schema Designer

A visual terminal-based tool for designing database schemas and generating TypeScript types and Zod validation schemas.

## Features

- **Interactive Terminal UI**: Design your schema using a user-friendly terminal interface
- **Visual Table Representations**: See your tables and relationships as ASCII diagrams
- **Theme Support**: Adapts to Git Monkey's theme system (Jungle, Hacker, Wizard, Cosmic)
- **Code Generation**: Export to TypeScript + Zod schemas
- **Relationship Visualization**: View and manage table relationships visually

## Usage

```bash
# Start the schema designer in interactive mode
gitmonkey schema

# Specify output format
gitmonkey schema --format=typescript+zod

# Specify output path
gitmonkey schema --output=./src/lib/schema.ts

# Disable visual features
gitmonkey schema --no-visual
```

## Example Output

### Terminal Visualization

```
┌──────────────────────────────────────────────────────────┐
│ Users                                                     │
├────────────────┬───────────────┬──────────────────────────┤
│ Column         │ Type          │ Constraints              │
├────────────────┼───────────────┼──────────────────────────┤
│ id             │ UUID          │ PRIMARY KEY              │
│ email          │ VARCHAR       │ UNIQUE, NOT NULL         │
│ password       │ VARCHAR       │ NOT NULL                 │
│ createdAt      │ TIMESTAMP     │ NOT NULL                 │
│ updatedAt      │ TIMESTAMP     │ NOT NULL                 │
└────────────────┴───────────────┴──────────────────────────┘

┌──────────────────────────────────────────────────────────┐
│ Products                                                  │
├────────────────┬───────────────┬──────────────────────────┤
│ Column         │ Type          │ Constraints              │
├────────────────┼───────────────┼──────────────────────────┤
│ id             │ UUID          │ PRIMARY KEY              │
│ name           │ VARCHAR       │ NOT NULL                 │
│ description    │ TEXT          │                          │
│ price          │ DECIMAL       │ NOT NULL                 │
│ userId         │ UUID          │ FOREIGN KEY REFERENCES...│
│ createdAt      │ TIMESTAMP     │ NOT NULL                 │
│ updatedAt      │ TIMESTAMP     │ NOT NULL                 │
└────────────────┴───────────────┴──────────────────────────┘

┌─────────────────────┬─────────────────────┬─────────────────────┐
│ Source Table        │ Source Column       │ References           │
├─────────────────────┼─────────────────────┼─────────────────────┤
│ Products            │ userId              │ Users.id             │
└─────────────────────┴─────────────────────┴─────────────────────┘
```

### Generated TypeScript + Zod Schema

```typescript
import { z } from 'zod';

// Users Schema
export const usersSchema = z.object({
  id: z.string().uuid(),
  email: z.string().email(),
  password: z.string().min(8),
  createdAt: z.date(),
  updatedAt: z.date()
});

export type Users = z.infer<typeof usersSchema>;

// Products Schema
export const productsSchema = z.object({
  id: z.string().uuid(),
  name: z.string().min(2),
  description: z.string().optional(),
  price: z.number().positive(),
  userId: z.string().uuid(),
  createdAt: z.date(),
  updatedAt: z.date()
});

export type Products = z.infer<typeof productsSchema>;
```

## Theme-Specific Visuals

Each theme provides a unique visual experience in the schema designer:

- **Jungle**: Banana-themed with vibrant yellows and greens
- **Hacker**: Matrix-inspired green-on-black terminal aesthetic
- **Wizard**: Mystical purple and blue magical theme
- **Cosmic**: Space-themed with celestial metaphors

## Interactive Features

- **Add Tables**: Create tables with custom columns, types, and constraints
- **Edit Tables**: Modify existing tables (add/remove columns, rename)
- **Manage Relationships**: Define foreign key relationships between tables
- **Visualize Schema**: See your complete schema with relationships
- **Export**: Generate TypeScript + Zod schemas from your design

## Coming Soon

- **Prisma Schema Generation**: Export your schema to Prisma format
- **SQL Generation**: Generate SQL creation scripts
- **Schema Import**: Import existing database schemas
- **Entity Relationship Diagram**: Generate visual ERD from schema