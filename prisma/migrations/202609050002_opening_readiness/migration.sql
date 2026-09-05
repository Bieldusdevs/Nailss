CREATE TABLE "AtelierOpeningPlan" (
  "id" TEXT PRIMARY KEY DEFAULT 'atelier', "revision" INTEGER NOT NULL DEFAULT 1 CHECK ("revision" >= 1),
  "weeklyHours" JSONB NOT NULL, "updatedAt" TIMESTAMP(3) NOT NULL
);
CREATE TABLE "AtelierOpeningException" (
  "date" TEXT PRIMARY KEY CHECK ("date" ~ '^\d{4}-\d{2}-\d{2}$'),
  "planId" TEXT NOT NULL DEFAULT 'atelier', "intervals" JSONB NOT NULL,
  "publicLabel" TEXT NOT NULL, "updatedAt" TIMESTAMP(3) NOT NULL,
  CONSTRAINT "AtelierOpeningException_planId_fkey" FOREIGN KEY ("planId") REFERENCES "AtelierOpeningPlan"("id") ON DELETE CASCADE ON UPDATE CASCADE
);
INSERT INTO "AtelierOpeningPlan" ("id", "weeklyHours", "updatedAt") VALUES ('atelier',
 '[{"weekday":1,"startMinute":600,"endMinute":1200},{"weekday":2,"startMinute":600,"endMinute":1200},{"weekday":3,"startMinute":600,"endMinute":1200},{"weekday":4,"startMinute":600,"endMinute":1200},{"weekday":5,"startMinute":600,"endMinute":1200},{"weekday":6,"startMinute":540,"endMinute":1080}]', CURRENT_TIMESTAMP);
CREATE TABLE "AtelierJobPulse" (
  "id" TEXT PRIMARY KEY DEFAULT 'maintenance', "runId" TEXT NOT NULL,
  "state" TEXT NOT NULL CHECK ("state" IN ('RUNNING','OK','ERROR')),
  "startedAt" TIMESTAMP(3) NOT NULL, "finishedAt" TIMESTAMP(3),
  "durationMs" INTEGER, "lastErrorCode" TEXT
);
CREATE TABLE "IntegrationObservation" (
  "kind" TEXT PRIMARY KEY, "environment" TEXT NOT NULL, "fingerprint" TEXT NOT NULL,
  "mode" TEXT, "observedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP
);
