# 07 - Protección en reposo y en tránsito

Camilo Angulo | LAB-02 | 18 de octubre de 2026

## Objetivo

Relacionar cada situación con el mecanismo que le corresponde y explicar qué protege.

## Comando o procedimiento

Análisis basado en lo que hice en las actividades 1 a 5.

## Resultado obtenido

| Situación | Mecanismo apropiado | ¿Qué protege? |
|---|---|---|
| Contraseña de usuario | Hash con sal (derivación de claves para contraseñas, como bcrypt o Argon2id) | Que una filtración de la base no revele la contraseña, porque no se puede recuperar |
| RFC almacenado en una tabla | Cifrado (pgp_sym_encrypt) | La confidencialidad del dato guardado, que solo se lee con la clave |
| Consulta enviada desde un cliente al servidor | TLS, de preferencia con verify-full | El dato en tránsito: confidencialidad, integridad y que el servidor sea el correcto |
| Respaldo de una base de datos | Cifrado del respaldo | Que un respaldo copiado o robado no se pueda leer |
| Clave criptográfica | Gestión de claves (gestor de secretos, acceso limitado, rotación) | Que la clave no se exponga ni se pierda, porque de ella depende todo el cifrado |

## Análisis

La contraseña es el único caso donde no se necesita recuperar el valor, por eso va con hash y no con cifrado. El RFC sí se necesita leer en algún momento, así que va cifrado. El respaldo, el RFC y las claves son protección en reposo, y la consulta del cliente es protección en tránsito. La clave aparece como un caso aparte porque de ella depende la seguridad de los demás cifrados.

## Conclusión

Cada problema tiene su mecanismo y ninguno sustituye a los otros. Un RFC cifrado viajando sin TLS, o con TLS pero con la clave expuesta, sigue en riesgo.