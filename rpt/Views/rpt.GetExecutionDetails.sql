CREATE VIEW [rpt].[GetExecutionDetails]
AS 


SELECT	 e.[ExecutionID]
		,e.[PackageID]
		,p.[PackageName]
		,ep.[PackageID] AS [ParentPackageID]
		,pp.[PackageName] AS [ParentPackageName]
		,e.[ExecutionStatus] AS [ExecutionStatusCode]
		,CASE e.[ExecutionStatus]
			WHEN 'E' THEN 'Executing'
			WHEN 'F' THEN 'Failed'
			WHEN 'A' THEN 'Aborted'
			WHEN 'S' THEN 'Success'
		 END AS [ExecutionStatus]
		,e.[NextLoadStatus] AS [NextLoadStatusCode]
		,CASE e.[NextLoadStatus]
			WHEN 'C' THEN 'Cancel'
			WHEN 'P' THEN 'Process'
			WHEN 'R' THEN 'Rollback'
		 END AS [NextLoadStatus]
		,CONVERT(DATETIME, e.[StartTime]) AS [StartTime]
		,CONVERT(DATETIME, e.[EndTime]) AS [EndTime]
		,ISNULL(e.[Duration], DATEDIFF(SECOND, e.[StartTime], ISNULL(e.[EndTime], GETDATE()))) AS [DurationInSeconds]
		,RIGHT('0' + CONVERT(varchar(5) ,ISNULL(e.[Duration], DATEDIFF(SECOND, e.[StartTime], ISNULL(e.[EndTime], GETDATE()))) / 3600), 2) + ':' 
			+ RIGHT('0' + CONVERT(VARCHAR(5), ISNULL(e.[Duration], DATEDIFF(SECOND, e.[StartTime], ISNULL(e.[EndTime], GETDATE()))) % 3600 / 60), 2) + ':' 
			+ RIGHT('0' + CONVERT(varchar(5), ISNULL(e.[Duration], DATEDIFF(SECOND, e.[StartTime], ISNULL(e.[EndTime], GETDATE()))) % 60), 2) AS [Duration] 
		,ee.[ErrorCode]
		,ee.[ErrorDescription]
		,e.[ParentExecutionID]
		,e.[ServerExecutionID]
		,e.[ParentSourceGUID]
		,e.[ExecutionGUID]
		,e.[SourceGUID]
FROM	[ssis].[Execution] e
INNER JOIN [ssis].[Package] p 
	ON e.[PackageID] = p.[PackageID]
INNER JOIN [ssis].[Execution] ep
	ON CASE	WHEN e.[ParentExecutionID] = -1 THEN e.[ExecutionID] ELSE e.[ParentExecutionID] END = ep.[ExecutionID]
INNER JOIN [ssis].[Package] pp 
	ON ep.[PackageID] = pp.[PackageID]
LEFT OUTER JOIN [ssis].[ExecutionError] ee
	ON	e.[PackageID] = ee.[PackageID]
	AND	e.[ExecutionID] = ee.[ExecutionID]
GO
