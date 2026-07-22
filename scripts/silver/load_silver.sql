CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
	DECLARE @batch_start_time DATETIME, @batch_end_time DATETIME, @start_time DATETIME, @end_time DATETIME
	BEGIN TRY
		SET @batch_start_time = GETDATE()
		PRINT '======================================';
		PRINT 'Loading bronze Layer';
		PRINT '======================================';
	
		PRINT '---------------------------------------';
		PRINT 'Loading CRM tables';
		PRINT '---------------------------------------';

		PRINT '====================================='
		PRINT '>> Truncating data from silver.crm_customer_info'
		SET @start_time = GETDATE()
		TRUNCATE TABLE silver.crm_customer_info;

		PRINT '>> inserting data into: silver.crm_customer_info'
		INSERT INTO silver.crm_customer_info (
			customer_id,
			customer_key,
			customer_firstname,
			customer_lastname,
			customer_marital_status,
			customer_gender,
			customer_create_date
		)

		SELECT
			customer_id,
			customer_key,
			TRIM(customer_firstname) AS customer_firstname,
			TRIM(customer_lastname) AS customer_lastname,
			CASE
				WHEN UPPER(TRIM(customer_marital_status)) = 'M' THEN 'Married'
				WHEN UPPER(TRIM(customer_marital_status)) = 'S' THEN 'Single'
				ELSE 'n/a'
			END AS customer_marital_status,
			CASE
				WHEN UPPER(TRIM(customer_gender)) = 'M' THEN 'Male'
				WHEN UPPER(TRIM(customer_gender)) = 'F' THEN 'Female'
				ELSE 'n/a'
			END AS customer_gender,
			customer_create_date
		FROM (
		SELECT
			*,
			ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY customer_create_date DESC) AS flag_last
		FROM bronze.crm_customer_info 
		WHERE customer_id IS NOT NULL) t 
		WHERE flag_last = 1
		SET @end_time = GETDATE()
		PRINT 'Time taken for loading silver.crm_customer_info is ' +
			CAST(DATEDIFF(second, @end_time, @start_time) AS VARCHAR) + ' seconds.'

		PRINT '====================================='

		PRINT '>> Truncating data from silver.crm_product_info'
		SET @start_time = GETDATE()
		TRUNCATE TABLE silver.crm_product_info;

		PRINT '>> inserting data into: silver.crm_product_info'
		INSERT INTO silver.crm_product_info (
			product_id,
			category_id,
			product_key,
			product_name,
			product_cost,
			product_line,
			product_start_date,
			product_end_date
		)
		SELECT 
			product_id,
			REPLACE(SUBSTRING(product_key, 1, 5), '-', '_') AS category_id,
			SUBSTRING(product_key, 7, LEN(product_key)) AS product_key,
			product_name,
			ISNULL(product_cost, 0) AS product_cost,
			CASE UPPER(TRIM(product_line))
				WHEN 'M' THEN 'Mountain'
				WHEN 'R' THEN 'Road'
				WHEN 'S' THEN 'Other Sales'
				WHEN 'T' THEN 'Touring'
				ELSE 'n/a'
			END AS product_line,
			product_start_date,
			DATEADD(day, -1, LEAD(product_start_date) OVER(PARTITION BY product_key ORDER BY product_start_date)) AS product_end_date
		FROM bronze.crm_product_info
		SET @end_time = GETDATE()
		PRINT 'Time taken for loading silver.crm_product_info ' +
			CAST(DATEDIFF(second, @end_time, @start_time) AS VARCHAR) + ' seconds.'

		PRINT '====================================='

		PRINT '>> Truncating data from silver.crm_sales_details'
		SET @start_time = GETDATE()
		TRUNCATE TABLE silver.crm_sales_details;

		PRINT '>> inserting data into: silver.crm_sales_details'
		INSERT INTO silver.crm_sales_details (
			sales_order_number,
			sales_product_key,
			sales_customer_id,
			sales_order_date,
			sales_ship_date,
			sales_due_date,
			sales_sales,
			sales_quantity,
			sales_price
		)
		SELECT 
			sales_order_number,
			sales_product_key,
			sales_customer_id,
			CASE
				WHEN sales_order_date <= 0 OR LEN(sales_order_date) != 8 THEN NULL
				ELSE CAST(CAST(sales_order_date AS VARCHAR) AS DATE)
			END AS sales_order_date,
			CASE
				WHEN sales_ship_date <= 0 OR LEN(sales_ship_date) != 8 THEN NULL
				ELSE CAST(CAST(sales_ship_date AS VARCHAR) AS DATE)
			END AS sales_ship_date,
			CASE
				WHEN sales_due_date <= 0 OR LEN(sales_due_date) != 8 THEN NULL
				ELSE CAST(CAST(sales_due_date AS VARCHAR) AS DATE)
			END AS sales_due_date,
			CASE 
				WHEN sales_sales <= 0 OR sales_sales IS NULL OR sales_sales != sales_quantity * ABS(sales_price)
					THEN ABS(sales_price) * sales_quantity
				ELSE sales_sales
			END AS sales_sales,
			sales_quantity,
			CASE 
				WHEN sales_price IS NULL OR sales_price <= 0
					THEN sales_sales/NULLIF(sales_quantity, 0)
				ELSE sales_price
			END AS sales_price
		FROM bronze.crm_sales_details
		SET @end_time = GETDATE()
		PRINT 'Time taken for loading silver.crm_sales_details is ' +
			CAST(DATEDIFF(second, @end_time, @start_time) AS VARCHAR) + ' seconds.'

		PRINT '====================================='

		PRINT '---------------------------------------';
		PRINT 'Loading ERP tables';
		PRINT '---------------------------------------';

		PRINT '>> Truncating data from silver.erp_cust_az12'
		SET @start_time = GETDATE()
		TRUNCATE TABLE silver.erp_cust_az12;

		PRINT '>> inserting data into: silver.erp_cust_az12'
		INSERT INTO silver.erp_cust_az12 (
			cid,
			bdate,
			gen
		)
		SELECT  
			CASE
				WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
				ELSE cid
			END AS cid,
			CASE
				WHEN bdate > GETDATE() THEN NULL
				ELSE bdate
			END AS bdate,
			CASE
				WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
				WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
				ELSE 'n/a'
			END AS gen
		FROM bronze.erp_cust_az12
		SET @end_time = GETDATE()
		PRINT 'Time taken for loading silver.erp_cust_az12 is ' +
			CAST(DATEDIFF(second, @end_time, @start_time) AS VARCHAR) + ' seconds.'

		PRINT '====================================='

		PRINT '>> Truncating data from silver.erp_loc_a101'
		SET @start_time = GETDATE()
		TRUNCATE TABLE silver.erp_loc_a101;

		PRINT '>> inserting data into: silver.erp_loc_a101'
		INSERT INTO silver.erp_loc_a101 (
			cid,
			cntry
		)
		SELECT 
			REPLACE(cid, '-', '') AS cid, 
			CASE 
				WHEN UPPER(TRIM(cntry)) IN ('DE', 'GERMANY') THEN 'Germany'
				WHEN UPPER(TRIM(cntry)) IN ('US', 'USA') THEN 'United States'
				WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'n/a'
				ELSE TRIM(cntry)
			END cntry 
		FROM bronze.erp_loc_a101

		SET @end_time = GETDATE()
		PRINT 'Time taken for loading silver.erp_loc_a101 is ' +
			CAST(DATEDIFF(second, @end_time, @start_time) AS VARCHAR) + ' seconds.'

		PRINT '====================================='

		PRINT '>> Truncating data from silver.erp_px_cat_g1v2'
		SET @start_time = GETDATE()
		TRUNCATE TABLE silver.erp_px_cat_g1v2;

		PRINT '>> inserting data into: silver.erp_px_cat_g1v2'
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
		FROM bronze.erp_px_cat_g1v2

		SET @end_time = GETDATE()
		PRINT 'Time taken for loading silver.erp_px_cat_g1v2 is ' +
			CAST(DATEDIFF(second, @end_time, @start_time) AS VARCHAR) + ' seconds.'
		PRINT '====================================='

		SET @batch_end_time = GETDATE()
		PRINT 'Time taken for batch loading ' + 
			CAST(DATEDIFF(second, @batch_end_time, @batch_start_time) AS VARCHAR) + 'seconds'
	END TRY
	BEGIN CATCH
		PRINT '========================================';
		PRINT 'Error occurred during  loading silver layer';
		PRINT 'Error Message ' + ERROR_MESSAGE();
		PRINT 'ERROR Message ' + CAST (ERROR_NUMBER() AS NVARCHAR);
		PRINT '========================================';
	END CATCH
END
