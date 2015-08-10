/*
# Copyright (C) 2015 Varigence, Inc.
#
# Licensed under the Varigence IP BimlFlex Framework Agreement, Version 1.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License by contacting support@varigence.com.
*/
CREATE PROCEDURE [ssis].[GetEventMessages]
	@ExecutionName VARCHAR(100),
	@ExecutionID VARCHAR(25)
AS


WITH msgex 
     AS (SELECT msg.[event_message_id], 
                msg.[operation_id], 
                CONVERT(DATETIME, msg.[message_time]) AS message_time, 
                msg.[message_type], 
                msg.[message_source_type], 
                CASE 
                  WHEN Len(msg.[message]) <= 4096 THEN msg.[message] 
                  ELSE LEFT(msg.[message], 1024) + '...' 
                END                                   AS [message], 
                msg.[extended_info_id], 
                msg.[event_name], 
                CASE 
                  WHEN Len(msg.[message_source_name]) <= 1024 THEN 
                  msg.[message_source_name] 
                  ELSE LEFT(msg.[message_source_name], 1024) 
                       + '...' 
                END                                   AS [message_source_name], 
                msg.[message_source_id], 
                CASE 
                  WHEN Len(msg.[subcomponent_name]) <= 1024 THEN 
                  msg.[subcomponent_name] 
                  ELSE LEFT(msg.[subcomponent_name], 1024) + '...' 
                END                                   AS [subcomponent_name], 
                CASE 
                  WHEN Len(msg.[package_path]) <= 1024 THEN msg.[package_path] 
                  ELSE LEFT(msg.[package_path], 1024) + '...' 
                END                                   AS [package_path], 
                CASE 
                  WHEN Len(msg.[execution_path]) <= 1024 THEN 
                  msg.[execution_path] 
                  ELSE LEFT(msg.[execution_path], 1024) + '...' 
                END                                   AS [execution_path], 
                msg.[message_code], 
                info.reference_id 
         FROM   [SSISDB].[catalog].[event_messages] msg 
                LEFT JOIN [SSISDB].[catalog].[extended_operation_info] info 
                       ON msg.extended_info_id = info.info_id 
         WHERE  msg.[operation_id] = @ExecutionID 
                AND msg.message_source_name = @ExecutionName), 
     msgref 
     AS (SELECT msgex.*, 
                ref.[reference_type], 
                ref.[environment_folder_name], 
                ref.[environment_name] 
         FROM   msgex 
                LEFT JOIN [SSISDB].[catalog].[environment_references] ref 
                       ON msgex.[reference_id] = ref.[reference_id]), 
     msgenv 
     AS (SELECT *, 
                CASE 
                  WHEN [reference_id] IS NULL THEN '-' 
                  ELSE ( CASE 
                           WHEN [reference_type] = 'R' 
                                 OR [reference_type] = 'r' THEN '.' 
                           ELSE [environment_folder_name] 
                         END ) + '\' + [environment_name] 
                END AS env 
         FROM   msgref) 
SELECT * 
FROM   msgenv 
ORDER  BY [message_time] DESC

RETURN 0



GO