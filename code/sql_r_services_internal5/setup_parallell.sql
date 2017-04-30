USE master;
GO

SET NOCOUNT ON;
GO


DROP DATABASE IF EXISTS TestParallel;
GO

CREATE DATABASE TestParallel;
GO

USE TestParallel;
GO

DROP TABLE IF EXISTS dbo.rand_1M
CREATE TABLE dbo.rand_1M(RowID bigint identity primary key, y int, rand1 int, rand2 int, rand3 int, rand4 int, rand5 int);

INSERT INTO dbo.rand_1M(y, rand1, rand2, rand3, rand4, rand5)
SELECT TOP(1000000) CAST(ABS(CHECKSUM(NEWID())) % 14 AS INT) 
	, CAST(ABS(CHECKSUM(NEWID())) % 20 AS INT)
	, CAST(ABS(CHECKSUM(NEWID())) % 25 AS INT)
	, CAST(ABS(CHECKSUM(NEWID())) % 14 AS INT)
	, CAST(ABS(CHECKSUM(NEWID())) % 50 AS INT)
	, CAST(ABS(CHECKSUM(NEWID())) % 100 AS INT)
FROM sys.objects o1
CROSS JOIN sys.objects o2
CROSS JOIN sys.objects o3
CROSS JOIN sys.objects o4;


DROP TABLE IF EXISTS dbo.rand_10M
CREATE TABLE dbo.rand_10M(RowID bigint identity primary key, y int, rand1 int, rand2 int, rand3 int, rand4 int, rand5 int);

INSERT INTO dbo.rand_10M(y, rand1, rand2, rand3, rand4, rand5)
SELECT TOP(10000000) CAST(ABS(CHECKSUM(NEWID())) % 14 AS INT) 
	, CAST(ABS(CHECKSUM(NEWID())) % 20 AS INT)
	, CAST(ABS(CHECKSUM(NEWID())) % 25 AS INT)
	, CAST(ABS(CHECKSUM(NEWID())) % 14 AS INT)
	, CAST(ABS(CHECKSUM(NEWID())) % 50 AS INT)
	, CAST(ABS(CHECKSUM(NEWID())) % 100 AS INT)
FROM sys.objects o1
CROSS JOIN sys.objects o2
CROSS JOIN sys.objects o3
CROSS JOIN sys.objects o4;

DROP TABLE IF EXISTS dbo.rand_30M
CREATE TABLE dbo.rand_30M(RowID bigint identity primary key, y int, rand1 int, rand2 int, rand3 int, rand4 int, rand5 int);

INSERT INTO dbo.rand_30M(y, rand1, rand2, rand3, rand4, rand5)
SELECT TOP(30000000) CAST(ABS(CHECKSUM(NEWID())) % 14 AS INT) 
	, CAST(ABS(CHECKSUM(NEWID())) % 20 AS INT)
	, CAST(ABS(CHECKSUM(NEWID())) % 25 AS INT)
	, CAST(ABS(CHECKSUM(NEWID())) % 14 AS INT)
	, CAST(ABS(CHECKSUM(NEWID())) % 50 AS INT)
	, CAST(ABS(CHECKSUM(NEWID())) % 100 AS INT)
FROM sys.objects o1
CROSS JOIN sys.objects o2
CROSS JOIN sys.objects o3
CROSS JOIN sys.objects o4;
GO

/*

SELECT COUNT(*) FROM dbo.rand_1M
SELECT COUNT(*) FROM dbo.rand_10M
SELECT COUNT(*) FROM dbo.rand_50M
*/


SELECT  
    task_address,  
    task_state,  
    context_switches_count,  
    pending_io_count,  
    pending_io_byte_count,  
    pending_io_byte_average,  
    scheduler_id,  
    session_id,  
    exec_context_id,  
    request_id,  
    worker_address,  
    host_address  
  FROM sys.dm_os_tasks 
  WHERE session_id = 54
    AND scheduler_id < 255;


SELECT * 
FROM sys.dm_os_tasks ot
JOIN sys.dm_os_workers w
  ON ot.task_address = w.task_address
WHERE session_id = 52