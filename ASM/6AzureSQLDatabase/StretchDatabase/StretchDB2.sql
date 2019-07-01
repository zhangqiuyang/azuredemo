USE AdventureWorks2016CTP3
--Review the Data
SELECT COUNT(*) FROM Sales.OrderTracking WHERE TrackingEventID <= 3
--Review the Data
SELECT COUNT(*) FROM Sales.OrderTracking WHERE TrackingEventID > 3


--�Ա���SQL Server 2016���򿪹鵵����
EXEC sp_configure 'remote data archive' , '1';
RECONFIGURE;

--���ƶ�Azure SQL Database���û��������룬���м��ܣ����ܵ�����ͬSQL Database�����룺
USE Adventureworks2016CTP3;
CREATE MASTER KEY ENCRYPTION BY PASSWORD='Abc@123456'
CREATE DATABASE SCOPED CREDENTIAL AzureDBCred WITH IDENTITY = 'sqladmin', SECRET = 'Abc@123456';

--�����ص�SQL Server 2016�Ĺ鵵Ŀ�ָ꣬��΢����SQL Database Server(l3cq1dckpd.database.chinacloudapi.cn)
--���l3cq1dckpd.database.chinacloudapi.cn����������׼�������У��������µķ�����
ALTER DATABASE [AdventureWorks2016CTP3] SET REMOTE_DATA_ARCHIVE = ON 
(SERVER = 'l3cq1dckpd.database.chinacloudapi.cn', CREDENTIAL = AzureDBCred);


--Create Function
CREATE FUNCTION dbo.fn_stretchpredicate(@status int) 
RETURNS TABLE WITH SCHEMABINDING AS 
RETURN	SELECT 1 AS is_eligible WHERE @status <= 3; 


--Migrate Some Data to the Cloud
ALTER TABLE Sales.OrderTracking SET (REMOTE_DATA_ARCHIVE = ON (
	MIGRATION_STATE = OUTBOUND,
	FILTER_PREDICATE = dbo.fn_stretchpredicate(TrackingEventId)));


--�鿴�鵵����Ǩ�ƵĽ���
SELECT * from sys.dm_db_rda_migration_status


USE AdventureWorks2016CTP3
GO
--��ʾ���������к���������
EXEC sp_spaceused 'Sales.OrderTracking', 'true', 'LOCAL_ONLY';
GO

--��ʾ�ƶ�Stretch Database�������к�������
EXEC sp_spaceused 'Sales.OrderTracking', 'true', 'REMOTE_ONLY';
GO