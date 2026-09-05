import { randomBytes, randomUUID } from 'node:crypto';
import { mkdirSync, writeFileSync } from 'node:fs';
import { spawnSync } from 'node:child_process';
import { hash } from 'bcryptjs';
import { atelierDb as db } from '../src/core/lib/atelier-db';
import { localDay, lisbonInstant } from '../src/core/lib/atelier-format';
async function prepare() {
  if (
    process.env.DEPLOYMENT_ENV !== 'test' ||
    !new URL(process.env.DATABASE_URL!).pathname.endsWith('/lumiere_test')
  )
    throw new Error('Use apenas a base de testes isolada.');
  await db.$executeRaw`TRUNCATE TABLE "Client", "Artist", "Treatment", "Category", "AtelierSetting", "AtelierOpeningPlan", "AtelierJobPulse", "IntegrationObservation", "Correspondence", "ContactLetter", "AgendaEvent", "WebhookReceipt", "RequestWindow" CASCADE`;
  const seed = spawnSync(process.execPath, ['--import', 'tsx', 'prisma/seed.ts'], {
    env: process.env,
    stdio: 'inherit',
  });
  if (seed.status !== 0) throw new Error('A seed isolada falhou.');
  const password = randomBytes(20).toString('base64url');
  const passwordHash = await hash(password, 12);
  const people = [];
  for (const [key, name, role] of [
    ['admin', 'Admin da verificação isolada', 'ADMIN'],
    ['artist-a', 'Profissional de teste A', 'ARTIST'],
    ['artist-b', 'Profissional de teste B', 'ARTIST'],
    ['patron-a', 'Cliente de teste A', 'CLIENT'],
    ['patron-b', 'Cliente de teste B', 'CLIENT'],
  ] as const)
    people.push(
      await db.client.create({
        data: {
          id: `e2e-${key}`,
          name,
          email: `${key}@qa.lumiere.invalid`,
          passwordHash,
          role,
          phone: '+351910000001',
          emailVerified: new Date(),
          privacyAcceptedAt: new Date(),
        },
      }),
    );
  for (const suffix of ['a', 'b'])
    await db.artist.create({
      data: {
        id: `e2e-artist-${suffix}`,
        name: `Profissional de teste ${suffix.toUpperCase()}`,
        title: 'Cenário de validação',
        bio: 'Perfil técnico de teste, não é uma profissional do atelier.',
        specialities: ['Manicure'],
        clientId: `e2e-artist-${suffix}`,
        treatments: { connect: { id: 'manicure-essencial' } },
        workingWindows: {
          create: [1, 2, 3, 4, 5, 6].map((weekday) => ({
            weekday,
            startMinute: 600,
            endMinute: 1080,
          })),
        },
      },
    });
  const day = localDay(new Date(Date.now() + 12 * 86400000));
  for (const suffix of ['a', 'b'])
    await db.appointment.create({
      data: {
        id: `e2e-visit-${suffix}`,
        reference: `ENSAIO-${suffix.toUpperCase()}`,
        clientId: `e2e-patron-${suffix}`,
        artistId: `e2e-artist-${suffix}`,
        treatmentId: 'manicure-essencial',
        treatmentName: 'Manicure essencial',
        startsAt: lisbonInstant(day, 600),
        endsAt: lisbonInstant(day, 630),
        occupiedUntil: lisbonInstant(day, 650),
        durationMinutes: 30,
        priceCents: 3000,
        depositCents: 2000,
        status: 'CONFIRMED',
      },
    });
  const payment = await db.payment.create({
    data: {
      id: 'e2e-payment',
      appointmentId: 'e2e-visit-a',
      amountCents: 2000,
      status: 'PARTIALLY_REFUNDED',
      refundedCents: 800,
      checkoutId: 'cs_isolated_fixture',
      intentId: 'pi_isolated_fixture',
      lastCheckedAt: new Date(),
      refunds: {
        create: {
          id: 're_isolated_fixture',
          amountCents: 800,
          status: 'succeeded',
          providerCreatedAt: new Date(),
        },
      },
    },
  });
  await db.loyaltyEntry.create({
    data: {
      clientId: 'e2e-patron-a',
      points: 7,
      reason: 'Fixture de verificação isolada; não é um atendimento comercial.',
    },
  });
  await db.bookingPreference.create({
    data: {
      clientId: 'e2e-patron-a',
      treatmentId: 'manicure-essencial',
      artistId: 'any',
      preferredDay: day,
      draftId: randomUUID(),
      revision: 1,
    },
  });
  mkdirSync('.cache', { recursive: true });
  writeFileSync(
    '.cache/browser-fixtures.json',
    JSON.stringify({
      password,
      day,
      paymentId: payment.id,
      adminEmail: 'admin@qa.lumiere.invalid',
      people: people.map(({ id, email, name, role }) => ({ id, email, name, role })),
    }),
    { mode: 0o600 },
  );
  console.log('Cenários preparados apenas em lumiere_test; segredos efémeros fora do repositório.');
}
prepare()
  .catch((error) => {
    console.error(error);
    process.exitCode = 1;
  })
  .finally(() => db.$disconnect());
