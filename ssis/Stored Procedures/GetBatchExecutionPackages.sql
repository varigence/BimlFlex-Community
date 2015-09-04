CREATE PROCEDURE [dbo].[GetBatchExecutionPackages]
	-- Add the parameters for the stored procedure here
	@ServerExecutionID VARCHAR(30)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
SELECT e.ExecutionID
	,e.ParentExecutionID
	,e.ServerExecutionID
	,e.ParentSourceGUID
	,e.ExecutionGUID
	,e.SourceGUID
	,e.PackageID
	,p.PackageName
	,e.ExecutionStatus
	,e.NextLoadStatus
	,CONVERT(DATETIME, e.StartTime) AS StartTime
	,CONVERT(DATETIME, e.EndTime) AS EndTime
	,RIGHT('0' + CONVERT(varchar(5)
	,DATEDIFF(s, e.StartTime, e.EndTime) / 3600), 2) + ':' + RIGHT('0' + CONVERT(VARCHAR(5), DATEDIFF(s, e.StartTime, e.EndTime) % 3600 / 60), 2) + ':' + RIGHT('0' + CONVERT(varchar(5), DATEDIFF(s, e.StartTime, e.EndTime) % 60), 2) AS Duration
	,SUM(CASE WHEN rc.[CountType] = 'Select' THEN rc.[RowCount] END) AS [RowCount]
	,SUM(ar.[RowCount]) AS AuditTypeRowCount
FROM ssis.Execution AS e
INNER JOIN 
	ssis.Package AS p ON e.PackageID = p.PackageID 
LEFT OUTER JOIN
	ssis.[RowCount] AS rc ON e.ExecutionID = rc.ExecutionID 
LEFT OUTER JOIN
	ssis.AuditRow AS ar ON e.ExecutionID = ar.ExecutionID
WHERE e.ServerExecutionID = @ServerExecutionID
	AND e.ParentExecutionID <> -1
GROUP BY e.ExecutionID
	,e.ParentExecutionID
	,e.ServerExecutionID
	,e.ParentSourceGUID
	,e.ExecutionGUID
	,e.SourceGUID 
	,e.PackageID
	,p.PackageName
	,e.ExecutionStatus
	,e.NextLoadStatus
	,e.StartTime
	,e.EndTime

RETURN 0
END