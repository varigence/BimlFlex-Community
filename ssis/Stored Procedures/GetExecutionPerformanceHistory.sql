/*
# Copyright (C) 2015 Varigence, Inc.
#
# Licensed under the Varigence IP BimlFlex Framework Agreement, Version 1.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License by contacting support@varigence.com.
*/
CREATE PROCEDURE [ssis].[GetExecutionPerformanceHistory]
	@ExecutionID VARCHAR(25)
AS

SELECT TOP(10) a.[execution_id], 
               a.[package_name], 
               Cast(a.[start_time] AS SMALLDATETIME) AS shortStartTime, 
               CONVERT (DATETIME, a.[start_time])    AS start_time, 
               Round(CONVERT(FLOAT, Datediff(millisecond, a.[start_time], 
                                          Isnull(a.[end_time], 
                                          Sysdatetimeoffset()))) / 1000, 2 
               )                                     AS duration 
FROM   [SSISDB].[catalog].[executions] a, 
       [SSISDB].[catalog].[executions] b 
WHERE  b.[execution_id] = @ExecutionID 
       AND a.[status] = 7 
       AND a.[package_name] = b.[package_name] 
       AND a.[project_name] = b.[project_name] 
       AND a.[folder_name] = b.[folder_name] 
ORDER  BY [start_time] DESC 

RETURN 0

GO


