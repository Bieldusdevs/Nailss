import 'dotenv/config';
import { hash } from 'bcryptjs';
import { atelierDb } from '../src/core/lib/atelier-db';
import {
  patronEmail,
  patronPassword,
  shortText,
} from '../src/domains/client/validators/patron-details';
async function provision() {
  const email = patronEmail.parse(process.env.ADMIN_EMAIL),
    password = patronPassword.parse(process.env.ADMIN_PASSWORD),
    name = shortText(100).parse(process.env.ADMIN_NAME ?? 'Responsável do atelier');
  const existing = await atelierDb.client.findUnique({ where: { email } });
  if (existing && process.env.ADMIN_ROTATE !== 'true')
    throw new Error(
      'A conta já existe. Use ADMIN_ROTATE=true apenas para uma rotação de acesso deliberada.',
    );
  const passwordHash = await hash(password, 12);
  const admin = await atelierDb.client.upsert({
    where: { email },
    create: {
      name,
      email,
      passwordHash,
      role: 'ADMIN',
      emailVerified: new Date(),
      privacyAcceptedAt: new Date(),
    },
    update: {
      name,
      passwordHash,
      role: 'ADMIN',
      emailVerified: new Date(),
      deletedAt: null,
      sessionVersion: { increment: 1 },
    },
  });
  await atelierDb.auditEvent.create({
    data: {
      kind: existing ? 'administration.access.rotated' : 'administration.access.provisioned',
      actorId: admin.id,
    },
  });
  console.log(
    'Conta de administração preparada. A palavra-passe não é apresentada nem escrita no repositório.',
  );
}
provision()
  .catch((error) => {
    console.error(error instanceof Error ? error.message : 'Falha ao criar o acesso.');
    process.exitCode = 1;
  })
  .finally(() => atelierDb.$disconnect());
