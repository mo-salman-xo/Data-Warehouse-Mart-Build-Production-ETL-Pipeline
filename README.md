# 🏗️ Data Warehouse & Mart Build: Production ETL Pipeline

An end-to-end data engineering pipeline that transforms raw CSV files from Google Cloud Storage into a normalized **star schema data warehouse**, then builds specialized **analytical data marts** on top of it.

![Data Pipeline Architecture](./Images/1_2_Project2_Data_Pipeline.png)

---

## 🧾 Project Overview

- ✅ **Pipeline scope:** Built a complete **ETL pipeline** from raw CSVs → star schema warehouse → analytical marts
- ✅ **Data modeling:** Designed a **star schema** with fact, dimension, and bridge tables to handle many-to-many relationships
- ✅ **ETL development:** Implemented **extract, transform, load** processes with idempotent operations and data quality checks
- ✅ **Mart architecture:** Created **specialized data marts** (flat, skills, priority) with additive measures and **incremental `MERGE` updates**
- ✅ **Automation:** One master SQL script rebuilds the entire warehouse and every mart end to end

---

## 🧩 Problem & Context

Raw job posting data arrives as flat CSV files in Google Cloud Storage. It is not structured for analytical queries, and analysts need to answer questions like:

- Which skills are most in demand over time?
- What are the hiring trends by company and location?
- How do salary patterns vary by role and skill?

**Challenge:** Data teams need a single source of truth, a data warehouse, to enable consistent and reliable analysis across the organization. On top of that, specialized data marts are required to pre-aggregate data for specific business use cases, which reduces query complexity, saves compute, and improves performance for common analytical patterns.

**Solution:** An end-to-end ETL pipeline that:

1. **Extracts** CSVs directly from cloud storage
2. **Transforms and loads** them into a star schema warehouse (separating facts from dimensions)
3. **Builds data marts** optimized for specific use cases: flat queries, skill demand analysis, and priority role tracking

---

## 🧰 Tech Stack

| Layer | Tools |
|-------|-------|
| 🐤 **Database** | DuckDB (file-based OLAP database with GCS integration via `httpfs`) |
| 🧮 **Language** | SQL (DDL for schema design, DML for loading and transformation) |
| 📊 **Data Model** | Star schema (fact + dimension + bridge tables) |
| 🛠️ **Development** | VS Code for SQL editing + Terminal for DuckDB CLI execution |
| 🔧 **Automation** | Master SQL script for pipeline orchestration |
| 📦 **Version Control** | Git / GitHub for versioned pipeline scripts |
| ☁️ **Storage** | Google Cloud Storage for source CSV files |

---

## 📂 Repository Structure

```text
2_DW_Mart_Build/
├── Images/                         # Architecture & schema diagrams used in this README
├── .gitignore                      # Git ignore rules
├── 01_create_tables_dw.sql         # Star schema DDL
├── 02_load_schema_dw.sql           # GCS data extraction & loading
├── 03_create_flat_mart.sql         # Denormalized flat mart
├── 04_create_skills_mart.sql       # Skills demand mart
├── 05_create_priority_mart.sql     # Priority roles mart
├── 06_update_priority_mart.sql     # Priority mart incremental update (MERGE)
├── build_dw_marts.sql              # Master SQL build script
└── README.md                       # You are here
```

---

## 🏗️ Pipeline Architecture

![Data Pipeline Architecture](./Images/1_2_Project2_Data_Pipeline.png)

The pipeline transforms job posting CSVs from Google Cloud Storage into a normalized star schema data warehouse, then builds specialized analytical data marts. BI tools (Excel, Power BI, Tableau, Python) consume from both the warehouse and the marts.

```text
GCS (raw CSVs)  ──►  Data Warehouse (star schema)  ──►  Data Marts  ──►  BI / Analytics
                                                          ├─ Flat Mart
                                                          ├─ Skills Mart
                                                          └─ Priority Mart
```

### 🏛️ Data Warehouse

The data warehouse implements a star schema with `company_dim`, `skills_dim`, `job_postings_fact`, and `skills_job_dim` tables.

![Data Warehouse Schema](./Images/1_2_Data_Warehouse.png)

- **SQL Files:**
  - [`01_create_tables_dw.sql`](./01_create_tables_dw.sql): Defines the star schema with 4 core tables
  - [`02_load_schema_dw.sql`](./02_load_schema_dw.sql): Extracts CSVs from GCS and loads them into the warehouse tables
- **Purpose:** Star schema serving as the single source of truth for analytical queries
- **Grain:** One row per job posting in the fact table (`job_postings_fact`)

### 📋 Flat Mart

A denormalized table with all dimensions joined, built for ad-hoc queries.

![Flat Mart Schema](./Images/1_2_Flat_Mart.png)

- **SQL File:** [`03_create_flat_mart.sql`](./03_create_flat_mart.sql): Builds the denormalized table with all dimensions joined
- **Purpose:** Quick ad-hoc queries without writing multi-table joins
- **Grain:** One row per job posting with all dimensions joined

### 🧠 Skills Mart

Time-series skill demand analysis with additive measures.

![Skills Mart Schema](./Images/1_2_Skills_Mart.png)

