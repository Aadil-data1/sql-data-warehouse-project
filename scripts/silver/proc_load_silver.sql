/*
===============================================================
Stored procedure: load Silver layer (bronze -> silver)
==============================================================
script purpose:
this stored procedure performs ETL (Extract, Transform, Load) process to populate the Silver Schema tables from bronze schema.
 Actions Performed:
       Inserted transformed and cleaned data from bronze into silver tables.


parameters: none

using example:
exec silver.load_silver
=============================================================

*/

create or alter procedure silver.load_silver as

begin
  declare  @batch_start_time datetime, @batch_end_time datetime;
  begin try
  set @batch_start_time = getdate();
        print '===============================================================';
        print 'loading Silver Layer';
        print '===============================================================';

        print'-----------------------------------------------------------------';
        print'loading Crm tables';
        print'-----------------------------------------------------------------';




insert into silver.crm_cust_info(
cst_id,
cst_key,
cst_firstname,
cst_lastname,
cst_marital_status,
cst_gndr,
cst_create_date
)
select 
cst_id,
cst_key,
trim (cst_firstname) as cst_firstname,
trim(cst_lastname) as cst_lastname,
case when upper(trim(cst_marital_status)) = 'S' then 'Single'
when upper(trim(cst_marital_status)) = 'M' then 'Married'
else 'not availabe'
end cst_marital_status,  --normalize marital status to readable format

case when upper(trim(cst_gndr)) = 'F' then 'Female'
when upper(trim(cst_gndr)) = 'M' then 'Male'
else 'not availabe'
end cst_gndr, --normalize gender to readable format
cst_create_date
from (
select 
*,
row_number() over (partition by cst_id order by cst_create_date desc) as flag_last
from bronze.crm_cust_info
where cst_id is not null
)t where flag_last = 1

insert into silver.crm_prd_info (
	prd_id,
	cat_id,
	prd_key,
	prd_name,
	prd_cost,
	prd_line,
	prd_start_date,
	prd_end_date
)

select 
prd_id,
replace(substring(prd_key,1,5), '-','_') as cat_id, --extract categoryid
substring(prd_key,7,len(prd_key)) as prd_key,  --extract productkey
prd_name,
isnull (prd_cost,0) as prd_cost,
case upper(trim(prd_line))
when 'M' then 'Mountain'
when 'R' then 'Road'
when 'S' then 'Other Sales'
when 'T' then 'Touring'
else 'not available'
end as prd_line, --map product line codes to discrete values 
cast(prd_start_date as date) as prd_start_date,
cast(lead(prd_start_date) over (partition by prd_key order by prd_start_date)  as date) as prd_end_date
from bronze.crm_prd_info

insert into silver.crm_sales_details (
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

 select
 sls_ord_num,
 sls_prd_key,
 sls_cust_id,
 cast(sls_order_dt as date) as sls_ord_dt,
 cast( sls_ship_dt as date) as sls_ship_dt, ---format 112 = YYYYMMDD
 cast(sls_due_dt as date) as sls_due_dt,
 case when sls_sales is null or sls_sales <=0 or sls_sales != sls_quantity * abs(sls_price)
 then sls_quantity * abs(sls_price)
 else sls_sales --recalculate values if original data is missing
 end as sls_sales,
 sls_quantity,
 case when sls_price is null or sls_price <=0
 then cast(sls_sales as int) / nullif( cast(sls_quantity as int),0 ) --derive price if original value is missed
 end as sls_price
 from bronze.crm_sales_details

        print'-----------------------------------------------------------------';
        print'loading erp tables';
        print'-----------------------------------------------------------------';

insert into silver.erp_cust_AZ12 (cust_customer_id,cust_birth_date,cust_gender)
select 

case when cust_customer_id like 'nas%' then substring(cust_customer_id,4,len(cust_customer_id)) --remove "NAS" prefix if present
else cust_customer_id
end as cust_customer_id,
 case when cust_birth_date > getdate() then null --set future birthdays to null
 else cust_birth_date
 end as cust_birth_date,
cust_gender
from bronze.erp_cust_AZ12



insert into silver.erp_loc_A101 (cust_c_id, cust_country)
select
replace(cust_c_id,'-', '') cust_c_id,
case when trim(cust_country) = 'DE' then 'Germany'
when trim(cust_country) in ('US', 'USA') then 'United States'
when trim(cust_country) = ''or cust_country is null then 'not availabe' --normalize and handle missing or blank country codes
end as cust_country
from bronze.erp_loc_A101



insert into silver.erp_category (
cust_id,
cust_category,
cust_subcategory,
cust_maintenance
)

select
cust_id,
cust_category,
cust_subcategory,
cust_maintenance
from bronze.erp_category

set @batch_end_time = getdate();
        print'===================================';
        print'loading bronze layer is complete';
        print' total load duration:' + cast(datediff(second, @batch_start_time, @batch_end_time) as nvarchar) + 'seconds';

 end try
    begin catch
    print'=====================================================';
    print' ERROR OCCURED DURING LOADING Silver LAYER';
    PRINT'ERROR MESSAGE' + ERROR_MESSAGE();
    PRINT' ERROR MESSAGE' + CAST (ERROR_STATE() AS NVARCHAR);
    PRINT'=====================================================';
    end catch
end





