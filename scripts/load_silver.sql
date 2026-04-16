/*
===============================================
Silver Layer - Data Transformation Load
===============================================
Script Purpose:
    This script loads cleaned and transformed data from the bronze schema
    into the silver schema. Each table undergoes data quality improvements
    including null filtering, deduplication, whitespace trimming, and
    value standardization.

    Tables loaded:
        CRM Source (source_crm):
            - silver.crm_cust_info      <- bronze.crm_cust_info
            - silver.crm_prd_info       <- bronze.crm_prd_info
            - silver.crm_sales_details  <- bronze.crm_sales_details

        ERP Source (source_erp):
            - silver.erp_cust_az12      <- bronze.erp_cust_az12
            - silver.erp_loc_a101       <- bronze.erp_loc_a101
            - silver.erp_px_cat_g1v2    <- bronze.erp_px_cat_g1v2

Warning:
    - Ensure you are connected to the 'data_warehouse' database before running.
    - The silver tables must already exist (run init_silver_tables.sql first).
    - The bronze tables must be loaded before running this script.
===============================================
*/

CREATE OR REPLACE PROCEDURE silver.load_silver()
LANGUAGE plpgsql
AS $$
DECLARE
    v_start_time  TIMESTAMP;
    v_end_time    TIMESTAMP;
    v_total_start TIMESTAMP;
