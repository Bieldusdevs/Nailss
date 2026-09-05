import 'dotenv/config';
import { maintainAtelier } from '../src/domains/communication/services/atelier-maintenance';
import { recordFailure } from '../src/core/analytics/atelier-journal';
import { atelierDb } from '../src/core/lib/atelier-db';
let busy = false;
async function tick() {
  if (busy) return;
  busy = true;
  try {
    const result = await maintainAtelier();
    if (
      result.expired ||
      result.mail.sent ||
      result.mail.failed ||
      result.mail.blocked ||
      result.refunds.processed ||
      result.refunds.checked ||
      result.refunds.failed
    )
      console.log(JSON.stringify({ event: 'atelier.maintenance', ...result }));
  } catch (error) {
    recordFailure('atelier.maintenance.failed', error);
  } finally {
    busy = false;
  }
}
console.log(JSON.stringify({ event: 'atelier.worker.ready', intervalSeconds: 30 }));
void tick();
const interval = setInterval(tick, 30000);
for (const signal of ['SIGTERM', 'SIGINT'])
  process.on(signal, () => {
    clearInterval(interval);
    void atelierDb.$disconnect().finally(() => process.exit(0));
  });
