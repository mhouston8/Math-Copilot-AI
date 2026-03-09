import "dotenv/config";
import cors from "cors";
import express from "express";
import { aiRouter } from "./routes/ai";

const app = express();
const port = Number(process.env.PORT) || 3000;

app.use(cors());
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
  console.log(`Server listening on http://localhost:${port}`);
});
