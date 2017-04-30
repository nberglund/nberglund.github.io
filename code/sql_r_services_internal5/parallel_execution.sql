

USE TestParallel2;
GO

SET NOCOUNT ON;
GO





--SELECT COUNT(*) FROM dbo.rand_50M

--@parallel = 1 no MOD
--16 processes
--8 rows
EXEC sp_execute_external_script
	@language = N'R'
	, @script = N'
    #Sys.sleep(15)
		pid <- Sys.getpid()
		r <- rxLinMod(y ~ rand1 + rand2 + rand3 + rand4 + rand5, data=InputDataSet, verbose=1)
    #r <- lm(y ~ rand1 + rand2 + rand3 + rand4 + rand5, data=InputDataSet)
		# print(r)
		
		coef <- r$coefficients
    icept <- r$coefficients[1]
		OutputDataSet <- data.frame(pid=pid, intercept=icept)
	'
	--, @parallel=1
	, @input_data_1 = N'
			SELECT  y, rand1, rand2, rand3, rand4, rand5 FROM dbo.rand_30M'
	--, @params = N'@r_rowsPerRead int'
	--, @r_rowsPerRead = 10000000
WITH RESULT SETS (
	(pid INT NOT NULL,
		--nRows INT NOT NULL,
		intercept FLOAT NULL
	)
); 

--9068 4.94337486948536
--@parallel = 1 no MOD
--1 processes
--1 rows
EXEC sp_execute_external_script
	@language = N'R'
	, @script = N'
		Sys.sleep(45)
    pid <- Sys.getpid()
		r <- rxLinMod(y ~ rand1 + rand2 + rand3 + rand4 + rand5, data=InputDataSet, verbose=1)
		# print(r)
		
		coef <- r$coefficients
		OutputDataSet <- data.frame(pid=pid, nRows=r$nValidObs, intercept=coef[1])
	'
	, @parallel=1
	, @input_data_1 = N'
			SELECT TOP(16) * FROM rand_10M'
	-- , @params = N'@r_rowsPerRead int'
	-- , @r_rowsPerRead = 100000
WITH RESULT SETS (
	(pid INT NOT NULL,
		nRows INT NOT NULL,
		intercept FLOAT NULL
	)
); 

--@parallel = 1 no MOD
--1 processes
--1 rows
EXEC sp_execute_external_script
	@language = N'R'
	, @script = N'
		Sys.sleep(5)
    pid <- Sys.getpid()
		r <- rxLinMod(y ~ rand1 + rand2 + rand3 + rand4 + rand5, data=InputDataSet, verbose=1)
		# print(r)
		
		coef <- r$coefficients
		OutputDataSet <- data.frame(pid=pid, nRows=r$nValidObs, intercept=coef[1])
	'
	, @parallel=1
	, @input_data_1 = N'
			SELECT TOP(10000) y, rand1, rand2, rand3, rand4, rand5 FROM rand_10M'
	-- , @params = N'@r_rowsPerRead int'
	-- , @r_rowsPerRead = 100000
WITH RESULT SETS (
	(pid INT NOT NULL,
		nRows INT NOT NULL,
		intercept FLOAT NULL
	)
); 


SELECT TOP(16) * FROM rand_10M



EXEC sp_execute_external_script 
                    @language =N'R',
                    @script=N'
                    Sys.sleep(5);
                    pid <- Sys.getpid()
                    wd <- getwd()
                    data2<-InputDataSet
                    data <- data.frame(Answer=42, pid=pid, wd=wd)
                    OutputDataSet<-data;
                    '
                    --, @parallel=1
                    , @input_data_1 =N'SELECT * FROM dbo.rand_10M'
WITH RESULT SETS (([TheAnswer] int not null, ProcessID int, WorkingDirectory nvarchar(1024)));



SELECT TOP(10) * FROM dbo.rand_50M

DECLARE @start datetime2 = SYSUTCDATETIME();
EXEC sp_execute_external_script
          @language = N'R'
        , @script = N'
            Sys.sleep(30)
             pid <- Sys.getpid()
             r <- rxLinMod(y ~ rand1 + rand2 + rand3 + rand4 + rand5, 
                           data=InputDataSet)
 
             coef <- r$coefficients
             icept <- coef[1];
              OutputDataSet <- data.frame(pid=pid, nRows=r$nValidObs, 
                                          intercept=icept)'
        , @input_data_1 = N'
              SELECT  y, rand1, rand2, rand3, 
                      rand4, rand5 
              FROM dbo.rand_30M WHERE RowID < 3000000  OPTION(MAXDOP 4)'
        , @parallel=1
        --, @params = N'@r_rowsPerRead int'
	      --, @r_rowsPerRead = 100000
WITH RESULT SETS ((pid INT NOT NULL, nRows INT NOT NULL, intercept FLOAT NULL)
); 
SELECT DATEDIFF(ms, @start, SYSUTCDATETIME()) AS ElapsedTime;


SELECT * 
FROM sys.dm_os_schedulers 
WHERE scheduler_id < 255; 

sp_configure 'show advanced options', 1
RECONFIGURE
GO


SELECT * FROM sys.dm_os_tasks
SELECT * FROM sys.dm_os_threads
SELECT * FROM sys.dm_os_workers
SELECT * FROM sys.dm_os_schedulers
SELECT * FROM sys.dm_exec_sessions


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
  ORDER BY session_id, request_id;  
