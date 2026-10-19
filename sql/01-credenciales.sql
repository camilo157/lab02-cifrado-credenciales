CREATE EXTENSION IF NOT EXISTS pgcrypto;

DROP TABLE IF EXISTS usuarios_insegura;
CREATE TABLE usuarios_insegura (
    id BIGSERIAL PRIMARY KEY,
    usuario VARCHAR(50) NOT NULL,
    password VARCHAR(100) NOT NULL
);

INSERT INTO usuarios_insegura (usuario, password)
VALUES ('juan', 'Password123');

SELECT * FROM usuarios_insegura;

-- misma contraseña, dos veces
SELECT crypt('Password123', gen_salt('bf'));
SELECT crypt('Password123', gen_salt('bf'));

DROP TABLE IF EXISTS usuarios_segura;
CREATE TABLE usuarios_segura (
    id BIGSERIAL PRIMARY KEY,
    usuario VARCHAR(50) UNIQUE NOT NULL,
    password_hash TEXT NOT NULL
);

INSERT INTO usuarios_segura (usuario, password_hash)
VALUES ('juan', crypt('Password123', gen_salt('bf')));

SELECT * FROM usuarios_segura;

-- contraseña correcta
SELECT usuario, password_hash = crypt('Password123', password_hash) AS correcta
FROM usuarios_segura WHERE usuario = 'juan';

-- contraseña incorrecta
SELECT usuario, password_hash = crypt('OtraPassword', password_hash) AS correcta
FROM usuarios_segura WHERE usuario = 'juan';