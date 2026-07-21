

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