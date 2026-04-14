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
