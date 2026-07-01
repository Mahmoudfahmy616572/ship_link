/* ============================================
   ShipLink Admin Dashboard
   ============================================ */

// ── Config ───────────────────────────────────
const SUPABASE_URL = 'https://aqxiziqybgtvrdfhmmoc.supabase.co';
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFxeGl6aXF5Ymd0dnJkZmhtbW9jIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODE3MjI5MDUsImV4cCI6MjA5NzI5ODkwNX0.vohe0h4gzDZSRttscc6c2RXREIv6Nt7WawxSoavFG6w';

let supabase;
let currentUser = null;

function initSupabase() {
  supabase = supabaseJs.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
}

// ── Auth ────────────────────────────────────
const $ = (s) => document.querySelector(s);
const $$ = (s) => document.querySelectorAll(s);
const ce = (tag, cls, html) => { const e = document.createElement(tag); if (cls) e.className = cls; if (html !== undefined) e.innerHTML = html; return e; };

// Admin emails check – adapt to your needs
const ADMIN_EMAILS = ['mahmoudfahmy616572@gmail.com']; // ← ADD YOUR EMAIL

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
      currentUser = null;
      throw new Error('Not authorized as admin');
    }
    showDashboard();
  } catch (err) {
    $('#login-error').textContent = err.message;
  } finally {
    btn.disabled = false; btn.textContent = 'Sign In';
  }
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
  $('#email').value = ''; $('#password').value = '';
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
    case 'products': renderProducts(); break;
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
  container.innerHTML = '<div class="loading-wrap"><div class="spinner"></div><p>Loading...</p></div>';
}

function showError(container, msg) {
  container.innerHTML = `<div class="empty"><p style="color:var(--danger)">${msg}</p></div>`;
}

function esc(str) { const d = document.createElement('div'); d.textContent = str; return d.innerHTML; }

function statusClass(s) {
  const m = { pending:'status-pending', confirmed:'status-confirmed', accepted:'status-accepted', delivered:'status-delivered', cancelled:'status-cancelled', payment_failed:'status-payment_failed' };
  return m[s] || 'status-pending';
}

function paymentBadge(m) {
  if (m === 'card') return '<span class="payment-badge payment-card">Card Paid</span>';
  if (m === 'cod') return '<span class="payment-badge payment-cod">Cash on Delivery</span>';
  return '';
}

function formatDate(d) {
  if (!d) return '-';
  return new Date(d).toLocaleDateString('en-US', { year:'numeric', month:'short', day:'numeric', hour:'2-digit', minute:'2-digit' });
}

// ── Overview ────────────────────────────────
async function renderOverview() {
  const cont = $('#page-content');
  cont.innerHTML = '<h1>Overview</h1>';
  try {
    const [orders, users, drivers, products] = await Promise.all([
      supabase.from('orders').select('id,status,payment_method', { count:'exact', head:false }),
      supabase.from('profiles').select('id', { count:'exact', head:false }),
      supabase.from('drivers').select('id', { count:'exact', head:false }),
      supabase.from('products').select('id', { count:'exact', head:false }),
    ]);

    const pendingOrders = orders.data?.filter(o => o.status === 'pending').length || 0;
    const cardPayments = orders.data?.filter(o => o.payment_method === 'card').length || 0;

    cont.innerHTML = `
      <div class="stats-grid">
        <div class="stat-card" style="border-left-color:var(--primary)"><h3>Total Orders</h3><div class="value">${orders.data?.length || 0}</div></div>
        <div class="stat-card" style="border-left-color:var(--warning)"><h3>Pending Orders</h3><div class="value">${pendingOrders}</div></div>
        <div class="stat-card" style="border-left-color:var(--success)"><h3>Card Payments</h3><div class="value">${cardPayments}</div></div>
        <div class="stat-card" style="border-left-color:#7C3AED"><h3>Products</h3><div class="value">${products.data?.length || 0}</div></div>
        <div class="stat-card" style="border-left-color:#8B5CF6"><h3>Users</h3><div class="value">${users.data?.length || 0}</div></div>
        <div class="stat-card" style="border-left-color:#F59E0B"><h3>Drivers</h3><div class="value">${drivers.data?.length || 0}</div></div>
      </div>
      <div class="card">
        <p>Welcome to ShipLink Admin Dashboard. Use the sidebar to manage orders, products, users, and drivers.</p>
      </div>`;
  } catch (e) { showError(cont, 'Failed to load stats: ' + e.message); }
}

