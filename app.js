// app.js
const express = require('express');
const client = require('prom-client');

const app = express();
const register = client.register;

// Create a counter metric
const counter = new client.Counter({
  name: 'node_app_requests_total',
  help: 'Total number of requests',
  labelNames: ['method', 'route', 'statusCode']
});

// Middleware to count requests
app.use((req, res, next) => {
  res.on('finish', () => {
    counter.labels(req.method, req.route ? req.route.path : req.path, res.statusCode).inc();
  });
  next();
});

app.get('/', (req, res) => {
  res.send('Hello from Node.js app with metrics!');
});

app.get('/metrics', async (req, res) => {
  res.set('Content-Type', register.contentType);
  res.end(await register.metrics());
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`App listening on port ${PORT}`);
});
