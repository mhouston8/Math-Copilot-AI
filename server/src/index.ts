import cors from "cors";
import dotenv from "dotenv";
import express from "express";
import { aiRouter } from "./routes/ai";

dotenv.config();

const app = express();
const port = Number(process.env.PORT) || 3000;

app.use(cors());
app.use(express.json({ limit: "2mb" }));

//Mount the routers to base path
app.use("/api/v1/ai", aiRouter);

app.get("/api/v1/health", (_req, res) => {
  res.status(200).json({ status: "ok" });
});

app.listen(port, () => {
  console.log(`Server listening on http://localhost:${port}`);
});
