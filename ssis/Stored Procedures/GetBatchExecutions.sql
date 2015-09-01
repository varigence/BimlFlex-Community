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
		 e.[ExecutionID]
		,e.[ParentExecutionID]
		,e.[ServerExecutionID]
		,p.[PackageName]
		,CONVERT(DATETIME, e.[StartTime]) AS [StartTime]
		,e.[ExecutionStatus]
		,e.[ParentSourceGUID]
		,e.[ExecutionGUID]
		,e.[SourceGUID] 
FROM   [ssis].[Execution] e 
INNER JOIN [ssis].[Package] p
	ON	e.[PackageID] = p.[PackageID]
WHERE  p.[ParentPackageID] IS NULL 
AND		CONVERT(DATE, e.[StartTime]) >= CONVERT(DATE, @StartDate, 103)
AND		CONVERT(DATE, e.[StartTime]) <= CONVERT(DATE, @EndDate, 103)
ORDER  BY e.[ExecutionID] DESC

RETURN 0
GO