BEGIN
    v_total_start := clock_timestamp();

    RAISE NOTICE '============================================';
    RAISE NOTICE 'Loading Silver Layer';
    RAISE NOTICE '============================================';

    -- ============================================
    -- Truncate All Silver Tables
    -- ============================================

    RAISE NOTICE 'Truncating all silver tables...';
    TRUNCATE TABLE
        silver.crm_cust_info,
        silver.crm_prd_info,
        silver.crm_sales_details,
        silver.erp_cust_az12,
        silver.erp_loc_a101,
        silver.erp_px_cat_g1v2;
    RAISE NOTICE 'Truncation complete.';

    -- ============================================
    -- CRM Tables
    -- ============================================

    RAISE NOTICE '--------------------------------------------';
    RAISE NOTICE 'Loading CRM Tables';
    RAISE NOTICE '--------------------------------------------';

    BEGIN
        v_start_time := clock_timestamp();
        RAISE NOTICE 'Loading silver.crm_cust_info...';

        INSERT INTO silver.crm_cust_info (
            cst_id,
            cst_key,
            cst_firstname,
            cst_lastname,
            cst_marital_status,
            cst_gndr,
            cst_create_date
        )
        SELECT
            cst_id,
            trim(cst_key)           as cst_key,
            trim(cst_firstname)     as cst_firstname,
            trim(cst_lastname)      as cst_lastname,
            case upper(trim(cst_marital_status))
                when 'S' then 'Single'
                when 'M' then 'Married'
                else 'n/a'
            end                     as cst_marital_status,
            case upper(trim(cst_gndr))
                when 'F' then 'Female'
                when 'M' then 'Male'
                else 'n/a'
            end                     as cst_gndr,
            cst_create_date
        FROM (
            SELECT *,
                row_number() over (partition by cst_id order by cst_create_date desc) as flag_last
            FROM bronze.crm_cust_info
            WHERE cst_id is not null
        ) t
        WHERE flag_last = 1;

        v_end_time := clock_timestamp();
        RAISE NOTICE 'silver.crm_cust_info loaded successfully. Rows: % | Duration: %',
            (SELECT COUNT(*) FROM silver.crm_cust_info),
            v_end_time - v_start_time;
    EXCEPTION WHEN OTHERS THEN
        RAISE EXCEPTION 'Failed to load silver.crm_cust_info: %', SQLERRM;
    END;

    BEGIN
        v_start_time := clock_timestamp();
        RAISE NOTICE 'Loading silver.crm_prd_info...';

        INSERT INTO silver.crm_prd_info (
            prd_id,
            cat_id,
            prd_key,
            prd_nm,
            prd_cost,
            prd_line,
            prd_start_dt,
            prd_end_dt
        )
        SELECT
            prd_id,
            replace(substring(prd_key, 1, 5), '-', '_')                                                        as cat_id,
            substring(prd_key, 7)                                                                              as prd_key,
            trim(prd_nm)                                                                                        as prd_nm,
            coalesce(prd_cost, 0)                                                                               as prd_cost,
            case upper(trim(prd_line))
                when 'M' then 'Mountain'
                when 'R' then 'Road'
                when 'S' then 'Other Sales'
                when 'T' then 'Touring'
                else 'n/a'
            end                                                                                                 as prd_line,
            cast(prd_start_dt as date)                                                                         as prd_start_dt,
            (lead(prd_start_dt) over (partition by prd_key order by prd_start_dt) - interval '1 day')::date   as prd_end_dt
        FROM bronze.crm_prd_info;

        v_end_time := clock_timestamp();
        RAISE NOTICE 'silver.crm_prd_info loaded successfully. Rows: % | Duration: %',
            (SELECT COUNT(*) FROM silver.crm_prd_info),
            v_end_time - v_start_time;
    EXCEPTION WHEN OTHERS THEN
        RAISE EXCEPTION 'Failed to load silver.crm_prd_info: %', SQLERRM;
    END;

    BEGIN
        v_start_time := clock_timestamp();
        RAISE NOTICE 'Loading silver.crm_sales_details...';

        INSERT INTO silver.crm_sales_details (
            sls_ord_num,
            sls_prd_key,
            sls_cust_id,
            sls_order_dt,
            sls_ship_dt,
            sls_due_dt,
            sls_sales,
            sls_quantity,
            sls_price
        )
        SELECT
            sls_ord_num,
            sls_prd_key,
            sls_cust_id,
            case
                when sls_order_dt = 0 or length(sls_order_dt::varchar) != 8 then null
                else to_date(sls_order_dt::varchar, 'YYYYMMDD')
            end                                                         as sls_order_dt,
            case
                when sls_ship_dt = 0 or length(sls_ship_dt::varchar) != 8 then null
                else to_date(sls_ship_dt::varchar, 'YYYYMMDD')
            end                                                         as sls_ship_dt,
            case
                when sls_due_dt = 0 or length(sls_due_dt::varchar) != 8 then null
                else to_date(sls_due_dt::varchar, 'YYYYMMDD')
            end                                                         as sls_due_dt,
            case
                when sls_sales is null or sls_sales <= 0 or sls_sales != sls_quantity * abs(sls_price)
                    then sls_quantity * abs(sls_price)
                else sls_sales
            end                                                         as sls_sales,
            sls_quantity,
            case
                when sls_price is null or sls_price = 0
                    then sls_sales / nullif(sls_quantity, 0)
                when sls_price < 0
                    then abs(sls_price)
                else sls_price
            end                                                         as sls_price
        FROM bronze.crm_sales_details;

        v_end_time := clock_timestamp();
        RAISE NOTICE 'silver.crm_sales_details loaded successfully. Rows: % | Duration: %',
            (SELECT COUNT(*) FROM silver.crm_sales_details),
            v_end_time - v_start_time;
    EXCEPTION WHEN OTHERS THEN
        RAISE EXCEPTION 'Failed to load silver.crm_sales_details: %', SQLERRM;
    END;

    -- ============================================
    -- ERP Tables
    -- ============================================

    RAISE NOTICE '--------------------------------------------';
    RAISE NOTICE 'Loading ERP Tables';
    RAISE NOTICE '--------------------------------------------';

    BEGIN
        v_start_time := clock_timestamp();
        RAISE NOTICE 'Loading silver.erp_cust_az12...';

        INSERT INTO silver.erp_cust_az12 (
            cid,
            bdate,
            gen
        )
        SELECT
            case when cid like 'NAS%' then substring(cid, 4)
                else cid
            end                         as cid,
            case when bdate > current_date then null
                else bdate
            end                         as bdate,
            case upper(trim(gen))
                when 'F'      then 'Female'
                when 'FEMALE' then 'Female'
                when 'M'      then 'Male'
                when 'MALE'   then 'Male'
                else 'n/a'
            end                         as gen
        FROM bronze.erp_cust_az12;

        v_end_time := clock_timestamp();
        RAISE NOTICE 'silver.erp_cust_az12 loaded successfully. Rows: % | Duration: %',
            (SELECT COUNT(*) FROM silver.erp_cust_az12),
            v_end_time - v_start_time;
    EXCEPTION WHEN OTHERS THEN
        RAISE EXCEPTION 'Failed to load silver.erp_cust_az12: %', SQLERRM;
    END;

    BEGIN
        v_start_time := clock_timestamp();
        RAISE NOTICE 'Loading silver.erp_loc_a101...';

        INSERT INTO silver.erp_loc_a101 (
            cid,
            cntry
        )
        SELECT
            replace(cid, '-', '')       as cid,
            case
                when trim(cntry) = 'DE'             then 'Germany'
                when trim(cntry) in ('US', 'USA')   then 'United States'
                when trim(cntry) = ''
                  or cntry is null                  then 'n/a'
                else trim(cntry)
            end                         as cntry
        FROM bronze.erp_loc_a101;

        v_end_time := clock_timestamp();
        RAISE NOTICE 'silver.erp_loc_a101 loaded successfully. Rows: % | Duration: %',
            (SELECT COUNT(*) FROM silver.erp_loc_a101),
            v_end_time - v_start_time;
    EXCEPTION WHEN OTHERS THEN
        RAISE EXCEPTION 'Failed to load silver.erp_loc_a101: %', SQLERRM;
    END;

    BEGIN
        v_start_time := clock_timestamp();
        RAISE NOTICE 'Loading silver.erp_px_cat_g1v2...';

        INSERT INTO silver.erp_px_cat_g1v2 (
            id,
            cat,
            subcat,
            maintenance
        )
        SELECT
            id,
            cat,
            subcat,
            maintenance
        FROM bronze.erp_px_cat_g1v2;

        v_end_time := clock_timestamp();
        RAISE NOTICE 'silver.erp_px_cat_g1v2 loaded successfully. Rows: % | Duration: %',
            (SELECT COUNT(*) FROM silver.erp_px_cat_g1v2),
            v_end_time - v_start_time;
    EXCEPTION WHEN OTHERS THEN
        RAISE EXCEPTION 'Failed to load silver.erp_px_cat_g1v2: %', SQLERRM;
    END;

    RAISE NOTICE '============================================';
    RAISE NOTICE 'Silver Layer Loaded Successfully';
    RAISE NOTICE 'Total Duration: %', clock_timestamp() - v_total_start;
    RAISE NOTICE '============================================';
END;
$$;

-- To execute the procedure run:
CALL silver.load_silver();
