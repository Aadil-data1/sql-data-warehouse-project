/*
========================================================================
purpose:
      this report consolidates key customer metrics and behaviour

Highlights:
      Gather essential fields like names, ages, total_sales
	  Aggregate customer level metrics:
	   - total orders
	   - total sales
	   - total quantity purchased

	   calculate valuable KPIs:
	   - recent (months since last order)
	   - average value order
==========================================================================
*/

--=======================================================================
-- Create Report: gold.report_customers
--=======================================================================

         
     
create view gold.report_customers as

with base_query as (

/*
*******************************************************
Base Query: retrieves core columnns from tables
*******************************************************
*/

select 
f.order_number,
f.order_date,
f.sales_amount,
f.quantity,
c.customer_key,
c.cst_key,
concat(c.cst_firstname,' ', c.cst_lastname) as customer_name,
datediff(year, cust_birth_date, getdate()) as age,
c.cust_birth_date
from
gold.fact_sales f
left join gold.dim_customers c
on c.customer_key = f.customer_key
where order_date is not null)

--==============================================================
--Customer Aggregation: Summarizes key metrics at customer level
--================================================================

,customer_aggregation as (
select 
	customer_key,
	cst_key,
	customer_name,
	age,
count(distinct order_number) as total_orders,
sum(sales_amount) as total_sales,
sum(quantity) as total_quantity,
max(order_date) as last_order_date
from base_query	
group by 
	customer_key,
	cst_key,
	customer_name,
	age)

select 
	    customer_key,
		cst_key,
		customer_name,
		age,
		case when age < 20 then 'under 20'
		when age between 20 and 29 then '20-29'
		when age between 30 and 39 then '30-39'
		when age between 40 and 60 then '40-60'
		else '60 and above'
		end as age_group,


	    total_orders,
        total_sales,
        total_quantity,
        last_order_date,
		datediff(month, last_order_date, getdate()) as recent,
		
		--compute average order value
		case when total_sales = 0 then 0
		else total_sales/total_orders
		end avg_ord_value
       

from customer_aggregation
