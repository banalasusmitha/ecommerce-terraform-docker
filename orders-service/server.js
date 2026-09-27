// Orders Service - a tiny backend microservice (no external packages needed)
const http = require('http');

const PORT = process.env.PORT || 3003;
const SERVICE_NAME = 'orders-service';

// Sample data returned by GET /orders
const data = [
  { orderId: 5001, userId: 1, items: [101, 103], total: 2098, status: 'SHIPPED' },
  { orderId: 5002, userId: 2, items: [102], total: 3499, status: 'PROCESSING' }
];

function send(res, statusCode, body) {
  res.writeHead(statusCode, { 'Content-Type': 'application/json' });
  res.end(JSON.stringify(body));
}

const server = http.createServer((req, res) => {
  const path = new URL(req.url, 'http://localhost').pathname;
  console.log(`[${new Date().toISOString()}] ${req.method} ${path}`);

  if (path === '/') {
    return send(res, 200, { service: SERVICE_NAME, message: 'Orders Service Running', port: Number(PORT) });
  }
  if (path === '/health') {
    return send(res, 200, { service: SERVICE_NAME, status: 'UP' });
  }
  if (path === '/orders') {
    return send(res, 200, data);
  }
  return send(res, 404, { error: 'Route not found', path });
});

server.listen(PORT, '0.0.0.0', () => {
  console.log(`Orders Service Running on port ${PORT}`);
});
