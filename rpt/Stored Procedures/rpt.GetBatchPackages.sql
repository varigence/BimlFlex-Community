/*
# Copyright (C) 2015 Varigence, Inc.
#
# Licensed under the Varigence IP BimlFlex Framework Agreement, Version 1.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License by contacting support@varigence.com.
*/
CREATE PROCEDURE [ssis].[GetBatchPackages]
AS
BEGIN
	SET NOCOUNT ON;

	SELECT	 p.[PackageName] AS [ObjectName]
			,MAX(e.[ExecutionID]) AS [ParentExecutionID]
			,MAX(e.[ServerExecutionID]) AS [ServerExecutionID] 
	FROM	[ssis].[Package] p
	INNER JOIN [ssis].[Execution] e
		ON	p.[PackageID] = e.[PackageID]
	WHERE	e.[ParentExecutionID] = -1 
	AND		(p.[PackageName] LIKE '%Batch%' OR p.[PackageName] LIKE '%Control%') 
	GROUP BY p.[PackageName]

END

GO