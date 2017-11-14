CREATE PROCEDURE [ssis].[ArchiveAll]
AS
BEGIN

	EXEC [ssis].[ArchiveRowAudit]
	EXEC [ssis].[ArchiveRowCount]
	EXEC [ssis].[ArchiveTaskExecution]
	EXEC [ssis].[ArchiveAuditLog]
	EXEC [ssis].[ArchiveConfigVariable]

	RETURN 0

END
