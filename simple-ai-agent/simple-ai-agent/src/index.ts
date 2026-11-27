import "dotenv/config";
import OpenAI from "openai";
import readline from "node:readline/promises";
import { search_documents, get_document } from "./tools.js";

if (!process.env.OPENAI_API_KEY) {
  console.log("Please add OPENAI_API_KEY in the .env file");
  process.exit(1);
}

const client = new OpenAI();

const tools: OpenAI.Chat.Completions.ChatCompletionTool[] = [
  {
    type: "function",
    function: {
      name: "search_documents",
      description: "Search the HR documents using keywords",
      parameters: {
        type: "object",
        properties: {
          query: { type: "string" }
        },
        required: ["query"]
      }
    }
  },
  {
    type: "function",
    function: {
      name: "get_document",
      description: "Get the full content of a document by its ID",
      parameters: {
        type: "object",
        properties: {
          id: { type: "string" }
        },
        required: ["id"]
      }
    }
  }
];

async function ask(question: string) {
  const messages: OpenAI.Chat.Completions.ChatCompletionMessageParam[] = [
    {
      role: "system",
      content: "You are an HR assistant. Use the document tools to answer questions. Search and read the relevant documents before answering. Answer only from the documents. If the information is not available, say you don't know."
    },
    { role: "user", content: question }
  ];

  for (let i = 0; i < 5; i++) {
    const response = await client.chat.completions.create({
      model: process.env.OPENAI_MODEL || "gpt-4.1-mini",
      messages,
      tools
    });

    const message = response.choices[0]?.message;
    if (!message) {
      throw new Error("No response from the model");
    }

    messages.push(message);

    if (!message.tool_calls || message.tool_calls.length === 0) {
      return message.content || "No answer found";
    }

    for (const call of message.tool_calls) {
      if (call.type !== "function") {
        continue;
      }

      let result;

      try {
        const args = JSON.parse(call.function.arguments);

        if (call.function.name === "search_documents" && typeof args.query === "string") {
          result = search_documents(args.query);
        } else if (call.function.name === "get_document" && typeof args.id === "string") {
          result = get_document(args.id);
        } else {
          result = { error: "Invalid tool or arguments" };
        }
      } catch (error) {
        result = { error: error instanceof Error ? error.message : "Tool error" };
      }

      messages.push({
        role: "tool",
        tool_call_id: call.id,
        content: JSON.stringify(result)
      });
    }
  }

  return "The agent reached the maximum number of steps.";
}

async function main() {
  const terminal = readline.createInterface({
    input: process.stdin,
    output: process.stdout
  });

  console.log("HR Document Agent");
  console.log("Type exit to quit\n");

  while (true) {
    let question = "";

    try {
      question = await terminal.question("You: ");
    } catch {
      break;
    }

    if (question.trim().toLowerCase() === "exit") {
      break;
    }

    if (question.trim() === "") {
      continue;
    }

    try {
      const answer = await ask(question);
      console.log("Agent:", answer, "\n");
    } catch (error) {
      console.log("Error:", error instanceof Error ? error.message : "Unexpected error");
    }
  }

  terminal.close();
}

main();
