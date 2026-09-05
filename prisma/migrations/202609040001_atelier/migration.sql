-- CreateEnum
CREATE TYPE "PatronRole" AS ENUM ('CLIENT', 'ARTIST', 'ADMIN');

-- CreateEnum
CREATE TYPE "AppointmentState" AS ENUM ('HOLD', 'AWAITING_PAYMENT', 'CONFIRMED', 'COMPLETED', 'CANCELLED', 'EXPIRED', 'NO_SHOW');

-- CreateTable
CREATE TABLE "Client" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "passwordHash" TEXT NOT NULL,
    "phone" TEXT NOT NULL DEFAULT '',
    "nif" TEXT NOT NULL DEFAULT '',
    "street" TEXT NOT NULL DEFAULT '',
    "postalCode" TEXT NOT NULL DEFAULT '',
    "city" TEXT NOT NULL DEFAULT '',
    "role" "PatronRole" NOT NULL DEFAULT 'CLIENT',
    "preferences" JSONB NOT NULL DEFAULT '{}',
    "emailVerified" TIMESTAMP(3),
    "sessionVersion" INTEGER NOT NULL DEFAULT 0,
    "privacyAcceptedAt" TIMESTAMP(3) NOT NULL,
    "marketingAllowed" BOOLEAN NOT NULL DEFAULT false,
    "deletedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Client_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "IdentityToken" (
    "id" TEXT NOT NULL,
    "clientId" TEXT NOT NULL,
    "hash" TEXT NOT NULL,
    "kind" TEXT NOT NULL,
    "expiresAt" TIMESTAMP(3) NOT NULL,
    "usedAt" TIMESTAMP(3),

    CONSTRAINT "IdentityToken_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Category" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "icon" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "position" INTEGER NOT NULL,

    CONSTRAINT "Category_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Treatment" (
    "id" TEXT NOT NULL,
    "slug" TEXT NOT NULL,
    "categoryId" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "summary" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "durationMinutes" INTEGER NOT NULL,
    "prepMinutes" INTEGER NOT NULL DEFAULT 5,
    "finishMinutes" INTEGER NOT NULL DEFAULT 5,
    "priceCents" INTEGER NOT NULL,
    "depositCents" INTEGER NOT NULL DEFAULT 0,
    "materials" TEXT[],
    "technique" TEXT NOT NULL,
    "image" TEXT NOT NULL,
    "active" BOOLEAN NOT NULL DEFAULT true,
    "position" INTEGER NOT NULL DEFAULT 0,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Treatment_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Artist" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "bio" TEXT NOT NULL,
    "specialities" TEXT[],
    "experienceYears" INTEGER,
    "image" TEXT,
    "bufferMinutes" INTEGER NOT NULL DEFAULT 10,
    "active" BOOLEAN NOT NULL DEFAULT true,
    "clientId" TEXT,

    CONSTRAINT "Artist_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "WorkingWindow" (
    "id" TEXT NOT NULL,
    "artistId" TEXT NOT NULL,
    "weekday" INTEGER NOT NULL,
    "startMinute" INTEGER NOT NULL,
    "endMinute" INTEGER NOT NULL,

    CONSTRAINT "WorkingWindow_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "CalendarBlock" (
    "id" TEXT NOT NULL,
    "artistId" TEXT NOT NULL,
    "startsAt" TIMESTAMPTZ(3) NOT NULL,
    "endsAt" TIMESTAMPTZ(3) NOT NULL,
    "reason" TEXT NOT NULL,

    CONSTRAINT "CalendarBlock_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Appointment" (
    "id" TEXT NOT NULL,
    "reference" TEXT NOT NULL,
    "clientId" TEXT NOT NULL,
    "artistId" TEXT NOT NULL,
    "treatmentId" TEXT NOT NULL,
    "treatmentName" TEXT NOT NULL,
    "durationMinutes" INTEGER NOT NULL,
    "startsAt" TIMESTAMPTZ(3) NOT NULL,
    "endsAt" TIMESTAMPTZ(3) NOT NULL,
    "occupiedUntil" TIMESTAMPTZ(3) NOT NULL,
    "status" "AppointmentState" NOT NULL DEFAULT 'HOLD',
    "expiresAt" TIMESTAMP(3),
    "priceCents" INTEGER NOT NULL,
    "depositCents" INTEGER NOT NULL DEFAULT 0,
    "discountCents" INTEGER NOT NULL DEFAULT 0,
    "notes" TEXT NOT NULL DEFAULT '',
    "policyVersion" TEXT NOT NULL DEFAULT '2026-09-04',
    "policyAcceptedAt" TIMESTAMP(3),
    "cancelledAt" TIMESTAMP(3),
    "completedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "redemptionId" TEXT,

    CONSTRAINT "Appointment_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Payment" (
    "id" TEXT NOT NULL,
    "appointmentId" TEXT NOT NULL,
    "provider" TEXT NOT NULL DEFAULT 'stripe',
    "checkoutId" TEXT,
    "intentId" TEXT,
    "amountCents" INTEGER NOT NULL,
    "status" TEXT NOT NULL DEFAULT 'PENDING',
    "refundId" TEXT,
    "refundRequestedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Payment_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "WebhookReceipt" (
    "id" TEXT NOT NULL,
    "processedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "WebhookReceipt_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "VerifiedReview" (
    "id" TEXT NOT NULL,
    "appointmentId" TEXT NOT NULL,
    "rating" INTEGER NOT NULL,
    "comment" TEXT NOT NULL,
    "approved" BOOLEAN NOT NULL DEFAULT false,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "VerifiedReview_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "LoyaltyEntry" (
    "id" TEXT NOT NULL,
    "clientId" TEXT NOT NULL,
    "appointmentId" TEXT,
    "points" INTEGER NOT NULL,
    "reason" TEXT NOT NULL,
    "redemptionId" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "LoyaltyEntry_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Redemption" (
    "id" TEXT NOT NULL,
    "clientId" TEXT NOT NULL,
    "kind" TEXT NOT NULL,
    "code" TEXT NOT NULL,
    "expiresAt" TIMESTAMP(3) NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Redemption_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "PortfolioPiece" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "technique" TEXT NOT NULL,
    "image" TEXT NOT NULL,
    "imageAlt" TEXT NOT NULL,
    "credit" TEXT NOT NULL,
    "sourceUrl" TEXT NOT NULL,
    "isInspiration" BOOLEAN NOT NULL DEFAULT true,
    "treatmentId" TEXT NOT NULL,
    "artistId" TEXT,
    "position" INTEGER NOT NULL,

    CONSTRAINT "PortfolioPiece_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Correspondence" (
    "id" TEXT NOT NULL,
    "dedupeKey" TEXT NOT NULL,
    "appointmentId" TEXT,
    "channel" TEXT NOT NULL DEFAULT 'EMAIL',
    "recipient" TEXT NOT NULL,
    "subject" TEXT NOT NULL,
    "body" TEXT NOT NULL,
    "state" TEXT NOT NULL DEFAULT 'PENDING',
    "attempts" INTEGER NOT NULL DEFAULT 0,
    "dueAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "leaseUntil" TIMESTAMP(3),
    "sentAt" TIMESTAMP(3),
    "providerId" TEXT,
    "lastErrorCode" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Correspondence_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ContactLetter" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "message" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "ContactLetter_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "AgendaEvent" (
    "id" TEXT NOT NULL,
    "kind" TEXT NOT NULL,
    "artistId" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "AgendaEvent_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "AuditEvent" (
    "id" TEXT NOT NULL,
    "kind" TEXT NOT NULL,
    "actorId" TEXT,
    "entityId" TEXT,
    "metadata" JSONB NOT NULL DEFAULT '{}',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "AuditEvent_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "RequestWindow" (
    "key" TEXT NOT NULL,
    "count" INTEGER NOT NULL DEFAULT 1,
    "expiresAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "RequestWindow_pkey" PRIMARY KEY ("key")
);

-- CreateTable
CREATE TABLE "AtelierSetting" (
    "id" TEXT NOT NULL DEFAULT 'atelier',
    "value" JSONB NOT NULL,

    CONSTRAINT "AtelierSetting_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "_ArtistToTreatment" (
    "A" TEXT NOT NULL,
    "B" TEXT NOT NULL,

    CONSTRAINT "_ArtistToTreatment_AB_pkey" PRIMARY KEY ("A","B")
);

-- CreateIndex
CREATE UNIQUE INDEX "Client_email_key" ON "Client"("email");

-- CreateIndex
CREATE UNIQUE INDEX "IdentityToken_hash_key" ON "IdentityToken"("hash");

-- CreateIndex
CREATE INDEX "IdentityToken_clientId_kind_idx" ON "IdentityToken"("clientId", "kind");

-- CreateIndex
CREATE UNIQUE INDEX "Treatment_slug_key" ON "Treatment"("slug");

-- CreateIndex
CREATE UNIQUE INDEX "Artist_clientId_key" ON "Artist"("clientId");

-- CreateIndex
CREATE UNIQUE INDEX "WorkingWindow_artistId_weekday_startMinute_key" ON "WorkingWindow"("artistId", "weekday", "startMinute");

-- CreateIndex
CREATE INDEX "CalendarBlock_artistId_startsAt_endsAt_idx" ON "CalendarBlock"("artistId", "startsAt", "endsAt");

-- CreateIndex
CREATE UNIQUE INDEX "Appointment_reference_key" ON "Appointment"("reference");

-- CreateIndex
CREATE UNIQUE INDEX "Appointment_redemptionId_key" ON "Appointment"("redemptionId");

-- CreateIndex
CREATE INDEX "Appointment_artistId_startsAt_occupiedUntil_idx" ON "Appointment"("artistId", "startsAt", "occupiedUntil");

-- CreateIndex
CREATE INDEX "Appointment_clientId_status_idx" ON "Appointment"("clientId", "status");

-- CreateIndex
CREATE INDEX "Appointment_status_expiresAt_idx" ON "Appointment"("status", "expiresAt");

-- CreateIndex
CREATE UNIQUE INDEX "Payment_appointmentId_key" ON "Payment"("appointmentId");

-- CreateIndex
CREATE UNIQUE INDEX "Payment_checkoutId_key" ON "Payment"("checkoutId");

-- CreateIndex
CREATE UNIQUE INDEX "Payment_intentId_key" ON "Payment"("intentId");

-- CreateIndex
CREATE UNIQUE INDEX "Payment_refundId_key" ON "Payment"("refundId");

-- CreateIndex
CREATE UNIQUE INDEX "VerifiedReview_appointmentId_key" ON "VerifiedReview"("appointmentId");

-- CreateIndex
CREATE UNIQUE INDEX "LoyaltyEntry_appointmentId_key" ON "LoyaltyEntry"("appointmentId");

-- CreateIndex
CREATE UNIQUE INDEX "LoyaltyEntry_redemptionId_key" ON "LoyaltyEntry"("redemptionId");

-- CreateIndex
CREATE INDEX "LoyaltyEntry_clientId_idx" ON "LoyaltyEntry"("clientId");

-- CreateIndex
CREATE UNIQUE INDEX "Redemption_code_key" ON "Redemption"("code");

-- CreateIndex
CREATE INDEX "Redemption_clientId_idx" ON "Redemption"("clientId");

-- CreateIndex
CREATE UNIQUE INDEX "Correspondence_dedupeKey_key" ON "Correspondence"("dedupeKey");

-- CreateIndex
CREATE INDEX "Correspondence_state_dueAt_idx" ON "Correspondence"("state", "dueAt");

-- CreateIndex
CREATE INDEX "AgendaEvent_createdAt_idx" ON "AgendaEvent"("createdAt");

-- CreateIndex
CREATE INDEX "AuditEvent_actorId_createdAt_idx" ON "AuditEvent"("actorId", "createdAt");

-- CreateIndex
CREATE INDEX "_ArtistToTreatment_B_index" ON "_ArtistToTreatment"("B");

-- AddForeignKey
ALTER TABLE "IdentityToken" ADD CONSTRAINT "IdentityToken_clientId_fkey" FOREIGN KEY ("clientId") REFERENCES "Client"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Treatment" ADD CONSTRAINT "Treatment_categoryId_fkey" FOREIGN KEY ("categoryId") REFERENCES "Category"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Artist" ADD CONSTRAINT "Artist_clientId_fkey" FOREIGN KEY ("clientId") REFERENCES "Client"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "WorkingWindow" ADD CONSTRAINT "WorkingWindow_artistId_fkey" FOREIGN KEY ("artistId") REFERENCES "Artist"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "CalendarBlock" ADD CONSTRAINT "CalendarBlock_artistId_fkey" FOREIGN KEY ("artistId") REFERENCES "Artist"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Appointment" ADD CONSTRAINT "Appointment_clientId_fkey" FOREIGN KEY ("clientId") REFERENCES "Client"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Appointment" ADD CONSTRAINT "Appointment_artistId_fkey" FOREIGN KEY ("artistId") REFERENCES "Artist"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Appointment" ADD CONSTRAINT "Appointment_treatmentId_fkey" FOREIGN KEY ("treatmentId") REFERENCES "Treatment"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Appointment" ADD CONSTRAINT "Appointment_redemptionId_fkey" FOREIGN KEY ("redemptionId") REFERENCES "Redemption"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Payment" ADD CONSTRAINT "Payment_appointmentId_fkey" FOREIGN KEY ("appointmentId") REFERENCES "Appointment"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "VerifiedReview" ADD CONSTRAINT "VerifiedReview_appointmentId_fkey" FOREIGN KEY ("appointmentId") REFERENCES "Appointment"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "LoyaltyEntry" ADD CONSTRAINT "LoyaltyEntry_clientId_fkey" FOREIGN KEY ("clientId") REFERENCES "Client"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "LoyaltyEntry" ADD CONSTRAINT "LoyaltyEntry_appointmentId_fkey" FOREIGN KEY ("appointmentId") REFERENCES "Appointment"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Redemption" ADD CONSTRAINT "Redemption_clientId_fkey" FOREIGN KEY ("clientId") REFERENCES "Client"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "PortfolioPiece" ADD CONSTRAINT "PortfolioPiece_treatmentId_fkey" FOREIGN KEY ("treatmentId") REFERENCES "Treatment"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "PortfolioPiece" ADD CONSTRAINT "PortfolioPiece_artistId_fkey" FOREIGN KEY ("artistId") REFERENCES "Artist"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "_ArtistToTreatment" ADD CONSTRAINT "_ArtistToTreatment_A_fkey" FOREIGN KEY ("A") REFERENCES "Artist"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "_ArtistToTreatment" ADD CONSTRAINT "_ArtistToTreatment_B_fkey" FOREIGN KEY ("B") REFERENCES "Treatment"("id") ON DELETE CASCADE ON UPDATE CASCADE;


-- Active intervals are protected at database level, including concurrent workers.
CREATE EXTENSION IF NOT EXISTS btree_gist;
ALTER TABLE "Appointment" ADD CONSTRAINT "atelier_no_overlapping_visits"
EXCLUDE USING gist (
  "artistId" WITH =,
  tstzrange("startsAt", "occupiedUntil", '[)') WITH &&
) WHERE ("status" IN ('HOLD', 'AWAITING_PAYMENT', 'CONFIRMED'));
ALTER TABLE "Appointment" ADD CONSTRAINT "positive_appointment_interval" CHECK ("occupiedUntil" > "startsAt" AND "endsAt" > "startsAt");
ALTER TABLE "Treatment" ADD CONSTRAINT "valid_treatment_price" CHECK ("priceCents" >= 0 AND "depositCents" >= 0 AND "depositCents" <= "priceCents" AND "durationMinutes" > 0);
ALTER TABLE "WorkingWindow" ADD CONSTRAINT "valid_working_window" CHECK ("weekday" BETWEEN 0 AND 6 AND "startMinute" >= 0 AND "endMinute" <= 1440 AND "endMinute" > "startMinute");
ALTER TABLE "CalendarBlock" ADD CONSTRAINT "valid_calendar_block" CHECK ("endsAt" > "startsAt");
ALTER TABLE "VerifiedReview" ADD CONSTRAINT "valid_review_rating" CHECK ("rating" BETWEEN 1 AND 5);
