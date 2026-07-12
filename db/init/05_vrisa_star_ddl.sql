-- ===========================
-- CREATE DATABASE
-- ===========================
-- CREATE DATABASE vrisa_db_star;
-- \c vrisa_db_star

-- ===========================
-- DIMENSION: Station
-- ===========================
CREATE TABLE dim_station (
    station_key     SERIAL PRIMARY KEY,
    station_id      INT,
    name            VARCHAR(100),
    location        VARCHAR(200),
    city            VARCHAR(100),
    status          VARCHAR(20)
);

-- ===========================
-- DIMENSION: Sensor
-- ===========================
CREATE TABLE dim_sensor (
    sensor_key      SERIAL PRIMARY KEY,
    sensor_id       INT,
    type            VARCHAR(50),
    model           VARCHAR(100),
    installation_date DATE,
    status          VARCHAR(20)
);

-- ===========================
-- DIMENSION: Time
-- ===========================
CREATE TABLE dim_time (
    time_key        SERIAL PRIMARY KEY,
    timestamp       TIMESTAMP NOT NULL,
    year            INT,
    quarter         INT,
    month           INT,
    day             INT,
    hour            INT,
    minute          INT
);

-- ===========================
-- DIMENSION: Alert Threshold
-- ===========================
CREATE TABLE dim_threshold (
    threshold_key   SERIAL PRIMARY KEY,
    threshold_id    INT,
    pollutant       VARCHAR(50),
    level_name      VARCHAR(50),
    min_value       FLOAT,
    max_value       FLOAT,
    unit            VARCHAR(20)
);

-- ===========================
-- DIMENSION: User
-- ===========================
CREATE TABLE dim_user (
    user_key        SERIAL PRIMARY KEY,
    user_id         INT,
    name            VARCHAR(100),
    role            VARCHAR(20),
    email           VARCHAR(150)
);

-- ===========================
-- FACT: Measurements
-- ===========================
CREATE TABLE fact_measurement (
    measurement_key SERIAL PRIMARY KEY,
    station_key     INT,
    sensor_key      INT,
    time_key        INT,
    value           FLOAT,
    unit            VARCHAR(20),
    FOREIGN KEY (station_key) REFERENCES dim_station(station_key),
    FOREIGN KEY (sensor_key) REFERENCES dim_sensor(sensor_key),
    FOREIGN KEY (time_key) REFERENCES dim_time(time_key)
);

-- ===========================
-- FACT: Alerts
-- ===========================
CREATE TABLE fact_alert (
    alert_key       SERIAL PRIMARY KEY,
    station_key     INT,
    threshold_key   INT,
    time_key        INT,
    status          VARCHAR(20),
    FOREIGN KEY (station_key) REFERENCES dim_station(station_key),
    FOREIGN KEY (threshold_key) REFERENCES dim_threshold(threshold_key),
    FOREIGN KEY (time_key) REFERENCES dim_time(time_key)
);
