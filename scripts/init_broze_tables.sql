/*
===============================================
Bronze Layer - Table Initialization
===============================================
Script Purpose:
    This script creates the raw ingestion tables in the bronze schema.
    Each table mirrors the structure of its source CSV file exactly,
    preserving all original columns and data as-is without transformation.

    Tables created:
        CRM Source (source_crm):
            - bronze.crm_cust_info      : Customer information
            - bronze.crm_prd_info       : Product information
            - bronze.crm_sales_details  : Sales transactions

        ERP Source (source_erp):
            - bronze.erp_cust_az12      : Customer birthdates and gender
            - bronze.erp_loc_a101       : Customer locations and countries
            - bronze.erp_px_cat_g1v2    : Product categories and subcategories

Warning:
    This script drops and recreates all bronze tables on each run.
    All existing data in these tables will be permanently deleted.
    Do NOT run this script in a production environment unless a full
    backup has been taken and data loss is acceptable.
===============================================
*/


-- ============================================
-- CRM Tables
-- ============================================

drop table if exists bronze.crm_cust_info;
create table bronze.crm_cust_info (
    cst_id              int,
    cst_key             varchar(50),
    cst_firstname       varchar(50),
    cst_lastname        varchar(50),
    cst_marital_status  varchar(50),
    cst_gndr            varchar(50),
    cst_create_date     date
);