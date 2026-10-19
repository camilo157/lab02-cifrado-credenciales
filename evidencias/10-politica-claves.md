# 10 - Política mínima de protección de claves

Camilo Angulo | LAB-02 | 18 de octubre de 2026

## Objetivo

Definir unas reglas básicas para manejar claves criptográficas.

## Comando o procedimiento

Redacté la política a partir de lo visto en la práctica, sobre todo en la parte de gestión de claves y en el problema de la clave escrita en un script.

## Resultado obtenido

1. Generación: las claves se generan con un generador aleatorio seguro y con una longitud adecuada, nunca a partir de una palabra o frase fácil de adivinar.
2. Almacenamiento: se guardan en un gestor de secretos o servicio de claves, separadas de los datos que cifran, y nunca en el código, los scripts ni el repositorio.
3. Acceso: solo las aplicaciones o personas que las necesitan tienen acceso, con el mínimo privilegio, y cada uso queda registrado.
4. Rotación: se cambian cada cierto tiempo y siempre que haya sospecha de exposición, volviendo a cifrar los datos con la clave nueva.
5. Respaldo: hay una copia de cada clave guardada en otro lugar seguro, cifrada, porque sin la clave los datos cifrados no se pueden recuperar.
6. Revocación: si una persona se va de la organización o un sistema se compromete, sus claves y accesos se revocan de inmediato.
7. Exposición accidental: si una clave aparece en un repositorio, correo o captura, se considera comprometida aunque se borre; se cambia, se vuelven a cifrar los datos y se revisa quién pudo verla.
8. Eliminación: cuando una clave ya no se necesita se destruye de forma segura, después de confirmar que ya no hay datos que dependan de ella.

## Análisis

Estas reglas tratan de evitar los dos riesgos que más pesan: que la clave se exponga y que se pierda. La del repositorio sale de lo visto en la actividad 3, donde borrar un archivo no quita la clave del historial.

## Conclusión

La seguridad del cifrado depende más de cómo se cuida la clave que del algoritmo.