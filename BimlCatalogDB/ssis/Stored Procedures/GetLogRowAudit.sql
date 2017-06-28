CREATE PROCEDURE [dbo].[GetLogRowAudit]
	-- Add the parameters for the stored procedure here
	@ExecutionID VARCHAR(25)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

SELECT CONVERT(DATE, e.start_time) AS [AuditRowDate], 
       bar.[AuditRowID], 
       bse.[ServerExecutionID], 
       bar.[ExecutionID], 
       bar.[ComponentName], 
       --bse.[PackageName], 
       bar.[ObjectName], 
       bar.[AuditType], 
       bar.[RowCount], 
       bar.[DistinctRowCount] 
FROM   [SSISDB].[catalog].[executions] e 
       JOIN [BimlCatalog].[ssis].[Execution] bse 
         ON bse.[ServerExecutionID] = e.[execution_id] 
       JOIN [BimlCatalog].[ssis].[AuditRow] bar 
         ON bse.[ExecutionID] = bar.[ExecutionID] 
WHERE  bar.[ExecutionID] = @ExecutionID 
END