- **SQL File:** [`04_create_skills_mart.sql`](./04_create_skills_mart.sql): Builds the time-series skill demand mart
- **Purpose:** Analyze how skill demand changes over time
- **Grain:** `skill_id + month_start_date + job_title_short`
- **Key Features:** All measures are additive (counts/sums), so they can be safely re-aggregated at any level

### ⭐ Priority Mart

Priority role tracking with incremental updates using `MERGE` operations.

![Priority Mart Schema](./Images/1_2_Priority_Mart.png)

- **SQL Files:**
  - [`05_create_priority_mart.sql`](./05_create_priority_mart.sql): Initial build of priority roles and the jobs snapshot
  - [`06_update_priority_mart.sql`](./06_update_priority_mart.sql): **Incremental update using `MERGE`** (upsert pattern)
- **Purpose:** Track priority roles and job snapshots with incremental update capability
- **Grain:** One row per job posting with a priority level assignment
- **Key Features:** **`MERGE` operations for incremental updates**, a production-ready upsert pattern (INSERT, UPDATE, DELETE in a single statement)

---

## 🚀 How to Run

**Prerequisites:** [DuckDB CLI](https://duckdb.org/docs/installation/) installed and internet access to reach the GCS bucket.

```bash
# 1. Clone the repository and move into the project folder
cd 2_DW_Mart_Build

# 2. Run the master script (builds the warehouse + all marts)
duckdb dw_marts.duckdb -c ".read build_dw_marts.sql"
```

This creates (or reuses) the `dw_marts.duckdb` database file and executes the full pipeline inside it. To run a single stage on its own, point it at the same database:

```bash
duckdb dw_marts.duckdb -c ".read 01_create_tables_dw.sql"
duckdb dw_marts.duckdb -c ".read 02_load_schema_dw.sql"
duckdb dw_marts.duckdb -c ".read 03_create_flat_mart.sql"
```

To explore the results afterwards, open the database interactively:

```bash
duckdb dw_marts.duckdb
```

> 💡 Every script is idempotent, so you can safely re-run the pipeline at any time without side effects.

![Pipeline Execution](./Images/Pipeline%20Execution.png)

---

## 💻 Data Engineering Skills Demonstrated

### ETL Pipeline Development

- **Extract:** Direct CSV loading from Google Cloud Storage using DuckDB's `httpfs` extension
- **Transform:** Data normalization, type conversion (`CAST`, `DATE_TRUNC`), and quality filtering
- **Load:** Idempotent table creation with `DROP TABLE IF EXISTS` patterns
- **Incremental Updates:** `MERGE` operations for upsert patterns (INSERT, UPDATE, DELETE in a single statement)
- **Orchestration:** Master SQL script (`build_dw_marts.sql`) for automated pipeline execution

### Dimensional Modeling

- **Star Schema Design:** Fact table (`job_postings_fact`) with dimension tables (`company_dim`, `skills_dim`)
- **Bridge Tables:** Many-to-many relationship handling (`skills_job_dim`)
- **Grain Definition:** Proper fact table granularity (one row per posting; skill + month + job title)
- **Additive Measures:** Counts and sums that can be safely re-aggregated at any level

### SQL Advanced Techniques

- **DDL Operations:** `CREATE TABLE`, `DROP TABLE`, `CREATE SCHEMA` for schema management
- **DML Operations:** `INSERT INTO ... SELECT` with explicit column mapping from CSV sources
- **MERGE Operations:** Incremental updates using `MERGE INTO` with `WHEN MATCHED`, `WHEN NOT MATCHED`, and `WHEN NOT MATCHED BY SOURCE` clauses
- **CTEs:** Common Table Expressions for complex transformations and boolean flag conversions
- **Date Functions:** `DATE_TRUNC('month')`, `EXTRACT(quarter)` for temporal dimension creation
- **String Functions:** `STRING_AGG` for concatenation, `REPLACE` for data cleaning
- **Boolean Logic:** `CASE WHEN` conversions for aggregating flags (remote, health insurance, no degree)

### Data Quality & Production Practices

- **Idempotency:** All scripts are safely re-runnable without side effects
- **Data Validation:** Verification queries at each pipeline step to ensure data integrity
- **Type Safety:** Proper data type definitions (`VARCHAR`, `INTEGER`, `DOUBLE`, `BOOLEAN`, `TIMESTAMP`)
- **Schema Organization:** Separate schemas (`flat_mart`, `skills_mart`, `priority_mart`) for logical separation
- **Error Handling:** Structured script execution with clear error messages and progress reporting

---

## 📈 Example Use Cases

| Business Question | Best Source |
|-------------------|-------------|
| Quick ad-hoc exploration of any job posting | `flat_mart` |
| Which skills are trending up or down month over month? | `skills_mart` |
| Which priority roles need attention right now? | `priority_mart` |
| Custom analysis across any dimension (company, skill, location) | Data warehouse (star schema) |


---

## 🎯 Key Takeaways

- A **star schema** keeps the warehouse clean, consistent, and a single source of truth
- **Purpose-built marts** reduce query complexity and speed up common analytical patterns
- **Additive measures** make marts safe to re-aggregate without double counting
- **`MERGE`-based incremental loads** avoid full rebuilds and mirror real production patterns
- **Idempotent, scripted pipelines** make the entire build repeatable and easy to automate