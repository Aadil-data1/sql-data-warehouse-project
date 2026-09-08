/*
===============================================================
Stored procedure: load bronze layer (source -> bronze)
==============================================================
script purpose:
this stored procedure loads data into bronze schema from external csv files.
it 'truncates the bronze tables before loading files and uses the bulk insert command.

parameters: none

using example:
exec bronze.load_bronze

*/



create or alter procedure bronze.load_bronze as
begin
  declare @start_time datetime, @end_time datetime, @batch_start_time datetime, @batch_end_time datetime;
  begin try
  set @batch_start_time = getdate();
        print '===============================================================';
        print 'loading Bronze Layer';
        print '===============================================================';

        print'-----------------------------------------------------------------';
        print'loading Crm tables';
        print'-----------------------------------------------------------------';

        set @start_time = getdate();
        print'>> truncating table:  bronze.crm_cust_info';
        truncate table bronze.crm_cust_info

        print'>> bulk inserting table: bronze.crm_cust_info';
        bulk insert bronze.crm_cust_info
        from 'D:\SQL\sql-ultimate-course-main\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
        with (
        firstrow = 2, 
        fieldterminator = ',',
        tablock
        );
        set @end_time = getdate();
        print'>> load duration:' + cast(datediff(second, @start_time, @end_time) as nvarchar)  +  'seconds';

        print'>> bulk inserting table: bronze.crm_prd_info';

        set @start_time = getdate();
        bulk insert bronze.crm_prd_info
        from 'D:\SQL\sql-ultimate-course-main\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
        with (
        firstrow = 2, 
        fieldterminator = ',',
        tablock
        );
       set @end_time = getdate();
       print'>> load duration:' + cast(datediff(second, @start_time, @end_time) as nvarchar)  +  'seconds';

         set @start_time = getdate();
         print'>> truncating table: bronze.crm_sales_details';
        truncate table bronze.crm_sales_details

        print'>> bulk inserting table: bronze.crm_sales_details';
        BULK INSERT bronze.crm_sales_details
        FROM 'D:\SQL\sql-ultimate-course-main\sql-data-warehouse-project\datasets\source_crm\sales_details_fixed.csv'
        WITH (
             FIRSTROW = 2,
             FIELDTERMINATOR = ',',
            TABLOCK
        );

          set @end_time = getdate();
          print'>> load duration:' + cast(datediff(second, @start_time, @end_time) as nvarchar)  +  'seconds';
        print'-----------------------------------------------------------------';
        print'loading erp tables';
        print'-----------------------------------------------------------------';

        print'>> bulk inserting table: bronze.erp_category';
        bulk insert bronze.erp_category
        from 'D:\SQL\sql-ultimate-course-main\sql-data-warehouse-project\datasets\source_erp\PX_CAT_G1V2.csv'
        with (
        firstrow = 2,
        fieldterminator = ',',
        tablock
        );

        print'>>  bulk inserting table: bronze.erp_cust_AZ12';
        bulk insert bronze.erp_cust_AZ12
        from 'D:\SQL\sql-ultimate-course-main\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv'
        with (
        firstrow = 2,
        fieldterminator = ',',
        tablock
        );

        print'>> bulk inserting table: bronze.erp_loc_A101';
        bulk insert bronze.erp_loc_A101
        from 'D:\SQL\sql-ultimate-course-main\sql-data-warehouse-project\datasets\source_erp\LOC_A101.csv'
        with (
        firstrow = 2,
        fieldterminator = ',',
        tablock
        );
        set @batch_end_time = getdate();
        print'===================================';
        print'loading bronze layer is complete';
        print' total load duration:' + cast(datediff(second, @batch_start_time, @batch_end_time) as nvarchar) + 'seconds';
    end try
    begin catch
    print'=====================================================';
    print' ERROR OCCURED DURING LOADING BRONZE LAYER';
    PRINT'ERROR MESSAGE' + ERROR_MESSAGE();
    PRINT' ERROR MESSAGE' + CAST (ERROR_STATE() AS NVARCHAR);
    PRINT'=====================================================';
    end catch
end