// ── Orders ──────────────────────────────────
async function renderOrders(search = '') {
  const cont = $('#page-content');
  cont.innerHTML = '<div class="page-header"><h1>Orders</h1></div><div id="orders-container"></div>';
  const oc = $('#orders-container');
  showLoading(oc);

  try {
    let query = supabase.from('orders').select('*, profiles(id,first_name,last_name,phone_number)').order('created_at', { ascending: false });
    if (search) query = query.or(`id.eq.${parseInt(search)||0},profiles.first_name.ilike.%${search}%,profiles.last_name.ilike.%${search}%`);
    const { data, error } = await query;

    if (error) throw error;
    if (!data || data.length === 0) { oc.innerHTML = '<div class="empty"><h2>No orders found</h2></div>'; return; }

    let html = `<div style="margin-bottom:16px"><input type="text" id="order-search" placeholder="Search by order ID or customer name..." style="padding:10px 12px;border:1px solid var(--border);border-radius:var(--radius);width:100%;max-width:400px;font-size:14px" value="${esc(search)}"></div>
      <div class="table-wrap"><table><thead><tr>
        <th>ID</th><th>Customer</th><th>Total</th><th>Status</th><th>Payment</th><th>Date</th><th>Actions</th>
      </tr></thead><tbody>`;

    for (const o of data) {
      const name = [o.profiles?.first_name, o.profiles?.last_name].filter(Boolean).join(' ') || 'Unknown';
      html += `<tr>
        <td>#${o.id}</td>
        <td>${esc(name)}</td>
        <td>$${o.total_price || 0}</td>
        <td><span class="status-badge ${statusClass(o.status)}">${o.status}</span></td>
        <td>${paymentBadge(o.payment_method)}</td>
        <td>${formatDate(o.created_at)}</td>
        <td><button class="btn btn-primary btn-sm" onclick="viewOrder(${o.id})">View</button></td>
      </tr>`;
    }
    html += '</tbody></table></div>';
    oc.innerHTML = html;

    $('#order-search')?.addEventListener('input', e => {
      clearTimeout(window._orderSearchDelay);
      window._orderSearchDelay = setTimeout(() => renderOrders(e.target.value), 400);
    });
  } catch (e) { showError(oc, 'Failed to load orders: ' + e.message); }
}

async function viewOrder(id) {
  const { data, error } = await supabase.from('orders').select('*, profiles(id,first_name,last_name,email,phone_number), order_items(*, products(*))').eq('id', id).single();
  if (error || !data) { toast('Failed to load order', 'error'); return; }
  const o = data;
  const name = [o.profiles?.first_name, o.profiles?.last_name].filter(Boolean).join(' ') || 'Unknown';
  const items = o.order_items || [];

  const modal = ce('div', 'modal-overlay');
  modal.onclick = e => { if (e.target === modal) modal.remove(); };

  let itemsHtml = items.length ? '<table><thead><tr><th>Product</th><th>Qty</th><th>Price</th></tr></thead><tbody>' +
    items.map(i => `<tr><td>${esc(i.products?.name || 'Product #'+i.product_id)}</td><td>${i.quantity}</td><td>$${i.products?.price || 0}</td></tr>`).join('') +
    '</tbody></table>' : '<p>No items</p>';

  modal.innerHTML = `<div class="modal"><h2>Order #${o.id}</h2>
    <div class="form-row">
      <div class="form-group"><label>Customer</label><p>${esc(name)}</p></div>
      <div class="form-group"><label>Phone</label><p>${esc(o.profiles?.phone_number||'-')}</p></div>
    </div>
    <div class="form-row">
      <div class="form-group"><label>Email</label><p>${esc(o.profiles?.email||'-')}</p></div>
      <div class="form-group"><label>Total</label><p>$${o.total_price||0}</p></div>
    </div>
    <div class="form-row">
      <div class="form-group"><label>Status</label><p><span class="status-badge ${statusClass(o.status)}">${o.status}</span></p></div>
      <div class="form-group"><label>Payment</label><p>${paymentBadge(o.payment_method)}${o.paid_at ? ' on '+formatDate(o.paid_at) : ''}</p></div>
    </div>
    <div class="form-group"><label>Delivery Address</label><p>${esc(o.delivery_address||'Not set')}</p></div>
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
      <button class="btn btn-primary" onclick="updateOrderStatus(${o.id})">Save Status</button>
      <button class="btn" onclick="this.closest('.modal-overlay').remove()">Close</button>
    </div></div>`;
  document.body.appendChild(modal);
}

