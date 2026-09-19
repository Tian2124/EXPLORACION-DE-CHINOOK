# Chinook PostgreSQL — Exploración mediante consultas SQL

## 1. Objetivo

Se prepara la base de datos Chinook en PostgreSQL local y demostrar el dominio de consultas sobre las tablas `customer` y `track` mediante:

- Selección de columnas y alias.
- `DISTINCT`.
- Comparaciones numéricas.
- Combinación de condiciones con `AND` y `OR`.
- `IN`.
- `BETWEEN`.
- `LIKE` e `ILIKE`.
- Manejo de valores `NULL`.
- Ordenamiento y desempate estable.
- Paginación con `LIMIT` y `OFFSET`.

Cada consulta debe responder una pregunta de negocio y su resultado debe ser interpretado, no solamente ejecutado.

---

## 2. Contexto

Se apoya al equipo de una tienda musical que necesita explorar información de clientes y pistas del catálogo sin modificar los datos.

Se utiliza la base Chinook oficial para PostgreSQL, respetando las convenciones de nombres indicadas para la Semana 9.

> **Importante:** el script `Chinook_PostgreSql_SerialPKs.sql` recrea la base `chinook_serial`. Por ello, debe utilizarse una base destinada exclusivamente a esta práctica y no una base que contenga información que deba conservarse.

---

## 3. Preparación del entorno

### 3.1 Levantar PostgreSQL

Se puede reutilizar el Docker Compose de semanas anteriores, procurando mantener persistencia mediante un volumen.

Como alternativa, una instancia PostgreSQL 18 puede levantarse con Docker mediante:

```bash
docker run -d --name postgres18 -e POSTGRES_USER=admin -e POSTGRES_PASSWORD=admin123 -e POSTGRES_DB=postgres -p 5432:5432 -v postgres18_data:/var/lib/postgresql postgres:18
```

Datos utilizados:

| Parámetro | Valor |
|---|---|
| Host | `localhost` |
| Puerto | `5432` |
| Usuario | `admin` |
| Contraseña | `admin123` |
| Base inicial | `postgres` |
| Versión | PostgreSQL 18 |

### 3.2 Comprobar que el contenedor está activo

```bash
docker ps
```

También se puede comprobar el estado mediante:

```bash
docker logs postgres18
```

### 3.3 Conectarse a PostgreSQL

Con `psql`:

```bash
psql -h localhost -p 5432 -U admin -d postgres
```

Si se utiliza otro cliente, como DBeaver, pgAdmin o DataGrip, deben utilizarse los mismos datos de conexión.

### 3.4 Crear/utilizar la base de Chinook

El archivo:

```text
Chinook_PostgreSql_SerialPKs.sql
```

debe ejecutarse siguiendo la guía proporcionada para la práctica.

El script recrea:

```text
chinook_serial
```

Por esta razón, la ejecución debe hacerse sobre un entorno de práctica.

Después de importar los datos, conectarse a la base:

```sql
\c chinook_serial
```

---

## 4. Verificación de la conexión y de las tablas

Antes de ejecutar las consultas, se debe comprobar la versión de PostgreSQL:

```sql
SELECT version();
```

Comprobar la base de datos activa:

```sql
SELECT current_database();
```

Comprobar el usuario conectado:

```sql
SELECT current_user;
```

En `psql`, listar las tablas:

```sql
\dt
```

También se pueden revisar las tablas relevantes:

```sql
\d customer
\d track
```

Las consultas de esta práctica trabajan principalmente con:

- `customer`: información de los clientes.
- `track`: información de las pistas musicales.

### Evidencia que debe registrarse

Para que la preparación sea reproducible, se recomienda guardar:

1. Comando utilizado para levantar PostgreSQL.
2. Versión obtenida mediante `SELECT version();`.
3. Base activa obtenida mediante `SELECT current_database();`.
4. Usuario utilizado.
5. Confirmación de que existen las tablas `customer` y `track`.
6. Comando/script utilizado para importar Chinook.

