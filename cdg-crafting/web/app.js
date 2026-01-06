const app = document.getElementById('app');
if (app) {
  app.classList.add('hidden');
  app.style.display = 'none';
}

const el = (id) => document.getElementById(id);

const benchName = el('benchSubtitle');
const benchSub = null; // merged into benchSubtitle
const closeBtn = el('closeBtn');
const refreshBtn = el('refreshBtn');
const searchInput = el('search');
const recipeGrid = el('recipeGrid');

const detailTitle = el('detailsTitle');
const detailsReq = el('detailsReq');
const reqList = el('reqList');
const qtyMinus = el('qtyMinus');
const qtyPlus = el('qtyPlus');
const qtyValue = el('qtyValue');
const qtyMax = el('qtyMax');
const addQueueBtn = el('addQueueBtn');

const queueMeta = el('queueMeta');
const queueList = el('queueList');
const craftBtn = el('craftBtn');
const skillsBar = el('skillsBar');

let state = {
  benchId: null,
  bench: null,
  categories: {},
  recipes: {},
  benchRecipeIds: [],
  learned: {},
  skills: {},
  counts: {},
  draftQueue: [],

  search: '',
  selected: null,
  qty: 1
};

function postNui(eventName, data) {
  return fetch(`https://${GetParentResourceName()}/${eventName}`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json; charset=UTF-8' },
    body: JSON.stringify(data || {})
  });
}

// --- UI helpers (icons + safe text) ---
function oxItemImage(itemName) {
  // Cross-resource NUI path to ox_inventory item images
  return `nui://ox_inventory/web/images/${itemName}.png`;
}

function escapeHtml(str) {
  return String(str ?? '')
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;')
    .replaceAll("'", '&#039;');
}

function imgTag(item, className = '', alt = '') {
  const src = oxItemImage(item);
  // Fallback to a tiny inline SVG placeholder if the png doesn't exist
  const fallback = `data:image/svg+xml;utf8,${encodeURIComponent(
    `<svg xmlns="http://www.w3.org/2000/svg" width="64" height="64">
      <rect width="64" height="64" rx="14" fill="rgba(0,0,0,0.25)"/>
      <path d="M20 24h24v4H20zm0 8h24v4H20zm0 8h16v4H20z" fill="rgba(255,255,255,0.55)"/>
    </svg>`
  )}`;
  return `<img class="${className}" src="${src}" alt="${escapeHtml(alt || item)}" onerror="this.onerror=null;this.src='${fallback}'" />`;
}

function queuedCountFor(recipeId) {
  let total = 0;
  for (const j of (state.draftQueue || [])) {
    if (j.recipeId === recipeId) total += (j.quantity || 1);
  }
  return total;
}

closeBtn?.addEventListener('click', () => postNui('close'));

refreshBtn?.addEventListener('click', async () => {
  const res = await postNui('refreshCounts', {});
  const data = await res.json().catch(() => null);
  if (!data || !data.ok) return;
  if (data.counts) state.counts = data.counts;
  renderAll();
});

searchInput?.addEventListener('input', (e) => {
  state.search = (e.target.value || '').toLowerCase();
  renderGrid();
});

function clampQty(q){
  q = parseInt(q, 10);
  if (Number.isNaN(q) || q < 1) q = 1;
  if (q > 100) q = 100;
  return q;
}


function computeMaxQty(recipe){
  if (!recipe || !Array.isArray(recipe.ingredients) || recipe.ingredients.length === 0) return 1;

  let max = Infinity;
  for (const ing of recipe.ingredients){
    const have = Number(state.counts?.[ing.item] ?? 0) || 0;
    const per = Number(ing.count ?? 0) || 0;
    if (per <= 0) continue;
    max = Math.min(max, Math.floor(have / per));
  }
  if (!Number.isFinite(max) || max < 1) max = 1;
  return max;
}
qtyMinus?.addEventListener('click', () => {
  state.qty = clampQty(state.qty - 1);
  qtyValue.textContent = String(state.qty);
  renderDetails();
});

qtyPlus?.addEventListener('click', () => {
  state.qty = clampQty(state.qty + 1);
  qtyValue.textContent = String(state.qty);
  renderDetails();
});

qtyMax?.addEventListener('click', () => {
  if (!state.selected) return;
  const r = state.recipes?.[state.selected];
  if (!r) return;
  state.qty = clampQty(computeMaxQty(r));
  qtyValue.textContent = String(state.qty);
  renderDetails();
});

addQueueBtn?.addEventListener('click', async () => {
  if (!state.selected) return;
  const r = state.recipes?.[state.selected];
  if (!r) return;

  // Enforce craftability at time of queueing
  const check = canCraftRecipe(state.selected, state.qty);
  if (!check.ok) return;

  state.draftQueue.push({ recipeId: state.selected, quantity: state.qty });
  renderAll();
});

