import { Router } from "express";
import { requireSupabaseJwt } from "../middleware/auth";
import {
  generateQuiz,
  respond,
  type ChatMessageInput,
} from "../services/openaiService";

const aiRouter = Router();
aiRouter.use(requireSupabaseJwt);

aiRouter.post("/respond", async (req, res) => {
  // Step 1: Pull request payload from req.body.
  const { messages } = req.body as { messages?: unknown };

  // Step 2: Basic request shape validation.
  if (!Array.isArray(messages) || messages.length == 0) {
    return res.status(400).json({
      error: {
        code: "VALIDATION_FAILED",
        message: "messages must be a non-empty array.",
      },
    });
  }

  // Step 3: Validate and normalize each message object.
  const normalizedMessages: ChatMessageInput[] = [];
  for (const item of messages) {
    if (
      typeof item !== "object" ||
      item === null ||
      !("role" in item) ||
      !("content" in item)
    ) {
      return res.status(400).json({
        error: {
          code: "VALIDATION_FAILED",
          message: "Each message must include role and content.",
        },
      });
    }

    const obj = item as { role: unknown; content: unknown };
    const { role, content } = obj;
    if (
      (role !== "system" && role !== "user" && role !== "assistant") ||
      typeof content !== "string" ||
      content.trim().length === 0
    ) {
      return res.status(400).json({
        error: {
          code: "VALIDATION_FAILED",
          message:
            "Each message requires role (system|user|assistant) and non-empty content.",
        },
      });
    }

    // Keep normalized values so downstream service receives clean input.
    normalizedMessages.push({
      role,
      content: content.trim(),
    });
  }

  try {
    // Step 4: Execute business logic after all checks pass.
    const content = await respond(normalizedMessages);
    return res.status(200).json({
      data: { content },
    });
  } catch (error) {
    console.error("AI respond failed:", error);
    return res.status(502).json({
      error: {
        code: "UPSTREAM_ERROR",
        message: "Failed to generate AI response.",
      },
    });
  }
});

aiRouter.post("/analyze-image", (_req, res) => {
  res.status(501).json({
    error: {
      code: "NOT_IMPLEMENTED",
      message: "POST /api/v1/ai/analyze-image is not implemented yet.",
    },
  });
});

aiRouter.post("/generate-quiz", async (req, res) => {
  const { subject } = req.body as { subject?: unknown };
  if (typeof subject !== "string" || subject.trim().length === 0) {
    return res.status(400).json({
      error: {
        code: "VALIDATION_FAILED",
        message: "subject is required and must be a non-empty string.",
      },
    });
  }

  try {
    const questions = await generateQuiz(subject.trim());
    return res.status(200).json({
      data: { questions },
    });
  } catch (error) {
    console.error("AI generate-quiz failed:", error);
    return res.status(502).json({
      error: {
        code: "UPSTREAM_ERROR",
        message: "Failed to generate quiz.",
      },
    });
  }
});

export { aiRouter };
