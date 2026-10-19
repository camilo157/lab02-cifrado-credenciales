# 02 - Cifrado de información sensible

Camilo Angulo | LAB-02 | 18 de octubre de 2026

## Objetivo

Proteger el RFC de un cliente con cifrado simétrico usando pgcrypto, y comprobar que solo se recupera con la clave correcta.

## Comando o procedimiento

Corrí sql/02-cifrado-datos.sql:

```
docker exec -it pg-lab01 psql -U postgres -a -f /lab02/02-cifrado-datos.sql
```

El script crea la tabla clientes_protegidos con una columna BYTEA para el RFC, guarda el RFC con pgp_sym_encrypt() usando una clave de prueba (ficticia), lo consulta tal cual está en la tabla, lo descifra con pgp_sym_decrypt() y prueba con una clave incorrecta.

## Resultado obtenido

Lo que se ve en la tabla:

```
 id |  nombre   |  rfc_cifrado
----+-----------+------------------------------------------------------
  1 | Ana López | \xc30d0407030202023301aea49bba72d23e018907c2281478...
```

Con la clave correcta:

```
 id |  nombre   |      rfc
----+-----------+---------------
  1 | Ana López | LOPA900101ABC
```

Con una clave incorrecta:

```
ERROR:  Wrong key or corrupt data
```

## Análisis

crypt() y pgp_sym_encrypt() sirven para cosas distintas. crypt() genera un hash que no se puede revertir y se usa para contraseñas, que solo hay que verificar. pgp_sym_encrypt() cifra un dato y se puede descifrar con la clave, y por eso sirve para información que sí hay que volver a leer, como el RFC. El único que permite recuperar el dato original es el cifrado.

Con una clave incorrecta no se obtiene nada parecido al dato, solo el error. Sin la clave, el valor guardado es solo una cadena de bytes.

El problema de escribir la clave directo en la consulta es que queda en el script, y de ahí puede pasar al repositorio, al historial de la terminal, a los registros del servidor (si registra las consultas) o a una captura de pantalla. Si la clave se expone, el cifrado ya no protege nada. Además, cifrar la columna no sustituye al control de acceso: quien tenga la clave puede leer todos los RFC.

## Conclusión

El cifrado protege el RFC mientras está guardado, pero solo es tan seguro como la clave. La clave usada aquí es de laboratorio y en un caso real no estaría escrita en una consulta.