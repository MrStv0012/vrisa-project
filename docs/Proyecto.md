# 🧩 Tablero analítico ambiental

Actividad completa para el curso de Bases de datos para análisis de datos:

1️⃣ Despliegue de una base de datos PostgreSQL en Docker,
2️⃣ Carga de datos con scripts DDL y DML, y
3️⃣ Ejecución de consultas analíticas para construir un tablero en Looker Studio.

## 🎯 Objetivo general

Desplegar una base de datos ambiental en PostgreSQL usando Docker, cargar su estructura y datos, y
realizar consultas que permitan construir un tablero de control en Looker Studio.

## 🧰 1. Preparación del entorno

Requisitos previos:

1️⃣ Tener instalado Docker Desktop
2️⃣ Tener una cuenta en Google Looker Studio
3️⃣ Editor de texto o VS Code

Archivos necesarios:

- `01_vrisa_ddl.sql`: definición de las tablas (Station, Sensor, Measurement, Alert, etc.)
- `02_vrisa_dml.sql`: datos de ejemplo para poblar las tablas
- `03_vrisa_measurements.sql`: datos de ejemplo de mediciones
- `04_vrisa_alerts.sql`: listado de alertas generadas por el sistema
- `05_vrisa_star_ddl.sql`, `06_vrisa_star_dml.sql`: modelo estrella (OLAP)
- `07_queries.sql`: consultas sugeridas

## 🧠 Actividad evaluativa

Entrega esperada:

1️⃣ Informe de los hallazgos
2️⃣ Captura o enlace del tablero en Looker Studio (opcional, con puntos extra)
3️⃣ Video corto (mínimo 5 min) explicando los hallazgos

## 🧾 Criterios de evaluación (rúbrica)

| Criterio | 1 (Bajo) | 3 (Medio) | 5 (Alto) |
| --- | --- | --- | --- |
| Configuración Docker | No se ejecuta correctamente | El contenedor funciona pero con errores en la carga | Contenedor operativo con datos cargados |
| Consultas SQL | Incorrectas o sin relación con el tablero | Parcialmente correctas | Correctas y optimizadas para análisis |
| Integración con Looker | No se conecta | Se conecta pero sin visualizaciones útiles | Tablero funcional con gráficos dinámicos |
| Interpretación de resultados | No hay análisis | Análisis superficial | Reflexión clara con evidencias visuales |
