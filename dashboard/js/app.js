/* ============================================
   ShipLink Admin Dashboard
   ============================================ */

const SUPABASE_URL = 'https://aqxiziqybgtvrdfhmmoc.supabase.co';
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFxeGl6aXF5Ymd0dnJkZmhtbW9jIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODE3MjI5MDUsImV4cCI6MjA5NzI5ODkwNX0.vohe0h4gzDZSRttscc6c2RXREIv6Nt7WawxSoavFG6w';

let supabase;
let currentUser = null;

function initSupabase() {
  supabase = supabaseJs.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
}

const $ = (s) => document.querySelector(s);
const $$ = (s) => document.querySelectorAll(s);
const ce = (tag, cls, html) => { const e = document.createElement(tag); if (cls) e.className = cls; if (html !== undefined) e.innerHTML = html; return e; };

const ADMIN_EMAILS = ['mahmoudfahmy616572@gmail.com'];

async function handleLogin(e) {
  e.preventDefault();
  const email = $('#email').value.trim();
  const password = $('#password').value;
  const btn = $('#login-btn');
  btn.disabled = true; btn.textContent = 'Signing in...';
  $('#login-error').textContent = '';
  try {
    const { data, error } = await supabase.auth.signInWithPassword({ email, password });
    if (error) throw error;
    currentUser = data.user;
    if (!ADMIN_EMAILS.includes(currentUser.email)) {
      await supabase.auth.signOut();
      currentUser = null; throw new Error('Not authorized as admin');
    }
    showDashboard();
  } catch (err) { $('#login-error').textContent = err.message; }
  finally { btn.disabled = false; btn.textContent = 'Sign In'; }
}

async function handleLogout() {
  await supabase.auth.signOut();
  currentUser = null;
  hideDashboard();
}

async function checkSession() {
  const { data: { session } } = await supabase.auth.getSession();
  if (session && ADMIN_EMAILS.includes(session.user.email)) {
    currentUser = session.user;
    showDashboard();
  }
}

function showDashboard() {
  $('#login-page').style.display = 'none';
  $('#dashboard').style.display = 'flex';
  $('#admin-email').textContent = currentUser?.email || '';
  navigate();
}

function hideDashboard() {
  $('#login-page').style.display = 'flex';
  $('#dashboard').style.display = 'none';
  window.location.hash = '';
}

// ── Router ──────────────────────────────────
function navigate() {
  const hash = window.location.hash.slice(1) || '/';
  const page = hash.split('/')[0] || '/';
  $$('.nav-item').forEach(n => n.classList.toggle('active', n.dataset.page === page.slice(1) || (page === '/' && n.dataset.page === 'overview')));
  switch (page) {
    case '/': renderOverview(); break;
    case 'orders': renderOrders(); break;
    case 'analytics': renderAnalytics(); break;
    case 'products': renderProducts(); break;
    case 'categories': renderCategories(); break;
    case 'users': renderUsers(); break;
    case 'drivers': renderDrivers(); break;
    case 'settings': renderSettings(); break;
    default: renderOverview();
  }
}
window.addEventListener('hashchange', navigate);

// ── Helpers ─────────────────────────────────
function toast(msg, type = 'success') {
  const t = ce('div', `toast toast-${type}`, msg);
  document.body.appendChild(t);
  setTimeout(() => t.remove(), 3000);
}
function showLoading(container) {
  container.innerHTML = '<div class="loading-wrap"><div class="spinner"></div></div>';
}
function showError(container, msg) {
  container.innerHTML = `<div class="empty"><p style="color:var(--danger)">${esc(msg)}</p></div>`;
}
function esc(s) { if (s == null) return ''; const d = document.createElement('div'); d.textContent = String(s); return d.innerHTML; }
function formatDate(d) {
  if (!d) return '-';
  return new Date(d).toLocaleDateString('en-US', { year:'numeric', month:'short', day:'numeric', hour:'2-digit', minute:'2-digit' });
}
function shortDate(d) {
  if (!d) return '-';
  return new Date(d).toLocaleDateString('en-US', { year:'numeric', month:'short', day:'numeric' });
}
function statusClass(s) {
  const m = { pending:'status-pending', confirmed:'status-confirmed', accepted:'status-accepted', delivered:'status-delivered', cancelled:'status-cancelled', payment_failed:'status-payment_failed' };
  return m[s] || 'status-pending';
}
function paymentBadge(m) {
  if (m === 'card') return '<span class="payment-badge payment-card">Card &#10003;</span>';
  if (m === 'cod') return '<span class="payment-badge payment-cod">COD</span>';
  return '';
}

