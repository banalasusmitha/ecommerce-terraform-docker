// User Service - a tiny backend microservice (no external packages needed)
const http = require('http');

const PORT = process.env.PORT || 3001;
const SERVICE_NAME = 'user-service';

// Sample data returned by GET /users
const data = [
  { id: 1, name: 'Asha Rao', email: 'asha@example.com' },
  { id: 2, name: 'Rahul Verma', email: 'rahul@example.com' }
];

function send(res, statusCode, body) {
  res.writeHead(statusCode, { 'Content-Type': 'application/json' });
  res.end(JSON.stringify(body));
}

const server = http.createServer((req, res) => {
  const path = new URL(req.url, 'http://localhost').pathname;
  console.log(`[${new Date().toISOString()}] ${req.method} ${path}`);

  if (path === '/') {
    return send(res, 200, { service: SERVICE_NAME, message: 'User Service Running', port: Number(PORT) });
  }
  if (path === '/health') {
    return send(res, 200, { service: SERVICE_NAME, status: 'UP' });
  }
  if (path === '/users') {
    return send(res, 200, data);
  }
  return send(res, 404, { error: 'Route not found', path });
});

server.listen(PORT, '0.0.0.0', () => {
  console.log(`User Service Running on port ${PORT}`);
});
