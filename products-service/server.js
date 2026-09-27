// Products Service - a tiny backend microservice (no external packages needed)
const http = require('http');

const PORT = process.env.PORT || 3002;
const SERVICE_NAME = 'products-service';

// Sample data returned by GET /products
const data = [
  { id: 101, name: 'Wireless Mouse', price: 799 },
  { id: 102, name: 'Mechanical Keyboard', price: 3499 },
  { id: 103, name: 'USB-C Hub', price: 1299 }
];

function send(res, statusCode, body) {
  res.writeHead(statusCode, { 'Content-Type': 'application/json' });
  res.end(JSON.stringify(body));
}

const server = http.createServer((req, res) => {
  const path = new URL(req.url, 'http://localhost').pathname;
  console.log(`[${new Date().toISOString()}] ${req.method} ${path}`);

  if (path === '/') {
    return send(res, 200, { service: SERVICE_NAME, message: 'Products Service Running', port: Number(PORT) });
  }
  if (path === '/health') {
    return send(res, 200, { service: SERVICE_NAME, status: 'UP' });
  }
  if (path === '/products') {
    return send(res, 200, data);
  }
  return send(res, 404, { error: 'Route not found', path });
});

server.listen(PORT, '0.0.0.0', () => {
  console.log(`Products Service Running on port ${PORT}`);
});
