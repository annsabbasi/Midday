CREATE TYPE "public"."inbox_blocklist_type" AS ENUM('email', 'domain');--> statement-breakpoint
ALTER TYPE "public"."reportTypes" ADD VALUE 'monthly_revenue';--> statement-breakpoint
ALTER TYPE "public"."reportTypes" ADD VALUE 'revenue_forecast';--> statement-breakpoint
ALTER TYPE "public"."reportTypes" ADD VALUE 'runway';--> statement-breakpoint
ALTER TYPE "public"."reportTypes" ADD VALUE 'category_expenses';--> statement-breakpoint
CREATE TABLE "inbox_blocklist" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"team_id" uuid NOT NULL,
	"type" "inbox_blocklist_type" NOT NULL,
	"value" text NOT NULL,
	CONSTRAINT "inbox_blocklist_team_id_type_value_key" UNIQUE("team_id","type","value")
);
--> statement-breakpoint
ALTER TABLE "inbox_blocklist" ENABLE ROW LEVEL SECURITY;--> statement-breakpoint
ALTER TABLE "inbox_accounts" ALTER COLUMN "provider" SET DATA TYPE text;--> statement-breakpoint
DROP TYPE "public"."inbox_account_providers";--> statement-breakpoint
CREATE TYPE "public"."inbox_account_providers" AS ENUM('gmail');--> statement-breakpoint
ALTER TABLE "inbox_accounts" ALTER COLUMN "provider" SET DATA TYPE "public"."inbox_account_providers" USING "provider"::"public"."inbox_account_providers";--> statement-breakpoint
ALTER TABLE "inbox" ADD COLUMN "sender_email" text;--> statement-breakpoint
ALTER TABLE "inbox" ADD COLUMN "invoice_number" text;--> statement-breakpoint
ALTER TABLE "inbox" ADD COLUMN "grouped_inbox_id" uuid;--> statement-breakpoint
ALTER TABLE "teams" ADD COLUMN "fiscal_year_start_month" smallint;--> statement-breakpoint
ALTER TABLE "transactions" ADD COLUMN "tax_rate" numeric(10, 2);--> statement-breakpoint
ALTER TABLE "inbox_blocklist" ADD CONSTRAINT "inbox_blocklist_team_id_fkey" FOREIGN KEY ("team_id") REFERENCES "public"."teams"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
CREATE INDEX "inbox_invoice_number_idx" ON "inbox" USING btree ("invoice_number" text_ops);--> statement-breakpoint
CREATE INDEX "inbox_grouped_inbox_id_idx" ON "inbox" USING btree ("grouped_inbox_id" uuid_ops);--> statement-breakpoint
ALTER TABLE "transactions" DROP COLUMN "taxRate";--> statement-breakpoint
CREATE POLICY "Inbox blocklist can be deleted by a member of the team" ON "inbox_blocklist" AS PERMISSIVE FOR DELETE TO public USING ((team_id IN ( SELECT private.get_teams_for_authenticated_user() AS get_teams_for_authenticated_user)));--> statement-breakpoint
CREATE POLICY "Inbox blocklist can be inserted by a member of the team" ON "inbox_blocklist" AS PERMISSIVE FOR INSERT TO public WITH CHECK ((team_id IN ( SELECT private.get_teams_for_authenticated_user() AS get_teams_for_authenticated_user)));--> statement-breakpoint
CREATE POLICY "Inbox blocklist can be selected by a member of the team" ON "inbox_blocklist" AS PERMISSIVE FOR SELECT TO public USING ((team_id IN ( SELECT private.get_teams_for_authenticated_user() AS get_teams_for_authenticated_user)));