---

# 5. Consultas obligatorias

## Apartado 1 — Directorio de clientes

### Pregunta de negocio

**¿Qué información básica de contacto existe para cada cliente registrado?**

### SQL

```sql
SELECT
    customer_id AS id_cliente,
    first_name AS nombre,
    last_name AS apellido,
    email AS correo_electronico
FROM customer;
```

### Explicación

La consulta obtiene cuatro datos relevantes de cada cliente:

- Identificador.
- Nombre.
- Apellido.
- Correo electrónico.

Los alias permiten presentar nombres de columnas más descriptivos para una persona que está revisando un reporte comercial.

`id_cliente`, `nombre`, `apellido` y `correo_electronico` son alias explícitos.

### Interpretación

Cada fila representa un cliente registrado en la tabla `customer`.

La consulta no modifica los datos; únicamente los recupera.

---

## Apartado 2 — Países representados

### Pregunta de negocio

**¿Qué países están representados entre los clientes de la tienda?**

### SQL

```sql
SELECT DISTINCT
    country AS pais
FROM customer
ORDER BY country ASC;
```

### Explicación

`DISTINCT` elimina los valores repetidos de `country`.

Por lo tanto, si existen muchos clientes del mismo país, el país aparece una sola vez en el resultado.

### Interpretación

**Cada fila representa un país distinto**, no un cliente.

El `ORDER BY` organiza los países alfabéticamente para facilitar su lectura.

---

## Apartado 3 — Criterio numérico

### Pregunta de negocio

**¿Qué pistas tienen una duración superior a cinco minutos y además cuestan más de $0.99?**

### SQL

```sql
SELECT
    track_id,
    name AS cancion,
    milliseconds AS duracion_ms,
    unit_price AS precio
FROM track
WHERE unit_price > 0.99
  AND milliseconds > 300000;
```

### Criterios utilizados

- `300000` milisegundos = **5 minutos**.
- `0.99` representa **$0.99**.

Se utilizan los operadores `>` para buscar valores estrictamente superiores a esos límites.

### Interpretación

Una pista solamente aparece cuando cumple **las dos condiciones simultáneamente**:

1. Dura más de cinco minutos.
2. Tiene un precio superior a $0.99.

Una pista que cumpla únicamente una de las condiciones queda excluida.

---

## Apartado 4 — Alternativas controladas

### Pregunta de negocio

**¿Qué clientes son de Brasil o son clientes de Estados Unidos que, además, tienen un correo que contiene `yahoo`?**

### SQL

```sql
SELECT
    customer_id,
    first_name,
    last_name,
    country,
    email
FROM customer
WHERE country = 'Brazil'
   OR (country = 'USA' AND email LIKE '%yahoo%');
```

### Explicación

Los paréntesis son importantes porque establecen que la segunda alternativa debe cumplir ambas condiciones:

```text
country = 'USA'
AND
email LIKE '%yahoo%'
```

La primera alternativa es:

```text
country = 'Brazil'
```

Por lo tanto, el criterio completo equivale a:

```text
Brasil
O
(Estados Unidos Y correo con "yahoo")
```

### ¿Qué ocurre sin los paréntesis?

Por la precedencia de operadores booleanos, `AND` tiene prioridad sobre `OR`, por lo que esta consulta:

```sql
WHERE country = 'Brazil'
   OR country = 'USA'
   AND email LIKE '%yahoo%';
```

normalmente se interpreta de manera equivalente a:

```sql
WHERE country = 'Brazil'
   OR (country = 'USA' AND email LIKE '%yahoo%');
```

Mover los paréntesis a otra posición sí puede cambiar el significado. Por ejemplo:

```sql
WHERE (country = 'Brazil' OR country = 'USA')
  AND email LIKE '%yahoo%';
```

ahora exige que **tanto los clientes de Brasil como los de Estados Unidos** tengan un correo que contenga `yahoo`.

