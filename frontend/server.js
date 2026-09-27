// Frontend service - shows "Frontend is Live" and the live status of all 4 backend services.
// No external packages needed: uses Node's built-in http module and fetch (Node 18+).
const http = require('http');

const PORT = process.env.PORT || 3000;

// Where to find each backend. Inside Docker, containers on the same network
// can reach each other by container name (e.g. http://user-service:3001).
const SERVICES = [
  { key: 'users',    name: 'User service',     url: process.env.USER_SERVICE_URL     || 'http://user-service:3001',     dataPath: '/users' },
  { key: 'products', name: 'Products service', url: process.env.PRODUCTS_SERVICE_URL || 'http://products-service:3002', dataPath: '/products' },
  { key: 'orders',   name: 'Orders service',   url: process.env.ORDERS_SERVICE_URL   || 'http://orders-service:3003',   dataPath: '/orders' },
  { key: 'cart',     name: 'Cart service',     url: process.env.CART_SERVICE_URL     || 'http://cart-service:3004',     dataPath: '/cart' },
];

// Call a backend URL and return { ok, body }. Never throws.
async function callService(url) {
  try {
    const res = await fetch(url, { signal: AbortSignal.timeout(2000) });
    const body = await res.json();
    return { ok: res.ok, body };
  } catch (err) {
    return { ok: false, body: { error: err.message } };
  }
}

function escapeHtml(text) {
  return String(text)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;');
}

function renderPage(results) {
  const upCount = results.filter((r) => r.ok).length;
  const rows = results.map(({ service, ok, body }) => `
        <li class="svc ${ok ? 'up' : 'down'}">
          <span class="dot" aria-hidden="true"></span>
          <div class="svc-main">
            <strong>${escapeHtml(service.name)}</strong>
            <span class="msg">${escapeHtml(ok ? body.message : 'Not reachable: ' + (body.error || 'unknown error'))}</span>
          </div>
          <span class="state">${ok ? 'Running' : 'Down'}</span>
          <a class="data" href="/api/${service.key}">View data</a>
        </li>`).join('');

  return `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>ShopEasy - Frontend is Live</title>
  <style>
    :root {
      --bg: #e9f0ee; --panel: #ffffff; --ink: #1d2b30; --muted: #5a6b70;
      --up: #0e7a67; --down: #b42318; --line: #c9d6d2;
    }
    @media (prefers-color-scheme: dark) {
      :root { --bg: #13201f; --panel: #1b2c2a; --ink: #e6efec; --muted: #9db0ab; --up: #3cc4a8; --down: #f97066; --line: #2c4441; }
    }
    * { box-sizing: border-box; }
    body { margin: 0; background: var(--bg); color: var(--ink);
           font-family: "Avenir Next", "Segoe UI", Ubuntu, Roboto, sans-serif; line-height: 1.5; }
    main { max-width: 760px; margin: 0 auto; padding: 48px 20px 64px; }
    .brand { font-size: 1rem; color: var(--muted); margin: 0 0 8px; }
    h1 { font-size: clamp(2.4rem, 7vw, 4rem); line-height: 1.05; margin: 0 0 12px; letter-spacing: -0.02em; }
    .lead { font-size: 1.1rem; color: var(--muted); margin: 0 0 36px; max-width: 60ch; }
    .summary { font-weight: 600; margin: 0 0 12px; }
    ul { list-style: none; padding: 0; margin: 0; background: var(--panel); border: 1px solid var(--line); border-radius: 14px; }
    .svc { display: grid; grid-template-columns: 14px 1fr auto auto; gap: 14px; align-items: center; padding: 16px 18px; }
    .svc + .svc { border-top: 1px solid var(--line); }
    .dot { width: 12px; height: 12px; border-radius: 50%; background: var(--up); box-shadow: 0 0 0 4px color-mix(in srgb, var(--up) 20%, transparent); }
    .down .dot { background: var(--down); box-shadow: 0 0 0 4px color-mix(in srgb, var(--down) 20%, transparent); }
    .svc-main { display: flex; flex-direction: column; min-width: 0; }
    .msg { color: var(--muted); font-size: 0.92rem; overflow-wrap: anywhere; }
    .state { font-weight: 600; color: var(--up); }
    .down .state { color: var(--down); }
    .data { color: var(--ink); font-size: 0.92rem; }
    .data:focus-visible { outline: 3px solid var(--up); outline-offset: 3px; border-radius: 4px; }
    footer { margin-top: 28px; color: var(--muted); font-size: 0.9rem; }
    @media (max-width: 520px) {
      .svc { grid-template-columns: 14px 1fr auto; }
      .data { grid-column: 2 / -1; }
    }
  </style>
</head>
<body>
  <main>
    <p class="brand">ShopEasy</p>
    <h1>Frontend is Live</h1>
    <p class="lead">This page is served by the frontend Docker container. It just checked each backend container over the private Docker network.</p>
    <p class="summary">${upCount} of ${results.length} backend services running</p>
    <ul>${rows}
    </ul>
    <footer>Checked at ${new Date().toUTCString()}. Refresh the page to check again.</footer>
  </main>
</body>
</html>`;
}

const server = http.createServer(async (req, res) => {
  const path = new URL(req.url, 'http://localhost').pathname;
  console.log(`[${new Date().toISOString()}] ${req.method} ${path}`);

  // Homepage: check every backend, then show the status page
  if (path === '/') {
    const results = await Promise.all(
      SERVICES.map(async (service) => ({ service, ...(await callService(service.url + '/')) }))
    );
    res.writeHead(200, { 'Content-Type': 'text/html; charset=utf-8' });
    return res.end(renderPage(results));
  }

  if (path === '/health') {
    res.writeHead(200, { 'Content-Type': 'application/json' });
    return res.end(JSON.stringify({ service: 'frontend', status: 'UP' }));
  }

  // /api/users, /api/products, /api/orders, /api/cart -> fetch data from that backend
  const match = path.match(/^\/api\/(\w+)$/);
  const service = match && SERVICES.find((s) => s.key === match[1]);
  if (service) {
    const { ok, body } = await callService(service.url + service.dataPath);
    res.writeHead(ok ? 200 : 502, { 'Content-Type': 'application/json' });
    return res.end(JSON.stringify(body, null, 2));
  }

  res.writeHead(404, { 'Content-Type': 'text/plain' });
  res.end('Page not found');
});

server.listen(PORT, '0.0.0.0', () => {
  console.log(`Frontend is Live on port ${PORT}`);
});