function downloadCSV(filename, rows) {
  const csv = rows.map(r => r.map(c => `"${String(c).replace(/"/g,'""')}"`).join(',')).join('\n');
  const blob = new Blob(['\uFEFF'+csv], { type:'text/csv;charset=utf-8;' });
  const a = ce('a'); a.href = URL.createObjectURL(blob); a.download = filename;
  a.click(); URL.revokeObjectURL(a.href);
}

// ── Overview ────────────────────────────────
async function renderOverview() {
  const cont = $('#page-content');
  cont.innerHTML = '<h1>Overview</h1>';
  try {
    const [orders, users, driversRes, products] = await Promise.all([
      supabase.from('orders').select('id,status,payment_method,total_price,created_at'),
      supabase.from('profiles').select('id', { count:'exact', head:false }),
      supabase.from('drivers').select('id,is_active'),
      supabase.from('products').select('id', { count:'exact', head:false }),
    ]);

    const allOrders = orders.data || [];
    const pendingOrders = allOrders.filter(o => o.status === 'pending').length;
    const cardPayments = allOrders.filter(o => o.payment_method === 'card').length;
    const totalRevenue = allOrders.reduce((s,o) => s + Number(o.total_price||0), 0);
    const activeDrivers = (driversRes.data||[]).filter(d => d.is_active).length;
    const today = new Date(); today.setHours(0,0,0,0);
    const todayRevenue = allOrders.filter(o => new Date(o.created_at) >= today).reduce((s,o) => s + Number(o.total_price||0), 0);

    cont.innerHTML = `
      <div class="stats-grid">
        <div class="stat-card" style="border-left-color:var(--success)"><h3>Revenue</h3><div class="value">$${totalRevenue.toFixed(2)}</div></div>
        <div class="stat-card" style="border-left-color:#10B981"><h3>Today</h3><div class="value">$${todayRevenue.toFixed(2)}</div></div>
        <div class="stat-card" style="border-left-color:var(--primary)"><h3>Orders</h3><div class="value">${allOrders.length}</div></div>
        <div class="stat-card" style="border-left-color:var(--warning)"><h3>Pending</h3><div class="value">${pendingOrders}</div></div>
        <div class="stat-card" style="border-left-color:var(--success)"><h3>Card Paid</h3><div class="value">${cardPayments}</div></div>
        <div class="stat-card" style="border-left-color:#7C3AED"><h3>Products</h3><div class="value">${products.data?.length||0}</div></div>
        <div class="stat-card" style="border-left-color:#8B5CF6"><h3>Users</h3><div class="value">${users.data?.length||0}</div></div>
        <div class="stat-card" style="border-left-color:#F59E0B"><h3>Drivers</h3><div class="value">${activeDrivers}/${driversRes.data?.length||0} active</div></div>
      </div>
      <div class="card"><p>Welcome to ShipLink Admin. Use the sidebar to manage everything.</p></div>`;
  } catch (e) { showError(cont, e.message); }
}

