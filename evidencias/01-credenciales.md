# 01 - Protección de credenciales

Camilo Angulo | LAB-02 | 18 de octubre de 2026

## Objetivo

Ver por qué una contraseña no debe guardarse en texto claro y probar cómo se protege con crypt() y gen_salt() de pgcrypto.

## Comando o procedimiento

Corrí el script sql/01-credenciales.sql en el contenedor de PostgreSQL 16:

```
docker exec -it pg-lab01 psql -U postgres -a -f /lab02/01-credenciales.sql
```

El script crea una tabla insegura (usuarios_insegura) con la contraseña en texto claro y otra (usuarios_segura) que solo guarda el hash. También genera dos hashes de la misma contraseña y verifica una contraseña correcta y una incorrecta.

## Resultado obtenido

Tabla insegura:

```
 id | usuario |  password
----+---------+-------------
  1 | juan    | Password123
```

La misma contraseña con crypt() y gen_salt('bf'), dos veces:

```
$2a$06$LbB26PGurGLIGL2nLcxjHecqupD3jKgj7sSy3HGMsVHubKHGMSDcC
$2a$06$j1FenZjV4SrCvbQDm.mm9.8yFL0qu9d8nceghccJFMHZnrKs9OsZy
```

Tabla segura:

```
 id | usuario |                        password_hash
----+---------+--------------------------------------------------------------
  1 | juan    | $2a$06$7cfVzzk4jazwXrfdZCCVPeIKoQyK5xNFFECUmxS6GRIRxI89oGrXe
```

Verificación:

```
contraseña correcta (Password123)   -> t
contraseña incorrecta (OtraPassword) -> f
```

## Análisis

Si alguien tiene acceso de lectura a usuarios_insegura ve la contraseña de juan tal cual. Una filtración de la base se vuelve una filtración de credenciales, y como mucha gente repite sus contraseñas, el daño pasa a otros sistemas.

Los dos hashes salieron distintos aunque la contraseña era la misma. Esto es por la sal: gen_salt() genera un valor aleatorio nuevo cada vez y crypt() lo combina con la contraseña para calcular el hash. Por eso dos usuarios con la misma contraseña no tienen el mismo hash, y se complican los ataques con tablas ya calculadas. La sal queda guardada dentro del propio hash, y por eso para verificar se usa crypt('Password123', password_hash): toma la sal del hash guardado y vuelve a calcular.

Esto no es un cifrado reversible. No existe un paso para recuperar la contraseña original a partir del hash, y no hace falta, porque solo se necesita comprobar que la contraseña que escribe el usuario produce el mismo hash. Con la correcta dio t y con la incorrecta f.

Algo que noté es que los hashes empiezan con $2a$06$: es bcrypt con costo 6, que es el valor por defecto de gen_salt('bf'). Para el laboratorio sirve, pero en un sistema real se usaría un costo más alto o un algoritmo como Argon2id, como dice la sección 7.6 de la práctica.

## Conclusión

Una contraseña no se guarda ni se cifra para poder recuperarla: se guarda un hash con sal y se compara. Un hash y un cifrado son cosas distintas.