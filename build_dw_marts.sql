
-- Step 1 : DW - Create Star schema tables
.read 01_create_tables_dw.sql

--Step 2 : Load data from CSV files into our table
.read 02_load_schema_dw.sql