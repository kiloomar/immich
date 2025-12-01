import { Kysely, sql } from 'kysely';

export async function up(db: Kysely<any>): Promise<void> {
  // add the isVisible column with default true
  await sql`ALTER TABLE "asset_ocr" ADD COLUMN IF NOT EXISTS "isVisible" boolean DEFAULT true;`.execute(db);
  await sql`ALTER TABLE "asset_face" ADD COLUMN IF NOT EXISTS "isVisible" boolean DEFAULT true;`.execute(db);
}

export async function down(db: Kysely<any>): Promise<void> {
  // drop the isVisible column
  await sql`ALTER TABLE "asset_ocr" DROP COLUMN IF EXISTS "isVisible";`.execute(db);
  await sql`ALTER TABLE "asset_face" DROP COLUMN IF EXISTS "isVisible";`.execute(db);
}
