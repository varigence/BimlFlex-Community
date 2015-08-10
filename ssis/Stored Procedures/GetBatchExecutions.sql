/*
# Copyright (C) 2015 Varigence, Inc.
#
# Licensed under the Varigence IP BimlFlex Framework Agreement, Version 1.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License by contacting support@varigence.com.
*/
CREATE PROCEDURE [ssis].[GetBatchExecutions]
	@StartDate VARCHAR(25),
	@EndDate VARCHAR(25)
AS

SELECT	 TOP 10 
		 bce.[ExecutionID]
		,sce.[execution_id] AS [SSISExecutionID]
		,bce.[ParentExecutionID]
		,bce.[ServerExecutionID]
		,bce.[PackageName]
		,CONVERT(DATETIME, sce.[start_time]) AS [start_time]
		,sce.[status]
		,bce.[ParentSourceGUID]
		,bce.[ExecutionGUID]
		,bce.[SourceGUID] 
FROM   [ssis].[Execution] bce 
INNER JOIN [SSISDB].[catalog].[executions] sce 
	ON bce.[ServerExecutionID] = sce.[execution_id] 
WHERE  bce.[ParentExecutionID] = -1 
AND		bce.[ServerExecutionID] <> 0 
AND		sce.[start_time] >= CONVERT(DATE, @StartDate, 103)
AND		sce.[start_time] <= CONVERT(DATE, @EndDate, 103)
ORDER  BY bce.[ExecutionID] DESC

RETURN 0
GO