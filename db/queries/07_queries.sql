-- =====================================================================
-- VRISA - Consultas analíticas (07_queries.sql)
-- Cada punto del checklist tiene:
--   a) Versión sobre el modelo OLTP  (station, sensor, measurement, alert, alert_threshold)
--   b) Versión sobre el modelo OLAP  (dim_*, fact_measurement, fact_alert)
-- =====================================================================


-- =====================================================================
-- 1. Promedio diario por variable (unidad de medida)
-- =====================================================================

-- 1a. OLTP
SELECT DATE(m.timestamp)          AS dia,
       m.unit                     AS variable,
       ROUND(AVG(m.value)::numeric, 2) AS promedio
FROM measurement m
GROUP BY DATE(m.timestamp), m.unit
ORDER BY dia, variable;

-- 1b. OLAP
SELECT DATE(dt.timestamp)         AS dia,
       fm.unit                    AS variable,
       ROUND(AVG(fm.value)::numeric, 2) AS promedio
FROM fact_measurement fm
JOIN dim_time dt ON fm.time_key = dt.time_key
GROUP BY DATE(dt.timestamp), fm.unit
ORDER BY dia, variable;


-- =====================================================================
-- 2. Promedio diario por tipo de sensor
-- =====================================================================

-- 2a. OLTP
SELECT DATE(m.timestamp)          AS dia,
       s.type                     AS tipo_sensor,
       ROUND(AVG(m.value)::numeric, 2) AS promedio
FROM measurement m
JOIN sensor s ON m.sensor_id = s.sensor_id
GROUP BY DATE(m.timestamp), s.type
ORDER BY dia, tipo_sensor;

-- 2b. OLAP
SELECT DATE(dt.timestamp)         AS dia,
       ds.type                    AS tipo_sensor,
       ROUND(AVG(fm.value)::numeric, 2) AS promedio
FROM fact_measurement fm
JOIN dim_time dt   ON fm.time_key   = dt.time_key
JOIN dim_sensor ds  ON fm.sensor_key = ds.sensor_key
GROUP BY DATE(dt.timestamp), ds.type
ORDER BY dia, tipo_sensor;


-- =====================================================================
-- 3. Promedio y número de mediciones por estación
-- =====================================================================

-- 3a. OLTP
SELECT st.name                    AS estacion,
       COUNT(m.measurement_id)    AS num_mediciones,
       ROUND(AVG(m.value)::numeric, 2) AS promedio
FROM measurement m
JOIN sensor s   ON m.sensor_id = s.sensor_id
JOIN station st ON s.station_id = st.station_id
GROUP BY st.name
ORDER BY estacion;

-- 3b. OLAP
SELECT dst.name                   AS estacion,
       COUNT(fm.measurement_key)  AS num_mediciones,
       ROUND(AVG(fm.value)::numeric, 2) AS promedio
FROM fact_measurement fm
JOIN dim_station dst ON fm.station_key = dst.station_key
GROUP BY dst.name
ORDER BY estacion;


-- =====================================================================
-- 4. Alertas activas por estación y contaminante
-- =====================================================================

-- 4a. OLTP
SELECT st.name                    AS estacion,
       at.pollutant                AS contaminante,
       COUNT(a.alert_id)          AS alertas_activas
FROM alert a
JOIN station st          ON a.station_id   = st.station_id
JOIN alert_threshold at  ON a.threshold_id = at.threshold_id
WHERE a.status = 'active'
GROUP BY st.name, at.pollutant
ORDER BY estacion, contaminante;

-- 4b. OLAP
SELECT dst.name                   AS estacion,
       dth.pollutant                AS contaminante,
       COUNT(fa.alert_key)        AS alertas_activas
FROM fact_alert fa
JOIN dim_station dst   ON fa.station_key   = dst.station_key
JOIN dim_threshold dth ON fa.threshold_key = dth.threshold_key
WHERE fa.status = 'active'
GROUP BY dst.name, dth.pollutant
ORDER BY estacion, contaminante;


