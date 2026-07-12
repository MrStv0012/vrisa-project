-- ===========================
-- TABLE: Station
-- ===========================
CREATE TABLE station (
    station_id      SERIAL PRIMARY KEY,
    name            VARCHAR(100) NOT NULL,
    location        VARCHAR(200),
    city            VARCHAR(100),
    status          VARCHAR(20) CHECK (status IN ('active', 'inactive', 'maintenance'))
);

-- ===========================
-- TABLE: Sensor
-- ===========================
CREATE TABLE sensor (
    sensor_id       SERIAL PRIMARY KEY,
    station_id      INT NOT NULL,
    type            VARCHAR(50) CHECK (type IN ('ozone', 'temperature', 'humidity', 'pressure', 'wind')),
    model           VARCHAR(100),
    installation_date DATE,
    status          VARCHAR(20) CHECK (status IN ('active', 'inactive', 'calibration')),
    FOREIGN KEY (station_id) REFERENCES station(station_id)
);

-- ===========================
-- TABLE: Measurement
-- ===========================
CREATE TABLE measurement (
    measurement_id  SERIAL PRIMARY KEY,
    sensor_id       INT NOT NULL,
    timestamp       TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    value           FLOAT,
    unit            VARCHAR(20) NOT NULL,
    FOREIGN KEY (sensor_id) REFERENCES sensor(sensor_id)
);

-- ===========================
-- TABLE: Alert Threshold
-- ===========================
CREATE TABLE alert_threshold (
    threshold_id    SERIAL PRIMARY KEY,
    pollutant       VARCHAR(50) CHECK (pollutant IN ('ozone', 'CO', 'NO2', 'SO2', 'PM10', 'PM2.5')),
    level_name      VARCHAR(50) NOT NULL,
    min_value       FLOAT NOT NULL,
    max_value       FLOAT NOT NULL,
    unit            VARCHAR(20) NOT NULL
);

-- ===========================
-- TABLE: Alert
-- ===========================
CREATE TABLE alert (
    alert_id        SERIAL PRIMARY KEY,
    station_id      INT NOT NULL,
    threshold_id    INT NOT NULL,
    start_time      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    end_time        TIMESTAMP,
    status          VARCHAR(20) CHECK (status IN ('active', 'resolved', 'error')),
    FOREIGN KEY (station_id) REFERENCES station(station_id),
    FOREIGN KEY (threshold_id) REFERENCES alert_threshold(threshold_id)
);

-- ===========================
-- TABLE: User (optional)
-- ===========================
CREATE TABLE app_user (
    user_id         SERIAL PRIMARY KEY,
    name            VARCHAR(100) NOT NULL,
    role            VARCHAR(20) CHECK (role IN ('admin', 'technician', 'citizen')),
    email           VARCHAR(150) UNIQUE NOT NULL,
    password_hash   VARCHAR(255) NOT NULL
);
