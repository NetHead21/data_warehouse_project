/*
===============================================
Create Database and Schemas
===============================================
Script Purpose:
    This script initializes the data warehouse database and its core schemas.
    It creates the 'data_warehouse' database along with three layered schemas:
        - bronze: Raw ingested data (source layer)
        - silver: Cleaned and transformed data (staging layer)
        - gold:   Aggregated and business-ready data (analytics layer)

Warning:
    This script drops the existing 'data_warehouse' database before recreating it.
    ALL existing data, tables, and objects within the database will be permanently
    deleted. Do NOT run this script in a production environment unless a full
    backup has been taken and data loss is acceptable.
===============================================
*/


-- Step 1: Run this while connected to the 'postgres' database
drop database if exists data_warehouse;
create database data_warehouse;


-- =====================================================
-- IMPORTANT: Before running Step 2, switch your
-- connection to the 'data_warehouse' database.
-- In psql: \c data_warehouse
-- In a GUI tool: manually change the active connection.
-- =====================================================

-- Step 2: Run this after switching to 'data_warehouse'
create schema bronze;
create schema silver;
create schema gold;
