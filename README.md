# VRISA — Tablero analítico ambiental (Cali, Colombia)

Proyecto de base de datos ambiental para el curso de Bases de datos para
análisis de datos. Modela una red de estaciones de monitoreo de calidad del
aire y clima en Cali, Colombia, y expone esos datos tanto en un esquema
transaccional (OLTP) como en un modelo dimensional en estrella (OLAP), listo
para conectarse a un tablero de Business Intelligence en Looker Studio.

## 📖 Descripción

La red simulada cuenta con **11 estaciones** distribuidas por la ciudad de
Cali, cada una con sensores de ozono, temperatura, humedad, presión y/o
viento. El sistema registra mediciones periódicas y genera **alertas**
automáticas cuando el nivel de un contaminante supera los umbrales definidos
(basados en estándares de calidad del aire tipo EPA).

## 🏗️ Arquitectura de datos

**Capa OLTP** (`station`, `sensor`, `measurement`, `alert_threshold`,
`alert`, `app_user`): modelo relacional normalizado que representa la
operación diaria del sistema de monitoreo.

**Capa OLAP** (`dim_station`, `dim_sensor`, `dim_time`, `dim_threshold`,
`dim_user`, `fact_measurement`, `fact_alert`): modelo en estrella derivado
del OLTP mediante un proceso ETL, pensado para consultas analíticas y para
alimentar el tablero de Looker Studio.

```
OLTP (transaccional)  →  ETL  →  Modelo estrella (OLAP)  →  Looker Studio
```

## 🧰 Tecnologías utilizadas

- **PostgreSQL 16** — motor de base de datos
- **Docker / Docker Compose** — despliegue y orquestación del contenedor
- **pgAdmin** — administración visual de la base de datos
- **Google Looker Studio** — visualización y tablero analítico

## 📁 Estructura del repositorio

```
vrisa-project/
├── docker-compose.yml        # Levanta Postgres + pgAdmin
├── .env.example               # Plantilla de variables de entorno
├── db/
│   ├── init/                  # Scripts ejecutados en orden al crear el contenedor
│   │   ├── 01_vrisa_ddl.sql          # Esquema OLTP
│   │   ├── 02_vrisa_dml.sql          # Estaciones, sensores, umbrales, usuarios
│   │   ├── 03_vrisa_measurements.sql # Mediciones
│   │   ├── 04_vrisa_alerts.sql       # Alertas
│   │   ├── 05_vrisa_star_ddl.sql     # Esquema en estrella (OLAP)
│   │   └── 06_vrisa_star_dml.sql     # ETL: carga del modelo en estrella
│   └── queries/
│       └── 07_queries.sql     # Consultas analíticas (OLTP y OLAP)
├── docs/
│   └── Proyecto.md            # Enunciado original de la actividad
└── informe/                   # Informe final de hallazgos
```

## 🛠️ Proceso de construcción

1. **Diseño del esquema OLTP** — tablas normalizadas para estaciones,
   sensores, mediciones, umbrales de alerta, alertas y usuarios.
2. **Carga de datos maestros** — 11 estaciones en Cali, sensores por
   estación, umbrales de ozono y usuarios del sistema.
3. **Generación de datos operativos** — mediciones horarias por sensor y
   alertas asociadas a superación de umbrales.
4. **Diseño del modelo dimensional en estrella** — dimensiones de estación,
   sensor, tiempo, umbral y usuario, con tablas de hechos de medición y
   de alerta.
5. **ETL hacia el modelo estrella** — población de las dimensiones y de
   las tablas de hechos a partir del esquema OLTP, resolviendo las llaves
   subrogadas (`*_key`) correspondientes en cada tabla de dimensión.
6. **Contenerización** — Docker Compose levanta PostgreSQL y pgAdmin, y
   ejecuta automáticamente todos los scripts de `db/init/` en orden al
   crear el contenedor por primera vez.
7. **Verificación de integridad** — conteo de registros por tabla para
   confirmar que la carga OLTP y la carga OLAP coinciden.
8. **Consultas analíticas y tablero** — construcción de las consultas de
   `db/queries/07_queries.sql` y su conexión a Looker Studio (en curso).

## ▶️ Cómo ejecutar el proyecto

```bash
git clone https://github.com/TU_USUARIO/vrisa-project.git
cd vrisa-project
cp .env.example .env
docker compose up -d
```

Esto levanta dos contenedores:

| Servicio | Descripción | Acceso |
| --- | --- | --- |
| `vrisa_db` | PostgreSQL con el esquema OLTP y OLAP ya cargados | `localhost:5432` |
| `vrisa_pgadmin` | Administración visual de la base | http://localhost:8080 |

Para verificar la carga de datos:

```bash
docker exec -it vrisa_db psql -U vrisa_user -d vrisa_db -c "\dt"
```

📍 Proyecto desarrollado para el curso de Bases de datos para análisis de
datos — datos de estaciones ambientales de Cali, Colombia.