craftBtn?.addEventListener('click', async () => {
  if (!state.draftQueue || state.draftQueue.length === 0) return;
  craftBtn.disabled = true;
  try {
    await postNui('startQueue', { queue: state.draftQueue });
  } finally {
    craftBtn.disabled = false;
  }
});

function catLabel(key){
  return state.categories?.[key]?.label || key;
}

function canCraftRecipe(recipeId, qty = 1){
  const r = state.recipes?.[recipeId];
  if (!r) return { ok:false, reason:'Missing recipe' };

  const lvl = state.skills?.[r.category]?.level || 1;
  const reqLvl = r.levelRequired || 1;
  if (lvl < reqLvl) return { ok:false, reason:`Needs Lv ${reqLvl}` };

  const requiresBlueprint = (r.requiresBlueprint !== false);
  if (requiresBlueprint && !state.learned?.[recipeId]) return { ok:false, reason:'Needs Blueprint' };

  for (const ing of (r.ingredients || [])){
    const have = state.counts?.[ing.item] ?? 0;
    const need = (ing.count ?? 0) * qty;
    if (have < need) return { ok:false, reason:'Missing Mats' };
  }

  return { ok:true };
}

function isRecipeVisible(recipeId){
  const r = state.recipes?.[recipeId];
  if (!r) return false;
  const requiresBlueprint = (r.requiresBlueprint !== false);
  if (requiresBlueprint && !state.learned?.[recipeId]) return false;
  return true;
}

function renderSkills(){
  if (!skillsBar) return;

  const cats = state.categories || {};
  const catKeys = Object.keys(cats);
  if (catKeys.length === 0){
    skillsBar.innerHTML = '';
    return;
  }

  const clamp01 = (v) => Math.max(0, Math.min(1, v));
  const rows = [];

  for (const catKey of catKeys){
    const cat = cats[catKey] || {};
    const sk = state.skills?.[catKey] || { level: 1, xp: 0 };

    const lvl = Number(sk.level ?? 1) || 1;
    const xpRaw = Number(sk.xp ?? 0) || 0;

    const levels = cat.levels || {};
    const cur = Number(levels[lvl] ?? 0);
    const next = Number(levels[lvl + 1] ?? cur);

    const denom = Math.max(1, (next - cur));

    // Some servers store XP as TOTAL lifetime XP, others store XP as "progress within level".
    // If xpRaw is less than the current level threshold, treat it as per-level XP.
    const xpInLevel = (xpRaw < cur) ? xpRaw : (xpRaw - cur);

    const pct = (next > cur) ? clamp01(xpInLevel / denom) : 1;

    rows.push(`
      <div class="skillCard">
        <div class="skillRow">
          <div class="skillName">${escapeHtml(cat.label || catKey)}</div>
          <div class="skillLv">Lv ${lvl}</div>
        </div>
        <div class="skillTrack">
          <div class="skillFill" style="width:${Math.round(pct * 100)}%"></div>
        </div>
      </div>
    `);
  }

  skillsBar.innerHTML = rows.join('');
}

function renderGrid(){
  recipeGrid.innerHTML = '';

  const ids = (state.benchRecipeIds || []).filter(isRecipeVisible);
  const q = state.search;

  state.visibleRecipeIds = ids;

  ids.forEach((id) => {
    const r = state.recipes?.[id];
    if (!r) return;

    const name = String(r.label || id);
    if (q && !name.toLowerCase().includes(q)) return;

    const craftCheck = canCraftRecipe(id, 1);
    const card = document.createElement('button');
    card.type = 'button';

    const count = 1; // If you want “owned count” later, we can wire item count from ox_inventory.

    const outItem = (r.outputs && r.outputs[0] && r.outputs[0].item) ? r.outputs[0].item : null;

const qCount = queuedCountFor(id);

card.className =
  'recipeCard ' +
  (state.selected === id ? 'selected ' : '') +
  (craftCheck.ok ? 'craftable ' : 'blocked ');

card.innerHTML = `
  <div class="stateStripe"></div>

  <div class="recipeTopRow">
    <div class="leftTop">
      <div class="recipeIconWrap">
        ${outItem ? imgTag(outItem, 'recipeIcon', outItem) : ''}
      </div>

      <div class="recipeText">
        <div class="recipeName">${escapeHtml(name)}</div>
        <div class="recipeSub">${escapeHtml(catLabel(r.category))} • Lv ${r.levelRequired || 1}</div>
      </div>
    </div>

    <div class="rightTop">
      ${qCount > 0 ? `<div class="queueBadge" title="In queue">${qCount}</div>` : ``}
    </div>
  </div>
`;

    card.addEventListener('click', () => {
      state.selected = id;
      state.qty = 1;
      qtyValue.textContent = '1';
      renderAll();
    });

    recipeGrid.appendChild(card);
  });
}

