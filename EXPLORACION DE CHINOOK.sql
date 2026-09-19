-- ============================================================================
-- EXPLORACION DE CHINOOK MEDIANTE CONSULTAS SQL
-- ============================================================================


-- Información de contacto básica de los clientes registrados

SELECT
    customer_id AS id_cliente,
    first_name AS nombre,
    last_name AS apellido,
    email AS correo_electronico
FROM customer;



-- Países en donde residen los clientes sin mostrar duplicados

SELECT DISTINCT 
    country AS pais
FROM customer
ORDER BY country ASC;


-- APARTADO 3: Criterio numérico
-- Canciones duran más de 5 minutos (300,000 ms) y tienen un precio superior a $0.99

SELECT 
    track_id, 
    name AS cancion, 
    milliseconds AS duracion_ms, 
    unit_price AS precio
FROM track
WHERE unit_price > 0.99 
  AND milliseconds > 300000;


-- Clientes que son de Brasil, o de EE.UU. que además tengan correo de Yahoo

SELECT 
    customer_id, 
    first_name, 
    last_name, 
    country, 
    email
FROM customer
WHERE country = 'Brazil' 
   OR (country = 'USA' AND email LIKE '%yahoo%');


-- Clientes radicados en Alemania, Francia o España

SELECT 
    customer_id, 
    first_name, 
    last_name, 
    country
FROM customer
WHERE country IN ('Germany', 'France', 'Spain')
ORDER BY country;

-- Pistas que duran entre 3 y 4 minutos

SELECT 
    track_id, 
    name AS cancion, 
    milliseconds AS duracion_ms
FROM track
WHERE milliseconds BETWEEN 180000 AND 240000;


-- Sensibilidad a la mayúsculas al buscar canciones con la palabra 'Love'?

SELECT track_id, name FROM track WHERE name LIKE '%Love%';

SELECT track_id, name FROM track WHERE name ILIKE '%Love%';

-- Clientes que carecen de empresa registrada y cuáles sí cuentan con un número de Fax

SELECT customer_id, first_name, last_name, company 
FROM customer 
WHERE company IS NULL;

SELECT customer_id, first_name, last_name, fax 
FROM customer 
WHERE fax IS NOT NULL;

-- 10 canciones con mayor duración de todo el catálogo

SELECT 
    track_id, 
    name AS cancion, 
    milliseconds AS duracion_ms
FROM track
ORDER BY milliseconds DESC, track_id ASC
LIMIT 10;

-- Registro de las dos primeras páginas (de 5 clientes cada una) ordenadas por ID

SELECT customer_id, first_name, last_name 
FROM customer 
ORDER BY customer_id ASC 
LIMIT 5 OFFSET 0;

SELECT customer_id, first_name, last_name 
FROM customer 
ORDER BY customer_id ASC 
LIMIT 5 OFFSET 5;
