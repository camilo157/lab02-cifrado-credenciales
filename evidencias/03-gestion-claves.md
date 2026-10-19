# 03 - Gestión de claves

Camilo Angulo | LAB-02 | 18 de octubre de 2026

## Objetivo

Identificar el problema de dejar una clave escrita en un script y revisar el repositorio antes de subirlo.

## Comando o procedimiento

Creé un archivo temporal, sql/ejemplo-mala-practica.sql, con esta consulta:

```
SELECT pgp_sym_decrypt(rfc_cifrado, 'CLAVE-DE-PRUEBA')
FROM clientes_protegidos;
```

Lo analicé y lo borré antes de hacer el commit, porque la práctica pide que no quede en la entrega.

Después busqué palabras sospechosas en los archivos con:

```
findstr /s /i /n "password passwd secret token api_key clave postgresql://" *.sql *.md
```

## Resultado obtenido

La búsqueda en los scripts solo encontró valores de laboratorio inventados: Password123 y OtraPassword (script 01), y CLAVE-DE-PRUEBA y OTRA-CLAVE (script 02), además de nombres de columnas como password y password_hash. No apareció ninguna contraseña real ni ninguna cadena postgresql:// con credenciales.

## Análisis

En el archivo la clave está escrita a la vista. Si fuera una clave real de una organización y el archivo se subiera a un repositorio, cualquiera con acceso al repo podría descifrar todos los RFC. Borrar el archivo después no arregla nada, porque el historial de Git conserva los commits anteriores. La clave tendría que considerarse expuesta: cambiarla, volver a cifrar los datos con la nueva y revisar quién pudo verla.

En un entorno real la clave no debería estar en el código, ni en el repositorio, ni junto a los datos que protege. Se guardaría en un gestor de secretos o en un servicio de claves, y la aplicación la obtendría en el momento de usarla, con permisos limitados y con registro de quién accede.

La búsqueda con findstr es una ayuda, pero no demuestra que no haya secretos. Solo encuentra las palabras que le pido, así que también hay que revisar los archivos a mano antes de subirlos.

## Conclusión

Una clave escrita en un script es una clave expuesta, y un repositorio, aunque sea privado, no es un lugar para secretos. En esta práctica solo usé valores ficticios.