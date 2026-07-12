-- ===========================
-- CORREGIDO respecto al 06_vrisa_star_dml.sql original:
-- 1) fact_measurement y fact_alert ahora se llenan haciendo JOIN contra
--    las tablas de dimensión (dim_station, dim_sensor, dim_threshold)
--    para obtener las llaves subrogadas (*_key) reales, en vez de
--    reutilizar directamente los id de la base transaccional.
-- 2) dim_time ahora se puebla con los timestamps de measurement Y de
--    alert (antes solo tomaba measurement, así que fact_alert quedaba
--    vacía porque no encontraba coincidencia en dim_time).
-- 3) Se quitó el filtro fijo "BETWEEN 2020 AND 2025" que hacía que los
--    datos generados en otras fechas no entraran al modelo estrella.
-- ===========================

-- Stations
INSERT INTO dim_station (station_id, name, location, city, status)
SELECT s.station_id, s.name, s.location, s.city, s.status
FROM station s;

-- Sensors
INSERT INTO dim_sensor (sensor_id, type, model, installation_date, status)
SELECT se.sensor_id, se.type, se.model, se.installation_date, se.status
FROM sensor se;

-- Thresholds
INSERT INTO dim_threshold (threshold_id, pollutant, level_name, min_value, max_value, unit)
SELECT th.threshold_id, th.pollutant, th.level_name, th.min_value, th.max_value, th.unit
FROM alert_threshold th;

-- Users
INSERT INTO dim_user (user_id, name, role, email)
SELECT u.user_id, u.name, u.role, u.email
FROM app_user u;

-- Poblar dim_time (timestamps de measurement + start_time de alert)
INSERT INTO dim_time (timestamp, year, quarter, month, day, hour, minute)
SELECT DISTINCT
    ts,
    EXTRACT(YEAR FROM ts)::INT,
    EXTRACT(QUARTER FROM ts)::INT,
    EXTRACT(MONTH FROM ts)::INT,
    EXTRACT(DAY FROM ts)::INT,
    EXTRACT(HOUR FROM ts)::INT,
    EXTRACT(MINUTE FROM ts)::INT
FROM (
    SELECT m.timestamp AS ts FROM measurement m
    UNION
    SELECT a.start_time AS ts FROM alert a
) all_ts;

-- Poblar fact_measurement (usando las llaves subrogadas de las dimensiones)
INSERT INTO fact_measurement (station_key, sensor_key, time_key, value, unit)
SELECT
    ds.station_key,
    dse.sensor_key,
    dt.time_key,
    m.value,
    m.unit
FROM measurement m
JOIN sensor se       ON m.sensor_id = se.sensor_id
JOIN dim_station ds  ON ds.station_id = se.station_id
JOIN dim_sensor dse  ON dse.sensor_id = m.sensor_id
JOIN dim_time dt     ON dt.timestamp = m.timestamp;

-- Poblar fact_alert (usando las llaves subrogadas de las dimensiones)
INSERT INTO fact_alert (station_key, threshold_key, time_key, status)
SELECT
    ds.station_key,
    dth.threshold_key,
    dt.time_key,
    a.status
FROM alert a
JOIN dim_station ds    ON ds.station_id = a.station_id
JOIN dim_threshold dth ON dth.threshold_id = a.threshold_id
JOIN dim_time dt       ON dt.timestamp = a.start_time;
