# 04 - TLS en PostgreSQL

Camilo Angulo | LAB-02 | 18 de octubre de 2026

## Objetivo

Comprobar el estado de TLS en PostgreSQL, activarlo con un certificado de laboratorio y verificar que la conexión realmente lo usa.

## Comando o procedimiento

Primero corrí sql/03-verificacion-tls.sql tal como venía el contenedor:

```
docker exec -it pg-lab01 psql -U postgres -a -f /lab02/03-verificacion-tls.sql
```

El PostgreSQL del contenedor viene con TLS apagado, así que generé un certificado autofirmado, ajusté permisos y activé ssl:

```
docker exec pg-lab01 openssl req -new -x509 -days 365 -nodes -text -out /var/lib/postgresql/data/server.crt -keyout /var/lib/postgresql/data/server.key -subj "/CN=localhost"
docker exec pg-lab01 chown postgres:postgres /var/lib/postgresql/data/server.crt /var/lib/postgresql/data/server.key
docker exec pg-lab01 chmod 600 /var/lib/postgresql/data/server.key
docker exec pg-lab01 psql -U postgres -c "ALTER SYSTEM SET ssl = on;"
docker exec pg-lab01 psql -U postgres -c "SELECT pg_reload_conf();"
```

Luego repetí el script conectándome por red con sslmode=require, y probé verify-full:

```
docker exec -it pg-lab01 psql "host=localhost port=5432 dbname=postgres user=postgres sslmode=require" -a -f /lab02/03-verificacion-tls.sql
docker exec -it pg-lab01 psql "host=localhost port=5432 dbname=postgres user=postgres sslmode=verify-full sslrootcert=/var/lib/postgresql/data/server.crt" -c "SELECT ssl, version FROM pg_stat_ssl WHERE pid = pg_backend_pid();"
docker exec -it pg-lab01 psql "host=127.0.0.1 port=5432 dbname=postgres user=postgres sslmode=verify-full sslrootcert=/var/lib/postgresql/data/server.crt" -c "SELECT 1;"
```

## Resultado obtenido

Antes de activar TLS:

```
SHOW ssl;                      -> off
SHOW ssl_min_protocol_version; -> TLSv1.2
SHOW port;                     -> 5432
SHOW listen_addresses;         -> *
inet_client_addr, port         -> (vacío)
pg_stat_ssl: ssl = f, version y cipher vacíos
```

Después de activarlo, con sslmode=require:

```
SHOW ssl;                      -> on
inet_client_addr, port         -> ::1 | 58962
pg_stat_ssl: ssl = t | TLSv1.3 | TLS_AES_256_GCM_SHA384
```

verify-full con host=localhost funcionó (ssl = t, TLSv1.3). Con host=127.0.0.1 falló:

```
psql: error: connection to server at "127.0.0.1", port 5432 failed:
server certificate for "localhost" does not match host name "127.0.0.1"
```

## Análisis

La primera conexión no usaba TLS: ssl estaba en off y la sesión aparece con ssl = f. Además esa conexión era por el socket local del contenedor, y por eso no tiene dirección de cliente. La conexión por red, después de activarlo, sí usa TLS 1.3 con el cifrado TLS_AES_256_GCM_SHA384.

Sin TLS, quien pueda ver el tráfico de red podría leer las consultas y los resultados, o incluso modificarlos. Con TLS el contenido va cifrado (confidencialidad), se detectan cambios (integridad) y el cliente puede verificar con quién habla (autenticación), esto último solo si valida el certificado.

La diferencia entre los modos se vio en la práctica. require solo exige TLS pero no comprueba quién es el servidor. verify-full además valida el certificado y que el nombre coincida: con localhost funcionó y con 127.0.0.1 falló, porque el certificado está hecho para localhost. Cifrar la conexión no es lo mismo que comprobar con quién me estoy conectando.

Dos límites: el certificado es autofirmado y solo vale para el laboratorio, ya que en un entorno real tendría que venir de una autoridad certificadora en la que el cliente confíe. Y ssl = on solo permite TLS, no lo obliga: para forzarlo habría que usar reglas hostssl en pg_hba.conf.

## Conclusión

Comprobé el estado real de TLS en PostgreSQL con pg_stat_ssl, no solo la configuración. TLS protege la comunicación, pero no sustituye a los permisos de PostgreSQL.