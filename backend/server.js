const express = require("express");
const mysql = require("mysql2");
const cors = require('cors');

const app = express();
const port = 3000;

app.use(cors());
app.use(express.json());

const pool = mysql.createPool({
  host: "db",
  user: "root",
  password: "rootpassword",
  database: "testdb",
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0,
  reconnect: true
});

pool.getConnection((err, connection) => {
  if (err) {
    console.error("ERROR AL CONECTAR CON LA DB:", err.message);
    console.log("Reintentando automáticamente...");
    return;
  }
  console.log("CONEXION A MySQL ACTIVA! (Pool creado)");
  connection.release();
});

app.get("/", (req, res) => {
  res.send("EL BACKEND TIENE VIDA! Con Node.js y Connection Pooling");
});

app.get("/users", (req, res) => {
  pool.query("SELECT * FROM users", (err, results) => {
    if (err) {
      console.error(err);
      res.status(500).json({ error: "ERROR DE CONSULTA EN LA DB" });
      return;
    }
    res.json(results);
  });
});

app.listen(port, () => {
  console.log(`SERVIDOR BACKEND EN http://localhost:${port}`);
});

process.on('SIGINT', () => {
  pool.end();
  process.exit();
});