// ── Analytics ───────────────────────────────
async function renderAnalytics(range = '7') {
  const cont = $('#page-content');
  cont.innerHTML = `<div class="page-header"><h1>Analytics</h1>
    <select id="analytics-range" style="padding:8px;border:1px solid var(--border);border-radius:var(--radius);font-size:14px">
      <option value="7" ${range==='7'?'selected':''}>Last 7 days</option>
      <option value="30" ${range==='30'?'selected':''}>Last 30 days</option>
      <option value="90" ${range==='90'?'selected':''}>Last 90 days</option>
    </select></div>
    <div id="analytics-content"></div>`;
  const ac = $('#analytics-content');
  showLoading(ac);
  $('#analytics-range').onchange = () => renderAnalytics($('#analytics-range').value);

  try {
    const since = new Date(); since.setDate(since.getDate() - parseInt(range));
    const { data, error } = await supabase.from('orders').select('id,total_price,status,payment_method,created_at').gte('created_at', since.toISOString()).order('created_at');
    if (error) throw error;
    const orders = data || [];

    // Daily aggregation
    const daily = {};
    for (const o of orders) {
      const day = shortDate(o.created_at);
      if (!daily[day]) daily[day] = { revenue:0, count:0, card:0, cod:0 };
      daily[day].revenue += Number(o.total_price||0);
      daily[day].count++;
      if (o.payment_method === 'card') daily[day].card++;
      else daily[day].cod++;
    }
    const days = Object.keys(daily).sort();
    const maxRev = Math.max(...days.map(d => daily[d].revenue), 1);

    // Build chart
    let bars = days.map(d => {
      const pct = (daily[d].revenue / maxRev) * 100;
      return `<div style="margin-bottom:16px">
        <div style="display:flex;justify-content:space-between;font-size:12px;margin-bottom:2px">
          <span>${d}</span><span>$${daily[d].revenue.toFixed(0)} (${daily[d].count} orders)</span>
        </div>
        <div style="background:var(--border);border-radius:4px;height:24px;overflow:hidden;display:flex">
          <div style="width:${pct}%;background:var(--primary);height:24px;border-radius:4px;transition:width 0.5s"></div>
        </div>
      </div>`;
    }).join('');

    const totalRev = orders.reduce((s,o) => s + Number(o.total_price||0), 0);
    const cardOrders = orders.filter(o => o.payment_method === 'card');
    const cardRev = cardOrders.reduce((s,o) => s + Number(o.total_price||0), 0);

    ac.innerHTML = `
      <div class="stats-grid" style="grid-template-columns:repeat(3,1fr)">
        <div class="stat-card" style="border-left-color:var(--success)"><h3>Revenue (${range}d)</h3><div class="value">$${totalRev.toFixed(2)}</div></div>
        <div class="stat-card" style="border-left-color:var(--primary)"><h3>Orders</h3><div class="value">${orders.length}</div></div>
        <div class="stat-card" style="border-left-color:var(--success)"><h3>Card Revenue</h3><div class="value">$${cardRev.toFixed(2)}</div></div>
      </div>
      <div class="card">
        <h3 style="margin-bottom:16px">Daily Revenue</h3>
        ${days.length ? bars : '<p style="color:var(--text-sec)">No orders in this period</p>'}
      </div>
      <div class="card">
        <h3 style="margin-bottom:12px">Payment Breakdown</h3>
        <div style="display:flex;gap:24px;flex-wrap:wrap">
          <div><strong>Card:</strong> ${cardOrders.length} orders ($${cardRev.toFixed(2)})</div>
          <div><strong>COD:</strong> ${orders.length - cardOrders.length} orders ($${(totalRev-cardRev).toFixed(2)})</div>
        </div>
        <div style="margin-top:12px;display:flex;height:32px;border-radius:6px;overflow:hidden;max-width:400px">
          <div style="flex:${cardRev||1};background:var(--success);display:flex;align-items:center;justify-content:center;color:white;font-size:12px;font-weight:600">${totalRev ? Math.round(cardRev/totalRev*100) : 0}%</div>
          <div style="flex:${(totalRev-cardRev)||1};background:var(--warning);display:flex;align-items:center;justify-content:center;color:white;font-size:12px;font-weight:600">${totalRev ? Math.round((totalRev-cardRev)/totalRev*100) : 0}%</div>
        </div>
      </div>`;
  } catch (e) { showError(ac, e.message); }
}

