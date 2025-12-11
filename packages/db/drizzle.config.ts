import type { Config } from "drizzle-kit";
import { config } from "dotenv";

// Load .env file from project root
config({ path: "./.env" });

console.log("TEST", process.env.DATABASE_SESSION_POOLER!)
export default {
  schema: "./src/schema.ts",
  out: "./migrations",
  dialect: "postgresql",
  dbCredentials: {
    url: process.env.DATABASE_SESSION_POOLER!,
  },
} satisfies Config;
