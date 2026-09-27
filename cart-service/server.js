// Cart Service - a tiny backend microservice (no external packages needed)
const http = require('http');

const PORT = process.env.PORT || 3004;
const SERVICE_NAME = 'cart-service';

// Sample data returned by GET /cart
const data = {
  userId: 1,
  items: [{ productId: 102, quantity: 1 }],
  total: 3499
};

function send(res, statusCode, body) {
  res.writeHead(statusCode, { 'Content-Type': 'application/json' });
  res.end(JSON.stringify(body));
}

const server = http.createServer((req, res) => {
  const path = new URL(req.url, 'http://localhost').pathname;
  console.log(`[${new Date().toISOString()}] ${req.method} ${path}`);

  if (path === '/') {
    return send(res, 200, { service: SERVICE_NAME, message: 'Cart Service Running', port: Number(PORT) });
  }
  if (path === '/health') {
    return send(res, 200, { service: SERVICE_NAME, status: 'UP' });
  }
  if (path === '/cart') {
    return send(res, 200, data);
  }
  return send(res, 404, { error: 'Route not found', path });
});

server.listen(PORT, '0.0.0.0', () => {
  console.log(`Cart Service Running on port ${PORT}`);
});
