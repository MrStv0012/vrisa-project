# Informe de Hallazgos — Proyecto VRISA

## 1. Introducción

VRISA es un sistema de monitoreo ambiental que despliega una base de datos en PostgreSQL (contenedor Docker) para 11 estaciones de medición ubicadas en Cali. Cada estación cuenta con sensores de ozono, temperatura, humedad, presión y viento, generando mediciones periódicas que alimentan un sistema de alertas por umbrales de contaminantes.

El objetivo del proyecto fue: (1) modelar y cargar la base en dos esquemas —uno transaccional (OLTP) y uno analítico (modelo estrella OLAP)—, (2) construir consultas analíticas sobre ambos modelos, y (3) visualizar los resultados en un tablero de Looker Studio.

## 2. Arquitectura de la base de datos

### Modelo OLTP (operacional)
6 tablas: `station`, `sensor`, `measurement`, `alert_threshold`, `alert`, `app_user`.

### Modelo estrella (OLAP)
- **Dimensiones (5):** `dim_station`, `dim_sensor`, `dim_time`, `dim_threshold`, `dim_user`
- **Hechos (2):** `fact_measurement`, `fact_alert`

El modelo estrella se alimenta mediante un proceso ETL (`06_vrisa_star_dml.sql`) que transforma los datos del modelo OLTP hacia las dimensiones y tablas de hechos correspondientes.

## 3. Problemas resueltos durante el ETL

1. **Llaves subrogadas incorrectas:** la versión inicial del script ETL insertaba directamente los IDs del modelo OLTP en las columnas `*_key` del modelo estrella, en lugar de resolverlos mediante `JOIN` contra cada tabla de dimensión. Se corrigió agregando JOINs explícitos contra `dim_station`, `dim_sensor` y `dim_threshold` para obtener la llave subrogada correcta.

2. **`dim_time` incompleta:** originalmente solo se poblaba con timestamps provenientes de `measurement`, lo que dejaba `fact_alert` vacía por falta de coincidencias. Se corrigió incluyendo también los `start_time` de la tabla `alert` al construir `dim_time`.

3. **Rendimiento de carga:** el archivo de mediciones (~2 millones de INSERT, uno por fila, sin transacción) generaba un commit por cada fila, haciendo la carga extremadamente lenta. Se solucionó envolviendo el contenido entre `BEGIN;` y `COMMIT;`, reduciendo la carga a una sola transacción.

## 4. Consultas analíticas

Se desarrollaron 10 consultas analíticas, cada una en dos versiones —sobre el modelo OLTP y sobre el modelo estrella OLAP— disponibles en `db/queries/07_queries.sql`:

1. Promedio diario por variable
2. Promedio diario por tipo de sensor
3. Promedio y número de mediciones por estación
4. Alertas activas por estación y contaminante
5. Tiempo promedio de resolución de alertas *(solo calculable en el modelo OLTP; el modelo estrella actual no almacena `end_time` en `fact_alert`)*
6. Promedios mensual, semanal y anual
7. Tendencia diaria por tipo de sensor
8. Comparativo mensual por estación y tipo de sensor
9. Distribución de sensores activos por tipo y estación
10. Variación horaria (últimas 24h) de temperatura, ozono y humedad

Todas las consultas fueron validadas contra el dataset completo (~1.8 millones de mediciones, ~3,264 alertas) en el entorno local de Docker.

## 5. Despliegue en la nube y conexión con Looker Studio

Dado que Looker Studio requiere un motor de base de datos accesible desde internet, se migró un subconjunto de los datos a **Supabase** (PostgreSQL administrado), utilizando el *Session Pooler* de Supabase para soportar la transacción larga de carga. La conexión desde Looker Studio se realizó mediante el conector nativo de PostgreSQL, usando una fuente de datos basada en consulta personalizada (JOIN entre `fact_measurement`, `dim_time`, `dim_sensor` y `dim_station`).

**Limitación conocida:** por restricciones de tiempo, el subconjunto cargado en Supabase corresponde a mediciones del período 2020–2021 y, dentro de ese período, únicamente al tipo de sensor **ozono**. Las consultas para temperatura y humedad (punto 10 del checklist) están correctamente implementadas y probadas contra el dataset completo en el entorno local, pero no pudieron representarse visualmente en el tablero por falta de esos datos en la nube.

## 6. Tablero y hallazgos

El tablero incluye 4 visualizaciones:

- **Tendencia diaria por tipo de sensor** (gráfico de líneas)
- **Comparativo mensual por estación** (gráfico de barras)
- **Distribución de mediciones por tipo de sensor** (gráfico circular)
- **Variación horaria de ozono, últimas 24h** (gráfico de líneas)

### Hallazgos principales

- [COMPLETAR: ¿qué estación(es) presentan niveles de ozono más altos?]
- [COMPLETAR: ¿en qué franja horaria se concentran los picos de ozono?]
- [COMPLETAR: ¿hay algún mes o período con comportamiento atípico?]
- La cobertura de datos en el tablero está limitada a ozono (2020–2021); se recomienda como trabajo futuro completar la carga del resto de sensores para un análisis multivariable.

## 7. Conclusión

El proyecto demuestra un flujo completo de ingeniería de datos ambientales: modelado dual (OLTP/OLAP), corrección de un pipeline ETL con errores de integridad referencial, optimización de carga masiva, consultas analíticas validadas en ambos modelos, y despliegue en la nube para visualización. Las limitaciones de cobertura de datos en el tablero final no afectan la validez del diseño de base de datos ni de las consultas, que fueron probadas exhaustivamente contra el dataset completo.
