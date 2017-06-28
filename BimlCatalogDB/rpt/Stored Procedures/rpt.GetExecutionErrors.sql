CREATE PROCEDURE [ssis].[GetExecutionErrors]
	-- Add the parameters for the stored procedure here
	@ExecutionID VARCHAR(25)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT ee.[ExecutionErrorID]
			,ee.[PackageID]
			,p.[PackageName]
			,ee.[ExecutionID]
			,ee.[ErrorCode]
			,ee.[ErrorDescription] 
	FROM [ssis].[ExecutionError] ee
	INNER JOIN [ssis].[Package] p 
		ON ee.[PackageID] = p.[PackageID]
	WHERE	ee.[ExecutionID] = @ExecutionID

END