CREATE VIEW [rpt].[LatestBatchExecutions]
AS 

WITH [cteRowCounts]
AS
(
	SELECT   [ExecutionID]
			,[ObjectName]
			,MAX(CASE WHEN [CountType] = 'Select' THEN [RowCount] ELSE NULL END) AS [SelectRowCount]
			,MAX(CASE WHEN [CountType] = 'Insert' THEN [RowCount] ELSE NULL END) AS [InsertRowCount]
	FROM	[ssis].[RowCount]
	WHERE	[ExecutionID] IN 
	(	
		SELECT	e.[ExecutionID]
		FROM [ssis].[Execution] e
		INNER JOIN (
			SELECT	TOP 5 e.[ExecutionID]
			FROM	[ssis].[Package] p
			INNER JOIN [ssis].[Execution] e
				ON	p.[PackageID] = e.[PackageID]
			WHERE	[IsBatch] = 1
			ORDER BY e.[StartTime] DESC
		) ce
			ON	e.[ExecutionID] = ce.[ExecutionID]
			OR	e.[ParentExecutionID] = ce.[ExecutionID]
	)
	GROUP BY [ExecutionID]
			,[ObjectName]
)

SELECT	 e.[ExecutionID]
		,e.[PackageID]
		,e.[PackageName]
		,e.[ParentPackageID]
		,e.[PackageType]
		,e.[ParentPackageName]
		,e.[ExecutionStatusCode]
		,e.[ExecutionStatus]
		,e.[ExecutionDate]
		,e.[NextLoadStatusCode]
		,e.[NextLoadStatus]
		,e.[StartTime]
		,e.[EndTime]
		,e.[DurationInSeconds]
		,e.[Duration] 
		,e.[ErrorCode]
		,e.[ErrorDescription]
		,rc.[ObjectName] AS [RowCountObject]
		,rc.[SelectRowCount]
		,rc.[InsertRowCount]
		,e.[ParentExecutionID]
		,e.[ServerExecutionID]
		,e.[ParentSourceGUID]
		,e.[ExecutionGUID]
		,e.[SourceGUID]
FROM	[rpt].[ExecutionDetails] e
LEFT OUTER JOIN [cteRowCounts] rc
	ON e.[ExecutionID] = rc.[ExecutionID]
WHERE	e.[ExecutionID] IN
(	
	SELECT	e.[ExecutionID]
	FROM [ssis].[Execution] e
	INNER JOIN (
		SELECT	TOP 5 e.[ExecutionID]
		FROM	[ssis].[Package] p
		INNER JOIN [ssis].[Execution] e
			ON	p.[PackageID] = e.[PackageID]
		WHERE	[IsBatch] = 1
		ORDER BY e.[StartTime] DESC
	) ce
		ON	e.[ExecutionID] = ce.[ExecutionID]
		OR	e.[ParentExecutionID] = ce.[ExecutionID]
)
GO
