/*
# Copyright (C) 2015 Varigence, Inc.
#
# Licensed under the Varigence IP BimlFlex Framework Agreement, Version 1.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License by contacting support@varigence.com.
*/
CREATE PROCEDURE [ssis].[GetExecutionPerformance]
	@ExecutionID BIGINT
AS

SELECT e.[ExecutionID]
      ,e.[ParentExecutionID]
      ,e.[ServerExecutionID]
      ,e.[ParentSourceGUID]
      ,e.[ExecutionGUID]
      ,e.[SourceGUID]
      ,e.[PackageID]
	  ,p.[PackageName]
	  ,p.[ProjectName]
      ,e.[ExecutionStatus]
      ,e.[NextLoadStatus]
      ,CONVERT(DATETIME, e.[StartTime]) AS [StartTime]
      ,CONVERT(DATETIME, e.[EndTime]) AS [EndTime]
	  ,RIGHT('0' + CONVERT(varchar(5) ,DATEDIFF(s, e.StartTime, e.EndTime) / 3600), 2) + ':' + RIGHT('0' + CONVERT(VARCHAR(5), DATEDIFF(s, e.StartTime, e.EndTime) % 3600 / 60), 2) + ':' + RIGHT('0' + CONVERT(varchar(5), DATEDIFF(s, e.StartTime, e.EndTime) % 60), 2) AS Duration  
FROM [BimlCatalog].[ssis].[Execution] e
  JOIN [BimlCatalog].[ssis].[Package] p ON e.[PackageID] = p.[PackageID]
  WHERE [ExecutionID] = @ExecutionID 

GO
