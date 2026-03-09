import OpenAI from "openai";

type ChatRole = "system" | "user" | "assistant";

export type ChatMessageInput = {
  role: ChatRole;
  content: string;
};

export type QuizQuestion = {
  question: string;
  options: string[];
  correct_index: number;
};

const openaiApiKey = process.env.OPENAI_API_KEY;
if (!openaiApiKey) {
  throw new Error("Missing OPENAI_API_KEY environment variable.");
}

const client = new OpenAI({ apiKey: openaiApiKey });

const defaultSystemPrompt =
  "You are a math tutor covering algebra, geometry, trigonometry, calculus, " +
  "and statistics. Explain clearly with concise, step-by-step reasoning.";
const imageAnalysisPrompt = "Please solve the math problem in this photo.";

export async function respond(messages: ChatMessageInput[]): Promise<string> {
  const completion = await client.chat.completions.create({
    model: "gpt-4o",
    messages: [
      { role: "system", content: defaultSystemPrompt },
      ...messages,
    ],
    max_tokens: 1024,
  });

  return completion.choices[0]?.message?.content?.trim() ?? "";
}

export async function generateQuiz(subject: string): Promise<QuizQuestion[]> {
  const completion = await client.chat.completions.create({
    model: "gpt-4o",
    messages: [
      {
        role: "system",
        content:
          "You are a math tutor. Generate clean JSON only, no markdown fences.",
      },
      {
        role: "user",
        content:
          `Generate 10 multiple-choice questions about ${subject}. ` +
          "Each question must have exactly 4 options and one correct answer. " +
          "Return ONLY a JSON array of objects with keys: " +
          "question (string), options (string[] length 4), correct_index (0-3).",
      },
    ],
    max_tokens: 1200,
  });

  const text = completion.choices[0]?.message?.content?.trim() ?? "[]";
  const parsed = JSON.parse(text) as unknown;
  if (!Array.isArray(parsed)) {
    throw new Error("Quiz response was not a JSON array.");
  }

  // Keep validation lightweight at the service layer.
  const questions = parsed as QuizQuestion[];
  for (const q of questions) {
    if (
      typeof q.question !== "string" ||
      !Array.isArray(q.options) ||
      q.options.length !== 4 ||
      typeof q.correct_index !== "number"
    ) {
      throw new Error("Quiz response format was invalid.");
    }
  }

  return questions;
}

export async function analyzeImage(imageBase64: string): Promise<string> {
  const imageDataUrl = `data:image/jpeg;base64,${imageBase64}`;

  const completion = await client.chat.completions.create({
    model: "gpt-4o",
    messages: [
      { role: "system", content: defaultSystemPrompt },
      {
        role: "user",
        content: [
          { type: "text", text: imageAnalysisPrompt },
          { type: "image_url", image_url: { url: imageDataUrl } },
        ],
      },
    ],
    max_tokens: 1024,
  });

  return completion.choices[0]?.message?.content?.trim() ?? "";
}