// ── Orders ──────────────────────────────────
async function renderOrders() {
  const cont = $('#page-content');
  cont.innerHTML = `<div class="page-header"><h1>Orders</h1>
    <button class="btn btn-success" onclick="exportOrdersCSV()">Export CSV</button>
  </div>
  <div class="card" style="padding:16px">
    <div style="display:flex;gap:12px;flex-wrap:wrap;align-items:center">
      <input type="text" id="order-search" placeholder="Search name/ID..." style="padding:8px 12px;border:1px solid var(--border);border-radius:var(--radius);flex:1;min-width:150px;font-size:14px">
      <select id="filter-status" style="padding:8px;border:1px solid var(--border);border-radius:var(--radius);font-size:13px">
        <option value="">All Status</option>
        <option>pending</option><option>confirmed</option><option>accepted</option><option>delivered</option><option>cancelled</option><option>payment_failed</option>
      </select>
      <select id="filter-payment" style="padding:8px;border:1px solid var(--border);border-radius:var(--radius);font-size:13px">
        <option value="">All Payment</option><option value="card">Card</option><option value="cod">COD</option>
      </select>
    </div>
  </div>
  <div id="orders-container"></div>`;
  const oc = $('#orders-container');
  showLoading(oc);
  await loadOrders();

  ['#order-search','#filter-status','#filter-payment'].forEach(id => {
    $(id).addEventListener('change', () => loadOrders());
    if (id === '#order-search') $(id).addEventListener('input', () => {
      clearTimeout(window._ordDelay);
      window._ordDelay = setTimeout(() => loadOrders(), 300);
    });
  });
}

async function loadOrders() {
  const oc = $('#orders-container');
  const search = $('#order-search').value.trim();
  const statusFilter = $('#filter-status').value;
  const paymentFilter = $('#filter-payment').value;

  let query = supabase.from('orders').select('*, profiles(id,first_name,last_name,phone_number)').order('created_at', { ascending: false });

  if (search) {
    const num = parseInt(search);
    if (!isNaN(num)) query = query.eq('id', num);
    else query = query.or(`profiles.first_name.ilike.%${search}%,profiles.last_name.ilike.%${search}%`);
  }
  if (statusFilter) query = query.eq('status', statusFilter);
  if (paymentFilter) query = query.eq('payment_method', paymentFilter);

  try {
    const { data, error } = await query;
    if (error) throw error;
    if (!data || data.length === 0) { oc.innerHTML = '<div class="empty"><h2>No orders found</h2></div>'; return; }
    let html = '<div class="table-wrap"><table><thead><tr><th>ID</th><th>Customer</th><th>Total</th><th>Status</th><th>Payment</th><th>Date</th><th>Actions</th></tr></thead><tbody>';
    for (const o of data) {
      const name = [o.profiles?.first_name, o.profiles?.last_name].filter(Boolean).join(' ') || 'Unknown';
      html += `<tr><td>#${o.id}</td><td>${esc(name)}</td><td>$${o.total_price||0}</td><td><span class="status-badge ${statusClass(o.status)}">${o.status}</span></td><td>${paymentBadge(o.payment_method)}</td><td>${shortDate(o.created_at)}</td><td><button class="btn btn-primary btn-sm" onclick="viewOrder(${o.id})">View</button></td></tr>`;
    }
    html += '</tbody></table></div>';
    oc.innerHTML = html;
  } catch (e) { showError(oc, e.message); }
}

