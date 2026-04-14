/*
===============================================
Bronze Layer - CSV Data Load
===============================================
Script Purpose:
    This script loads raw data from CSV source files into the bronze schema
    tables using PostgreSQL's COPY command. Each table is loaded directly
    from its corresponding source CSV file without any transformation,
    preserving the data exactly as it appears in the source systems.

    Tables loaded:
        CRM Source (source_crm):
            - bronze.crm_cust_info      <- source_crm/cust_info.csv
            - bronze.crm_prd_info       <- source_crm/prd_info.csv
            - bronze.crm_sales_details  <- source_crm/sales_details.csv

        ERP Source (source_erp):
            - bronze.erp_cust_az12      <- source_erp/CUST_AZ12.csv
            - bronze.erp_loc_a101       <- source_erp/LOC_A101.csv
            - bronze.erp_px_cat_g1v2    <- source_erp/PX_CAT_G1V2.csv

Warning:
    - Ensure you are connected to the 'data_warehouse' database before running.
    - The bronze tables must already exist (run init_broze_tables.sql first).
    - The COPY command requires the file paths to be accessible by the
      PostgreSQL server. Update the file paths if your directory structure
      differs.
===============================================
*/


CREATE OR REPLACE PROCEDURE bronze.load_bronze()
LANGUAGE plpgsql
AS $$
DECLARE
    v_start_time  TIMESTAMP;
    v_end_time    TIMESTAMP;
    v_total_start TIMESTAMP;


BEGIN
    v_total_start := clock_timestamp();

    RAISE NOTICE '============================================';
    RAISE NOTICE 'Loading Bronze Layer';
    RAISE NOTICE '============================================';

    -- ============================================
    -- Truncate All Bronze Tables
    -- ============================================

    RAISE NOTICE 'Truncating all bronze tables...';
    TRUNCATE TABLE
        bronze.crm_cust_info,
        bronze.crm_prd_info,
        bronze.crm_sales_details,
        bronze.erp_cust_az12,
        bronze.erp_loc_a101,
        bronze.erp_px_cat_g1v2;
    RAISE NOTICE 'Truncation complete.';

    -- ============================================
    -- CRM Tables
    -- ============================================

    RAISE NOTICE '--------------------------------------------';
    RAISE NOTICE 'Loading CRM Tables';
    RAISE NOTICE '--------------------------------------------';

    BEGIN
        v_start_time := clock_timestamp();
        RAISE NOTICE 'Loading bronze.crm_cust_info...';
        COPY bronze.crm_cust_info
        FROM 'C:/DataEngineeringProject/data_warehouse_project/datasets/source_crm/cust_info.csv'
        DELIMITER ','
        CSV HEADER;
        v_end_time := clock_timestamp();
        RAISE NOTICE 'bronze.crm_cust_info loaded successfully. Rows: % | Duration: %',
            (SELECT COUNT(*) FROM bronze.crm_cust_info),
            v_end_time - v_start_time;

    EXCEPTION WHEN OTHERS THEN
        RAISE EXCEPTION 'Failed to load bronze.crm_cust_info: %', SQLERRM;
    END;


    BEGIN
        v_start_time := clock_timestamp();
        RAISE NOTICE 'Loading bronze.crm_prd_info...';
        COPY bronze.crm_prd_info
        FROM 'C:/DataEngineeringProject/data_warehouse_project/datasets/source_crm/prd_info.csv'
        DELIMITER ','
        CSV HEADER;
        v_end_time := clock_timestamp();
        RAISE NOTICE 'bronze.crm_prd_info loaded successfully. Rows: % | Duration: %',
            (SELECT COUNT(*) FROM bronze.crm_prd_info),
            v_end_time - v_start_time;
    EXCEPTION WHEN OTHERS THEN
        RAISE EXCEPTION 'Failed to load bronze.crm_prd_info: %', SQLERRM;
    END;


    BEGIN
        v_start_time := clock_timestamp();
        RAISE NOTICE 'Loading bronze.crm_sales_details...';
        COPY bronze.crm_sales_details
        FROM 'C:/DataEngineeringProject/data_warehouse_project/datasets/source_crm/sales_details.csv'
        DELIMITER ','
        CSV HEADER;
        v_end_time := clock_timestamp();
        RAISE NOTICE 'bronze.crm_sales_details loaded successfully. Rows: % | Duration: %',
            (SELECT COUNT(*) FROM bronze.crm_sales_details),
            v_end_time - v_start_time;
    EXCEPTION WHEN OTHERS THEN
        RAISE EXCEPTION 'Failed to load bronze.crm_sales_details: %', SQLERRM;
    END;


    -- ============================================
    -- ERP Tables
    -- ============================================

    RAISE NOTICE '--------------------------------------------';
    RAISE NOTICE 'Loading ERP Tables';
    RAISE NOTICE '--------------------------------------------';


    BEGIN
        v_start_time := clock_timestamp();
        RAISE NOTICE 'Loading bronze.erp_cust_az12...';
        COPY bronze.erp_cust_az12
        FROM 'C:/DataEngineeringProject/data_warehouse_project/datasets/source_erp/CUST_AZ12.csv'
        DELIMITER ','
        CSV HEADER;
        v_end_time := clock_timestamp();
        RAISE NOTICE 'bronze.erp_cust_az12 loaded successfully. Rows: % | Duration: %',
            (SELECT COUNT(*) FROM bronze.erp_cust_az12),
            v_end_time - v_start_time;
    EXCEPTION WHEN OTHERS THEN
        RAISE EXCEPTION 'Failed to load bronze.erp_cust_az12: %', SQLERRM;
    END;


    BEGIN
        v_start_time := clock_timestamp();
        RAISE NOTICE 'Loading bronze.erp_loc_a101...';
        COPY bronze.erp_loc_a101
        FROM 'C:/DataEngineeringProject/data_warehouse_project/datasets/source_erp/LOC_A101.csv'
        DELIMITER ','
        CSV HEADER;
        v_end_time := clock_timestamp();
        RAISE NOTICE 'bronze.erp_loc_a101 loaded successfully. Rows: % | Duration: %',
            (SELECT COUNT(*) FROM bronze.erp_loc_a101),
            v_end_time - v_start_time;
    EXCEPTION WHEN OTHERS THEN
        RAISE EXCEPTION 'Failed to load bronze.erp_loc_a101: %', SQLERRM;
    END;


    BEGIN
        v_start_time := clock_timestamp();
        RAISE NOTICE 'Loading bronze.erp_px_cat_g1v2...';
        COPY bronze.erp_px_cat_g1v2
        FROM 'C:/DataEngineeringProject/data_warehouse_project/datasets/source_erp/PX_CAT_G1V2.csv'
        DELIMITER ','
        CSV HEADER;
        v_end_time := clock_timestamp();
        RAISE NOTICE 'bronze.erp_px_cat_g1v2 loaded successfully. Rows: % | Duration: %',
            (SELECT COUNT(*) FROM bronze.erp_px_cat_g1v2),
            v_end_time - v_start_time;