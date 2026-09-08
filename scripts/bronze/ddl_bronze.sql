
/* 
===================================================================
DDL SCRIPT: CREATE BRONZE TABLES
===================================================================
this script creates tables in 'bronze schema', and altering for undesirable datatype.
**********************************************************************************
*/







create table bronze.crm_cust_info(

	cst_id int,
	cst_key nvarchar(50),
	cst_firstname nvarchar(50),
	cst_lastname nvarchar(50),
	cst_marital_status nvarchar(50),
	cst_gndr nvarchar(50),
	cst_create_date date

);

drop table bronze.crm_cust_info

create table bronze.crm_cust_info(

	cst_id int,
	cst_key nvarchar(50),
	cst_firstname nvarchar(50),
	cst_lastname nvarchar(50),
	cst_marital_status nvarchar(50),
	cst_gndr nvarchar(50),
	cst_create_date date

);

create table bronze.crm_prd_info
(

	prd_id int,
	prd_key nvarchar(50),
	prd_name nvarchar(50),
	prd_cost int,
	prd_line nvarchar(50),
	prd_start_date date,
	prd_end_date date
);

create table bronze.crm_sales_details
(

	sls_ord_num varchar,
	sls_prd_key nvarchar(50),
	sls_cust_id int,
	sls_ord_date date,
	sls_ship_date date,
	sls_due_date date,
	sls_sales decimal(10,2),
	sls_quantity int,
	sls_price decimal(10,2)
);


create table bronze.erp_cust_AZ12
(
cust_customer_id varchar,
cust_birth_date date,
cust_gender varchar

);

create table bronze.erp_loc_A101
(
cust_c_id varchar,
cust_country varchar
);

create table bronze.erp_category
(
cust_id varchar,
cust_category varchar,
cust_subcategory varchar,
cust_maintenance varchar,
);
alter table bronze.erp_loc_A101
alter column cust_c_id nvarchar(50);

alter table bronze.erp_loc_A101
alter column cust_country nvarchar(50);

alter table bronze.erp_cust_AZ12
alter column cust_customer_id nvarchar(50);

alter table bronze.erp_cust_AZ12
alter column cust_gender  nvarchar(50);

alter table bronze.erp_category
alter column cust_id nvarchar(50);
alter table bronze.erp_category
alter column cust_category nvarchar(50);
alter table bronze.erp_category
alter column cust_subcategory nvarchar(50);
alter table bronze.erp_category
alter column cust_maintenance nvarchar(50);
