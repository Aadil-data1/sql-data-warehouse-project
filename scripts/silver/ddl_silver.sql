
/* 
===================================================================
DDL SCRIPT: CREATE Silver TABLES
===================================================================
this script creates tables in 'silver schema'..
**********************************************************************************
*/








create table silver.crm_cust_info(

	cst_id int,
	cst_key nvarchar(50),
	cst_firstname nvarchar(50),
	cst_lastname nvarchar(50),
	cst_marital_status nvarchar(50),
	cst_gndr nvarchar(50),
	cst_create_date date,
	dwh_create_date datetime2 default getdate()

);

create table silver.crm_prd_info
(

	prd_id int,
	prd_key nvarchar(50),
	prd_name nvarchar(50),
	prd_cost int,
	prd_line nvarchar(50),
	prd_start_date date,
	prd_end_date date,
	dwh_create_date datetime2 default getdate()
);

create table silver.crm_sales_details
(

	sls_ord_num nvarchar(50),
	sls_prd_key nvarchar(50),
	sls_cust_id int,
	sls_ord_date date,
	sls_ship_date date,
	sls_due_date date,
	sls_sales nvarchar(50),
	sls_quantity int,
	sls_price nvarchar(50),
	dwh_create_date datetime2 default getdate()
);


create table silver.erp_cust_AZ12
(
cust_customer_id nvarchar(50),
cust_birth_date date,
cust_gender nvarchar(50),
dwh_create_date datetime2 default getdate()

);

create table silver.erp_loc_A101
(
cust_c_id nvarchar(50),
cust_country nvarchar(50),
dwh_create_date datetime2 default getdate()
);

create table silver.erp_category
(
cust_id nvarchar(50),
cust_category nvarchar(50),
cust_subcategory nvarchar(50),
cust_maintenance nvarchar(50),
dwh_create_date datetime2 default getdate()
);