-- =====================================================================
-- 5. Tiempo promedio de alertas resueltas
--    NOTA: fact_alert no tiene end_time (solo time_key = start_time),
--    por lo que esta métrica SOLO se puede calcular sobre el modelo OLTP.
-- =====================================================================

-- 5a. OLTP
SELECT ROUND(
         AVG(EXTRACT(EPOCH FROM (a.end_time - a.start_time)) / 3600)::numeric,
         2
       ) AS horas_promedio_resolucion
FROM alert a
WHERE a.status = 'resolved'
  AND a.end_time IS NOT NULL;

-- 5b. OLAP: no calculable con el modelo estrella actual (falta end_time en fact_alert).


-- =====================================================================
-- 6. Promedios mensual, semanal y anual
-- =====================================================================

-- 6a. OLTP - mensual
SELECT EXTRACT(YEAR FROM m.timestamp)::int  AS anio,
       EXTRACT(MONTH FROM m.timestamp)::int AS mes,
       ROUND(AVG(m.value)::numeric, 2)      AS promedio
FROM measurement m
GROUP BY anio, mes
ORDER BY anio, mes;

-- 6a. OLTP - semanal
SELECT EXTRACT(YEAR FROM m.timestamp)::int AS anio,
       EXTRACT(WEEK FROM m.timestamp)::int AS semana,
       ROUND(AVG(m.value)::numeric, 2)     AS promedio
FROM measurement m
GROUP BY anio, semana
ORDER BY anio, semana;

-- 6a. OLTP - anual
SELECT EXTRACT(YEAR FROM m.timestamp)::int AS anio,
       ROUND(AVG(m.value)::numeric, 2)     AS promedio
FROM measurement m
GROUP BY anio
ORDER BY anio;

-- 6b. OLAP - mensual (usa columnas ya precalculadas en dim_time)
SELECT dt.year  AS anio,
       dt.month AS mes,
       ROUND(AVG(fm.value)::numeric, 2) AS promedio
FROM fact_measurement fm
JOIN dim_time dt ON fm.time_key = dt.time_key
GROUP BY dt.year, dt.month
ORDER BY anio, mes;

-- 6b. OLAP - semanal (dim_time no tiene columna de semana, se calcula desde timestamp)
SELECT dt.year AS anio,
       EXTRACT(WEEK FROM dt.timestamp)::int AS semana,
       ROUND(AVG(fm.value)::numeric, 2) AS promedio
FROM fact_measurement fm
JOIN dim_time dt ON fm.time_key = dt.time_key
GROUP BY dt.year, semana
ORDER BY anio, semana;

-- 6b. OLAP - anual
SELECT dt.year AS anio,
       ROUND(AVG(fm.value)::numeric, 2) AS promedio
FROM fact_measurement fm
JOIN dim_time dt ON fm.time_key = dt.time_key
GROUP BY dt.year
ORDER BY anio;


-- =====================================================================
-- 7. Tendencia diaria por tipo de sensor
-- =====================================================================

-- 7a. OLTP
SELECT s.type              AS tipo_sensor,
       DATE(m.timestamp)   AS dia,
       ROUND(AVG(m.value)::numeric, 2) AS promedio
FROM measurement m
JOIN sensor s ON m.sensor_id = s.sensor_id
GROUP BY s.type, DATE(m.timestamp)
ORDER BY tipo_sensor, dia;

-- 7b. OLAP
SELECT ds.type             AS tipo_sensor,
       DATE(dt.timestamp)  AS dia,
       ROUND(AVG(fm.value)::numeric, 2) AS promedio
FROM fact_measurement fm
JOIN dim_sensor ds ON fm.sensor_key = ds.sensor_key
JOIN dim_time dt   ON fm.time_key   = dt.time_key
GROUP BY ds.type, DATE(dt.timestamp)
ORDER BY tipo_sensor, dia;


-- =====================================================================
-- 8. Comparativo mensual por estación y tipo de sensor
-- =====================================================================

