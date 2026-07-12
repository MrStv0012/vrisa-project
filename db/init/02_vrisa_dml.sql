-- ===========================
-- INSERT DATA INTO Station (10 in Cali, Colombia)
-- ===========================
INSERT INTO station (name, location, city, status) VALUES
('Centro - San Antonio', '3.4510,-76.5315', 'Cali', 'active'),
('Sur - Pance', '3.3167,-76.5833', 'Cali', 'active'),
('Norte - Cañaveralejo', '3.4833,-76.5000', 'Cali', 'active'),
('Oeste - Univalle', '3.3750,-76.5333', 'Cali', 'maintenance'),
('Este - Paso del Comercio', '3.5167,-76.4833', 'Cali', 'inactive'),
('Noroeste - La Flora', '3.4667,-76.5167', 'Cali', 'active'),
('Suroeste - Menga', '3.4333,-76.5500', 'Cali', 'active'),
('Noreste - Andres Sanín', '3.4667,-76.4667', 'Cali', 'active'),
('Sureste - Puerto Rellena', '3.3833,-76.4667', 'Cali', 'active'),
('Centro - Sameco', '3.4500,-76.5333', 'Cali', 'active'),
('Corregimiento - Navarro', '3.4167,-76.6167', 'Cali', 'active');

-- ===========================
-- INSERT DATA INTO Sensor
-- Each station has at least one ozone sensor and one climate sensor
-- ===========================
INSERT INTO sensor (station_id, type, model, installation_date, status) VALUES
(1, 'ozone', 'MQ_131', '2005-01-10', 'active'),
(1, 'temperature', 'H12E1', '2005-01-10', 'active'),
(1, 'wind', 'W05103', '2005-04-15', 'active'),
(1, 'humidity', 'NCP18WF104F3SRB', '2005-02-05', 'active'),

(2, 'ozone', 'MQ_131', '2006-02-05', 'active'),
(2, 'humidity', 'NCP18WF104F3SRB', '2006-02-05', 'active'),
(2, 'temperature', 'H12E1', '2006-02-05', 'active'),
(2, 'wind', 'W05103', '2006-04-15', 'active'),

(3, 'ozone', 'MQ_131', '2007-02-15', 'active'),
(3, 'pressure', 'PressMax-300', '2007-02-15', 'active'),
(3, 'temperature', 'H12E1', '2007-02-15', 'active'),
(3, 'wind', 'W05103', '2007-04-15', 'active'),

(4, 'ozone', 'MQ_131', '2008-03-01', 'active'),
(4, 'humidity', 'NCP18WF104F3SRB', '2006-02-05', 'active'),
(4, 'temperature', 'H12E1', '2008-03-01', 'active'),
(4, 'humidity', 'NCP18WF104F3SRB', '2008-03-20', 'active'),

(5, 'ozone', 'MQ_131', '2009-03-20', 'inactive'),
(5, 'humidity', 'NCP18WF104F3SRB', '2009-03-20', 'inactive'),
(5, 'temperature', 'H12E1', '2009-03-20', 'active'),
(5, 'wind', 'W05103', '2009-04-15', 'active'),

(6, 'ozone', 'MQ_131', '2010-04-01', 'active'),
(6, 'temperature', 'H12E1', '2010-04-01', 'active'),
(6, 'humidity', 'NCP18WF104F3SRB', '2010-04-01', 'inactive'),
(6, 'wind', 'W05103', '2010-04-15', 'active'),

(7, 'ozone', 'MQ_131', '2011-03-20', 'inactive'),
(7, 'humidity', 'NCP18WF104F3SRB', '2011-03-20', 'inactive'),
(7, 'temperature', 'H12E1', '2011-03-20', 'active'),
(7, 'wind', 'W05103', '2011-04-15', 'active'),

(8, 'ozone', 'MQ_131', '2012-01-10', 'active'),
(8, 'temperature', 'H18HP2A', '2012-05-01', 'active'),
(8, 'wind', 'W05103', '2012-05-01', 'active'),
(8, 'humidity', 'NCP18WF104F3SRB', '2012-05-01', 'active'),

(9, 'ozone', 'MQ_131', '2013-02-15', 'active'),
(9, 'pressure', 'PressMax-300', '2013-02-15', 'active'),
(9, 'temperature', 'H12E1', '2013-02-15', 'active'),
(9, 'wind', 'W05103', '2013-04-15', 'active'),

(10, 'ozone', 'MQ_131', '2014-06-01', 'active'),
(10, 'pressure', 'PressMax-300', '2013-02-15', 'active'),
(10, 'temperature', 'H18HP2A', '2014-06-01', 'active'),
(10, 'wind', 'W05103', '2014-06-01', 'active'),

(11, 'ozone', 'MQ_131', '2015-04-15', 'active'),
(11, 'wind', 'W05103', '2015-04-15', 'active'),
(11, 'temperature', 'H12E1', '2015-04-15', 'calibration'),
(11, 'humidity', 'NCP18WF104F3SRB', '2015-04-15', 'calibration');

-- ===========================
-- INSERT DATA INTO Alert Threshold
-- (Ozone values based on EPA standards)
-- ===========================
INSERT INTO alert_threshold (pollutant, level_name, min_value, max_value, unit) VALUES
('ozone', 'Good', 0.000, 0.059, 'ppm'),
('ozone', 'Moderate', 0.060, 0.075, 'ppm'),
('ozone', 'Unhealthy for Sensitive Groups', 0.076, 0.095, 'ppm'),
('ozone', 'Unhealthy', 0.096, 0.150, 'ppm');

-- ===========================
-- INSERT DATA INTO User
-- ===========================
INSERT INTO app_user (name, role, email, password_hash) VALUES
('Laura Gomez', 'admin', 'laura.gomez@cali.gov.co', 'hash673d190b758967621da243f06c350ce68be4276174dc886560239fea923d4a5a'),
('Jefferson A Pena T.', 'admin', 'jefferson.pena@usbusbcali.edu.co', 'hash673d190b758967621da243f06c350ce68be4276174dc886560239fea923d4a5a'),
('Andres Torres', 'technician', 'andres.torres@usbusbcali.edu.co', 'hash84d4dce0d11bc319bc61143cd0849a1464cd7dcef4c73393d155fb27879df26b'),
('Maria Rodriguez', 'technician', 'maria.rodriguez@correounivalle.edu.co', 'hash6e5f6170d4e1f2560ecb8d0db7aebe03576a7504b7e305ba338f9b635ad02f67');
