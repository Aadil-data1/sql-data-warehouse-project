/*
======================================================================
 DDL Script : Create Gold Views
======================================================================
Script Purpose:
 This script creates views for the Gold Layer in the Data Warehouse.
 The gold layer represents the fact table and dimensions (Star Schema).
 
 Each view performs transformation and combines data from the silver
 layer to produce clean, enriches and business_ready dataset.
======================================================================

*/


--=================================================================================
--this script creates gold.dim_customers, joining different tables, and remove the duplicates.
also create a surrogate key

--=================================================================================


create view gold.dim_customers as

WITH cte AS (
    SELECT 
        ROW_NUMBER() OVER (PARTITION BY ci.cst_id ORDER BY ci.cst_id) as rn,
        ci.cst_id,
        ci.cst_key,
        ci.cst_firstname,
        ci.cst_lastname,
        ci.cst_marital_status,
        CASE WHEN ci.cst_gndr != 'not available' 
             THEN ci.cst_gndr
             ELSE COALESCE(ca.cust_gender, 'not available')
        END as gender,
        ci.cst_create_date,
        ca.cust_birth_date,
        la.cust_country
    FROM silver.crm_cust_info ci
    LEFT JOIN silver.erp_cust_AZ12 ca
        ON ci.cst_key = ca.cust_customer_id
    LEFT JOIN silver.erp_loc_A101 la
        ON ci.cst_key = la.cust_c_id
)
SELECT 
    ROW_NUMBER() OVER (ORDER BY cst_id) as customer_key,
    cst_id,
    cst_key,
    cst_firstname,
    cst_lastname,
    cst_marital_status,
    gender,
    cst_create_date,
    cust_birth_date,
    cust_country
FROM cte
WHERE rn = 1;

--===============================================================
  --creates view: gold.dim_products
--==============================================================

create view gold.dim_products as
with cte as (
select
ROW_NUMBER() OVER (PARTITION BY pn.prd_id ORDER BY pn.prd_id) as rn,
	pn.prd_id,
	pn.prd_key,
	pn.cat_id,
	pn.prd_name,
	pc.cust_category,
	pc.cust_subcategory,
	pn.prd_cost,
	pn.prd_line,
	pn.prd_start_date,
	pc.cust_maintenance
from silver.crm_prd_info pn
left join silver.erp_category pc
on pn.cat_id = pc.cust_id
)
SELECT 
    ROW_NUMBER() OVER (ORDER BY prd_id) as product_key,
	prd_id,
	prd_key,
	cat_id,
	prd_name,
	cust_category,
	cust_subcategory,
	prd_cost,
	prd_line,
	prd_start_date,
	cust_maintenance
	from cte 
	where rn =1;

--========================================================
--create view: gold.fact_sales
--=======================================================

create view gold.fact_sales as
 select 
sd.sls_ord_num as order_number,
pr.product_key,
cu.customer_key,
sd.sls_order_dt as order_date,
sd.sls_ship_dt as shipping_date,
sd.sls_due_dt as due_date,
sd.sls_sales as sales_amount,
sd.sls_quantity as quantity
from silver.crm_sales_details sd
left join gold.dim_products pr
on sd.sls_prd_key = pr.prd_key 
left join gold.dim_customers cu
on sd.sls_cust_id = cu.cst_id



