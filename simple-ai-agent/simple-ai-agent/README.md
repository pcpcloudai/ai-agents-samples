# Simple AI Agent with TypeScript

This is a small HR document assistant that runs in the terminal. The documents are fictional examples stored directly in the code.

The agent uses an LLM with two tools:

- `search_documents`: finds documents using keywords.
- `get_document`: reads one document using its ID.

The LLM chooses the tools and uses their results to answer. A question can use up to five model calls. There is no database or frontend.

## Requirements

- Node.js 20 or later
- An OpenAI API key with API access to the selected model

## Setup

Open a terminal in the `simple-ai-agent` folder and run:

```bash
npm install
```

Create a `.env` file by copying `.env.example`. Replace `your_api_key_here` with your actual API key. Keep `.env` private.

## Run

```bash
npm run check
npm start
```

Example questions:

- How many days of annual leave do employees have?
- Can employees work remotely?
- What are the working hours?
- What happens during onboarding?

Type `exit` to stop the program.

## Project files

- `src/documents.ts`: example HR documents
- `src/tools.ts`: keyword search and document retrieval
- `src/index.ts`: terminal, LLM calls, tool execution and agent loop

The application needs a working API key and an internet connection. API usage may be billed. The documents are fictional and are not company policies.