### Interpretación

El uso de paréntesis hace explícita la intención comercial y evita ambigüedades al leer o modificar la consulta.

---

## Apartado 5 — Pertenencia

### Pregunta de negocio

**¿Qué clientes pertenecen a Alemania, Francia o España?**

### SQL

```sql
SELECT
    customer_id,
    first_name,
    last_name,
    country
FROM customer
WHERE country IN ('Germany', 'France', 'Spain')
ORDER BY country;
```

### Explicación

`IN` permite comprobar si `country` pertenece a una lista de valores.

Conceptualmente, equivale a combinar varias comparaciones mediante `OR`:

```sql
country = 'Germany'
OR country = 'France'
OR country = 'Spain'
```

### Interpretación

Cada fila representa un cliente cuyo país está incluido en la lista indicada.

El `ORDER BY country` agrupa visualmente los resultados por país.

---

## Apartado 6 — Intervalo

### Pregunta de negocio

**¿Qué pistas tienen una duración entre tres y cuatro minutos?**

### SQL

```sql
SELECT
    track_id,
    name AS cancion,
    milliseconds AS duracion_ms
FROM track
WHERE milliseconds BETWEEN 180000 AND 240000;
```

### Criterios utilizados

- 3 minutos = `180000` milisegundos.
- 4 minutos = `240000` milisegundos.

### ¿`BETWEEN` incluye los extremos?

Sí.

En este caso:

```sql
BETWEEN 180000 AND 240000
```

equivale a:

```text
180000 <= milliseconds <= 240000
```

Por lo tanto, una pista que dure exactamente tres minutos o exactamente cuatro minutos también cumple el filtro.

### Interpretación

El resultado contiene pistas cuya duración está dentro del intervalo de tres a cuatro minutos, incluyendo ambos extremos.

---

## Apartado 7 — Patrones

### Pregunta de negocio

**¿Cómo cambia la búsqueda de canciones que contienen la palabra `Love` cuando se utiliza `LIKE` frente a `ILIKE`?**

### Consulta con `LIKE`

```sql
SELECT
    track_id,
    name
FROM track
WHERE name LIKE '%Love%';
```

### Consulta con `ILIKE`

```sql
SELECT
    track_id,
    name
FROM track
WHERE name ILIKE '%Love%';
```

### Explicación del patrón

El patrón:

```text
%Love%
```

significa:

- `%` al inicio: puede existir cualquier cantidad de caracteres antes de `Love`.
- `Love`: texto buscado.
- `%` al final: puede existir cualquier cantidad de caracteres después de `Love`.

Por ejemplo, el patrón puede encontrar nombres como:

```text
Love Song
A Love Story
Love
```

El carácter `%` permite cualquier cantidad de caracteres. El carácter `_`, si se utilizara, representaría un único carácter.

### Diferencia entre `LIKE` e `ILIKE`

En PostgreSQL:

- `LIKE` realiza una comparación sensible a mayúsculas/minúsculas.
- `ILIKE` realiza una comparación sin distinguir mayúsculas/minúsculas.

Por ello, `ILIKE '%Love%'` también puede encontrar variantes como `love`, `LOVE` o `LoVe`.

### Interpretación

Comparar ambas consultas permite observar directamente si existen diferencias en los resultados debido al uso de mayúsculas y minúsculas en los nombres de las pistas.

---

## Apartado 8 — Ausencias

### Pregunta de negocio

**¿Qué clientes no tienen empresa registrada y qué clientes sí tienen un número de fax?**

### Clientes sin empresa

```sql
SELECT
    customer_id,
    first_name,
    last_name,
    company
FROM customer
WHERE company IS NULL;
```

### Clientes con fax

```sql
SELECT
    customer_id,
    first_name,
    last_name,
    fax
FROM customer
WHERE fax IS NOT NULL;
```

### Explicación

`NULL` representa la ausencia de un valor conocido.

Para comprobarlo se utiliza:

```sql
IS NULL
```

