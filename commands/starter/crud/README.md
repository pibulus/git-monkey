# Git Monkey Modern CRUD Generator

This module enhances Git Monkey's CRUD generation capabilities with modern web development patterns and best practices for SvelteKit applications.

## Features

### 1. Server Actions
- Progressive enhancement for forms that work without JavaScript
- Type-safe server-side validation with client feedback
- Clean separation of client and server responsibilities
- Unified form handling with SuperForms

### 2. Zod Validation
- Type-safe schema validation for all data models
- Runtime validation that matches TypeScript types
- Comprehensive error messages for form fields
- Schema sharing between client and server

### 3. Optimistic UI Updates
- Instant UI response for better user experience
- Smart state management with rollback capabilities
- Animated transitions for smooth interactions
- Loading indicators that don't block user interaction

### 4. Real-time Features
- Live data updates with Supabase realtime subscriptions
- Automatic UI synchronization across clients
- Event-based architecture for data changes
- Graceful degradation for non-realtime environments

### 5. Filtering and Pagination
- Server-side filtering and pagination for performance
- URL-based state for shareable and bookmarkable views
- Reusable components for filters and pagination
- Sorting capabilities for all data columns

## Usage

Add the `--modern` flag when generating CRUD operations:

```bash
gitmonkey generate crud --modern ./my-project supabase svelte users
```

This will generate a complete CRUD interface with all the modern features.

## Architecture

The modern CRUD generator follows a robust architecture:

```
┌────────────────────────────────────────────────────────────────────┐
│                                                                    │
│  ┌──────────┐      ┌──────────┐      ┌──────────┐     ┌──────────┐ │
│  │          │      │          │      │          │     │          │ │
│  │  Client  │◄────►│  Routes  │◄────►│  Server  │◄───►│ Database │ │
│  │  State   │      │  Forms   │      │ Actions  │     │          │ │
│  │          │      │          │      │          │     │          │ │
│  └──────────┘      └──────────┘      └──────────┘     └──────────┘ │
│        ▲                                    │                      │
│        │                                    │                      │
│        │             ┌──────────┐           │                      │
│        │             │          │           │                      │
│        └─────────────┤ Real-time◄───────────┘                      │
│                      │ Updates  │                                  │
│                      │          │                                  │
│                      └──────────┘                                  │
│                                                                    │
└────────────────────────────────────────────────────────────────────┘
```

## Generated Files

For each CRUD operation, the generator creates:

- **Schema files** (`/lib/schemas/{table}.ts`): Zod validation schemas
- **Route files** (`/routes/{table}/`): SvelteKit routes with server actions
- **Component files** (`/lib/components/`): Reusable UI components
- **Store files** (`/lib/stores/`): State management for real-time updates
- **Utility files** (`/lib/utils/`): Helper functions for optimistic UI

## Theme and Tone Awareness

The generator adapts its output based on the user's selected theme and tone:

- **Jungle theme**: Playful, nature-themed CRUD with monkey analogies
- **Hacker theme**: Technical, matrix-style CRUD with coding terminology
- **Wizard theme**: Magical CRUD with spells and enchantments
- **Cosmic theme**: Space-themed CRUD with celestial metaphors

The tone system adjusts verbosity and technical depth based on user experience.

## Integration

This module seamlessly integrates with the existing CRUD generator through the `crud_integrator.sh` script, which extends the original functionality without breaking backward compatibility.