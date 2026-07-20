IF OBJECT_ID('bronze.crm_customer_info', 'U') IS NOT NULL
	DROP TABLE bronze.crm_customer_info;
GO

CREATE TABLE bronze.crm_customer_info (
	customer_id				INT,
	customer_key			NVARCHAR(50),
	customer_firstname		NVARCHAR(50),
	Customer_lastname		NVARCHAR(50),
	customer_marital_status NVARCHAR(50),
	customer_gender			NVARCHAR(50),
	customer_create_date	DATE
)
GO

IF OBJECT_ID('bronze.crm_product_info', 'U') IS NOT NULL
	DROP TABLE bronze.crm_product_info;
GO

CREATE TABLE bronze.crm_product_info (
	product_id			INT,
	product_key			NVARCHAR(50),
	product_name		NVARCHAR(50),
	product_cost		INT,
	product_line		NVARCHAR(50),
	product_start_date	DATE,
	product_end_date	DATE
)
GO

IF OBJECT_ID('bronze.crm_sales_details', 'U') IS NOT NULL
	DROP TABLE bronze.crm_sales_details;
GO

CREATE TABLE bronze.crm_sales_details (
	sales_order_number	NVARCHAR(50),
	sales_product_key	NVARCHAR(50),
	sales_customer_id	INT,
	sales_order_date	INT,
	sales_ship_date		INT,
	sales_due_date		INT,
	sales_sales			INT,
	sales_quantity		INT,
	sales_price			INT
)
GO

IF OBJECT_ID('bronze.erp_loc_a101', 'U') IS NOT NULL
	DROP TABLE bronze.erp_loc_a101;
GO

CREATE TABLE bronze.erp_loc_a101 (
    cid    NVARCHAR(50),
    cntry  NVARCHAR(50)
);
GO

IF OBJECT_ID('bronze.erp_cust_az12', 'U') IS NOT NULL
	DROP TABLE bronze.erp_cust_az12;
GO

CREATE TABLE bronze.erp_cust_az12 (
    cid    NVARCHAR(50),
    bdate  DATE,
    gen    NVARCHAR(50)
);
GO

IF OBJECT_ID('bronze.erp_px_cat_g1v2', 'U') IS NOT NULL
    DROP TABLE bronze.erp_px_cat_g1v2;
GO

CREATE TABLE bronze.erp_px_cat_g1v2 (
    id           NVARCHAR(50),
    cat          NVARCHAR(50),
    subcat       NVARCHAR(50),
    maintenance  NVARCHAR(50)
);
GO
