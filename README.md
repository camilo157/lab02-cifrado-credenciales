# LAB-02: Cifrado, credenciales y comunicaciones seguras

- Estudiante: Camilo Angulo
- Materia: Gestión de Seguridad y Desempeño de Bases de Datos, Unidad II (tema 2.4)
- Motor: PostgreSQL 16 en Docker
- Fecha: 18 de octubre de 2026

## Contenido

- sql/: los tres scripts de la práctica (01-credenciales, 02-cifrado-datos y 03-verificacion-tls).
- evidencias/: las evidencias en texto, una por actividad (01, 02, 03, 04, 07, 08 y 10).

## Cómo ejecutarlo

Levanté PostgreSQL 16 con Docker (la contraseña del contenedor es de laboratorio y no la pongo aquí):

```
docker run -d --name pg-lab01 -e POSTGRES_PASSWORD=<contraseña-de-laboratorio> -p 5432:5432 postgres:16
docker exec pg-lab01 mkdir -p /lab02
docker cp sql/. pg-lab01:/lab02
docker exec -it pg-lab01 psql -U postgres -a -f /lab02/01-credenciales.sql
```

Los demás scripts se corren igual cambiando el nombre. Para TLS, los pasos de certificado y activación están en evidencias/04-tls.md.

## 1. Introducción

La protección de una base de datos no termina con usuarios y permisos. En este laboratorio trabajé tres problemas: cómo guardar contraseñas, cómo proteger un dato sensible (el RFC) y cómo proteger la comunicación entre el cliente y PostgreSQL, además de por qué hay que cuidar las claves.

## 2. Protección de credenciales

Una contraseña en texto claro la puede leer cualquiera que tenga acceso a la tabla. Un hash con sal, hecho con crypt() y gen_salt('bf'), no se puede revertir, y la sal hace que la misma contraseña genere hashes distintos. Para verificar no se recupera la contraseña, se vuelve a calcular el hash y se compara. Un cifrado, en cambio, sí se puede revertir con la clave, por eso no es lo adecuado para contraseñas.

## 3. Protección de datos sensibles

Protegí el RFC con cifrado simétrico (pgp_sym_encrypt) porque es un dato que sí hay que poder leer en algún momento. En la tabla solo se ve una cadena de bytes, se recupera con la clave correcta y con otra clave sale un error.

## 4. TLS

TLS protege los datos mientras viajan por la red: confidencialidad, integridad y autenticación del servidor. Verifiqué en PostgreSQL que al inicio ssl estaba apagado, lo activé con un certificado autofirmado y comprobé con pg_stat_ssl que la conexión usaba TLS 1.3 con TLS_AES_256_GCM_SHA384. También probé verify-full, que funcionó con localhost y falló con 127.0.0.1 por no coincidir el nombre del certificado.

## 5. Gestión de claves

Una clave escrita en un script o en un repositorio queda expuesta, y borrarla después no basta porque el historial la conserva. Por eso las claves no deben guardarse junto con los scripts ni con los datos que cifran, sino en un gestor de secretos, con acceso limitado y rotación. En la práctica solo usé claves ficticias.

## 6. Resultados

- Con la tabla segura, la contraseña no aparece y la verificación da t con la correcta y f con la incorrecta.
- El RFC cifrado no es legible y solo se recupera con la clave correcta.
- TLS pasó de off a on, y la sesión usó TLSv1.3.
- verify-full rechazó una conexión cuyo nombre no coincidía con el certificado.
- La búsqueda de secretos solo encontró valores ficticios de laboratorio.

## 7. Problemas encontrados

- Al empezar, el contenedor estaba detenido (Exited) y tuve que arrancarlo con docker start.
- El PostgreSQL de Docker trae TLS apagado, así que no había nada que verificar hasta crear el certificado y activarlo.
- Escribí por error una consulta SQL directamente en la terminal de Windows, que no la reconoce; tenía que ir dentro de un archivo .sql.

## 8. Conclusiones

Aprendí que cada problema tiene su mecanismo: hash para contraseñas, cifrado para datos que hay que recuperar y TLS para la red, y que ninguno sustituye a los demás ni al control de acceso. También que la clave pesa tanto como el algoritmo. En un entorno productivo usaría un hash fuerte para contraseñas, cifrado para los datos sensibles y los respaldos, TLS con verify-full y un certificado de una autoridad confiable (con hostssl para obligar a usarlo), y un gestor de secretos para las claves.

## 9. Preguntas de reflexión

1. Una contraseña en texto claro la puede leer cualquiera que acceda a la tabla, a un respaldo o a una filtración, y la puede usar directamente.
2. Porque un hash no se puede revertir y se usa para comparar, mientras que el cifrado se puede revertir con la clave.
3. Porque quien tenga acceso y la clave puede leer el dato, y el cifrado no decide quién puede consultar la tabla ni qué puede hacer.
4. Porque TLS protege el trayecto, pero no decide qué puede hacer cada usuario una vez conectado.
5. Los datos cifrados quedarían irrecuperables, por eso se hacen respaldos seguros de las claves.
6. Cualquiera podría descifrar los datos protegidos con esa clave y, aunque se borre, queda en el historial: habría que cambiarla, volver a cifrar y revisar quién la vio.
7. Porque un repositorio privado lo ven colaboradores, cuentas comprometidas y copias locales, y conserva el historial, y no ofrece rotación ni control de acceso propios de un gestor de secretos.
8. La información almacenada se protege en reposo (cifrado de columnas, discos y respaldos), y la que viaja se protege en tránsito con TLS.
9. Porque un algoritmo bueno no sirve si la clave se expone, se pierde o está junto a los datos.
10. Cifraría los respaldos antes de sacarlos del servidor, guardaría las claves aparte, tendría copias en otro lugar y probaría restaurarlos.