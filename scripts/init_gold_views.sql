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


-- ============================================
-- Dimension: Customers
-- ============================================

CREATE OR REPLACE VIEW gold.dim_customers AS
SELECT row_number() over (order by ci.cst_id) as customer_key,
       ci.cst_id                              as customer_id,
       ci.cst_key                             as customer_number,
       ci.cst_firstname                       as first_name,
       ci.cst_lastname                        as last_name,
       ci.cst_marital_status                  as marital_status,
       la.cntry                               as country,
       case
           when ci.cst_gndr != 'n/a' then ci.cst_gndr
           else coalesce(ca.gen, 'n/a')
           end                                as gender,
       ca.bdate                               as birthdate,
       ci.cst_create_date                     as create_date
FROM silver.crm_cust_info ci
         LEFT JOIN silver.erp_cust_az12 ca ON ci.cst_key = ca.cid
         LEFT JOIN silver.erp_loc_a101 la ON ci.cst_key = la.cid;