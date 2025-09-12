const http = require('http');
const fs = require('fs');
const path = require('path');
const url = require('url');

const port = process.env.CSP_PORT || 4244;
const types = {
  html: 'text/html; charset=utf-8',
  css: 'text/css; charset=utf-8',
  js: 'application/javascript; charset=utf-8',
  svg: 'image/svg+xml',
  png: 'image/png',
  jpg: 'image/jpeg',
  jpeg: 'image/jpeg',
};

const csp =
  "default-src 'self'; img-src 'self' data: https:; script-src 'self' https://www.clarity.ms; style-src 'self' 'unsafe-inline'; frame-src https://www.canva.com; connect-src 'self' https://www.clarity.ms; font-src 'self' data:";
const headers = {
  'Content-Security-Policy': csp,
  'Referrer-Policy': 'strict-origin-when-cross-origin',
  'X-Content-Type-Options': 'nosniff',
  'Permissions-Policy': 'geolocation=(), camera=(), microphone=()',
};

http
  .createServer((req, res) => {
    const parsed = url.parse(req.url);
    let pathname = decodeURIComponent(parsed.pathname || '/');
    if (pathname === '/') pathname = '/index.html';
    const filePath = path.join(process.cwd(), pathname);
    fs.readFile(filePath, (err, data) => {
      if (err) {
        res.writeHead(404, headers);
        res.end('Not found');
        return;
      }
      const ext = path.extname(filePath).slice(1);
      const type = types[ext] || 'application/octet-stream';
      res.writeHead(200, { 'Content-Type': type, ...headers });
      res.end(data);
    });
  })
  .listen(port, () => console.log(`CSP static server on http://localhost:${port}`));
