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

# API Contract (Stable Shapes)

Define and keep these shapes stable early. This reduces client churn and makes
the API reusable across projects.

## Global conventions

- **Base path:** `/api/v1`
- **Content-Type:** `application/json`
- **Auth header on protected endpoints:** `Authorization: Bearer <token>`

## Global response envelopes

### Success envelope

```json
{
  "data": {}
}
```

### Error envelope

```json
{
  "error": {
    "code": "ERROR_CODE",
    "message": "Human readable message",
    "details": {}
  }
}
```

`details` is optional and can contain validation errors or context.

## Endpoint contracts

### POST `/api/v1/ai/respond`

**Required request fields**

```json
{
  "messages": [
    { "role": "user", "content": "How do I factor x^2 - 5x + 6?" }
  ]
}
```

**Rules**
- `messages` is required, array, and non-empty.
- Each message requires:
  - `role`: one of `system | user | assistant`
  - `content`: non-empty string

**Success response**

```json
{
  "data": {
    "content": "Assistant response text"
  }
}
```

### POST `/api/v1/ai/analyze-image`

**Required request fields**

```json
{
  "imageBase64": "<base64-image-string>",
  "prompt": "Please solve the math problem in this photo."
}
```

**Rules**
- `imageBase64` is required and size-limited.
- `prompt` is required and non-empty.

**Success response**

```json
{
  "data": {
    "content": "Assistant response text"
  }
}
```

### POST `/api/v1/ai/generate-quiz`

**Required request fields**

```json
{
  "subject": "Algebra"
}
```

**Rules**
- `subject` is required and non-empty.

**Success response**

```json
{
  "data": {
    "questions": [
      {
        "question": "What is ...?",
        "options": ["A", "B", "C", "D"],
        "correct_index": 1
      }
    ]
  }
}
```

### GET `/api/v1/health`

**Success response**

```json
{
  "data": {
    "status": "ok"
  }
}
```

## Standard error codes

- `UNAUTHORIZED` (`401`)
- `VALIDATION_FAILED` (`400`)
- `PAYLOAD_TOO_LARGE` (`413`)
- `FORBIDDEN` (`403`)
- `RATE_LIMITED` (`429`)
- `UPSTREAM_ERROR` (`502`)
- `INTERNAL_ERROR` (`500`)
- `NOT_IMPLEMENTED` (`501`)

# URL Structure Cheat Sheet

Use this formula:

`<scheme>://<host>:<port>/<base>/<resource>/<action>?<query>`

## URL parts

- **scheme/protocol:** `http` or `https`
- **host:** domain or host name (e.g. `localhost`, `api.example.com`)
- **port:** optional when non-default (e.g. `3000`)
- **base path:** API namespace + version (e.g. `/api/v1`)
- **resource/action path:** endpoint path (e.g. `/ai/respond`)
- **query params:** optional request modifiers (e.g. `?limit=20&cursor=abc`)

## Current project examples

### Local

- `GET http://localhost:3000/api/v1/health`
- `POST http://localhost:3000/api/v1/ai/respond`
- `POST http://localhost:3000/api/v1/ai/analyze-image`
- `POST http://localhost:3000/api/v1/ai/generate-quiz`

### Production (Render)

- `GET https://<your-service>.onrender.com/api/v1/health`
- `POST https://<your-service>.onrender.com/api/v1/ai/respond`
- `POST https://<your-service>.onrender.com/api/v1/ai/analyze-image`
- `POST https://<your-service>.onrender.com/api/v1/ai/generate-quiz`

## Path vs query vs body

- **Path params:** identify a resource, e.g. `/users/:id/messages/:messageId`
- **Query params:** filtering/sorting/pagination, e.g. `?limit=20`
- **Body (JSON):** payload for `POST`/`PATCH`, sent in request body (not URL)

# Scripts

Scripts are command shortcuts defined in `server/package.json` under
`"scripts"`.

## Available scripts

