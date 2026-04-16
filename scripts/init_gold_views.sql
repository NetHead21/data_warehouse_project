/*
===============================================
Gold Layer - Views Initialization
===============================================
Script Purpose:
    This script creates the business-ready views in the gold schema.
    Each view represents a fully transformed, cleaned, and integrated
    dataset ready for reporting and analytics. The gold layer follows
    a dimensional modelling approach with dimension and fact tables.

    Views created:
        Dimensions:
            - gold.dim_customers : Customer master data integrating CRM
                                   and ERP sources
            - gold.dim_products  : Product master data with category
                                   information

        Facts:
            - gold.fact_sales    : Sales transactions linked to customers
                                   and products

Warning:
    - Ensure you are connected to the 'data_warehouse' database before running.
    - The silver tables must be loaded before running this script
      (run load_silver.sql first).
    - Re-running this script will replace existing views with updated
      definitions. No data will be lost.
===============================================
*/