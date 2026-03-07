import { Router } from "express";
import { requireSupabaseJwt } from "../middleware/auth";

const aiRouter = Router();
aiRouter.use(requireSupabaseJwt);

aiRouter.post("/respond", (_req, res) => {
  res.status(501).json({
    error: {
      code: "NOT_IMPLEMENTED",
      message: "POST /api/v1/ai/respond is not implemented yet.",
    },
  });
});

aiRouter.post("/analyze-image", (_req, res) => {
  res.status(501).json({
    error: {
      code: "NOT_IMPLEMENTED",
      message: "POST /api/v1/ai/analyze-image is not implemented yet.",
    },
  });
});

aiRouter.post("/generate-quiz", (_req, res) => {
  res.status(501).json({
    error: {
      code: "NOT_IMPLEMENTED",
      message: "POST /api/v1/ai/generate-quiz is not implemented yet.",
    },
  });
});

export { aiRouter };
