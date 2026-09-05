ALTER TABLE "Payment" ADD COLUMN "refundedCents" INTEGER NOT NULL DEFAULT 0,
  ADD COLUMN "lastCheckedAt" TIMESTAMP(3), ADD COLUMN "refundLastError" TEXT,
  ADD COLUMN "refundRequestCents" INTEGER, ADD COLUMN "refundAttempt" INTEGER NOT NULL DEFAULT 0,
  ADD COLUMN "refundAttemptedAt" TIMESTAMP(3);
-- A previously confirmed full refund remains financially correct; no event timestamp is invented.
UPDATE "Payment" SET "refundedCents" = "amountCents" WHERE "status" = 'REFUNDED';
ALTER TABLE "Payment" ADD CONSTRAINT "valid_refunded_amount" CHECK ("refundedCents" >= 0 AND "refundedCents" <= "amountCents"),
  ADD CONSTRAINT "valid_refund_request" CHECK ("refundRequestCents" IS NULL OR ("refundRequestCents" > 0 AND "refundRequestCents" <= "amountCents")),
  ADD CONSTRAINT "valid_refund_attempt" CHECK ("refundAttempt" >= 0);
CREATE TABLE "DepositRefund" (
  "id" TEXT NOT NULL PRIMARY KEY, "paymentId" TEXT NOT NULL,
  "amountCents" INTEGER NOT NULL CHECK ("amountCents" > 0),
  "status" TEXT NOT NULL CHECK ("status" IN ('pending','requires_action','succeeded','failed','canceled')),
  "providerCreatedAt" TIMESTAMP(3) NOT NULL,
  "automaticAttempt" INTEGER CHECK ("automaticAttempt" IS NULL OR "automaticAttempt" >= 0),
  "observedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "DepositRefund_paymentId_fkey" FOREIGN KEY ("paymentId") REFERENCES "Payment"("id") ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE INDEX "DepositRefund_paymentId_idx" ON "DepositRefund"("paymentId");
ALTER TABLE "BookingPreference" ADD COLUMN "revision" INTEGER NOT NULL DEFAULT 1 CHECK ("revision" >= 1),
  ADD COLUMN "draftId" TEXT, ADD COLUMN "clearedAt" TIMESTAMP(3);
UPDATE "BookingPreference" SET "draftId" = gen_random_uuid()::text;