- `npm run dev`
  - Runs: `ts-node-dev --respawn --transpile-only src/index.ts`
  - Purpose: local development with auto-restart on file changes.

- `npm run build`
  - Runs: `tsc`
  - Purpose: compile TypeScript from `src/` into JavaScript in `dist/`.

- `npm run start`
  - Runs: `node dist/index.js`
  - Purpose: run compiled server output (production style).

## Dev flags explained

- `--respawn`
  - Fully restarts the Node process whenever watched files change.
  - Useful when startup logic/env setup must re-run cleanly.

- `--transpile-only`
  - Skips full type checking during dev runs for faster reloads.
  - Type errors are still caught by `tsc` and editor diagnostics.

# Middleware Syntax and Workflow

Middleware runs between request arrival and route handlers.

## Core middleware signature

```ts
(req, res, next) => { ... }
```

- `req`: incoming request data (headers, params, body, context you attach)
- `res`: outgoing response helper
- `next`: function that passes control to the next middleware or route handler

## Request lifecycle with middleware

1. Request enters app/router.
2. Middleware executes in registration order.
3. Middleware either:
   - calls `next()` to continue, or
   - sends a response and stops the chain.
4. Final route handler runs only if previous middleware passed control.

## `next()` behavior

- `next()` means “continue to the next step in the chain.”
- `next(error)` passes control to error middleware (if configured).
- If middleware neither calls `next()` nor sends a response, request hangs.

## Passing data between middleware and handlers

Use request-scoped fields on `req`, for example:

- auth middleware verifies token
- sets `req.user = { id, email, role }`
- later handlers read `req.user`

In TypeScript, augment Express request types so `req.user` is typed.

## Current project flow

For AI routes:

1. `index.ts` mounts `aiRouter` at `/api/v1/ai`
2. `ai.ts` applies `requireSupabaseJwt` with `aiRouter.use(...)`
3. If token is valid, auth middleware calls `next()`
4. Endpoint handler runs
5. If token is invalid/missing, middleware returns `401` and handler does not run

## Common mistakes to avoid

- forgetting `return` after sending an error response
- forgetting to call `next()` on success
- throwing from async middleware without `try/catch`
- storing request-specific data in globals instead of `req`

# Local Endpoint Test Examples

Use these examples to quickly verify endpoints while developing.

Before running requests:
- start server with `npm run dev`
- provide a valid Supabase access token in `TOKEN`

## POST `/api/v1/ai/respond`

```bash
curl -X POST "http://localhost:3000/api/v1/ai/respond" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "messages": [
      { "role": "user", "content": "Explain factoring x^2 - 5x + 6." }
    ]
  }'
```

## POST `/api/v1/ai/generate-quiz`

```bash
curl -X POST "http://localhost:3000/api/v1/ai/generate-quiz" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "subject": "Algebra"
  }'
```

# Request Anatomy (Headers, Body, Params, Query)

This section documents where request data lives and when to use each part.

## Headers

Metadata sent with the request.

- Example: `Authorization: Bearer <token>`
- Express access: `req.header("authorization")` or `req.headers`
- Typical use: auth, content type, tracing IDs

## Body

Main payload data, usually for `POST`, `PUT`, and `PATCH`.

- Example JSON body:
  ```json
  {
    "messages": [
      { "role": "user", "content": "Explain factoring." }
    ]
  }
  ```
- Express access: `req.body`
- Typical use: structured request input

## Params (Path Params)

Dynamic values embedded in the URL path.

- Route pattern example: `/users/:userId/messages/:messageId`
- Request example: `/users/123/messages/abc`
- `:` means “dynamic path segment”
- Express access:
  - `req.params.userId` -> `"123"`
  - `req.params.messageId` -> `"abc"`

## Query String (Query Params)

Optional URL modifiers after `?`.

- Example: `/messages?limit=20&cursor=abc&sort=desc`
- Express access: `req.query`
- Typical use:
  - filtering
  - pagination
  - sorting
  - feature/behavior flags (`stream=true`)

Query params are not database-specific; they are general request options.
