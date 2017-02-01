CREATE PROCEDURE [ssis].[ArchiveAll]
AS
BEGIN

	EXEC [ssis].[ArchiveRowAudit]
	EXEC [ssis].[ArchiveTaskExecution]

	RETURN 0

END
