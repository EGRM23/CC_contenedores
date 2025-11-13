SELECT '=== EJECUTANDO INIT.SQL ===' as log_message;

CREATE DATABASE IF NOT EXISTS testdb;
USE testdb;

CREATE TABLE IF NOT EXISTS users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(50),
  email VARCHAR(100)
);

INSERT INTO users (name, email) VALUES
('Eduardo', 'eduardo@intento.com'),
('German', 'german@intento.com');

SELECT '=== INIT.SQL COMPLETADO ===' as log_message;