async function viewOrder(id) {
  const { data, error } = await supabase.from('orders').select('*, profiles(id,first_name,last_name,email,phone_number), order_items(*, products(*))').eq('id', id).single();
  if (error || !data) { toast('Failed to load order', 'error'); return; }
  const o = data;
  const name = [o.profiles?.first_name, o.profiles?.last_name].filter(Boolean).join(' ') || 'Unknown';
  const items = o.order_items || [];

  const modal = ce('div', 'modal-overlay');
  modal.onclick = e => { if (e.target === modal) modal.remove(); };

  let itemsHtml = items.length
    ? '<table><thead><tr><th>Product</th><th>Qty</th><th>Price</th></tr></thead><tbody>' +
      items.map(i => `<tr><td>${esc(i.products?.name||'Product #'+i.product_id)}</td><td>${i.quantity}</td><td>$${i.products?.price||0}</td></tr>`).join('') +
      '</tbody></table>'
    : '<p>No items</p>';

  modal.innerHTML = `<div class="modal"><h2>Order #${o.id}</h2>
    <div class="form-row"><div class="form-group"><label>Customer</label><p>${esc(name)}</p></div><div class="form-group"><label>Phone</label><p>${esc(o.profiles?.phone_number||'-')}</p></div></div>
    <div class="form-row"><div class="form-group"><label>Email</label><p>${esc(o.profiles?.email||'-')}</p></div><div class="form-group"><label>Total</label><p>$${o.total_price||0}</p></div></div>
    <div class="form-row"><div class="form-group"><label>Status</label><p><span class="status-badge ${statusClass(o.status)}">${o.status}</span></p></div><div class="form-group"><label>Payment</label><p>${paymentBadge(o.payment_method)}${o.paid_at ? ' on '+shortDate(o.paid_at) : ''}</p></div></div>
    <div class="form-group"><label>Delivery</label><p>${esc(o.delivery_address||'Not set')}</p></div>
    <div class="form-group"><label>Items</label>${itemsHtml}</div>
    <div class="form-group"><label>Update Status</label>
      <select id="order-status-select">
        <option value="pending" ${o.status==='pending'?'selected':''}>Pending</option>
        <option value="confirmed" ${o.status==='confirmed'?'selected':''}>Confirmed</option>
        <option value="accepted" ${o.status==='accepted'?'selected':''}>Accepted by Driver</option>
        <option value="delivered" ${o.status==='delivered'?'selected':''}>Delivered</option>
        <option value="cancelled" ${o.status==='cancelled'?'selected':''}>Cancelled</option>
        <option value="payment_failed" ${o.status==='payment_failed'?'selected':''}>Payment Failed</option>
      </select>
    </div>
    <div class="modal-actions">
      <button class="btn btn-primary" onclick="updateOrderStatus(${o.id})">Save</button>
      <button class="btn" onclick="this.closest('.modal-overlay').remove()">Close</button>
    </div></div>`;
  document.body.appendChild(modal);
}

async function updateOrderStatus(id) {
  try {
    const { error } = await supabase.from('orders').update({ status: $('#order-status-select').value }).eq('id', id);
    if (error) throw error;
    toast('Status updated');
    document.querySelector('.modal-overlay')?.remove();
    loadOrders();
  } catch (e) { toast(e.message, 'error'); }
}

async function exportOrdersCSV() {
  try {
    const { data } = await supabase.from('orders').select('*, profiles(first_name,last_name)');
    if (!data) return;
    const rows = [['OrderID','Customer','Total','Status','Payment','PaidAt','DeliveryAddress','Date']];
    for (const o of data) {
      const name = [o.profiles?.first_name, o.profiles?.last_name].filter(Boolean).join(' ') || '';
      rows.push([o.id, name, o.total_price, o.status, o.payment_method, o.paid_at||'', o.delivery_address||'', o.created_at]);
    }
    downloadCSV('orders.csv', rows);
    toast('CSV downloaded');
  } catch (e) { toast(e.message, 'error'); }
}

// ── Products ────────────────────────────────
async function renderProducts() {
  const cont = $('#page-content');
  cont.innerHTML = '<div class="page-header"><h1>Products</h1><button class="btn btn-primary" onclick="showProductForm()">+ Add</button></div><div id="products-container"></div>';
  const pc = $('#products-container');
  showLoading(pc);
  try {
    const { data, error } = await supabase.from('products').select('*').order('id', { ascending: false });
    if (error) throw error;
    if (!data || data.length === 0) { pc.innerHTML = '<div class="empty"><h2>No products</h2></div>'; return; }
    let html = '<div class="table-wrap"><table><thead><tr><th>ID</th><th>Image</th><th>Name</th><th>Price</th><th>Category</th><th>Qty</th><th>Actions</th></tr></thead><tbody>';
    for (const p of data) {
      html += `<tr><td>#${p.id}</td><td>${p.image ? `<img src="${esc(p.image)}" style="width:40px;height:40px;object-fit:cover;border-radius:4px">` : '-'}</td><td>${esc(p.name||'')}</td><td>$${p.price||0}</td><td>${esc(p.category||'')}</td><td>${p.quantity??'-'}</td><td><button class="btn btn-primary btn-sm" onclick="showProductForm(${p.id})">Edit</button> <button class="btn btn-danger btn-sm" onclick="deleteProduct(${p.id})">Delete</button></td></tr>`;
    }
    html += '</tbody></table></div>';
    pc.innerHTML = html;
  } catch (e) { showError(pc, e.message); }
}

