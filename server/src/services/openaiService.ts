import OpenAI from "openai";

type ChatRole = "system" | "user" | "assistant";

export type ChatMessageInput = {
  role: ChatRole;
  content: string;
};

const openaiApiKey = process.env.OPENAI_API_KEY;
if (!openaiApiKey) {
  throw new Error("Missing OPENAI_API_KEY environment variable.");
}

const client = new OpenAI({ apiKey: openaiApiKey });

const defaultSystemPrompt =
  "You are a math tutor covering algebra, geometry, trigonometry, calculus, " +
  "and statistics. Explain clearly with concise, step-by-step reasoning.";

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
