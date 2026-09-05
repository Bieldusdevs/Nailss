import { defaultOpeningHours } from '../src/domains/administration/validators/opening-hours';
import { PrismaClient } from '@prisma/client';
import {
  atelierCategories,
  atelierTreatments,
  atelierGallery,
} from '../src/domains/catalog/services/atelier-collection';
import { atelierDefaults } from '../src/domains/administration/schemas/atelier-settings';
const prisma = new PrismaClient();
async function curate() {
  await prisma.atelierOpeningPlan.upsert({
    where: { id: 'atelier' },
    update: {},
    create: { id: 'atelier', weeklyHours: defaultOpeningHours },
  });
  for (const category of atelierCategories)
    await prisma.category.upsert({ where: { id: category.id }, update: {}, create: category });
  for (const treatment of atelierTreatments)
    await prisma.treatment.upsert({ where: { id: treatment.id }, update: {}, create: treatment });
  const artistId = 'equipa-lumiere';
  await prisma.artist.upsert({
    where: { id: artistId },
    update: {},
    create: {
      id: artistId,
      name: 'Equipa Lumière',
      title: 'Cuidado de mãos & pés',
      bio: 'Uma agenda partilhada com a profissional disponível no atelier. Cuidado atento, técnica e tempo para escutar as suas preferências.',
      specialities: ['Manicure', 'Verniz gel', 'Nail art', 'Pedicure'],
      workingWindows: {
        create: [1, 2, 3, 4, 5, 6].flatMap((weekday) =>
          (weekday === 6
            ? [
                [540, 780],
                [840, 1080],
              ]
            : [
                [600, 780],
                [840, 1200],
              ]
          ).map(([startMinute, endMinute]) => ({ weekday, startMinute, endMinute })),
        ),
      },
      treatments: { connect: atelierTreatments.map((t) => ({ id: t.id })) },
    },
  });
  for (const { artist: _artist, ...piece } of atelierGallery)
    await prisma.portfolioPiece.upsert({ where: { id: piece.id }, update: {}, create: piece });
  await prisma.atelierSetting.upsert({
    where: { id: 'atelier' },
    update: {},
    create: { id: 'atelier', value: atelierDefaults },
  });
  console.log('atelier.catalog.curated', {
    treatments: atelierTreatments.length,
    artists: 1,
    reviews: 0,
  });
}
curate()
  .catch((e) => {
    console.error(e);
    process.exitCode = 1;
  })
  .finally(() => prisma.$disconnect());