async function showProductForm(id = null) {
  let p = null;
  if (id) {
    const { data } = await supabase.from('products').select('*').eq('id', id).single();
    p = data;
  }
  const modal = ce('div', 'modal-overlay');
  modal.onclick = e => { if (e.target === modal) modal.remove(); };

  // Load categories for dropdown
  const { data: cats } = await supabase.from('categories').select('name');
  const catOptions = (cats||[]).map(c => `<option value="${esc(c.name)}" ${p?.category===c.name?'selected':''}>${esc(c.name)}</option>`).join('');

  modal.innerHTML = `<div class="modal"><h2>${id ? 'Edit' : 'New'} Product</h2>
    <form id="product-form">
      <div class="form-group"><label>Name</label><input type="text" id="p-name" value="${esc(p?.name||'')}" required></div>
      <div class="form-row"><div class="form-group"><label>Price ($)</label><input type="number" step="0.01" id="p-price" value="${p?.price||''}" required></div>
        <div class="form-group"><label>Qty</label><input type="number" id="p-qty" value="${p?.quantity||''}"></div></div>
      <div class="form-group"><label>Category</label>
        <select id="p-cat"><option value="">None</option>${catOptions}</select>
      </div>
      <div class="form-group"><label>Image URL</label><input type="url" id="p-img" value="${esc(p?.image||'')}"></div>
      <div class="form-group"><label>Description</label><textarea id="p-desc" rows="3">${esc(p?.description||'')}</textarea></div>
      <div class="modal-actions"><button type="submit" class="btn btn-primary">${id?'Update':'Create'}</button><button type="button" class="btn" onclick="this.closest('.modal-overlay').remove()">Cancel</button></div>
    </form></div>`;
  document.body.appendChild(modal);

  $('#product-form').onsubmit = async (e) => {
    e.preventDefault();
    const payload = { name: $('#p-name').value, price: parseFloat($('#p-price').value)||0, quantity: parseInt($('#p-qty').value)||0, category: $('#p-cat').value||null, image: $('#p-img').value||null, description: $('#p-desc').value||null };
    try {
      if (id) { const { error } = await supabase.from('products').update(payload).eq('id', id); if (error) throw error; }
      else { const { error } = await supabase.from('products').insert(payload); if (error) throw error; }
      toast(id ? 'Updated' : 'Created');
      modal.remove(); renderProducts();
    } catch (e) { toast(e.message, 'error'); }
  };
}

async function deleteProduct(id) {
  if (!confirm('Delete this product?')) return;
  try {
    const { error } = await supabase.from('products').delete().eq('id', id);
    if (error) throw error;
    toast('Deleted'); renderProducts();
  } catch (e) { toast(e.message, 'error'); }
}

// ── Categories ──────────────────────────────
async function renderCategories() {
  const cont = $('#page-content');
  cont.innerHTML = '<div class="page-header"><h1>Categories</h1><button class="btn btn-primary" onclick="showCategoryForm()">+ Add</button></div><div id="categories-container"></div>';
  const cc = $('#categories-container');
  showLoading(cc);
  try {
    const { data, error } = await supabase.from('categories').select('*').order('name');
    if (error) throw error;
    if (!data || data.length === 0) { cc.innerHTML = '<div class="empty"><h2>No categories</h2></div>'; return; }
    let html = '<div class="table-wrap"><table><thead><tr><th>Name</th><th>Products</th><th>Actions</th></tr></thead><tbody>';
    for (const c of data) {
      const { count } = await supabase.from('products').select('id', { count:'exact', head:true }).eq('category', c.name);
      html += `<tr><td>${esc(c.name)}</td><td>${count}</td><td><button class="btn btn-primary btn-sm" onclick="showCategoryForm('${esc(c.name)}')">Edit</button> <button class="btn btn-danger btn-sm" onclick="deleteCategory('${esc(c.name)}')">Delete</button></td></tr>`;
    }
    html += '</tbody></table></div>';
    cc.innerHTML = html;
  } catch (e) { showError(cc, e.message); }
}