o:

```sql
IS NOT NULL
```

No se debe utilizar:

```sql
company = NULL
```

ni:

```sql
company != NULL
```

porque `NULL` no se compara mediante `=` o `!=`. Las expresiones con `NULL` utilizan la lógica de valores desconocidos de SQL.

### Interpretación

La primera consulta muestra clientes para los cuales no existe un valor registrado en `company`.

La segunda muestra clientes que sí tienen un valor registrado en `fax`.

---

## Apartado 9 — Ranking

### Pregunta de negocio

**¿Cuáles son las diez pistas más largas del catálogo?**

### SQL

```sql
SELECT
    track_id,
    name AS cancion,
    milliseconds AS duracion_ms
FROM track
ORDER BY milliseconds DESC, track_id ASC
LIMIT 10;
```

### Explicación

```sql
ORDER BY milliseconds DESC
```

coloca primero las pistas con mayor duración.

El segundo criterio:

```sql
track_id ASC
```

funciona como desempate estable cuando dos pistas tienen exactamente la misma duración.

Finalmente:

```sql
LIMIT 10
```

limita el resultado a diez filas.

### Interpretación

El resultado representa las diez pistas de mayor duración.

El `track_id` no determina quién es más largo; solamente proporciona un orden de desempate cuando existe igualdad en `milliseconds`.

---

## Apartado 10 — Paginación

### Pregunta de negocio

**¿Cómo podemos mostrar los clientes en páginas consecutivas de cinco registros sin repetir identificadores?**

### Página 1

```sql
SELECT
    customer_id,
    first_name,
    last_name
FROM customer
ORDER BY customer_id ASC
LIMIT 5 OFFSET 0;
```

### Página 2

```sql
SELECT
    customer_id,
    first_name,
    last_name
FROM customer
ORDER BY customer_id ASC
LIMIT 5 OFFSET 5;
```

### Explicación

Las dos consultas utilizan exactamente el mismo orden:

```sql
ORDER BY customer_id ASC
```

y un identificador único como criterio de ordenamiento.

La primera página:

```sql
LIMIT 5 OFFSET 0
```

toma los primeros cinco clientes.

La segunda:

```sql
LIMIT 5 OFFSET 5
```

omite los primeros cinco y obtiene los siguientes cinco.

### Validación de que no se repiten identificadores

Después de ejecutar ambas consultas, se deben comparar los valores de `customer_id`.

La página 1 debe contener los identificadores de las posiciones 1 a 5 y la página 2 los de las posiciones 6 a 10 del mismo orden.

Por ejemplo, también puede validarse con una consulta:

```sql
WITH paginas AS (
    SELECT
        customer_id,
        ROW_NUMBER() OVER (ORDER BY customer_id ASC) AS posicion
    FROM customer
)
SELECT
    customer_id,
    posicion,
    CASE
        WHEN posicion BETWEEN 1 AND 5 THEN 1
        WHEN posicion BETWEEN 6 AND 10 THEN 2
    END AS pagina
FROM paginas
WHERE posicion <= 10
ORDER BY posicion;
```

### Interpretación

La paginación permite dividir el conjunto de clientes en grupos de cinco.

Como ambas páginas utilizan el mismo orden y `customer_id` es un identificador único, los primeros diez registros se dividen en dos grupos consecutivos sin repetir identificadores.

---

# 6. Validación de resultados

No basta con entregar las sentencias SQL. Todas las consultas deben ejecutarse sobre la base Chinook importada.

Para cada apartado se recomienda registrar:

1. La pregunta de negocio.
2. La consulta SQL.
3. El resultado observado.
4. Una interpretación breve.
5. Cualquier detalle relevante encontrado durante la ejecución.

La evidencia puede conservarse mediante capturas de pantalla o mediante la salida de `psql`.

---

# 7. Archivo `consultas.sql`

Las consultas deben mantenerse en un archivo independiente:

```text
consultas.sql
```

