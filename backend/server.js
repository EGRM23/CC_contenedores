const express = require("express");
const mysql = require("mysql2");
const cors = require('cors');

const app = express();
const port = 3000;

// ESTA OPCIÓN PUEDE MANEJARSE MUY BIEN CON UN INGRESS, PERO AGREGA COMPLEJIDAD
// app.use(cors({
//   origin: ['http://miapp.local', 'http://localhost', 'http://frontend'],
//   methods: ['GET', 'POST', 'PUT', 'DELETE'],
//   allowedHeaders: ['Content-Type', 'Authorization'],
//   credentials: true
// }));
// app.use(express.json());

app.use(cors());

const pool = mysql.createPool({
  host: "db",
  user: "root",
  password: "rootpassword",
  database: "testdb",
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0,
  ssl: false,
  insecureAuth: true
});

pool.getConnection((err, connection) => {
  if (err) {
    console.error("=== ERROR DETALLADO DE CONEXIÓN ===");
    console.error("Timestamp:", new Date().toISOString());
    console.error("Mensaje:", err.message);
    console.error("Código:", err.code);
    console.error("Errno:", err.errno);
    console.error("SQL State:", err.sqlState);
    console.error("Stack:", err.stack);
    
    // Debug de configuración
    console.error("Config host:", pool.config.connectionConfig.host);
    console.error("Config user:", pool.config.connectionConfig.user);
    console.error("Config database:", pool.config.connectionConfig.database);
    console.error("=== FIN ERROR ===");
    
    return;
  }
  console.log("✅ CONEXION A MySQL ACTIVA! (Pool creado)");
  connection.release();
});

app.get("/", (req, res) => {
  res.send("EL BACKEND TIENE VIDA (MUY INSEGURO PERO CON VIDA :D)! Con Node.js y Connection Pooling");
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

app.listen(port, "0.0.0.0", () => {
  console.log(`SERVIDOR BACKEND EN http://0.0.0.0:${port}`);
});

process.on('SIGINT', () => {
  pool.end();
  process.exit();
});
