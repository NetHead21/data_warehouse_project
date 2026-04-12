# Data Warehouse Project

Welcome to the **Data Warehouse Project** repository!
This project demonstrates a comprehensive data warehousing solution built with **PostgreSQL**, following the **Medallion Architecture** (Bronze, Silver, Gold). Designed as a portfolio project, it highlights industry best practices in data engineering including ETL pipelines, data modelling, stored procedures, error handling, and data quality checks.

---

## Data Architecture

This project follows the **Medallion Architecture** with three layers:

1. **Bronze Layer**: Stores raw data as-is from the source systems. Data is ingested from CSV files into PostgreSQL using the `COPY` command via a stored procedure.
2. **Silver Layer**: Applies data cleansing, standardization, deduplication, and transformation to prepare data for analysis.
3. **Gold Layer**: Houses business-ready data modelled into a **star schema** (dimension and fact views) for reporting and analytics.

---

## Project Overview

This project involves:

1. **Data Architecture**: Designing a modern data warehouse using Medallion Architecture (Bronze, Silver, Gold).
2. **ETL Pipelines**: Extracting, transforming, and loading data from source CSV files into the warehouse using PostgreSQL stored procedures.
3. **Data Modelling**: Developing fact and dimension views optimized for analytical queries.
4. **Data Quality**: Writing quality checks to validate assumptions and ensure data integrity across the gold layer.
5. **Documentation**: Providing a data catalog and clear documentation for business stakeholders and analytics teams.

This project is an excellent portfolio piece for professionals and students looking to showcase expertise in:
- SQL Development
- Data Engineering
- ETL Pipeline Development
- Data Modelling
- Data Quality & Testing

---

## Tools & Technologies

- **[PostgreSQL](https://www.postgresql.org/):** Open-source relational database used to host the data warehouse.
- **[DataGrip](https://www.jetbrains.com/datagrip/):** IDE for managing and interacting with the PostgreSQL database.
- **[Git & GitHub](https://github.com/):** Version control and repository management.
- **[DrawIO](https://www.drawio.com/):** For designing data architecture, data flow, and data model diagrams.

---

## Project Requirements

### Data Engineering

#### Objective
Develop a modern data warehouse using PostgreSQL to consolidate sales data from CRM and ERP source systems, enabling analytical reporting and informed decision-making.

#### Specifications
- **Data Sources**: Two source systems (CRM and ERP) provided as CSV files.
- **Data Quality**: Cleanse and resolve data quality issues (nulls, duplicates, invalid values, incorrect formats) prior to analysis.
- **Integration**: Combine both sources into a single, user-friendly data model designed for analytical queries.
- **Scope**: Focus on the latest dataset only; historization of data is not required.
- **Documentation**: Provide clear documentation of the data model to support both business stakeholders and analytics teams.

---

## Repository Structure

```
data_warehouse_project/
│
├── datasets/                           # Raw source datasets (CRM and ERP CSV files)
│   ├── source_crm/                     # CRM source files
│   │   ├── cust_info.csv               # Customer information
│   │   ├── prd_info.csv                # Product information
│   │   └── sales_details.csv           # Sales transactions
│   └── source_erp/                     # ERP source files
│       ├── CUST_AZ12.csv               # Customer demographics
│       ├── LOC_A101.csv                # Customer locations
│       └── PX_CAT_G1V2.csv            # Product categories
│
├── docs/                               # Project documentation
│   └── data_catalog.md                 # Catalog of gold layer views with field descriptions
│
├── scripts/                            # SQL scripts for the full pipeline
│   ├── init_database.sql               # Creates the database and bronze/silver/gold schemas
│   ├── init_broze_tables.sql           # Creates raw ingestion tables in the bronze schema
│   ├── init_silver_tables.sql          # Creates cleaned tables in the silver schema
│   ├── load_bronze.sql                 # Stored procedure to load CSV data into bronze tables
│   ├── load_silver.sql                 # Stored procedure to transform and load silver tables
│   └── init_gold_views.sql             # Creates dim/fact views in the gold schema
│
├── tests/                              # Data quality check scripts
│   └── quality_checks_gold.sql         # 11 quality checks across all gold layer views
│
└── README.md                           # Project overview and instructions
```

---

## Pipeline Execution Order

Run the scripts in the following order:

```
1. scripts/init_database.sql          -- Create database and schemas
         ↓
2. scripts/init_broze_tables.sql      -- Create bronze tables
         ↓
3. CALL bronze.load_bronze();         -- Load raw CSV data into bronze
         ↓
4. scripts/init_silver_tables.sql     -- Create silver tables
         ↓
5. CALL silver.load_silver();         -- Transform and load silver tables
         ↓
6. scripts/init_gold_views.sql        -- Create gold dimension and fact views
         ↓
7. tests/quality_checks_gold.sql      -- Validate gold layer data quality
```

> **Important:** Always run `init_*` scripts before their corresponding `load_*` scripts. Ensure you are connected to the `data_warehouse` database before running any script after step 1.

---

## Data Model (Star Schema)

The gold layer is structured as a **star schema** with the following views:

**Dimensions:**
- `gold.dim_customers` — Customer master data integrating CRM and ERP sources
- `gold.dim_products` — Product master data with category information

**Facts:**
- `gold.fact_sales` — Sales transactions linked to customers and products via surrogate keys

---

## Data Quality Checks

The `tests/quality_checks_gold.sql` file includes **11 checks** across all gold views:

| Check | View | Description |
|---|---|---|
| 1 | dim_customers | No duplicate `customer_key` |
| 2 | dim_customers | No nulls in `customer_key` or `customer_id` |
| 3 | dim_customers | Valid `gender` values only |
| 4 | dim_customers | Valid `marital_status` values only |
| 5 | dim_products | No duplicate `product_key` |
| 6 | dim_products | No nulls in `product_key` or `product_id` |
| 7 | dim_products | Valid `product_line` values only |
| 8 | fact_sales | No orphaned `product_key` |
| 9 | fact_sales | No orphaned `customer_key` |
| 10 | fact_sales | No nulls in key columns |
| 11 | fact_sales | `sales_amount = quantity * price` |

> All checks should return **0 rows** if the data is clean.

---

## License

This project is licensed under the [MIT License](LICENSE). You are free to use, modify, and share this project with proper attribution.
