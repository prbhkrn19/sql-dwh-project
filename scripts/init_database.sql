/*
============================================================
CREATE DATABASE AND SCHEMA
============================================================
Script purpose:
This script creates new database named "Datawarehouse" and creates three Schemas "bronze",
"silver" and "gold".
*/


USE master;
GO

-- Create Database  'DataWarehouse'
-- If database 'DataWarehouse' is present drop and create it.
CREATE DATABASE DataWarehouse;
GO

USE DataWarehouse;
GO

-- Create Schemas bronze, silver and gold
CREATE SCHEMA bronze;
GO

CREATE SCHEMA silver;
GO

CREATE SCHEMA gold;
