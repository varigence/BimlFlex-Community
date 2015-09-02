/*
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
		,p.[PackageName] AS [package_name]
		,sce.[package_path]
		,CONVERT(DATETIME, bce.[StartTime]) AS [start_time]
		,CONVERT(DATETIME, bce.[EndTime]) AS [end_time]
		,RIGHT('0'+ convert(varchar(5),DateDiff(s, bce.[StartTime], bce.[EndTime])/3600),2)+':'+RIGHT('0'+ convert(varchar(5),DateDiff(s, bce.[StartTime], bce.[EndTime])%3600/60),2)+':'+ RIGHT('0'+ convert(varchar(5),(DateDiff(s, bce.[StartTime], bce.[EndTime])%60)),2) AS [execution_duration]
		,SUM(CASE WHEN brc.[CountType] = 'Select' THEN brc.[RowCount] END) AS [RowCount]
		,bar.[AuditType]
		,SUM(bar.[RowCount]) AS [AuditTypeRowCount]
FROM   [ssis].[Execution] bce
INNER JOIN [ssis].[Package] p
	ON	bce.[PackageID] = p.[PackageID] 
LEFT OUTER JOIN [SSISDB].[catalog].[executables] sce 
    ON	sce.[executable_guid] = '{' + bce.[ParentSourceGUID] COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS + '}' 
LEFT OUTER JOIN [ssis].[RowCount] brc 
	ON	brc.[ExecutionID] = bce.[ExecutionID] 
LEFT OUTER JOIN [ssis].[AuditRow] bar 
	ON	bar.[ExecutionID] = bce.[ExecutionID] 
WHERE	bce.[ParentExecutionID] = @ParentExecutionID 
--AND		sce.[execution_id] = @ServerExecutionID 
GROUP BY sce.[executable_id] 
		,bce.[ParentExecutionID]
		,bce.[ExecutionID]
		,sce.[execution_id]
		,sce.[executable_name]
		,sce.[executable_guid]
		,p.[PackageName]
		,sce.[package_path]
		,bce.[StartTime]
		,bce.[EndTime]
		,bar.[AuditType]

RETURN 0

GO