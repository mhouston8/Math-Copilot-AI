import type { NextFunction, Request, Response } from "express";
import { createRemoteJWKSet, jwtVerify } from "jose";

type AuthenticatedUser = {
  id: string;
  email?: string;
  role?: string;
};

declare global {
  namespace Express {
    interface Request {
      user?: AuthenticatedUser;
    }
  }
}

const supabaseUrl = process.env.SUPABASE_URL;
const jwtAudience = process.env.SUPABASE_JWT_AUDIENCE ?? "authenticated";

if (!supabaseUrl) {
  throw new Error("Missing SUPABASE_URL environment variable.");
}

const jwks = createRemoteJWKSet(
  new URL(`${supabaseUrl}/auth/v1/.well-known/jwks.json`),
);

export async function requireSupabaseJwt(
  req: Request,
  res: Response,
  next: NextFunction,
) {
  try {
    const authHeader = req.header("authorization") ?? "";
    if (!authHeader.startsWith("Bearer ")) {
      return res.status(401).json({
        error: {
          code: "UNAUTHORIZED",
          message: "Missing bearer token.",
        },
      });
    }

    const token = authHeader.slice("Bearer ".length).trim();
    if (!token) {
      return res.status(401).json({
        error: {
          code: "UNAUTHORIZED",
          message: "Missing bearer token.",
        },
      });
    }

    const { payload } = await jwtVerify(token, jwks, {
      issuer: `${supabaseUrl}/auth/v1`,
      audience: jwtAudience,
    });

    req.user = {
      id: String(payload.sub),
      email: payload.email ? String(payload.email) : undefined,
      role: payload.role ? String(payload.role) : undefined,
    };

    return next();
  } catch {
    return res.status(401).json({
      error: {
        code: "UNAUTHORIZED",
        message: "Invalid or expired token.",
      },
    });
  }
}