function renderDetails(){
  const r = state.selected ? state.recipes?.[state.selected] : null;

  if (!r){
    detailTitle.textContent = 'Select a recipe';
    if (detailsReq) detailsReq.textContent = 'Select a recipe';
    reqList.innerHTML = '';
    addQueueBtn.disabled = true;
    return;
  }

  detailTitle.textContent = r.label || state.selected;
  const reqLvl = r.levelRequired || 1;
  if (detailsReq) detailsReq.textContent = `${catLabel(r.category)} • Needs Lv ${reqLvl}`;

  reqList.innerHTML = '';
for (const ing of (r.ingredients || [])){
  const have = state.counts?.[ing.item] ?? 0;
  const need = (ing.count ?? 0) * state.qty;
  const ok = have >= need;

  const row = document.createElement('div');
  row.className = 'reqItem ' + (ok ? 'ok' : 'bad');

  row.innerHTML = `
    ${imgTag(ing.item, 'reqIcon', ing.item)}
    <div class="reqText">
      <div class="reqName">${escapeHtml(ing.item)}</div>
      <div class="reqCount">${have}/${need}</div>
    </div>
  `;

  reqList.appendChild(row);
}

  const craftCheck = canCraftRecipe(state.selected, state.qty);
  addQueueBtn.disabled = !craftCheck.ok;
  addQueueBtn.textContent = craftCheck.ok ? 'ADD TO QUEUE' : craftCheck.reason.toUpperCase();
}

function renderQueue(){
  queueList.innerHTML = '';

  const jobs = state.draftQueue || [];
  const totalLines = jobs.length;
  const totalQty = jobs.reduce((a, j) => a + (j.quantity || 1), 0);

  if (queueMeta) {
    queueMeta.textContent = totalLines === 0 ? 'Empty' : `${totalLines} item(s) • ${totalQty} total`;
  }

  if (craftBtn) craftBtn.disabled = (totalLines === 0);

  if (jobs.length === 0){
    const empty = document.createElement('div');
    empty.className = 'queueEmpty';
    empty.textContent = 'Queue is empty.';
    queueList.appendChild(empty);
    return;
  }

  jobs.forEach((job, idx) => {
    const r = state.recipes?.[job.recipeId];
    const row = document.createElement('div');
    row.className = 'queueRow';

    const label = r?.label || job.recipeId;
    const cat = r?.category ? catLabel(r.category) : '';
    const right = `Qty: ${job.quantity || 1}`;

    row.innerHTML = `
      <div class="queueLeft">
        <div class="queueName">${escapeHtml(label)}</div>
        <div class="queueSub">${escapeHtml(cat)}</div>
      </div>
      <div class="queueRight">
        <span>${right}</span>
        <button class="btn qtyBtn" data-qremove="${idx}" title="Remove">×</button>
      </div>
    `;

    queueList.appendChild(row);
  });

  // Bind remove buttons
  queueList.querySelectorAll('[data-qremove]')?.forEach(btn => {
    btn.addEventListener('click', (e) => {
      e.preventDefault();
      const i = parseInt(btn.getAttribute('data-qremove'), 10);
      if (Number.isNaN(i)) return;
      state.draftQueue.splice(i, 1);
      renderAll();
    });
  });
}

function renderAll(){
  renderSkills();
  renderGrid();
  renderDetails();
  renderQueue();
}

function open(payload){
  
  app.classList.remove('is-open');
state.benchId = payload.bench?.id || null;
  state.bench = payload.bench;
  state.categories = payload.categories || {};
  state.recipes = payload.recipes || {};
  state.benchRecipeIds = payload.bench?.recipes || [];
  state.learned = payload.learned || {};
  state.skills = payload.skills || {};
  state.counts = payload.counts || {};
  state.draftQueue = [];

  state.search = '';
  if (searchInput) searchInput.value = '';

  // default select first *visible* recipe
  const visible = (state.benchRecipeIds || []).filter(isRecipeVisible);
  state.visibleRecipeIds = visible;
  state.selected = visible?.[0] || null;
  state.qty = 1;
  if (qtyValue) qtyValue.textContent = '1';

  benchName.textContent = `${payload.bench?.label || 'Crafting Bench'} • ${visible.length} recipe(s)`;

  renderAll();

  app.classList.remove('hidden');
  app.style.display = 'flex';
  // Fade-in
  requestAnimationFrame(() => app.classList.add('is-open'));
}

function close(){
  app.classList.add('hidden');
  app.style.display = 'none';
}

function applyServerUpdate(payload){
  if (!payload) return;
  if (payload.counts) state.counts = payload.counts;
  if (payload.skills) state.skills = payload.skills;
  renderAll();
}

window.addEventListener('message', (event) => {
  const msg = event.data;
  if (!msg || !msg.action) return;

  if (msg.action === 'open') open(msg.payload);
  if (msg.action === 'close') close();
  if (msg.action === 'update') applyServerUpdate(msg.payload);
});
