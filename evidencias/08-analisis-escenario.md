# 08 - Análisis del escenario

Camilo Angulo | LAB-02 | 18 de octubre de 2026

## Objetivo

Analizar una empresa que tiene usuarios y roles bien configurados pero otros problemas de protección.

## Comando o procedimiento

Análisis del escenario de la actividad 8 de la práctica, apoyado en lo probado en el laboratorio.

## Resultado obtenido

Pregunta 1, riesgos principales: con contraseñas en texto claro, una filtración o un acceso de lectura expone las credenciales de todos. Con el RFC en texto claro pasa lo mismo con ese dato. Sin validación del servidor, alguien podría hacerse pasar por él y recibir las credenciales y las consultas. Con las claves en archivos SQL, quien lea el repositorio o el historial puede descifrar todo. Y los respaldos sin protección permiten leer toda la base si alguien los copia.

Pregunta 2, mecanismo para cada elemento:

| Elemento | Mecanismo |
|---|---|
| Nombre y correo | Control de acceso y enmascaramiento según el área, TLS al transmitirlos |
| Contraseña | Hash con sal (bcrypt o Argon2id) |
| RFC | Cifrado de la columna, con la clave fuera de la base |
| Información financiera | Cifrado, acceso restringido y registro de accesos |
| Claves criptográficas | Gestor de secretos, fuera de los scripts, con rotación |
| Conexiones | TLS con verify-full |
| Respaldos | Cifrado del respaldo, con la clave guardada aparte |

## Análisis

Pregunta 3: creo que lo más crítico es tener las claves en archivos SQL. Con la clave, el cifrado de los datos deja de servir, y además el archivo puede estar en un repositorio con historial y en muchas copias, sin poder retirarlo. Las contraseñas en texto claro están muy cerca en gravedad, porque se pueden usar directamente y la gente las repite en otros sitios.

Pregunta 4: no. Los usuarios y los permisos controlan quién consulta la base, pero no protegen contra el robo de un respaldo o de los archivos del servidor, contra alguien que observe la red, ni contra claves o contraseñas expuestas. En LAB-01 vimos que los permisos funcionan, pero eso no hace que el contenido sea ilegible fuera de la base.

## Conclusión

La seguridad no depende de un solo mecanismo. Los permisos correctos no compensan contraseñas en claro, claves expuestas ni conexiones sin validar.