async function showCategoryForm(name = null) {
  const modal = ce('div', 'modal-overlay');
  modal.onclick = e => { if (e.target === modal) modal.remove(); };
  modal.innerHTML = `<div class="modal"><h2>${name ? 'Edit' : 'New'} Category</h2>
    <form id="cat-form">
      <div class="form-group"><label>Name</label><input type="text" id="cat-name" value="${esc(name||'')}" required></div>
      <div class="modal-actions"><button type="submit" class="btn btn-primary">${name?'Update':'Create'}</button><button type="button" class="btn" onclick="this.closest('.modal-overlay').remove()">Cancel</button></div>
    </form></div>`;
  document.body.appendChild(modal);
  $('#cat-form').onsubmit = async (e) => {
    e.preventDefault();
    const newName = $('#cat-name').value.trim();
    if (!newName) return;
    try {
      if (name) {
        const { error: upErr } = await supabase.from('categories').update({ name: newName }).eq('name', name);
        if (upErr) throw upErr;
        // Update all products with old category name
        await supabase.from('products').update({ category: newName }).eq('category', name);
      } else {
        const { error } = await supabase.from('categories').insert({ name: newName });
        if (error) throw error;
      }
      toast(name ? 'Updated' : 'Created');
      modal.remove(); renderCategories();
    } catch (e) { toast(e.message, 'error'); }
  };
}

async function deleteCategory(name) {
  if (!confirm(`Delete category "${name}"?`)) return;
  try {
    await supabase.from('categories').delete().eq('name', name);
    await supabase.from('products').update({ category: null }).eq('category', name);
    toast('Deleted'); renderCategories();
  } catch (e) { toast(e.message, 'error'); }
}

// ── Users ───────────────────────────────────
async function renderUsers() {
  const cont = $('#page-content');
  cont.innerHTML = '<div class="page-header"><h1>Users</h1></div><div id="users-container"></div>';
  const uc = $('#users-container');
  showLoading(uc);
  try {
    const { data, error } = await supabase.from('profiles').select('*').order('created_at', { ascending: false });
    if (error) throw error;
    if (!data || data.length === 0) { uc.innerHTML = '<div class="empty"><h2>No users</h2></div>'; return; }
    let html = '<div class="table-wrap"><table><thead><tr><th>Name</th><th>Email</th><th>Phone</th><th>Address</th><th>Joined</th></tr></thead><tbody>';
    for (const u of data) {
      html += `<tr><td>${esc([u.first_name, u.last_name].filter(Boolean).join(' ')||'-')}</td><td>${esc(u.email||'-')}</td><td>${esc(u.phone_number||'-')}</td><td>${esc(u.address||'-')}</td><td>${shortDate(u.created_at)}</td></tr>`;
    }
    html += '</tbody></table></div>';
    uc.innerHTML = html;
  } catch (e) { showError(uc, e.message); }
}