-- 8a. OLTP
SELECT st.name                          AS estacion,
       s.type                           AS tipo_sensor,
       EXTRACT(YEAR FROM m.timestamp)::int  AS anio,
       EXTRACT(MONTH FROM m.timestamp)::int AS mes,
       ROUND(AVG(m.value)::numeric, 2)  AS promedio
FROM measurement m
JOIN sensor s    ON m.sensor_id  = s.sensor_id
JOIN station st  ON s.station_id = st.station_id
GROUP BY estacion, tipo_sensor, anio, mes
ORDER BY estacion, tipo_sensor, anio, mes;

-- 8b. OLAP
SELECT dst.name    AS estacion,
       ds.type      AS tipo_sensor,
       dt.year      AS anio,
       dt.month     AS mes,
       ROUND(AVG(fm.value)::numeric, 2) AS promedio
FROM fact_measurement fm
JOIN dim_station dst ON fm.station_key = dst.station_key
JOIN dim_sensor ds   ON fm.sensor_key  = ds.sensor_key
JOIN dim_time dt     ON fm.time_key    = dt.time_key
GROUP BY estacion, tipo_sensor, anio, mes
ORDER BY estacion, tipo_sensor, anio, mes;


-- =====================================================================
-- 9. Distribución de sensores activos por tipo y estación
--    NOTA: dim_sensor no tiene station_key, así que en el modelo OLAP
--    la relación sensor-estación se infiere a partir de las combinaciones
--    que aparecen en fact_measurement. Un sensor activo que nunca generó
--    mediciones no aparecerá en el resultado OLAP (sí en el OLTP).
-- =====================================================================

-- 9a. OLTP
SELECT st.name    AS estacion,
       s.type      AS tipo_sensor,
       COUNT(*)    AS sensores_activos
FROM sensor s
JOIN station st ON s.station_id = st.station_id
WHERE s.status = 'active'
GROUP BY estacion, tipo_sensor
ORDER BY estacion, tipo_sensor;

-- 9b. OLAP
SELECT dst.name                     AS estacion,
       ds.type                      AS tipo_sensor,
       COUNT(DISTINCT ds.sensor_key) AS sensores_activos
FROM (SELECT DISTINCT station_key, sensor_key FROM fact_measurement) sm
JOIN dim_station dst ON sm.station_key = dst.station_key
JOIN dim_sensor ds   ON sm.sensor_key  = ds.sensor_key
WHERE ds.status = 'active'
GROUP BY estacion, tipo_sensor
ORDER BY estacion, tipo_sensor;


-- =====================================================================
-- 10. Variación horaria (últimas 24h) de temperatura, ozono y humedad
--     NOTA: se usa MAX(timestamp) como referencia de "ahora" en vez de
--     NOW(), porque los datos son históricos/simulados, no en tiempo real.
-- =====================================================================

-- 10a. OLTP
SELECT s.type                       AS tipo_sensor,
       EXTRACT(HOUR FROM m.timestamp)::int AS hora,
       ROUND(AVG(m.value)::numeric, 2) AS promedio
FROM measurement m
JOIN sensor s ON m.sensor_id = s.sensor_id
WHERE s.type IN ('temperature', 'ozone', 'humidity')
  AND m.timestamp >= (SELECT MAX(timestamp) FROM measurement) - INTERVAL '24 hours'
GROUP BY tipo_sensor, hora
ORDER BY tipo_sensor, hora;

-- 10b. OLAP
SELECT ds.type                      AS tipo_sensor,
       dt.hour                      AS hora,
       ROUND(AVG(fm.value)::numeric, 2) AS promedio
FROM fact_measurement fm
JOIN dim_sensor ds ON fm.sensor_key = ds.sensor_key
JOIN dim_time dt   ON fm.time_key   = dt.time_key
WHERE ds.type IN ('temperature', 'ozone', 'humidity')
  AND dt.timestamp >= (SELECT MAX(timestamp) FROM dim_time) - INTERVAL '24 hours'
GROUP BY tipo_sensor, hora
ORDER BY tipo_sensor, hora;
