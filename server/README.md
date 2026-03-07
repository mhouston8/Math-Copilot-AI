# Server

Node + TypeScript backend for secure AI proxy endpoints.

# Dependencies

This section documents each dependency with:
- **What:** what the package is for
- **How:** how this project uses it

### Runtime dependencies

- `express`
  - **What:** HTTP server framework for routes and middleware.
  - **How:** used to define API endpoints such as `/api/v1/ai/respond` and attach auth/security middleware.

- `cors`
  - **What:** Cross-Origin Resource Sharing middleware.
  - **How:** used to allow approved client origins to call this API.

- `dotenv`
  - **What:** Loads environment variables from `.env`.
  - **How:** used at startup so secrets/config (e.g. `OPENAI_API_KEY`, `SUPABASE_URL`) are read from environment instead of source code.

- `openai`
  - **What:** Official OpenAI Node SDK.
  - **How:** used by server-side AI service modules to send prompts and receive model responses.

- `jose`
  - **What:** JWT/JWKS cryptographic verification library.
  - **How:** used to verify Supabase JWTs on protected AI routes before executing OpenAI calls.

### Development dependencies

- `typescript`
  - **What:** TypeScript compiler.
  - **How:** compiles source in `src/` to JavaScript for production builds.

- `ts-node-dev`
  - **What:** TypeScript dev runner with auto-reload.
  - **How:** used for local development to restart server automatically on file changes.

- `@types/node`
  - **What:** Type definitions for Node.js APIs.
  - **How:** provides typing for core modules like `process`, `http`, and runtime globals.

- `@types/express`
  - **What:** Type definitions for Express.
  - **How:** provides typed `Request`, `Response`, and middleware signatures.

- `@types/cors`
  - **What:** Type definitions for CORS middleware.
  - **How:** adds TypeScript support for CORS configuration and middleware usage.

# Backend Checklist Per Request

Use this checklist for every protected API endpoint so behavior is consistent
and reusable across projects.

1. **Authentication check**
   - Verify bearer token signature, expiry, issuer, and audience.
   - Reject invalid or missing token with `401`.

2. **Validation check**
   - Validate required fields, types, and required structure.
   - Reject malformed payloads with `400`.

3. **Sanitization check**
   - Normalize and constrain inputs (length limits, allowed enum values, max
     payload size).
   - Drop or reject unexpected fields.

4. **Authorization / business rules check**
   - Confirm user is allowed to perform the action (rate limits, quota,
     subscription/entitlement, ownership rules).
   - Reject disallowed requests with `403` or `429`.

5. **Execute external/system action**
   - Only after checks pass, call downstream services (e.g. OpenAI, database).
   - Return structured output and consistent error shape.
