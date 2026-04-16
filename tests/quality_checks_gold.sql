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


-- ============================================
-- dim_customers Checks
-- ============================================

-- Check 1: Uniqueness of customer_key
-- Expectation: No results (no duplicate customer keys)
SELECT 'dim_customers - Duplicate customer_key' AS check_name,
       customer_key,
       COUNT(*)                                  AS duplicate_count
FROM gold.dim_customers
GROUP BY customer_key
HAVING COUNT(*) > 1;


-- Check 2: Nulls in critical columns
-- Expectation: No results (no nulls in key columns)
SELECT 'dim_customers - Null customer_key or customer_id' AS check_name,
       *
FROM gold.dim_customers
WHERE customer_key IS NULL
   OR customer_id IS NULL;


-- Check 3: Invalid gender values
-- Expectation: No results (only 'Male', 'Female', 'n/a' allowed)
SELECT 'dim_customers - Invalid gender value' AS check_name,
       gender,
       COUNT(*)                               AS record_count
FROM gold.dim_customers
WHERE gender NOT IN ('Male', 'Female', 'n/a')
GROUP BY gender;


-- Check 4: Invalid marital_status values
-- Expectation: No results (only 'Married', 'Single', 'n/a' allowed)
SELECT 'dim_customers - Invalid marital_status value' AS check_name,
       marital_status,
       COUNT(*)                                       AS record_count
FROM gold.dim_customers
WHERE marital_status NOT IN ('Married', 'Single', 'n/a')
GROUP BY marital_status;


-- ============================================
-- dim_products Checks
-- ============================================

-- Check 5: Uniqueness of product_key
-- Expectation: No results (no duplicate product keys)
SELECT 'dim_products - Duplicate product_key' AS check_name,
       product_key,
       COUNT(*)                               AS duplicate_count
FROM gold.dim_products
GROUP BY product_key
HAVING COUNT(*) > 1;


-- Check 6: Nulls in critical columns
-- Expectation: No results (no nulls in key columns)
SELECT 'dim_products - Null product_key or product_id' AS check_name,
       *
FROM gold.dim_products
WHERE product_key IS NULL
   OR product_id IS NULL;


-- Check 7: Invalid product_line values
-- Expectation: No results (only known product lines allowed)
SELECT 'dim_products - Invalid product_line value' AS check_name,
       product_line,
       COUNT(*)                                    AS record_count
FROM gold.dim_products
WHERE product_line NOT IN ('Mountain', 'Road', 'Other Sales', 'Touring', 'n/a')
GROUP BY product_line;


-- ============================================
-- fact_sales Checks
-- ============================================

-- Check 8: Referential integrity - orphaned product keys
-- Expectation: No results (every sale must link to a valid product)
SELECT 'fact_sales - Orphaned product_key' AS check_name,
       f.*
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p ON p.product_key = f.product_key
WHERE p.product_key IS NULL;


-- Check 9: Referential integrity - orphaned customer keys
-- Expectation: No results (every sale must link to a valid customer)
SELECT 'fact_sales - Orphaned customer_key' AS check_name,
       f.*
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c ON c.customer_key = f.customer_key
WHERE c.customer_key IS NULL;


-- Check 10: Nulls in key columns
-- Expectation: No results (order_number, customer_key, product_key must not be null)
SELECT 'fact_sales - Null key columns' AS check_name,
       *
FROM gold.fact_sales
WHERE order_number IS NULL
   OR customer_key IS NULL
   OR product_key IS NULL;


-- Check 11: Sales amount validation (sales = quantity * price)
-- Expectation: No results (sales_amount must equal quantity * price)
SELECT 'fact_sales - sales_amount != quantity * price' AS check_name,
       order_number,
       sales_amount,
       quantity,
       price,
       quantity * price AS expected_sales_amount
FROM gold.fact_sales
WHERE sales_amount != quantity * price;