Se recomienda organizarlo así:

```text
-- ============================================================================
-- EXPLORACIÓN DE CHINOOK MEDIANTE CONSULTAS SQL
-- ============================================================================

-- APARTADO 1: Directorio de clientes
...

-- APARTADO 2: Países representados
...

-- APARTADO 3: Criterio numérico
...

-- APARTADO 4: Alternativas controladas
...

-- APARTADO 5: Pertenencia
...

-- APARTADO 6: Intervalo
...

-- APARTADO 7: Patrones
...

-- APARTADO 8: Ausencias
...

-- APARTADO 9: Ranking
...

-- APARTADO 10: Paginación
...
```

Los apartados 7, 8 y 10 contienen más de una sentencia. Esto es correcto: la evaluación corresponde a **diez apartados**, no a un límite de diez sentencias SQL.

---

# 8. Video de demostración

Se debe grabar un video de máximo **8 minutos**.

El video debe mostrar y explicar:

1. PostgreSQL ejecutándose localmente.
2. La conexión a la base `chinook_serial`.
3. La versión de PostgreSQL.
4. Las tablas disponibles.
5. Los diez apartados de `consultas.sql`.
6. Qué pregunta responde cada consulta.
7. La interpretación de los resultados.
8. En los apartados 7, 8 y 10, explicar las diferencias entre las sentencias utilizadas.
9. En el apartado 10, demostrar que las dos páginas no repiten identificadores.

### Guion sugerido

| Tiempo aproximado | Contenido |
|---|---|
| 0:00–0:45 | Docker/PostgreSQL y conexión |
| 0:45–1:15 | Base activa, versión y tablas |
| 1:15–4:45 | Apartados 1–6 |
| 4:45–6:30 | Apartados 7–9 |
| 6:30–7:30 | Apartado 10 y validación |
| 7:30–8:00 | Conclusión y comprobación final |

---

# 9. Estructura recomendada del proyecto

```text
chinook-postgresql/
│
├── README.md
├── consultas.sql
├── Chinook_PostgreSql_SerialPKs.sql
└── docker-compose.yml        # si se utiliza Docker Compose
```

Si el script oficial se mantiene fuera del repositorio por su tamaño o por las instrucciones del curso, debe indicarse en el README dónde obtenerlo.

---

# 10. Lista de comprobación final

Antes de entregar:

- [ ] PostgreSQL está levantado localmente.
- [ ] Existe persistencia mediante Docker/volumen o Docker Compose.
- [ ] Se utilizó una base de práctica que puede ser recreada.
- [ ] Chinook fue importado correctamente.
- [ ] La base activa es `chinook_serial`.
- [ ] Se comprobó la versión de PostgreSQL.
- [ ] Se comprobaron las tablas.
- [ ] Existe `consultas.sql`.
- [ ] Existen exactamente diez apartados numerados.
- [ ] Cada apartado contiene una pregunta de negocio.
- [ ] Cada apartado contiene SQL.
- [ ] Cada apartado explica cómo interpretar el resultado.
- [ ] Se utilizaron criterios propios y no solamente ejemplos copiados.
- [ ] Se ejecutaron y validaron todas las consultas.
- [ ] Se explicó `DISTINCT`.
- [ ] Se explicaron `AND` y `OR` con paréntesis.
- [ ] Se explicó `IN`.
- [ ] Se explicó que `BETWEEN` incluye sus extremos.
- [ ] Se compararon `LIKE` e `ILIKE`.
- [ ] Se explicó el uso de `%` y `_`.
- [ ] Se explicó `IS NULL` e `IS NOT NULL`.
- [ ] Se explicó por qué no se utiliza `= NULL`.
- [ ] El ranking utiliza `ORDER BY ... DESC` y `track_id` como desempate.
- [ ] La paginación utiliza el mismo orden en ambas páginas.
- [ ] Se comprobó que las páginas no repiten `customer_id`.
- [ ] El video dura como máximo ocho minutos.
