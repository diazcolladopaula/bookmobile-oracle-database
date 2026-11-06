# Bookmobile Database

Base de datos en Oracle SQL / PL/SQL para un servicio de biblioteca móvil: un autobús visita municipios según un calendario fijo, y los usuarios pueden reservar, tomar prestados y devolver libros, además de escribir comentarios sobre lo que leen. El proyecto incluye el modelo de datos, las reglas de negocio (paquete PL/SQL y triggers), vistas por usuario, datos de ejemplo, consultas y pruebas.

Nació como una práctica de la asignatura de bases de datos en la universidad y se ha reescrito como un repositorio autocontenido.

[English version](README.md)

## Qué demuestra

- Diseño relacional con claves compuestas, restricciones `CHECK` e integridad referencial (15 tablas).
- Un paquete PL/SQL que aplica las reglas de préstamo: límite de préstamos, sanciones, disponibilidad, reservas que se convierten en préstamos y penalización por devolución tardía.
- Triggers para reglas de negocio que las restricciones no pueden expresar.
- Vistas con triggers `INSTEAD OF` para que cada usuario acceda solo a sus propios datos.
- Consultas analíticas con CTE, anti-joins y agregaciones.
- Scripts de prueba autoverificables escritos en PL/SQL.

## Modelo de datos

El diagrama entidad-relación está en el [README en inglés](README.md#data-model). Un **servicio** es una visita de un autobús con su conductor a una parada en un día concreto. Cada fila de `loans` es un préstamo (`L`) o una reserva (`R`) y está ligada a un servicio, por lo que no se puede prestar nada en un municipio un día en que el autobús no pasa por él.

## Estructura del repositorio

```
sql/
  install.sql          ejecuta todo lo siguiente en orden
  00_reset.sql         elimina los objetos del proyecto (seguro en un esquema vacío)
  01_schema.sql        tablas, restricciones e índices
  02_package.sql       bookmobile_pkg: procedimientos de reserva, préstamo y devolución
  03_triggers.sql      triggers de tablas
  04_views.sql         vistas por usuario y sus triggers INSTEAD OF
  05_sample_data.sql   datos de ejemplo ficticios
  06_queries.sql       consultas de ejemplo
tests/
  test_package.sql
  test_triggers.sql
  test_views.sql
```

## Puesta en marcha

Necesitas Oracle Database 12c o superior y un usuario con permisos para crear tablas, vistas, paquetes y triggers. Una forma rápida de tenerlo es la imagen gratuita en contenedor:

```bash
docker run -d --name oracle -p 1521:1521 \
  -e ORACLE_PASSWORD=change_me \
  -e APP_USER=bookmobile -e APP_USER_PASSWORD=change_me \
  gvenzl/oracle-free:slim
```

Instala todo desde el directorio `sql` con SQL*Plus o SQLcl:

```bash
cd sql
sqlplus bookmobile/change_me@//localhost:1521/FREEPDB1 @install.sql
```

Después puedes ejecutar las consultas (`@06_queries.sql`) o las pruebas.

## Reglas de negocio

| Regla | Dónde |
|-------|-------|
| Un usuario puede tener como máximo 5 préstamos y reservas abiertos | `bookmobile_pkg` |
| Los usuarios sancionados no pueden pedir prestado ni reservar | `bookmobile_pkg` |
| Préstamos y reservas se hacen en un día en que el autobús visita el municipio del usuario | `bookmobile_pkg` y clave foránea a `services` |
| Un ejemplar dañado, dado de baja, prestado o reservado no está disponible | `bookmobile_pkg` |
| La reserva de un día se convierte en préstamo al recoger el ejemplar | `bookmobile_pkg.loan_copy` |
| El préstamo dura 14 días; devolver tarde sanciona tantos días como el retraso | `bookmobile_pkg.return_copy` |
| Los usuarios institucionales no pueden publicar comentarios | `trg_posts_no_institutions` |
| Marcar un ejemplar como dañado registra su fecha de baja | `trg_copies_deregister` |
| Cada préstamo suma una lectura al libro | `trg_loans_count_reads` |

Los procedimientos no hacen `COMMIT` ni `ROLLBACK`: lo decide quien los llama. Los errores usan los códigos `-20001` a `-20011`, documentados al inicio de `02_package.sql`.

Las vistas `my_data`, `my_loans` y `my_reservations` muestran solo las filas del usuario cuyo identificador está en el identificador de cliente de la sesión (`DBMS_SESSION.SET_IDENTIFIER`).

## Pruebas

Los scripts necesitan el proyecto instalado. Cada uno imprime `[PASS]` o `[FAIL]` por comprobación y revierte sus cambios, de modo que los datos de ejemplo quedan intactos.

```bash
cd tests
sqlplus bookmobile/change_me@//localhost:1521/FREEPDB1 @test_package.sql
sqlplus bookmobile/change_me@//localhost:1521/FREEPDB1 @test_triggers.sql
sqlplus bookmobile/change_me@//localhost:1521/FREEPDB1 @test_views.sql
```

## Notas

- Todos los datos de ejemplo (municipios, personas, correos, teléfonos, ISBN) son ficticios.
- Los scripts son solo ASCII para evitar problemas de codificación en SQL*Plus.
