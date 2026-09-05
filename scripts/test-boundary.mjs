// Preload before Prisma: its dotenv fallback must never import live providers or Redis into fixtures.
const url = new URL(process.env.DATABASE_URL ?? 'postgresql://invalid/');
if (!url.pathname.endsWith('/lumiere_test') || process.env.DEPLOYMENT_ENV !== 'test')
  throw new Error('Os testes destrutivos exigem a base lumiere_test e DEPLOYMENT_ENV=test.');
for (const key of [
  'REDIS_URL',
  'STRIPE_SECRET_KEY',
  'STRIPE_WEBHOOK_SECRET',
  'RESEND_API_KEY',
  'MAIL_FROM',
  'TWILIO_ACCOUNT_SID',
  'TWILIO_AUTH_TOKEN',
  'TWILIO_FROM',
  'BLOB_READ_WRITE_TOKEN',
  'OTEL_EXPORTER_OTLP_ENDPOINT',
])
  process.env[key] = '';
