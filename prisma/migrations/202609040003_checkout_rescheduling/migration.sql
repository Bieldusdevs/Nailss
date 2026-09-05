ALTER TABLE "Appointment" ADD COLUMN "rescheduleFromId" TEXT;
ALTER TABLE "Payment" ADD COLUMN "checkoutRequest" JSONB;
ALTER TABLE "Appointment" ADD CONSTRAINT "reschedule_not_self" CHECK ("rescheduleFromId" IS NULL OR "rescheduleFromId" <> "id");
