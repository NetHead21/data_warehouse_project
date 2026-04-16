/*
===============================================
Silver Layer - Table Initialization
===============================================
Script Purpose:
    This script creates the cleaned and transformed tables in the silver schema.
    Each table represents a refined version of its bronze counterpart, with
    data quality improvements, standardization, and the addition of audit
    metadata columns.

    Tables created:
        CRM Source (source_crm):
            - silver.crm_cust_info      : Customer information
            - silver.crm_prd_info       : Product information
            - silver.crm_sales_details  : Sales transactions

        ERP Source (source_erp):
            - silver.erp_cust_az12      : Customer birthdates and gender
            - silver.erp_loc_a101       : Customer locations and countries
            - silver.erp_px_cat_g1v2    : Product categories and subcategories

Warning:
    This script drops and recreates all silver tables on each run.
    All existing data in these tables will be permanently deleted.
    Do NOT run this script in a production environment unless a full
    backup has been taken and data loss is acceptable.
===============================================
*/


-- ============================================
-- CRM Tables
-- ============================================

drop table if exists silver.crm_cust_info;
create table silver.crm_cust_info (
    cst_id              int,
    cst_key             varchar(50),
    cst_firstname       varchar(50),
    cst_lastname        varchar(50),
    cst_marital_status  varchar(50),
    cst_gndr            varchar(50),
    cst_create_date     date,
    dwh_create_date     date default current_date
);


drop table if exists silver.crm_prd_info;
create table silver.crm_prd_info (
    prd_id          int,
    cat_id          varchar(50),
    prd_key         varchar(50),
    prd_nm          varchar(100),
    prd_cost        numeric(10,2),
    prd_line        varchar(50),
    prd_start_dt    date,
    prd_end_dt      date,
    dwh_create_date date default current_date
);


drop table if exists silver.crm_sales_details;
create table silver.crm_sales_details (
    sls_ord_num     varchar(50),
    sls_prd_key     varchar(50),
    sls_cust_id     int,
    sls_order_dt    date,
    sls_ship_dt     date,
    sls_due_dt      date,
    sls_sales       int,
    sls_quantity    int,
    sls_price       int,
    dwh_create_date date default current_date
);