async function updateOrderStatus(id) {
  const status = $('#order-status-select').value;
  try {
    const { error } = await supabase.from('orders').update({ status }).eq('id', id);
    if (error) throw error;
    toast('Order status updated');
    document.querySelector('.modal-overlay')?.remove();
    renderOrders();
  } catch (e) { toast(e.message, 'error'); }
}

// ── Products ────────────────────────────────
async function renderProducts() {
  const cont = $('#page-content');
  cont.innerHTML = '<div class="page-header"><h1>Products</h1><button class="btn btn-primary" onclick="showProductForm()">+ Add Product</button></div><div id="products-container"></div>';
  const pc = $('#products-container');
  showLoading(pc);

  try {
    const { data, error } = await supabase.from('products').select('*').order('id', { ascending: false });
    if (error) throw error;
    if (!data || data.length === 0) { pc.innerHTML = '<div class="empty"><h2>No products yet</h2></div>'; return; }

    let html = '<div class="table-wrap"><table><thead><tr><th>ID</th><th>Image</th><th>Name</th><th>Price</th><th>Category</th><th>Actions</th></tr></thead><tbody>';
    for (const p of data) {
      html += `<tr>
        <td>#${p.id}</td>
        <td>${p.image ? `<img src="${esc(p.image)}" style="width:40px;height:40px;object-fit:cover;border-radius:4px">` : '-'}</td>
        <td>${esc(p.name||'')}</td>
        <td>$${p.price||0}</td>
        <td>${esc(p.category||'')}</td>
        <td>
          <button class="btn btn-primary btn-sm" onclick="showProductForm(${p.id})">Edit</button>
          <button class="btn btn-danger btn-sm" onclick="deleteProduct(${p.id})">Delete</button>
        </td>
      </tr>`;
    }
    html += '</tbody></table></div>';
    pc.innerHTML = html;
  } catch (e) { showError(pc, 'Failed to load products: ' + e.message); }
}

async function showProductForm(id = null) {
  let product = null;
  if (id) {
    const { data } = await supabase.from('products').select('*').eq('id', id).single();
    product = data;
  }

  const modal = ce('div', 'modal-overlay');
  modal.onclick = e => { if (e.target === modal) modal.remove(); };
  modal.innerHTML = `<div class="modal">
    <h2>${id ? 'Edit Product' : 'Add Product'}</h2>
    <form id="product-form">
      <div class="form-group"><label>Product Name</label><input type="text" id="p-name" value="${esc(product?.name||'')}" required></div>
      <div class="form-row">
        <div class="form-group"><label>Price ($)</label><input type="number" step="0.01" id="p-price" value="${product?.price||''}" required></div>
        <div class="form-group"><label>Quantity</label><input type="number" id="p-qty" value="${product?.quantity||''}"></div>
      </div>
      <div class="form-group"><label>Category</label><input type="text" id="p-cat" value="${esc(product?.category||'')}"></div>
      <div class="form-group"><label>Image URL</label><input type="url" id="p-img" value="${esc(product?.image||'')}"></div>
      <div class="form-group"><label>Description</label><textarea id="p-desc" rows="3">${esc(product?.description||'')}</textarea></div>
      <div class="modal-actions">
        <button type="submit" class="btn btn-primary">${id ? 'Update' : 'Create'}</button>
        <button type="button" class="btn" onclick="this.closest('.modal-overlay').remove()">Cancel</button>
      </div>
    </form></div>`;
  document.body.appendChild(modal);

  $('#product-form').onsubmit = async (e) => {
    e.preventDefault();
    const payload = {
      name: $('#p-name').value,
      price: parseFloat($('#p-price').value) || 0,
      quantity: parseInt($('#p-qty').value) || 0,
      category: $('#p-cat').value || null,
      image: $('#p-img').value || null,
      description: $('#p-desc').value || null,
    };
    try {
      if (id) {
        const { error } = await supabase.from('products').update(payload).eq('id', id);
        if (error) throw error;
      } else {
        const { error } = await supabase.from('products').insert(payload);
        if (error) throw error;
      }
      toast(id ? 'Product updated' : 'Product created');
      modal.remove();
      renderProducts();
    } catch (e) { toast(e.message, 'error'); }
  };
}

