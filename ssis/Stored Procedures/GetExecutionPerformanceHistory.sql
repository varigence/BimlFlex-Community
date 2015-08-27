/*
# Copyright (C) 2015 Varigence, Inc.
#
# Licensed under the Varigence IP BimlFlex Framework Agreement, Version 1.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License by contacting support@varigence.com.
*/
CREATE PROCEDURE [ssis].[GetExecutionPerformanceHistory]
	@ObjectName VARCHAR(50)
AS

SELECT
TOP 10 e.[ExecutionID]
,e.[ParentExecutionID]
,e.[ServerExecutionID]
,e.[ParentSourceGUID]
,e.[ExecutionGUID]
,e.[SourceGUID]
,e.[PackageID]
,p.[PackageName]
,e.[ExecutionStatus]
,e.[NextLoadStatus]
,FORMAT(CONVERT(DATE, e.[StartTime]), 'dd/MM/yyyy') AS [StartDate]
,FORMAT(CONVERT(DATE, e.[EndTime]), 'dd/MM/yyyy') AS [EndDate]
,CONVERT(DATETIME, e.[StartTime]) AS [StartTime]
,CONVERT(DATETIME, e.[EndTime]) AS [EndTime]
,ROUND(CONVERT(FLOAT, DATEDIFF(millisecond,e. [StartTime],
							ISNULL([EndTime],
							SYSDATETIMEOFFSET()))) / 1000, 2) AS [Duration]
FROM [BimlCatalog].[ssis].[Execution] e
JOIN [BimlCatalog].[ssis].[Package] p ON e.PackageID = p.PackageID
WHERE p.[PackageName] = @ObjectName
AND e.[ExecutionStatus] = 'S'
ORDER  BY e.[StartTime] DESC 

RETURN 0

GO


