﻿/*
# Copyright (C) 2015 Varigence, Inc.
#
# Licensed under the Varigence IP BimlFlex Framework Agreement, Version 1.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License by contacting support@varigence.com.
*/
CREATE PROCEDURE [ssis].[GetBatchExecutionDetail]
	@ParentExecutionID VARCHAR(25),
	@ServerExecutionID VARCHAR(25)
AS

SELECT	 sce.[executable_id]
		,bce.[ParentExecutionID]
		,bce.[ExecutionID]
		,sce.[execution_id]
		,sce.[executable_name]
		,sce.[executable_guid]
		,sce.[package_name]
		,sce.[package_path]
		,CONVERT(DATETIME, ses.[start_time]) AS [start_time]
		,CONVERT(DATETIME, ses.[end_time]) AS [end_time]
		,CONVERT(VARCHAR, DATEADD(ms, ses.[execution_duration], 0), 108) AS [execution_duration]
		,SUM(CASE WHEN brc.[CountType] = 'Select' THEN brc.[RowCount] END) AS [RowCount]
		,bar.[AuditType]
		,SUM(bar.[RowCount]) AS [AuditTypeRowCount]
FROM   [SSISDB].[catalog].[executables] sce 
INNER JOIN [ssis].[Execution] bce 
    ON	sce.[executable_guid] = '{' + bce.[ParentSourceGUID] COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS + '}' 
INNER JOIN [catalog].[executable_statistics] ses 
    ON	ses.[execution_id] = sce.[execution_id] 
    AND ses.[executable_id] = sce.[executable_id] 
LEFT OUTER JOIN [ssis].[RowCount] brc 
	ON	brc.[ExecutionID] = bce.[ExecutionID] 
LEFT OUTER JOIN [ssis].[AuditRow] bar 
	ON	bar.[ExecutionID] = bce.[ExecutionID] 
WHERE	bce.[ParentExecutionID] = @ParentExecutionID 
AND		sce.[execution_id] = @ServerExecutionID 
AND		ses.[execution_id] = @ServerExecutionID 
GROUP BY sce.[executable_id] 
		,bce.[ParentExecutionID]
		,bce.[ExecutionID]
		,sce.[execution_id]
		,sce.[executable_name]
		,sce.[executable_guid]
		,sce.[package_name]
		,sce.[package_path]
		,ses.[start_time]
		,ses.[end_time]
		,ses.[execution_duration]
		,bar.[AuditType]

RETURN 0

GO