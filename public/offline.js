const field = document.getElementById('treatment');
const day = document.getElementById('day');
day.value = new Intl.DateTimeFormat('en-CA', { timeZone: 'Europe/Lisbon', year: 'numeric', month: '2-digit', day: '2-digit' }).format(new Date());
fetch('/api/domains/catalog').then(response => { if (!response.ok) throw new Error(); return response.json(); }).then(collection => {
  field.replaceChildren();
  for (const treatment of collection.treatments) {
    const option = document.createElement('option'); option.value = treatment.id; option.textContent = treatment.name; field.append(option);
    const card = document.createElement('article'), image = document.createElement('img'), body = document.createElement('div'), name = document.createElement('h3'), copy = document.createElement('p'), detail = document.createElement('small');
    image.src = treatment.image; image.alt = ''; image.loading = 'lazy'; name.textContent = treatment.name; copy.textContent = treatment.summary; detail.textContent = `${treatment.durationMinutes} min · ${new Intl.NumberFormat('pt-PT', { style: 'currency', currency: 'EUR' }).format(treatment.priceCents / 100)}`;
    body.append(name, copy, detail); card.append(image, body); document.getElementById('care-grid').append(card);
  }
  try { const draft = JSON.parse(localStorage.getItem('lumiere:booking-draft') || 'null'); if (draft && collection.treatments.some(t => t.id === draft.treatmentId)) { field.value = draft.treatmentId; day.value = draft.date; } } catch {}
}).catch(() => { field.replaceChildren(new Option('A coleção ainda não está guardada', '')); document.getElementById('offline-catalogue').hidden = true; });
document.getElementById('draft-form').addEventListener('submit', event => {
  event.preventDefault(); if (!field.value || !day.value) return;
  try { const previous = JSON.parse(localStorage.getItem('lumiere:booking-draft') || 'null'); localStorage.setItem('lumiere:booking-draft', JSON.stringify({ treatmentId: field.value, artistId: 'any', date: day.value, savedAt: Date.now(), draftId: crypto.randomUUID(), ownerId: previous?.ownerId || localStorage.getItem('lumiere:draft-owner') || null, baseRevision: previous?.baseRevision ?? null, dirty: true, conflict: false })); document.getElementById('draft-status').textContent = 'Preferência guardada. Ainda não existe uma marcação confirmada.'; }
  catch { document.getElementById('draft-status').textContent = 'O navegador não permitiu guardar. Tente novamente quando tiver ligação.'; }
});
function connection() { document.getElementById('connection').textContent = navigator.onLine ? 'A ligação voltou. Abra o atelier para continuar.' : ''; }
window.addEventListener('online', connection); connection();
