/*
# Copyright (C) 2015 Varigence, Inc.
#
# Licensed under the Varigence IP BimlFlex Framework Agreement, Version 1.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License by contacting support@varigence.com.
*/
CREATE PROCEDURE [ssis].[GetExecutionPerformance]
	@ExecutionID VARCHAR(25)
AS


WITH ve 
     AS (SELECT [validation_id] AS execution_id, 
                [use32bitruntime], 
                [start_time], 
                [end_time], 
                [caller_name], 
                [folder_name], 
                [project_name], 
                [object_name]   AS package_name, 
                [status], 
                'v'             AS op_type 
         FROM   [SSISDB].[catalog].[validations] 
         WHERE  [object_type] = 30 
         UNION ALL 
         SELECT [execution_id], 
                [use32bitruntime], 
                [start_time], 
                [end_time], 
                [caller_name], 
                [folder_name], 
                [project_name], 
                [package_name], 
                [status], 
                'e' AS op_type 
         FROM   [SSISDB].[catalog].[executions]) 
SELECT [execution_id], 
       [folder_name], 
       [project_name], 
       [package_name], 
       [use32bitruntime], 
       [status], 
       CONVERT (DATETIME, [start_time]) AS start_time, 
       CONVERT (DATETIME, [end_time])   AS end_time, 
       Round(CONVERT(FLOAT, Datediff(millisecond, [start_time], 
                                  Isnull([end_time], Sysdatetimeoffset()))) / 
             1000, 2) 
                                        AS duration, 
       [caller_name] 
FROM   ve 
WHERE  [execution_id] = @ExecutionID 

RETURN 0




GO
