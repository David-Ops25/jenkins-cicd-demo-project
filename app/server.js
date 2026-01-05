const http = require("http");

const PORT = process.env.PORT || 3000;

http.createServer((req, res) => {
  res.writeHead(200, { "Content-Type": "application/json" });
  res.end(JSON.stringify({
    message: "Hello from jenkins-cicd-demo 🚀",
    path: req.url,
    time: new Date().toISOString()
  }));
}).listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});

