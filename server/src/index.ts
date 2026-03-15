import "dotenv/config";
import cors from "cors";
import express from "express";
import { aiRouter } from "./routes/ai";

const app = express();
const port = Number(process.env.PORT) || 3000;
const nodeEnv = process.env.NODE_ENV ?? "development";
const publicBaseUrl = process.env.PUBLIC_BASE_URL ?? "";
const allowedOrigins = (process.env.CORS_ALLOWED_ORIGINS ?? "")
  .split(",")
  .map((origin) => origin.trim())
  .filter((origin) => origin.length > 0);
const corsOptions = allowedOrigins.length > 0 ? { origin: allowedOrigins } : undefined;

app.use(cors(corsOptions));
app.use(express.json({ limit: "8mb" }));

// Mount the routers to base path.
app.use("/api/v1/ai", aiRouter);

app.get("/api/v1/health", (_req, res) => {
  res.status(200).json({ status: "ok" });
});

app.use((err: unknown, _req: express.Request, res: express.Response, _next: express.NextFunction) => {
  const error = err as {
    status?: number;
    statusCode?: number;
    type?: string;
    message?: string;
  };
  const status = error.statusCode ?? error.status ?? 500;

  if (status === 413 || error.type === "entity.too.large") {
    return res.status(413).json({
      error: {
        code: "PAYLOAD_TOO_LARGE",
        message: "Request body exceeds the allowed size limit.",
      },
    });
  }

  if (status === 400 && error.type === "entity.parse.failed") {
    return res.status(400).json({
      error: {
        code: "INVALID_JSON",
        message: "Request body must be valid JSON.",
      },
    });
  }

  console.error("Unhandled server error:", err);
  return res.status(500).json({
    error: {
      code: "INTERNAL_SERVER_ERROR",
      message: "Unexpected server error.",
    },
  });
});

app.listen(port, () => {
  const trimmedPublicBaseUrl = publicBaseUrl.trim();
  const localBaseUrl = `http://localhost:${port}`;
  const isProduction = nodeEnv === "production";
  const effectiveBaseUrl =
    isProduction && trimmedPublicBaseUrl.length > 0
      ? trimmedPublicBaseUrl
      : localBaseUrl;

  if (isProduction && trimmedPublicBaseUrl.length === 0) {
    console.warn(
      "NODE_ENV is production but PUBLIC_BASE_URL is not set. Falling back to localhost in logs.",
    );
  }

  console.log(
    `Server started on port ${port} (env: ${nodeEnv}, baseUrl: ${effectiveBaseUrl})`,
  );
});
