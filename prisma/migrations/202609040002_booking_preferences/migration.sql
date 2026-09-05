ALTER TABLE "Appointment" ADD COLUMN "cancellationHours" INTEGER NOT NULL DEFAULT 24;
ALTER TABLE "Appointment" ADD CONSTRAINT "positive_cancellation_window" CHECK ("cancellationHours" BETWEEN 1 AND 168);
CREATE TABLE "BookingPreference" (
  "clientId" TEXT NOT NULL,
  "treatmentId" TEXT NOT NULL,
  "artistId" TEXT NOT NULL,
  "preferredDay" TEXT NOT NULL,
  "updatedAt" TIMESTAMP(3) NOT NULL,
  CONSTRAINT "BookingPreference_pkey" PRIMARY KEY ("clientId"),
  CONSTRAINT "BookingPreference_clientId_fkey" FOREIGN KEY ("clientId") REFERENCES "Client"("id") ON DELETE CASCADE ON UPDATE CASCADE
);
