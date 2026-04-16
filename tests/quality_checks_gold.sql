/*
===============================================
Gold Layer - Quality Checks
===============================================
Script Purpose:
    This script performs quality checks on the gold layer views to validate
    data integrity, referential integrity, and business rule compliance.
    Each check returns rows only when an issue is found — an empty result
    means the check passed.

    Checks performed:
        gold.dim_customers:
            - Uniqueness of customer_key
            - Nulls in critical columns (customer_key, customer_id)
            - Invalid gender values
            - Invalid marital_status values

        gold.dim_products:
            - Uniqueness of product_key
            - Nulls in critical columns (product_key, product_id)
            - Invalid product_line values

        gold.fact_sales:
            - Referential integrity with dim_customers
            - Referential integrity with dim_products
            - Nulls in key columns (order_number, customer_key, product_key)
            - Sales amount validation (sales = quantity * price)

Warning:
    - Ensure you are connected to the 'data_warehouse' database before running.
    - All checks should return 0 rows if the data is clean.
    - Investigate any rows returned by these checks before proceeding.
===============================================
*/