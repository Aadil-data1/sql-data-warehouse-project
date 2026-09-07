/* Create Database and Schemas.
Create Database 'Datawarehouse. Additionally, the script setsups three schemas within the database : 'bronze', 'silver', and 'gold 
*/

use master;

--Create the datawarehouse database

create database Datawarehouse;

use Datawarehouse;

go

--create schemas

create schema bronze;
go

create schema silver;
go

create schema gold;
go