async function deleteProduct(id) {
  if (!confirm('Delete this product?')) return;
  try {
    const { error } = await supabase.from('products').delete().eq('id', id);
    if (error) throw error;
    toast('Product deleted');
    renderProducts();
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
    if (!data || data.length === 0) { uc.innerHTML = '<div class="empty"><h2>No users found</h2></div>'; return; }

    let html = '<div class="table-wrap"><table><thead><tr><th>Name</th><th>Email</th><th>Phone</th><th>Joined</th></tr></thead><tbody>';
    for (const u of data) {
      html += `<tr>
        <td>${esc([u.first_name, u.last_name].filter(Boolean).join(' ')||'-')}</td>
        <td>${esc(u.email||'-')}</td>
        <td>${esc(u.phone_number||'-')}</td>
        <td>${formatDate(u.created_at)}</td>
      </tr>`;
    }
    html += '</tbody></table></div>';
    uc.innerHTML = html;
  } catch (e) { showError(uc, 'Failed to load users: ' + e.message); }
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
    if (!data || data.length === 0) { dc.innerHTML = '<div class="empty"><h2>No drivers found</h2></div>'; return; }

    let html = '<div class="table-wrap"><table><thead><tr><th>Name</th><th>Phone</th><th>Email</th><th>Status</th><th>License</th><th>Joined</th></tr></thead><tbody>';
    for (const d of data) {
      const name = [d.profiles?.first_name, d.profiles?.last_name].filter(Boolean).join(' ') || 'Unknown';
      html += `<tr>
        <td>${esc(name)}</td>
        <td>${esc(d.profiles?.phone_number||'-')}</td>
        <td>${esc(d.profiles?.email||'-')}</td>
        <td><span class="status-badge ${d.is_active ? 'status-accepted' : 'status-pending'}">${d.is_active ? 'Active' : 'Inactive'}</span></td>
        <td>${d.license_number ? esc(d.license_number) : '-'}</td>
        <td>${formatDate(d.created_at)}</td>
      </tr>`;
    }
    html += '</tbody></table></div>';
    dc.innerHTML = html;
  } catch (e) { showError(dc, 'Failed to load drivers: ' + e.message); }
}

// ── Settings ────────────────────────────────
function renderSettings() {
  $('#page-content').innerHTML = `
    <h1>Settings</h1>
    <div class="card">
      <h3 style="margin-bottom:12px">Supabase Configuration</h3>
      <p><strong>Project URL:</strong> ${SUPABASE_URL}</p>
      <p style="margin-top:8px;color:var(--text-sec);font-size:13px">Configure secrets (Paymob API, etc.) in Supabase Dashboard → Edge Functions → Environment Variables.</p>
    </div>
    <div class="card">
      <h3 style="margin-bottom:12px">Admin Access</h3>
      <p>Authorized admin emails: <strong>${ADMIN_EMAILS.join(', ')}</strong></p>
      <p style="margin-top:8px;color:var(--text-sec);font-size:13px">To add more admins, edit the <code>ADMIN_EMAILS</code> array in <code>js/app.js</code>.</p>
    </div>
    <div class="card">
      <h3 style="margin-bottom:12px">SQL Runner</h3>
      <p style="margin-bottom:12px;color:var(--text-sec)">Run SQL queries directly against your database.</p>
      <form id="sql-form">
        <div class="form-group"><textarea id="sql-input" rows="6" style="font-family:monospace;font-size:13px" placeholder="SELECT * FROM orders LIMIT 10"></textarea></div>
        <button type="submit" class="btn btn-primary">Run SQL</button>
      </form>
      <div id="sql-result" style="margin-top:16px"></div>
    </div>`;

  $('#sql-form').onsubmit = async (e) => {
    e.preventDefault();
    const sql = $('#sql-input').value.trim();
    if (!sql) return;
    const result = $('#sql-result');
    result.innerHTML = '<div class="spinner"></div>';
    try {
      const { data, error } = await supabase.rpc('exec_sql', { query: sql });
      if (error) throw error;
      result.innerHTML = `<pre style="background:#F8FAFC;padding:16px;border-radius:var(--radius);overflow-x:auto;font-size:13px">${esc(JSON.stringify(data, null, 2))}</pre>`;
    } catch (e) {
      result.innerHTML = `<p style="color:var(--danger)">${esc(e.message)}</p>`;
    }
  };
}

// ── Init ────────────────────────────────────
document.addEventListener('DOMContentLoaded', () => {
  initSupabase();

  if (window.location.hostname === 'localhost' || window.location.hostname === '127.0.0.1') {
    console.log('Admin Dashboard running locally');
  }

  $('#login-form').addEventListener('submit', handleLogin);
  $('#logout-btn').addEventListener('click', handleLogout);

  checkSession();
});