// ── Drivers ─────────────────────────────────
async function renderDrivers() {
  const cont = $('#page-content');
  cont.innerHTML = '<div class="page-header"><h1>Drivers</h1></div><div id="drivers-container"></div>';
  const dc = $('#drivers-container');
  showLoading(dc);
  try {
    const { data, error } = await supabase.from('drivers').select('*, profiles(id,first_name,last_name,email,phone_number)').order('created_at', { ascending: false });
    if (error) throw error;
    if (!data || data.length === 0) { dc.innerHTML = '<div class="empty"><h2>No drivers</h2></div>'; return; }
    let html = '<div class="table-wrap"><table><thead><tr><th>Name</th><th>Email</th><th>Phone</th><th>Status</th><th>License</th><th>Joined</th><th>Actions</th></tr></thead><tbody>';
    for (const d of data) {
      const name = [d.profiles?.first_name, d.profiles?.last_name].filter(Boolean).join(' ') || 'Unknown';
      html += `<tr>
        <td>${esc(name)}</td>
        <td>${esc(d.profiles?.email||'-')}</td>
        <td>${esc(d.profiles?.phone_number||'-')}</td>
        <td><span class="status-badge ${d.is_active ? 'status-accepted' : 'status-pending'}">${d.is_active ? 'Active' : 'Inactive'}</span></td>
        <td>${esc(d.license_number||'-')}</td>
        <td>${shortDate(d.created_at)}</td>
        <td>
          ${d.license_verified !== false && !d.is_active ? `<button class="btn btn-success btn-sm" onclick="approveDriver('${d.id}')">Approve</button>` : ''}
          ${d.is_active ? `<button class="btn btn-warning btn-sm" onclick="deactivateDriver('${d.id}')">Deactivate</button>` : `<button class="btn btn-success btn-sm" onclick="approveDriver('${d.id}')">Activate</button>`}
        </td>
      </tr>`;
    }
    html += '</tbody></table></div>';
    dc.innerHTML = html;
  } catch (e) { showError(dc, e.message); }
}

async function approveDriver(id) {
  try {
    const { error } = await supabase.from('drivers').update({ is_active: true }).eq('id', id);
    if (error) throw error;
    toast('Driver approved');
    renderDrivers();
  } catch (e) { toast(e.message, 'error'); }
}

async function deactivateDriver(id) {
  try {
    const { error } = await supabase.from('drivers').update({ is_active: false }).eq('id', id);
    if (error) throw error;
    toast('Driver deactivated');
    renderDrivers();
  } catch (e) { toast(e.message, 'error'); }
}

// ── Settings ────────────────────────────────
function renderSettings() {
  $('#page-content').innerHTML = `
    <h1>Settings</h1>
    <div class="card"><h3 style="margin-bottom:8px">Supabase</h3><p>Project: <code>${SUPABASE_URL}</code></p><p style="margin-top:4px;color:var(--text-sec);font-size:13px">Secrets (Paymob keys) → Supabase Dashboard → Edge Functions → Environment Variables</p></div>
    <div class="card"><h3 style="margin-bottom:8px">Admin Emails</h3><p>${ADMIN_EMAILS.join(', ')}</p><p style="margin-top:4px;color:var(--text-sec);font-size:13px">Edit <code>ADMIN_EMAILS</code> in <code>js/app.js</code></p></div>
    <div class="card"><h3 style="margin-bottom:12px">SQL Runner</h3>
      <form id="sql-form">
        <div class="form-group"><textarea id="sql-input" rows="5" style="font-family:monospace;font-size:13px" placeholder="SELECT * FROM orders LIMIT 10"></textarea></div>
        <button type="submit" class="btn btn-primary">Run</button>
      </form>
      <div id="sql-result" style="margin-top:12px"></div>
    </div>`;
  $('#sql-form').onsubmit = async (e) => {
    e.preventDefault();
    const sql = $('#sql-input').value.trim();
    if (!sql) return;
    const res = $('#sql-result');
    res.innerHTML = '<div class="spinner"></div>';
    try {
      const { data, error } = await supabase.rpc('exec_sql', { query: sql });
      if (error) throw error;
      res.innerHTML = `<pre style="background:#F8FAFC;padding:16px;border-radius:var(--radius);overflow-x:auto;font-size:13px">${esc(JSON.stringify(data, null, 2))}</pre>`;
    } catch (e) { res.innerHTML = `<p style="color:var(--danger)">${esc(e.message)}</p>`; }
  };
}

// ── Init ────────────────────────────────────
document.addEventListener('DOMContentLoaded', () => {
  initSupabase();
  $('#login-form').addEventListener('submit', handleLogin);
  $('#logout-btn').addEventListener('click', handleLogout);
  checkSession();
});
